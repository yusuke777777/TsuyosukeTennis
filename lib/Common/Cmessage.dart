import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  late String message;
  late bool isMe;
  late Timestamp sendTime;
  late String matchStatusFlg;
  late String friendStatusFlg;

  Message({required this.message,required this.isMe,required this.sendTime,required this.matchStatusFlg,required this.friendStatusFlg});
}