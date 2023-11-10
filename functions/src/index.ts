import * as functions from "firebase-functions";
import {format} from "date-fns";
import {utcToZonedTime} from "date-fns-tz";
import * as admin from "firebase-admin";

admin.initializeApp();
const manSinglesRankRef = admin.firestore().collection("manSinglesRank");
const matchResultRef = admin.firestore().collection("matchResult");
const profileDetailRef = admin.firestore().collection("myProfileDetail");

/** 定期的にメタ情報を更新する関数。 */
exports.updateMetaFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 0-23/1 * * *")
    .timeZone("Asia/Tokyo")
    .onRun(async () => {
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
    .pubsub.schedule("0 0 1 * *")
    .timeZone("Asia/Tokyo")
    .onRun(async () => {
      console.log("失効TSPポイント再計算");
      try {
        await getTspRevocation();
      } catch (e) {
        console.log("失効TSPポイント再計算に失敗しました ----$e");
      }
      return null;
    });

exports.updateTitleFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 0 * * *")
    .timeZone("Asia/Tokyo")
    .onRun(async () => {
      console.log("取得称号状況更新");
      try {
        await checkTitleState();
      } catch (e) {
        console.log(e + "取得称号状況更新に失敗しました ----$e");
      }
      return null;
    });

/** ランキングテーブルから情報を取得する */
async function getRankTable(): Promise<void> {
  const matchResultSnapshot = await matchResultRef.get();
  const shokyuRanks: RankList[] = [];
  const chukyuRanks: RankList[] = [];
  const jyokyuRanks: RankList[] = [];

  for (const doc of matchResultSnapshot.docs) {
    const torokuRank: string = doc.data()["TOROKU_RANK"];
    if (torokuRank == "初級" ) {
      await shokyuRanks.push({
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
      await chukyuRanks.push({
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
      await jyokyuRanks.push({
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
  }
  /** 初級ランキングテーブルを作成 */
  await shokyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  let shokyuRankNo = 0;
  for (let index = 0; index < shokyuRanks.length; index++) {
    if (index != 0) {
      if (shokyuRanks[index].TS_POINT ==
        shokyuRanks[index - 1].TS_POINT) {
        try {
          await manSinglesRankRef
              .doc("ShokyuRank")
              .collection("RankList")
              .doc(shokyuRanks[index].USER_ID)
              .set({
                RANK_NO: shokyuRankNo,
                USER_ID: shokyuRanks[index].USER_ID,
                TS_POINT: shokyuRanks[index].TS_POINT,
              });
          await profileDetailRef
              .doc(shokyuRanks[index].USER_ID)
              .update({
                RANK_NO: shokyuRankNo,
              });
          console.log("初級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      } else {
        shokyuRankNo = index + 1;
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
          await profileDetailRef
              .doc(shokyuRanks[index].USER_ID)
              .update({
                RANK_NO: index + 1,
              });
          console.log("初級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      }
    } else {
      shokyuRankNo = index + 1;
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
        await profileDetailRef
            .doc(shokyuRanks[index].USER_ID)
            .update({
              RANK_NO: index + 1,
            });
        console.log("初級追加");
      } catch (e) {
        console.log("ランキング作成に失敗しました --- $e");
      }
    }
  }
  /** 中級ランキングテーブルを作成 */
  await chukyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  let chukyuRankNo = 0;
  for (let index = 0; index < chukyuRanks.length; index++) {
    if (index != 0) {
      if (chukyuRanks[index].TS_POINT ==
        chukyuRanks[index - 1].TS_POINT) {
        try {
          await manSinglesRankRef
              .doc("ChukyuRank")
              .collection("RankList")
              .doc(chukyuRanks[index].USER_ID)
              .set({
                RANK_NO: chukyuRankNo,
                USER_ID: chukyuRanks[index].USER_ID,
                TS_POINT: chukyuRanks[index].TS_POINT,
              });
          await profileDetailRef
              .doc(chukyuRanks[index].USER_ID)
              .update({
                RANK_NO: chukyuRankNo,
              });
          console.log("中級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      } else {
        chukyuRankNo = index + 1;
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
          await profileDetailRef
              .doc(chukyuRanks[index].USER_ID)
              .update({
                RANK_NO: index + 1,
              });
          console.log("中級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      }
    } else {
      chukyuRankNo = index + 1;
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
        await profileDetailRef
            .doc(chukyuRanks[index].USER_ID)
            .update({
              RANK_NO: index + 1,
            });
        console.log("中級追加");
      } catch (e) {
        console.log("ランキング作成に失敗しました --- $e");
      }
    }
  }
  /** 上級ランキングテーブルを作成 */
  await jyokyuRanks.sort((a, b) => b.TS_POINT - a.TS_POINT );
  let jokyuRankNo = 0;
  for (let index = 0; index < jyokyuRanks.length; index++) {
    if (index != 0) {
      if (jyokyuRanks[index].TS_POINT ==
        jyokyuRanks[index - 1].TS_POINT) {
        try {
          await manSinglesRankRef
              .doc("JyokyuRank")
              .collection("RankList")
              .doc(jyokyuRanks[index].USER_ID)
              .set({
                RANK_NO: jokyuRankNo,
                USER_ID: jyokyuRanks[index].USER_ID,
                TS_POINT: jyokyuRanks[index].TS_POINT,
              });
          await profileDetailRef
              .doc(jyokyuRanks[index].USER_ID)
              .update({
                RANK_NO: jokyuRankNo,
              });
          console.log("上級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      } else {
        jokyuRankNo = index + 1;
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
          await profileDetailRef
              .doc(jyokyuRanks[index].USER_ID)
              .update({
                RANK_NO: index + 1,
              });
          console.log("上級追加");
        } catch (e) {
          console.log("ランキング作成に失敗しました --- $e");
        }
      }
    } else {
      jokyuRankNo = index + 1;
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
        await profileDetailRef
            .doc(jyokyuRanks[index].USER_ID)
            .update({
              RANK_NO: index + 1,
            });
        console.log("上級追加");
      } catch (e) {
        console.log("ランキング作成に失敗しました --- $e");
      }
    }
  }
}

type RankList = {
  USER_ID: string,
  TS_POINT: number,
}

/** TSPポイント減算処理 */
async function getTspRevocation(): Promise<void> {
  const shoriYmd: Date = utcToZonedTime(new Date(), "Asia/Tokyo");
  console.log(shoriYmd);
  const sakunenShoriYmdWk1 = new Date(
      shoriYmd.getFullYear() - 1,
      shoriYmd.getMonth(),
      shoriYmd.getDate(),
      shoriYmd.getHours(),
      shoriYmd.getMinutes(),
      shoriYmd.getSeconds(),
      shoriYmd.getMilliseconds()
  );
  console.log(sakunenShoriYmdWk1);
  const sakunenShoriYmWk = format(sakunenShoriYmdWk1, "yyyy-MM-dd");
  console.log(sakunenShoriYmWk);
  const sakunenShoriYmWk2 =
    sakunenShoriYmWk.substring(0, 4) + sakunenShoriYmWk.substring(5, 7);
  console.log(sakunenShoriYmWk2);
  const sakunenShoriYm = parseInt(sakunenShoriYmWk2);
  console.log(sakunenShoriYm);

  const querySnapshot1 = await matchResultRef.get();
  for (const doc1 of querySnapshot1.docs) {
    const torokuRank = doc1.data()["TOROKU_RANK"];
    const shokyuTspPointCur = doc1.data()["SHOKYU_TS_POINT"];
    const chukyuTspPointCur = doc1.data()["CHUKYU_TS_POINT"];
    const jyokyuTspPointCur = doc1.data()["JYOKYU_TS_POINT"];
    let shokyuTspPoint = 0;
    let chukyuTspPoint = 0;
    let jyokyuTspPoint = 0;

    const querySnapshot2 = await matchResultRef
        .doc(doc1.id)
        .collection("opponentList")
        .get();
    for (const doc2 of querySnapshot2.docs) {
      const querySnapshot3 = await matchResultRef
          .doc(doc1.id)
          .collection("opponentList")
          .doc(doc2.id)
          .collection("daily")
          .get();
      for (const doc3 of querySnapshot3.docs) {
        const querySnapshot4 = await matchResultRef
            .doc(doc1.id)
            .collection("opponentList")
            .doc(doc2.id)
            .collection("daily")
            .doc(doc3.id)
            .collection("matchDetail")
            .get();
        for (const doc4 of querySnapshot4.docs) {
          const koushinTimeGet: string = doc4.data()["KOUSHIN_TIME"];
          const koushinTimeWk =
            koushinTimeGet.substring(0, 4) + koushinTimeGet.substring(5, 7);
          const koushinTime = parseInt(koushinTimeWk);
          console.log("koushinTime" + koushinTime);
          console.log("koushinTimeGet" + koushinTimeGet);
          const tspValidFlg = doc4.data()["TSP_VALID_FLG"];
          if (koushinTime <= sakunenShoriYm && tspValidFlg == "1") {
            console.log("TSP_VALID_FLG" + tspValidFlg);
            const individualMatchResultSna = admin.firestore()
                .collection("matchResult")
                .doc(doc1.id)
                .collection("opponentList")
                .doc(doc2.id)
                .collection("daily")
                .doc(doc3.id)
                .collection("matchDetail")
                .doc(doc4.id);
            const tspPoint: number = doc4.data()["TS_POINT"];
            const myTorokuRank: string = doc4.data()["MY_TOROKU_RANK"];
            switch (myTorokuRank) {
              case "初級":
                shokyuTspPoint = shokyuTspPoint + tspPoint;
                console.log("shokyuTspPoint" + shokyuTspPoint);
                break;
              case "中級":
                chukyuTspPoint = chukyuTspPoint + tspPoint;
                console.log("chukyuTspPoint" + chukyuTspPoint);
                break;
              case "上級":
                jyokyuTspPoint = jyokyuTspPoint + tspPoint;
                console.log("jyokyuTspPoint" + jyokyuTspPoint);
                break;
            }
            await individualMatchResultSna.update({"TSP_VALID_FLG": "0"});
            console.log("更新処理を行う");
          }
        }
      }
      const shokyuTspPointNew = shokyuTspPointCur - shokyuTspPoint;
      const chukyuTspPointNew = chukyuTspPointCur - chukyuTspPoint;
      const jyokyuTspPointNew = jyokyuTspPointCur - jyokyuTspPoint;
      const myMatchResult = await admin.firestore()
          .collection("matchResult")
          .doc(doc1.id);
      console.log("shokyuTspPointNew" + shokyuTspPointNew);
      console.log("chukyuTspPointCur" + chukyuTspPointCur);
      console.log("chukyuTspPointNew" + chukyuTspPointNew);
      console.log("jyokyuTspPointNew" + jyokyuTspPointNew);
      switch (torokuRank) {
        case "初級":
          await myMatchResult.update({
            "SHOKYU_TS_POINT": shokyuTspPointNew,
            "CHUKYU_TS_POINT": chukyuTspPointNew,
            "JYOKYU_TS_POINT": jyokyuTspPointNew,
            "TS_POINT": shokyuTspPointNew,
          });
          break;
        case "中級":
          await myMatchResult.update({
            "SHOKYU_TS_POINT": shokyuTspPointNew,
            "CHUKYU_TS_POINT": chukyuTspPointNew,
            "JYOKYU_TS_POINT": jyokyuTspPointNew,
            "TS_POINT": chukyuTspPointNew,
          });
          break;
        case "上級":
          await myMatchResult.update({
            "SHOKYU_TS_POINT": shokyuTspPointNew,
            "CHUKYU_TS_POINT": chukyuTspPointNew,
            "JYOKYU_TS_POINT": jyokyuTspPointNew,
            "TS_POINT": jyokyuTspPointNew,
          });
          break;
      }
    }
  }
}
/** 称号の取得状況確認 */
async function checkTitleState(): Promise<void> {
  console.log("称号更新start");
  // DB更新用Map
  const myObjectData: Map<string, string> = new Map<string, string>();
  const profileDetailSnapshot = await profileDetailRef.get();
  for (const docs of profileDetailSnapshot.docs) {
    console.log("通過点１");
    const titleData: Map<string, string> = objectToMap(docs.data()?.TITLE);
    const feedbackCount: number = Number(docs.data()["FEEDBACK_COUNT"]);
    const strokeForeAve: number = Number(docs.data()["STROKE_FOREHAND_AVE"]);
    console.log(typeof titleData);
    // 更新確認(No1の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal1: string = "0";
    if (titleData.get("1") !== undefined) {
      console.log("No1存在します");
      mapVal1 = titleData.get("1") as string;
      console.log(mapVal1);
    } else {
      console.log("No1存在しません");
    }
    if (mapVal1 == "0") {
      console.log("No1が0");
      console.log(feedbackCount);
      // myObjectDataの1キーを更新
      if (feedbackCount >= 10 && strokeForeAve >= 1.0) {
        console.log("No1条件達成！");
        myObjectData.set("1", "1");
      } else {
        myObjectData.set("1", "0");
      }
    } else {
      myObjectData.set("1", mapVal1);
    }
    // No1の確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No2の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal2: string = "0";
    if (titleData.get("2") !== undefined) {
      console.log("No2存在します");
      mapVal2 = titleData.get("2") as string;
      console.log(mapVal2);
    } else {
      console.log("No2存在しません");
    }
    // myObjectDataの2キーを更新
    if (mapVal2 == "0") {
      console.log("No2が0");
      if (feedbackCount >= 15 && strokeForeAve >= 2.0) {
        console.log("No2条件達成！");
        myObjectData.set("2", "1");
      } else {
        myObjectData.set("2", "0");
      }
    } else {
      myObjectData.set("2", mapVal2);
    }
    // No2確認終了＝＝＝＝＝＝＝＝＝＝
    // Map3以降
    myObjectData.set("3", "0");
    myObjectData.set("4", "0");
    myObjectData.set("5", "0");
    myObjectData.set("6", "0");
    myObjectData.set("7", "0");
    myObjectData.set("8", "0");
    myObjectData.set("9", "0");
    myObjectData.set("10", "0");
    // 結果をマップに詰める
    const updateMap = {
      "1": myObjectData.get("1"),
      "2": myObjectData.get("2"),
      "3": myObjectData.get("3"),
      "4": myObjectData.get("4"),
      "5": myObjectData.get("5"),
      "6": myObjectData.get("6"),
      "7": myObjectData.get("7"),
      "8": myObjectData.get("8"),
      "9": myObjectData.get("9"),
      "10": myObjectData.get("10"),
    };
    await profileDetailRef.doc(docs.id).update({"TITLE": updateMap});
    console.log("称号更新を行う");
  }
}
/**
 * Object
 * @param {object} obj - The first number.
 * @return {Map<string, string>} The Map.
 */
function objectToMap(obj: { [key: string]: string }): Map<string, string> {
  return new Map(Object.entries(obj));
}

