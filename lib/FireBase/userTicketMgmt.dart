import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/singletons_data.dart';
import '../Common/CticketList.dart';
import './../BillingThreshold.dart';
import 'package:intl/intl.dart';

// Firestoreのコレクションおよびドキュメントのパス
FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
final userTicketMgmtRef = _firestoreInstance.collection('userTicketMgmt');

/*
新規ユーザー作成時にチケット発行する
 */
Future<void> newUserMakeTicket(String myUserId) async {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String today = outputFormat.format(now);
  print("チケット発行");
  try {
    userTicketMgmtRef.doc(myUserId).set({
      'ticketSu': ticketGeneralLimit,
      'togetsuTicketSu': ticketGeneralLimit,
      'zengetsuTicketSu': 0,
      'ticketKoushinYmd': today
    });
  } catch (e) {
    throw ("チケット発行に失敗しました $e");
  }
}

/*
チケット数を取得
 */
Future<CTicketModel> getTicketSu(String myUserId) async {
  final userTicketMgmDoc = await userTicketMgmtRef.doc(myUserId).get();
  CTicketModel ticketSu = CTicketModel(TICKET_SU: userTicketMgmDoc.data()!['ticketSu'],
      TOGETSU_TICKET_SU: userTicketMgmDoc.data()!['togetsuTicketSu'],
      ZENGETSU_TICKET_SU: userTicketMgmDoc.data()!['zengetsuTicketSu']);
  return ticketSu;
}


/*
TSPプレミアム会員に入会時
 */
Future<void> billingUpdateTicket(String myUserId) async {
  DateTime now = DateTime.now();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String today = outputFormat.format(now);
  int zengetsuTicketSu = 0;
  DocumentSnapshot userTicketMgmDoc = await userTicketMgmtRef.doc(myUserId)
      .get();
  if (userTicketMgmDoc.exists) {
    zengetsuTicketSu = userTicketMgmDoc['zengetsuTicketSu'];
  }
  int ticketSuSum = ticketPremiumLimit + zengetsuTicketSu;
  //当月のプレミアム会員のチケット数だけ更新する
  try {
    userTicketMgmtRef.doc(myUserId).set({
      'ticketSu': ticketSuSum,
      'togetsuTicketSu': ticketPremiumLimit,
      'zengetsuTicketSu': zengetsuTicketSu,
      'ticketKoushinYmd': today
    }, SetOptions(merge: true));
    // throw ("エラー");
  } catch (e) {
    throw ("TSPプレミアム会員のチケット発行に失敗しました $e");
  }
}
