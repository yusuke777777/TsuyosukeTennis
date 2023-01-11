import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const manSinglesRankRef = admin.firestore().collection("manSinglesRank");
const matchResultRef = admin.firestore().collection("matchResult");

/** 定期的にメタ情報を更新する関数。 */
exports.updateMetaFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("every 1 hours")
    .onRun(async (context) => {
      console.log("ランキング作成開始");
      await getRankTable();
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
