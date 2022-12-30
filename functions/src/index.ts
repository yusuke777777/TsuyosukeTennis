import * as admin from "firebase-admin";
import * as functions from "firebase-functions";

admin.initializeApp();
const manSinglesRankRef = admin.firestore().collection("manSinglesRank");

/** 定期的にメタ情報を更新する関数。 */
exports.updateMetaFunction = functions
    .region("asia-northeast1")
    .pubsub.schedule("every 5 minutes")
    .onRun(async (context) => {
      console.log("ランキング作成開始");
      await getRankTable();
      return null;
    });

/** ランキングテーブルから情報を取得する */
async function getRankTable(): Promise<void> {
  const ranks: RankList[] = [];
  const snapshot = await manSinglesRankRef
      .doc("ShokyuRank")
      .collection("RankList").get();
  snapshot.docs.forEach((doc) => {
    ranks.push({
      DOCUMENT_ID: doc.id,
      RANK_NO: doc.data()["RANK_NO"],
      USER_ID: doc.data()["USER_ID"],
      TP_POINT: doc.data()["TP_POINT"],
      TAISHO_SHU: doc.data()["TAISHO_SHU"],
    });
  }
  );
  ranks.sort((a, b) => a.TP_POINT - b.TP_POINT);

  for (let index = 0; index < ranks.length; index++) {
    try {
      await manSinglesRankRef
          .doc("ShokyuRank")
          .collection("RankList")
          .doc(ranks[index].DOCUMENT_ID)
          .set({
            RANK_NO: index + 1,
            USER_ID: ranks[index].USER_ID,
            TP_POINT: ranks[index].TP_POINT,
            TAISHO_SHU: ranks[index].TAISHO_SHU,
          });
    } catch (e) {
      console.log("ランキング作成に失敗しました --- $e");
    }
  }
}

type RankList = {
  DOCUMENT_ID:string,
  RANK_NO: string,
  USER_ID:string,
  TP_POINT: number,
  TAISHO_SHU:string
}
