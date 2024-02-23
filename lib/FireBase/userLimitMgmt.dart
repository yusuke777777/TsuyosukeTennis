import 'package:cloud_firestore/cloud_firestore.dart';

// Firestoreのコレクションおよびドキュメントのパス
FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
final userLimitMgmtRef = _firestoreInstance.collection('userLimitMgmt');

Future<int> getDailyMessageLimit(String userId) async {
  DocumentSnapshot userSnapshot = await userLimitMgmtRef.doc(userId).get();

  if (userSnapshot.exists) {
    return userSnapshot['dailyMessageLimit'];
  } else {
    // ユーザーが存在しない場合のデフォルト上限を返す
    return 10; // 例として100としていますが、適切なデフォルト値を設定してください
  }
}


Future<bool> updateDailyMessageLimit(String userId) async {
  late bool MessageLimitFlg;
  // トランザクション内で上限数を減算してから更新
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentReference myMessageLimitRef =
    await userLimitMgmtRef.doc(userId);
    final myMessageLimitSna = await transaction.get(myMessageLimitRef);

    if (myMessageLimitSna.exists) {
      final newLimitSu = myMessageLimitSna.get("dailyMessageLimit") - 1;
      if(newLimitSu >= 0){
      transaction.update(
        myMessageLimitRef,
        {'dailyMessageLimit': newLimitSu},
      );
      MessageLimitFlg = true;
    }else{
        MessageLimitFlg = false;
      }
  }}
    ).then(
        (value) => print("DocumentSnapshot successfully updated!"),
    onError: (e) => print("Error updating document $e"),
  );
  return MessageLimitFlg;
}

Future<void> resetDailyMessageLimit(String userId) async {
  // 現在のタイムスタンプを取得
  Timestamp currentTimestamp = Timestamp.now();

  // Firestoreのユーザードキュメントを更新してリセット
  await userLimitMgmtRef.doc(userId).set({
    'dailyMessageLimit': 10, // リセット後のデフォルト上限を設定
    'lastResetTimestamp': currentTimestamp,
  }, SetOptions(merge: true));
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
      await resetDailyMessageLimit(userId);
    }
  } else {
    await resetDailyMessageLimit(userId);
  }
}
