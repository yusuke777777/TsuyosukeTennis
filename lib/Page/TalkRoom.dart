import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'as intl;

import '../Common/Cmessage.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';

class TalkRoom extends StatefulWidget {
  final TalkRoomModel room;

  TalkRoom(this.room);

  @override
  _TalkRoomState createState() => _TalkRoomState();
}

class _TalkRoomState extends State<TalkRoom> {
  List<Message> messageList = [];
  TextEditingController controller = TextEditingController();
  Future<void> getMessages()async{
    messageList = await FirestoreMethod.getMessages(widget.room.roomId);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        appBar: AppBar(
          title: Text(widget.room.user.NICK_NAME),
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreMethod.messageSnapshot(widget.room.roomId),
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: getMessages(),
                      builder:(context,snapshot){
                        return  ListView.builder(
                            physics: RangeMaintainingScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: messageList.length,
                            itemBuilder: (context,index){
                              Message _message = messageList[index];
                              DateTime sendtime = _message.sendTime.toDate();
                              return Padding(
                                padding: EdgeInsets.only(top:10.0,right: 10.0,left: 10, bottom: index == 0 ? 10.0 : 0.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  textDirection: messageList[index].isMe ? TextDirection.rtl :TextDirection.ltr,
                                  children: [
                                    Container(
                                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
                                        padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 6.0),
                                        decoration: BoxDecoration(
                                            color: messageList[index].isMe ? Colors.green : Colors.white,
                                            borderRadius: BorderRadius.circular(20)
                                        ),
                                        child: Text(messageList[index].message)),
                                    Text(intl.DateFormat('HH:mm').format(sendtime),style: TextStyle(fontSize: 12),)
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  }
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,color: Colors.white,
                child: Row(
                  children: [
                    Expanded(child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    )),
                    IconButton(icon: Icon(Icons.send), onPressed: () async{
                      print("送信");
                      if(controller.text.isNotEmpty){
                        await FirestoreMethod.sendMessage(widget.room.roomId, controller.text);
                        controller.clear();
                      }
                    },),
                  ],
                ),
              ),
            )
          ],
        )
    );
  }
}
