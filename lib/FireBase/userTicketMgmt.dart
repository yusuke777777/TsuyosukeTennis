import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/singletons_data.dart';
import './../BillingThreshold.dart';
import 'package:intl/intl.dart';

// Firestoreのコレクションおよびドキュメントのパス
FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
final userTicketMgmtRef = _firestoreInstance.collection('userTicketMgmt');

/*
試合マッチング時に、両者より１枚ずつチケットを減算処理する
 */
Future<bool> updateTicketSu(String myUserId, String yourUserId) async {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String today = outputFormat.format(now);

  late bool ticketFlg;
  // トランザクション内で上限数を減算してから更新
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    //自分と相手の残チケット数を取得する
    DocumentReference myTicketRef = await userTicketMgmtRef.doc(myUserId);
    final myTicketRefSna = await transaction.get(myTicketRef);

    DocumentReference yourTicketRef = await userTicketMgmtRef.doc(yourUserId);
    final yourTicketRefSna = await transaction.get(yourTicketRef);

    if (myTicketRefSna.exists && yourTicketRefSna.exists) {
      final myTicketSu = myTicketRefSna.get("ticketSu") - 1;
      final yourTicketSu = yourTicketRefSna.get("ticketSu") - 1;

      if (myTicketSu >= 0 && yourTicketSu >= 0) {
        transaction.update(
          myTicketRef,
          {'ticketSu': myTicketSu, 'ticketKoushinYmd': today},
        );
        transaction.update(
          yourTicketRef,
          {'ticketSu': yourTicketSu, 'ticketKoushinYmd': today},
        );
        ticketFlg = true;
      } else {
        ticketFlg = false;
      }
    }else{
      ticketFlg = false;
    }
  }).then(
    (value) => print("DocumentSnapshot successfully updated!"),
    onError: (e) => throw("チケット数の更新に失敗しました $e"),
  );
  return ticketFlg;
}

/*
新規ユーザー作成時にチケット発行する
 */
Future<void> makeTicket(String myUserId) async {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String today = outputFormat.format(now);
  try {
    userTicketMgmtRef
        .doc(myUserId)
        .set({'ticketSu': ticketGeneralLimit, 'ticketKoushinYmd': today});
  }catch(e){
    throw("チケット発行に失敗しました $e");
  }
}

/*
TSPプレミアム会員に入会時
 */
Future<void> billingUpdateTicket(String myUserId) async {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String today = outputFormat.format(now);
  try{
    userTicketMgmtRef
        .doc(myUserId)
        .set({'ticketSu': ticketPremiumLimit, 'ticketKoushinYmd': today});
  }catch(e){
    throw("TSPプレミアム会員のチケット発行に失敗しました $e");
  }
}

