import 'package:cloud_firestore/cloud_firestore.dart';

class Message{
  late String message;
  late bool isMe;
  late Timestamp sendTime;
  Message({required this.message,required this.isMe,required this.sendTime});
}