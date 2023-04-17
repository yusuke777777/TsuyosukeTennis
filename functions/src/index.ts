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
    .pubsub.schedule("* */1 * * *")
    .timeZone("Asia/Tokyo")
    .onRun(async (context) => {
      console.log("ランキング作成開始");
      try {
        await getRankTable();
      } catch (e) {
        console.log("ランキングの更新に失敗しました ----$e");
      }
      return null;
    });

exports.tspRevocationFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("*/1 * * * *")
    .timeZone("Asia/Tokyo")
    .onRun(async (context) => {
      console.log("失効TSPポイント再計算");
      try {
        await getTspRevocation();
      } catch (e) {
        console.log("失効TSPポイント再計算に失敗しました ----$e");
      }
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

/** TSPポイント減算処理 */
async function getTspRevocation(): Promise<void> {
  const shoriYmd:Date = utcToZonedTime(new Date(), "Asia/Tokyo");
  console.log(shoriYmd);
  const sakunenShoriYmdWk1 = new Date(shoriYmd.getFullYear() - 1,
      shoriYmd.getMonth(), shoriYmd.getDate(), shoriYmd.getHours(),
      shoriYmd.getMinutes(), shoriYmd.getSeconds(), shoriYmd.getMilliseconds());
  console.log(sakunenShoriYmdWk1);
  const sakunenShoriYmWk = format(sakunenShoriYmdWk1, "yyyy-MM-dd");
  console.log(sakunenShoriYmWk);
  const sakunenShoriYmWk2 = sakunenShoriYmWk.substring(0, 4) +
    sakunenShoriYmWk.substring(5, 7);
  console.log(sakunenShoriYmWk2);
  const sakunenShoriYm = parseInt(sakunenShoriYmWk2);
  console.log(sakunenShoriYm);

  matchResultRef.get().then(function(querySnapshot1) {
    querySnapshot1.forEach(function(doc1) {
      matchResultRef.doc(doc1.id)
          .collection("opponentList")
          .get().then(function(querySnapshot2) {
            querySnapshot2.forEach(function(doc2) {
              matchResultRef.doc(doc1.id)
                  .collection("opponentList")
                  .doc(doc2.id)
                  .collection("daily")
                  .get().then(function(querySnapshot3) {
                    querySnapshot3.forEach(function(doc3) {
                      matchResultRef.doc(doc1.id)
                          .collection("opponentList")
                          .doc(doc2.id)
                          .collection("daily")
                          .doc(doc3.id)
                          .collection("matchDetail")
                          .get().then(function(querySnapshot4) {
                            querySnapshot4.forEach(function(doc4) {
                              const koushinTimeGet: string =
                                doc4.data()["KOUSHIN_TIME"];
                              const koushinTimeWk =
                                koushinTimeGet.substring(0, 4) +
                                koushinTimeGet.substring(5, 7);
                              const koushinTime = parseInt(koushinTimeWk);
                              console.log("koushinTime" + koushinTime);
                              console.log("koushinTimeGet" + koushinTimeGet);
                              const tspValidFlg = doc4.data()["TSP_VALID_FLG"];
                              if (koushinTime <= sakunenShoriYm &&
                                tspValidFlg == "1") {
                                console.log("TSP_VALID_FLG" + tspValidFlg);
                                let shokyuTspPoint = 0;
                                let chukyuTspPoint = 0;
                                let jyokyuTspPoint = 0;
                                const individualMatchResultSna =
                                  admin.firestore()
                                      .collection("matchResult")
                                      .doc(doc1.id)
                                      .collection("opponentList")
                                      .doc(doc2.id)
                                      .collection("daily")
                                      .doc(doc3.id)
                                      .collection("matchDetail")
                                      .doc(doc4.id);
                                const tspPoint: number =
                                  doc4.data()["TS_POINT"];
                                const myTorokuRank: string =
                                  doc4.data()["MY_TOROKU_RANK"];
                                switch (myTorokuRank) {
                                  case "初級":
                                    shokyuTspPoint = shokyuTspPoint + tspPoint;
                                    console.log("shokyuTspPoint" +
                                      shokyuTspPoint);
                                    break;
                                  case "中級":
                                    chukyuTspPoint =
                                      chukyuTspPoint + tspPoint;
                                    console.log("chukyuTspPoint" +
                                      chukyuTspPoint);
                                    break;
                                  case "上級":
                                    jyokyuTspPoint =
                                      jyokyuTspPoint + tspPoint;
                                    console.log("jyokyuTspPoint" +
                                      jyokyuTspPoint);
                                    break;
                                }
                                individualMatchResultSna
                                    .update({"TSP_VALID_FLG": "0"});
                                console.log("更新処理を行う");
                                const torokuRank =
                                  doc1.data()["TOROKU_RANK"];
                                const shokyuTspPointCur =
                                  doc1.data()["SHOKYU_TS_POINT"];
                                const chukyuTspPointCur =
                                  doc1.data()["CHUKYU_TS_POINT"];
                                const jyokyuTspPointCur =
                                  doc1.data()["JYOKYU_TS_POINT"];
                                const shokyuTspPointNew =
                                  shokyuTspPointCur - shokyuTspPoint;
                                const chukyuTspPointNew =
                                  chukyuTspPointCur - chukyuTspPoint;
                                const jyokyuTspPointNew =
                                  jyokyuTspPointCur - jyokyuTspPoint;
                                const myMatchResult = admin.firestore()
                                    .collection("matchResult").doc(doc1.id);
                                console.log("shokyuTspPointNew" +
                                  shokyuTspPointNew);
                                console.log("chukyuTspPointNew" +
                                  chukyuTspPointNew);
                                console.log("jyokyuTspPointNew" +
                                  jyokyuTspPointNew);
                                switch (torokuRank) {
                                  case "初級":
                                    myMatchResult.update({"SHOKYU_TS_POINT":
                                    shokyuTspPointNew,
                                    "CHUKYU_TS_POINT": chukyuTspPointNew,
                                    "JYOKYU_TS_POINT": jyokyuTspPointNew,
                                    "TS_POINT": shokyuTspPointNew});
                                    break;
                                  case "中級":
                                    myMatchResult.update({
                                      "SHOKYU_TS_POINT": shokyuTspPointNew,
                                      "CHUKYU_TS_POINT": chukyuTspPointNew,
                                      "JYOKYU_TS_POINT": jyokyuTspPointNew,
                                      "TS_POINT": chukyuTspPointNew});
                                    break;
                                  case "上級":
                                    myMatchResult.update({
                                      "SHOKYU_TS_POINT": shokyuTspPointNew,
                                      "CHUKYU_TS_POINT": chukyuTspPointNew,
                                      "JYOKYU_TS_POINT": jyokyuTspPointNew,
                                      "TS_POINT": jyokyuTspPointNew});
                                    break;
                                }
                              }
                            }
                            );
                          }
                          );
                    }
                    );
                  }
                  );
            }
            );
          }
          );
    }
    );
  }
  );
}
