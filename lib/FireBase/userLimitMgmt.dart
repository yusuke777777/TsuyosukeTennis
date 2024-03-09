import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/singletons_data.dart';
import './../BillingThreshold.dart';

// Firestoreのコレクションおよびドキュメントのパス
FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
final userLimitMgmtRef = _firestoreInstance.collection('userLimitMgmt');

Future<bool> updateDailyMessageLimit(String userId) async {
  late bool MessageLimitFlg;
  // トランザクション内で上限数を減算してから更新
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentReference myMessageLimitRef = await userLimitMgmtRef.doc(userId);
    final myMessageLimitSna = await transaction.get(myMessageLimitRef);

    if (myMessageLimitSna.exists) {
      final newLimitSu = myMessageLimitSna.get("dailyMessageLimit") - 1;
      if (newLimitSu >= 0) {
        transaction.update(
          myMessageLimitRef,
          {'dailyMessageLimit': newLimitSu},
        );
        MessageLimitFlg = true;
      } else {
        MessageLimitFlg = false;
      }
    } else {
      MessageLimitFlg = false;
    }
  }).then((value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => throw ("残メッセージ数の計算が失敗しました $e"));
  return MessageLimitFlg;
}

Future<void> resetDailyMessageLimit(String userId) async {
  // 現在のタイムスタンプを取得
  Timestamp currentTimestamp = Timestamp.now();
  late int dailyMessageLimit;

  if (appData.entitlementIsActive) {
    dailyMessageLimit = messagePremiumLimit;
  } else {
    dailyMessageLimit = messageGeneralLimit;
  }

  // Firestoreのユーザードキュメントを更新してリセット
  try {
    await userLimitMgmtRef.doc(userId).set({
      'dailyMessageLimit': dailyMessageLimit, // リセット後のデフォルト上限を設定
      'lastResetTimestamp': currentTimestamp,
    }, SetOptions(merge: true));
  } catch (e) {
    throw ("メッセージ数のリセットに失敗しました $e");
  }
}

Future<void> checkAndResetDailyLimitIfNeeded(String userId) async {
  DocumentSnapshot userSnapshot = await userLimitMgmtRef.doc(userId).get();

  if (userSnapshot.exists) {
    // ドキュメントが存在する場合は、最終リセット日時を取得
    Timestamp lastResetTimestamp = userSnapshot['lastResetTimestamp'];

    // 現在のタイムスタンプを取得
    Timestamp currentTimestamp = Timestamp.now();

    // 24時間経過していた場合、リセット
    if (currentTimestamp.seconds - lastResetTimestamp.seconds >= 24 * 60 * 60) {
      try {
        await resetDailyMessageLimit(userId);
      } catch (e) {
        print("XXXXXXここでエラーに対する処理を入れるXXXXXX");
      }
    }
  } else {
    try {
      await resetDailyMessageLimit(userId);
    } catch (e) {
      print("XXXXXXここでエラーに対する処理を入れるXXXXXX");
    }
  }
}
