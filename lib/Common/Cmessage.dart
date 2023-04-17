import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  late String messageId;
  late String message;
  late bool isMe;
  late Timestamp sendTime;
  late String matchStatusFlg;
  late String friendStatusFlg;
  late bool isRead;
  String? dayKey;

  Message({required this.messageId,required this.message,required this.isMe,required this.sendTime,required this.matchStatusFlg,required this.friendStatusFlg,required this.isRead,this.dayKey});
}