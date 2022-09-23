import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tsuyosuke_tennis_ap/Common/CprofileSetting.dart';

class FriendsListModel{
  late String FRIENDS_ID;
  late String RECIPIENT_ID;
  late String SENDER_ID;
  late String SAKUSEI_TIME;
  late String FRIENDS_FLG;
  late CprofileSetting MY_USER;
  late CprofileSetting YOUR_USER;

  FriendsListModel({
    required this.FRIENDS_ID,required this.RECIPIENT_ID,required this.SENDER_ID,required this.SAKUSEI_TIME,required this.FRIENDS_FLG,required this.MY_USER,required this.YOUR_USER
  });
}