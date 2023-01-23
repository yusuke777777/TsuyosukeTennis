import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import {format} from "date-fns";
import {utcToZonedTime} from "date-fns-tz";

admin.initializeApp();
const manSinglesRankRef = admin.firestore().collection("manSinglesRank");
const matchResultRef = admin.firestore().collection("matchResult");

/** 定期的にメタ情報を更新する関数。 */
exports.updateMetaFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 */1 * * *")
    .timeZone("Asia/Tokyo")
    .onRun(async (context) => {
      console.log("ランキング作成開始");
      await getRankTable();
      return null;
    });

exports.tspRevocationFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 0 1 * *")
    .timeZone("Asia/Tokyo")
    .onRun(async (context) => {
      console.log("失効TSPポイント再計算");
      await getTspRevocation();
      return null;
    });

/** ランキングテーブルから情報を取得する */
async function getRankTable(): Promise<void> {
  const matchResultSnapshot = await matchResultRef.get();
  const shokyuRanks: RankList[] = [];
  const chukyuRanks: RankList[] = [];
  const jyokyuRanks: RankList[] = [];

  await matchResultSnapshot.docs.forEach( async (doc) => {
    const torokuRank: string = doc.data()["TOROKU_RANK"];
    if (torokuRank == "初級" ) {
      shokyuRanks.push({
        USER_ID: doc.id,
        TS_POINT: doc.data()["TS_POINT"],
      });
      await manSinglesRankRef
          .doc("ChukyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
      await manSinglesRankRef
          .doc("JyokyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
    } else if (torokuRank == "中級" ) {
      chukyuRanks.push({
        USER_ID: doc.id,
        TS_POINT: doc.data()["TS_POINT"],
      });
      await manSinglesRankRef
          .doc("ShokyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
      await manSinglesRankRef
          .doc("JyokyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
    } else {
      jyokyuRanks.push({
        USER_ID: doc.id,
        TS_POINT: doc.data()["TS_POINT"],
      });
      await manSinglesRankRef
          .doc("ShokyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
      await manSinglesRankRef
          .doc("ChukyuRank")
          .collection("RankList")
          .doc(doc.id)
          .delete();
    }
  });
  /** 初級ランキングテーブルを作成 */
  await shokyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  for (let index = 0; index < shokyuRanks.length; index++) {
    try {
      await manSinglesRankRef
          .doc("ShokyuRank")
          .collection("RankList")
          .doc(shokyuRanks[index].USER_ID)
          .set({
            RANK_NO: index + 1,
            USER_ID: shokyuRanks[index].USER_ID,
            TS_POINT: shokyuRanks[index].TS_POINT,
          });
    } catch (e) {
      console.log("ランキング作成に失敗しました --- $e");
    }
  }
  /** 中級ランキングテーブルを作成 */
  await chukyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  for (let index = 0; index < chukyuRanks.length; index++) {
    try {
      await manSinglesRankRef
          .doc("ChukyuRank")
          .collection("RankList")
          .doc(chukyuRanks[index].USER_ID)
          .set({
            RANK_NO: index + 1,
            USER_ID: chukyuRanks[index].USER_ID,
            TS_POINT: chukyuRanks[index].TS_POINT,
          });
    } catch (e) {
      console.log("ランキング作成に失敗しました --- $e");
    }
  }
  /** 上級ランキングテーブルを作成 */
  await jyokyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  for (let index = 0; index < jyokyuRanks.length; index++) {
    try {
      await manSinglesRankRef
          .doc("JyokyuRank")
          .collection("RankList")
          .doc(jyokyuRanks[index].USER_ID)
          .set({
            RANK_NO: index + 1,
            USER_ID: jyokyuRanks[index].USER_ID,
            TS_POINT: jyokyuRanks[index].TS_POINT,
          });
    } catch (e) {
      console.log("ランキング作成に失敗しました --- $e");
    }
  }
}
type RankList = {
  USER_ID: string,
  TS_POINT: number,
}

/** 失効するTSPポイントの取得を行う */
async function getTspRevocation(): Promise<void> {
  const matchResultSnapshot = await matchResultRef.get();
  const shoriYmd:Date = utcToZonedTime(new Date(), "Asia/Tokyo");
  console.log(shoriYmd);
  const sakunenShoriYmdWk1 = new Date(shoriYmd.getFullYear() - 1,
      shoriYmd.getMonth(), shoriYmd.getDate(), shoriYmd.getHours(),
      shoriYmd.getMinutes(), shoriYmd.getSeconds(), shoriYmd.getMilliseconds());
  console.log(sakunenShoriYmdWk1);
  const sakunenShoriYmWk = format(sakunenShoriYmdWk1, "yyyy-MM-dd");
  console.log(sakunenShoriYmWk);
  const constsakunenShoriYmWk2 = sakunenShoriYmWk.substring(0, 4) +
    sakunenShoriYmWk.substring(5, 7);
  console.log(constsakunenShoriYmWk2);
  const sakunenShoriYm = parseInt(constsakunenShoriYmWk2);
  console.log(sakunenShoriYm);

  await matchResultSnapshot.docs.forEach( async (doc1) => {
    const matchResultOppSna = await admin.firestore()
        .collection("matchResult")
        .doc(doc1.id)
        .collection("opponentList").get();
    await matchResultOppSna.docs.forEach( async (doc2) => {
      const matchResultDetail = await admin.firestore()
          .collection("matchResult")
          .doc(doc1.id)
          .collection("opponentList")
          .doc(doc2.id)
          .collection("matchDetail").get();
      await matchResultDetail.docs.forEach( async (doc3) => {
        const koushinTimeGet: string = doc3.data()["KOUSHIN_TIME"];
        const koushinTimeWk = koushinTimeGet.substring(0, 4) +
          koushinTimeGet.substring(5, 7);
        const koushinTime = parseInt(koushinTimeWk);
        console.log(koushinTime);
        if (koushinTime <= sakunenShoriYm) {
          const individualMatchResultSna = await admin.firestore()
              .collection("matchResult")
              .doc(doc1.id)
              .collection("opponentList")
              .doc(doc2.id)
              .collection("matchDetail")
              .doc(doc3.id);
          await individualMatchResultSna.update({"TSP_VALID_FLG": "0"});
          console.log("更新処理を行う");
        }
      }
      );
    }
    );
  }
  );
}

