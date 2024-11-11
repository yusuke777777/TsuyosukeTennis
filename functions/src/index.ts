import * as functions from "firebase-functions";
import {format} from "date-fns";
import {utcToZonedTime} from "date-fns-tz";
import * as admin from "firebase-admin";

admin.initializeApp();
const manSinglesRankRef = admin.firestore().collection("manSinglesRank");
const matchResultRef = admin.firestore().collection("matchResult");
const profileDetailRef = admin.firestore().collection("myProfileDetail");
const profileRef = admin.firestore().collection("myProfile");
const userTicketMgmtRef = admin.firestore().collection("userTicketMgmt");
const talkRoomRef = admin.firestore().collection("talkRoom");


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

exports.addTicketFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 0 1 * *")
    .timeZone("Asia/Tokyo")
    .onRun(async () => {
      console.log("チケットの付与");
      try {
        await addTicket();
      } catch (e) {
        console.log("チケットの付与に失敗しました ----$e");
      }
      return null;
    });


export const deleteOldMessages = functions
    .region("asia-northeast1")
    .pubsub.schedule("0 0 * * *")
    .timeZone("Asia/Tokyo") // タイムゾーンを日本に設定
    .onRun(async (context) => {
      const now = admin.firestore.Timestamp.now();
      const oneYearAgo =
        new admin.firestore.Timestamp(now.seconds -
          (366 * 24 * 60 * 60), now.nanoseconds);

      try {
        const roomsSnapshot = await talkRoomRef.get();

        for (const roomDoc of roomsSnapshot.docs) {
          const messagesRef =
            talkRoomRef.doc(roomDoc.id).collection("message");
          const oldMessagesSnapshot =
            await messagesRef.where("send_time", "<", oneYearAgo).get();

          const batch = admin.firestore().batch();

          for (const oldMessageDoc of oldMessagesSnapshot.docs) {
            batch.delete(oldMessageDoc.ref);
          }
          await batch.commit();
          console.log(`Deleted ${oldMessagesSnapshot.size}
            messages from room ${roomDoc.id}`);
        }
      } catch (error) {
        console.error("Error deleting old messages: ", error);
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
              .set({
                RANK_NO: shokyuRankNo,
                RANK_TOROKU_RANK: "初級",
              }, {merge: true});
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
              .set({
                RANK_NO: index + 1,
                RANK_TOROKU_RANK: "初級",
              }, {merge: true});
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
            .set({
              RANK_NO: index + 1,
              RANK_TOROKU_RANK: "初級",
            }, {merge: true});
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
              .set({
                RANK_NO: chukyuRankNo,
                RANK_TOROKU_RANK: "中級",
              }, {merge: true});
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
              .set({
                RANK_NO: index + 1,
                RANK_TOROKU_RANK: "中級",
              }, {merge: true});
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
            .set({
              RANK_NO: index + 1,
              RANK_TOROKU_RANK: "中級",
            }, {merge: true});
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
              .set({
                RANK_NO: jokyuRankNo,
                RANK_TOROKU_RANK: "上級",
              }, {merge: true});
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
              .set({
                RANK_NO: index + 1,
                RANK_TOROKU_RANK: "上級",
              }, {merge: true});
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
            .set({
              RANK_NO: index + 1,
              RANK_TOROKU_RANK: "上級",
            }, {merge: true});
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
    const feedbackCount = Number(docs.data()["FEEDBACK_COUNT"]);
    const strokeForeAve = Number(docs.data()["STROKE_FOREHAND_AVE"]);
    const strokeBackAve = Number(docs.data()["STROKE_BACKHAND_AVE"]);
    const volleyForeAve = Number(docs.data()["VOLLEY_FOREHAND_AVE"]);
    const volleyBackAve = Number(docs.data()["VOLLEY_BACKHAND_AVE"]);
    const serve1stAve = Number(docs.data()["SERVE_1ST_AVE"]);
    console.log(typeof titleData);
    // 更新確認(No1の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal1 = "0";
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
    let mapVal2 = "0";
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
    // 更新確認(No3の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal3 = "0";
    if (titleData.get("3") !== undefined) {
      console.log("No3存在します");
      mapVal3 = titleData.get("3") as string;
      console.log(mapVal3);
    } else {
      console.log("No3存在しません");
    }
    // myObjectDataの3キーを更新
    if (mapVal3 == "0") {
      console.log("No3が0");
      if (feedbackCount >= 20 && strokeForeAve >= 3.0) {
        console.log("No3条件達成！");
        myObjectData.set("3", "1");
      } else {
        myObjectData.set("3", "0");
      }
    } else {
      myObjectData.set("3", mapVal3);
    }
    // No3確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No4の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal4 = "0";
    if (titleData.get("4") !== undefined) {
      console.log("No4存在します");
      mapVal4 = titleData.get("4") as string;
      console.log(mapVal4);
    } else {
      console.log("No4存在しません");
    }
    // myObjectDataの4キーを更新
    if (mapVal4 == "0") {
      console.log("No4が0");
      if (feedbackCount >= 30 && strokeForeAve >= 4.0) {
        console.log("No4条件達成！");
        myObjectData.set("4", "1");
      } else {
        myObjectData.set("4", "0");
      }
    } else {
      myObjectData.set("4", mapVal4);
    }
    // No4確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No5の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal5 = "0";
    if (titleData.get("5") !== undefined) {
      console.log("No5存在します");
      mapVal5 = titleData.get("5") as string;
      console.log(mapVal5);
    } else {
      console.log("No5存在しません");
    }
    // myObjectDataの5キーを更新
    if (mapVal5 == "0") {
      console.log("No5が0");
      if (feedbackCount >= 50 && strokeForeAve >= 4.1) {
        console.log("No5条件達成！");
        myObjectData.set("5", "1");
      } else {
        myObjectData.set("5", "0");
      }
    } else {
      myObjectData.set("5", mapVal5);
    }
    // No5確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No6の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal6 = "0";
    if (titleData.get("6") !== undefined) {
      console.log("No6存在します");
      mapVal6 = titleData.get("6") as string;
      console.log(mapVal6);
    } else {
      console.log("No6存在しません");
    }
    // myObjectDataの6キーを更新
    if (mapVal6 == "0") {
      console.log("No6が0");
      if (feedbackCount >= 10 && strokeBackAve >= 1.0) {
        console.log("No6条件達成！");
        myObjectData.set("6", "1");
      } else {
        myObjectData.set("6", "0");
      }
    } else {
      myObjectData.set("6", mapVal6);
    }
    // No6確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No7の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal7 = "0";
    if (titleData.get("7") !== undefined) {
      console.log("No7存在します");
      mapVal7 = titleData.get("7") as string;
      console.log(mapVal7);
    } else {
      console.log("No7存在しません");
    }
    // myObjectDataの7キーを更新
    if (mapVal7 == "0") {
      console.log("No7が0");
      if (feedbackCount >= 15 && strokeBackAve >= 2.0) {
        console.log("No7条件達成！");
        myObjectData.set("7", "1");
      } else {
        myObjectData.set("7", "0");
      }
    } else {
      myObjectData.set("7", mapVal6);
    }
    // No7確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No8の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal8 = "0";
    if (titleData.get("8") !== undefined) {
      console.log("No8存在します");
      mapVal8 = titleData.get("8") as string;
      console.log(mapVal8);
    } else {
      console.log("No8存在しません");
    }
    // myObjectDataの8キーを更新
    if (mapVal8 == "0") {
      console.log("No8が0");
      if (feedbackCount >= 20 && strokeBackAve >= 3.0) {
        console.log("No8条件達成！");
        myObjectData.set("8", "1");
      } else {
        myObjectData.set("8", "0");
      }
    } else {
      myObjectData.set("8", mapVal8);
    }
    // No8確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No9の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal9 = "0";
    if (titleData.get("9") !== undefined) {
      console.log("No9存在します");
      mapVal9 = titleData.get("9") as string;
      console.log(mapVal9);
    } else {
      console.log("No9存在しません");
    }
    // myObjectDataの9キーを更新
    if (mapVal9 == "0") {
      console.log("No9が0");
      if (feedbackCount >= 30 && strokeBackAve >= 4.0) {
        console.log("No9条件達成！");
        myObjectData.set("9", "1");
      } else {
        myObjectData.set("9", "0");
      }
    } else {
      myObjectData.set("9", mapVal9);
    }
    // No9確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No10の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal10 = "0";
    if (titleData.get("10") !== undefined) {
      console.log("No10存在します");
      mapVal10 = titleData.get("10") as string;
      console.log(mapVal10);
    } else {
      console.log("No10存在しません");
    }
    // myObjectDataの10キーを更新
    if (mapVal10 == "0") {
      console.log("No10が0");
      if (feedbackCount >= 50 && strokeBackAve >= 4.1) {
        console.log("No10条件達成！");
        myObjectData.set("10", "1");
      } else {
        myObjectData.set("10", "0");
      }
    } else {
      myObjectData.set("10", mapVal10);
    }
    // No10確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No11の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal11 = "0";
    if (titleData.get("11") !== undefined) {
      console.log("No11存在します");
      mapVal11 = titleData.get("11") as string;
      console.log(mapVal11);
    } else {
      console.log("No11存在しません");
    }
    // myObjectDataの11キーを更新
    if (mapVal11 == "0") {
      console.log("No11が0");
      if (feedbackCount >= 10 && volleyForeAve >= 1.0) {
        console.log("No11条件達成！");
        myObjectData.set("11", "1");
      } else {
        myObjectData.set("11", "0");
      }
    } else {
      myObjectData.set("11", mapVal11);
    }
    // No11確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No12の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal12 = "0";
    if (titleData.get("12") !== undefined) {
      console.log("No12存在します");
      mapVal12 = titleData.get("12") as string;
      console.log(mapVal12);
    } else {
      console.log("No12存在しません");
    }
    // myObjectDataの12キーを更新
    if (mapVal12 == "0") {
      console.log("No12が0");
      if (feedbackCount >= 15 && volleyForeAve >= 2.0) {
        console.log("No12条件達成！");
        myObjectData.set("12", "1");
      } else {
        myObjectData.set("12", "0");
      }
    } else {
      myObjectData.set("12", mapVal12);
    }
    // No12確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No13の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal13 = "0";
    if (titleData.get("13") !== undefined) {
      console.log("No13存在します");
      mapVal13 = titleData.get("13") as string;
      console.log(mapVal13);
    } else {
      console.log("No13存在しません");
    }
    // myObjectDataの13キーを更新
    if (mapVal13 == "0") {
      console.log("No13が0");
      if (feedbackCount >= 30 && volleyForeAve >= 4.0) {
        console.log("No13条件達成！");
        myObjectData.set("13", "1");
      } else {
        myObjectData.set("13", "0");
      }
    } else {
      myObjectData.set("13", mapVal13);
    }
    // No13確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No14の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal14 = "0";
    if (titleData.get("14") !== undefined) {
      console.log("No14存在します");
      mapVal14 = titleData.get("14") as string;
      console.log(mapVal14);
    } else {
      console.log("No14存在しません");
    }
    // myObjectDataの14キーを更新
    if (mapVal14 == "0") {
      console.log("No14が0");
      if (feedbackCount >= 50 && volleyForeAve >= 4.1) {
        console.log("No14条件達成！");
        myObjectData.set("14", "1");
      } else {
        myObjectData.set("14", "0");
      }
    } else {
      myObjectData.set("14", mapVal14);
    }
    // No14確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No15の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal15 = "0";
    if (titleData.get("15") !== undefined) {
      console.log("No15存在します");
      mapVal15 = titleData.get("15") as string;
      console.log(mapVal15);
    } else {
      console.log("No15存在しません");
    }
    // myObjectDataの15キーを更新
    if (mapVal15 == "0") {
      console.log("No15が0");
      if (feedbackCount >= 10 && volleyBackAve >= 1.0) {
        console.log("No15条件達成！");
        myObjectData.set("15", "1");
      } else {
        myObjectData.set("15", "0");
      }
    } else {
      myObjectData.set("15", mapVal15);
    }
    // No15確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No16の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal16 = "0";
    if (titleData.get("16") !== undefined) {
      console.log("No16存在します");
      mapVal16 = titleData.get("16") as string;
      console.log(mapVal16);
    } else {
      console.log("No16存在しません");
    }
    // myObjectDataの16キーを更新
    if (mapVal16 == "0") {
      console.log("No16が0");
      if (feedbackCount >= 15 && volleyBackAve >= 2.0) {
        console.log("No16条件達成！");
        myObjectData.set("16", "1");
      } else {
        myObjectData.set("16", "0");
      }
    } else {
      myObjectData.set("16", mapVal16);
    }
    // No16確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No17の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal17 = "0";
    if (titleData.get("17") !== undefined) {
      console.log("No17存在します");
      mapVal17 = titleData.get("17") as string;
      console.log(mapVal17);
    } else {
      console.log("No17存在しません");
    }
    // myObjectDataの17キーを更新
    if (mapVal17 == "0") {
      console.log("No17が0");
      if (feedbackCount >= 30 && volleyBackAve >= 4.0) {
        console.log("No17条件達成！");
        myObjectData.set("17", "1");
      } else {
        myObjectData.set("17", "0");
      }
    } else {
      myObjectData.set("17", mapVal17);
    }
    // No17確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No18の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal18 = "0";
    if (titleData.get("18") !== undefined) {
      console.log("No18存在します");
      mapVal18 = titleData.get("18") as string;
      console.log(mapVal18);
    } else {
      console.log("No18存在しません");
    }
    // myObjectDataの18キーを更新
    if (mapVal18 == "0") {
      console.log("No18が0");
      if (feedbackCount >= 50 && volleyBackAve >= 4.1) {
        console.log("No18条件達成！");
        myObjectData.set("18", "1");
      } else {
        myObjectData.set("18", "0");
      }
    } else {
      myObjectData.set("18", mapVal18);
    }
    // No18確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No19の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal19 = "0";
    if (titleData.get("19") !== undefined) {
      console.log("No19存在します");
      mapVal19 = titleData.get("19") as string;
      console.log(mapVal19);
    } else {
      console.log("No19存在しません");
    }
    // myObjectDataの19キーを更新
    if (mapVal19 == "0") {
      console.log("No19が0");
      if (feedbackCount >= 10 && serve1stAveAve >= 1.0) {
        console.log("No19条件達成！");
        myObjectData.set("19", "1");
      } else {
        myObjectData.set("19", "0");
      }
    } else {
      myObjectData.set("19", mapVal19);
    }
    // No19確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No20の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal20 = "0";
    if (titleData.get("20") !== undefined) {
      console.log("No20存在します");
      mapVal20 = titleData.get("20") as string;
      console.log(mapVal20);
    } else {
      console.log("No20存在しません");
    }
    // myObjectDataの20キーを更新
    if (mapVal20 == "0") {
      console.log("No20が0");
      if (feedbackCount >= 15 && serve1stAveAve >= 2.0) {
        console.log("No20条件達成！");
        myObjectData.set("20", "1");
      } else {
        myObjectData.set("20", "0");
      }
    } else {
      myObjectData.set("20", mapVal20);
    }
    // No20確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No21の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal21 = "0";
    if (titleData.get("21") !== undefined) {
      console.log("No21存在します");
      mapVal21 = titleData.get("21") as string;
      console.log(mapVal21);
    } else {
      console.log("No21存在しません");
    }
    // myObjectDataの21キーを更新
    if (mapVal21 == "0") {
      console.log("No21が0");
      if (feedbackCount >= 30 && serve1stAveAve >= 4.0) {
        console.log("No21条件達成！");
        myObjectData.set("21", "1");
      } else {
        myObjectData.set("21", "0");
      }
    } else {
      myObjectData.set("21", mapVal21);
    }
    // No21確認終了＝＝＝＝＝＝＝＝＝＝
    // 更新確認(No22の確認)!!!!!!!!!!!!!!!!!!!!!
    let mapVal22 = "0";
    if (titleData.get("22") !== undefined) {
      console.log("No22存在します");
      mapVal22 = titleData.get("22") as string;
      console.log(mapVal22);
    } else {
      console.log("No22存在しません");
    }
    // myObjectDataの22キーを更新
    if (mapVal22 == "0") {
      console.log("No22が0");
      if (feedbackCount >= 50 && serve1stAveAve >= 4.1) {
        console.log("No22条件達成！");
        myObjectData.set("22", "1");
      } else {
        myObjectData.set("22", "0");
      }
    } else {
      myObjectData.set("22", mapVal21);
    }
    // No22確認終了＝＝＝＝＝＝＝＝＝＝

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
      "11": myObjectData.get("11"),
      "12": myObjectData.get("12"),
      "13": myObjectData.get("13"),
      "14": myObjectData.get("14"),
      "15": myObjectData.get("15"),
      "16": myObjectData.get("16"),
      "17": myObjectData.get("17"),
      "18": myObjectData.get("18"),
      "19": myObjectData.get("19"),
      "20": myObjectData.get("20"),
      "21": myObjectData.get("21"),
      "22": myObjectData.get("22"),
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

/** 月次でチケットを付与する */
async function addTicket(): Promise<void> {
  const userTicketMgmtSnapshot = await userTicketMgmtRef.get();
  const shoriYmd: Date = utcToZonedTime(new Date(), "Asia/Tokyo");
  // 日付を "yyyy-MM-dd" 形式の文字列に変換する
  const formattedDate: string = shoriYmd.toISOString().slice(0, 10);
  for (const doc of userTicketMgmtSnapshot.docs) {
    const profileDoc = await profileRef.doc(doc.id).get();
    let billingFlg;
    if (profileDoc.exists) {
      billingFlg = profileDoc.data()?.["BILLING_FLG"] ?? "0";
    } else {
      billingFlg = "0";
    }
    const togetsuTicketSu: number = doc.data()["togetsuTicketSu"];

    if (billingFlg == "0" ) {
      // 一般ユーザーに対する処理
      await userTicketMgmtRef
          .doc(doc.id)
          .update({
            ticketSu: 5 + togetsuTicketSu,
            togetsuTicketSu: 5,
            zengetsuTicketSu: togetsuTicketSu,
            ticketKoushinYmd: formattedDate,
          });
      console.log("一般ユーザーにチケット追加");
    } else {
      // 課金ユーザーに対する処理
      await userTicketMgmtRef
          .doc(doc.id)
          .update({
            ticketSu: 20 + togetsuTicketSu,
            togetsuTicketSu: 20,
            zengetsuTicketSu: togetsuTicketSu,
            ticketKoushinYmd: formattedDate,
          });
      console.log("課金ユーザーにチケット追加");
    }
  }
}

export const sendMessage = functions.region("asia-northeast1")
    .https.onRequest(async (req, res) => {
      try {
        const token = req.body.token;
        const message = {
          token: token,
          data: {
            senderUid: req.body.data.senderUid,
          },
          notification: {
            title: req.body.notification.title,
            body: req.body.notification.body,
          },
        };
        const response = await admin.messaging().send(message);
        console.log("Successfully sent message:", response);
        res.status(200).send("Message sent successfully");
      } catch (error) {
        console.error("Error sending message:", error);
        res.status(500).send("Error sending message");
      }
    });
