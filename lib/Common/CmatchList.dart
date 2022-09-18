import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class MatchListModel{
  late String MATCH_ID;
  late String RECIPIENT_ID;
  late String SENDER_ID;
  late String SAKUSEI_TIME;
  late String MATCH_FLG;
  late CprofileSetting MY_USER;
  late CprofileSetting YOUR_USER;

  MatchListModel({
    required this.MATCH_ID,required this.RECIPIENT_ID,required this.SENDER_ID,required this.SAKUSEI_TIME,required this.MATCH_FLG,required this.MY_USER,required this.YOUR_USER
  });
}