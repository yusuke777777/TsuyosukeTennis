import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

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

  //プラスボタンを押した時に試合申請ボタン・友人申請ボタンを表示する
  String addFlg = "0";
  double menuHeight = 70.0;

  Future<void> getMessages() async {
    messageList = await FirestoreMethod.getMessages(widget.room.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF2FFE4),
        appBar: AppBar(
          backgroundColor: Color(0xFF3CB371),
          title: Text(widget.room.user.NICK_NAME),
            leading: IconButton(
              icon: const Icon(
                Icons.reply,
                color: Colors.black,
                size: 40.0,
              ),
              onPressed: () => {Navigator.pop(context)},
            )
        ),
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: menuHeight),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreMethod.messageSnapshot(widget.room.roomId),
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: getMessages(),
                      builder: (context, snapshot) {
                        return ListView.builder(
                            physics: RangeMaintainingScrollPhysics(),
                            shrinkWrap: true,
                            reverse: true,
                            itemCount: messageList.length,
                            itemBuilder: (context, index) {
                              Message _message = messageList[index];
                              DateTime sendtime = _message.sendTime.toDate();
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: 10.0,
                                    right: 10.0,
                                    left: 10,
                                    bottom: index == 0 ? 10.0 : 0.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  textDirection: messageList[index].isMe
                                      ? TextDirection.rtl
                                      : TextDirection.ltr,
                                  children: [
                                    Container(
                                        constraints: BoxConstraints(
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.6),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 6.0),
                                        decoration: BoxDecoration(
                                            color: messageList[index].isMe
                                                ? Color(0xFF3CB371)
                                                : Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: messageList[index]
                                                    .matchStatusFlg ==
                                                "1"
                                            ? Column(
                                                children: [
                                                  Text(messageList[index]
                                                      .message),
                                                  TextButton(
                                                      onPressed: () {
                                                        if (messageList[index]
                                                            .isMe) {
                                                          print(
                                                              "試合の受け入れメッセージ送信済");
                                                        } else {
                                                          FirestoreMethod
                                                              .matchAccept(
                                                                  widget.room
                                                                      .roomId,
                                                                  messageList[
                                                                          index]
                                                                      .messageId);
                                                          //受け入れ処理を入れる
                                                          FirestoreMethod.makeMatch(widget.room);
                                                        }
                                                      },
                                                      child: Text(
                                                        "Generate",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.purple),
                                                      ))
                                                ],
                                              )
                                            : messageList[index]
                                                        .friendStatusFlg ==
                                                    "1"
                                                ? Column(
                                                    children: [
                                                      Text(messageList[index]
                                                          .message),
                                                      TextButton(
                                                          onPressed: () {
                                                            if (messageList[
                                                                    index]
                                                                .isMe) {
                                                              print(
                                                                  "友達登録申請の受け入れメッセージ送信済");
                                                            } else {
                                                              //受け入れ処理を入れる
                                                              FirestoreMethod.friendAccept(
                                                                  widget.room
                                                                      .roomId,
                                                                  messageList[
                                                                          index]
                                                                      .messageId);
                                                              //友人一覧追記
                                                              FirestoreMethod.makeFriends(widget.room);
                                                            }
                                                          },
                                                          child: Text(
                                                            "受け入れる",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .purple),
                                                          ))
                                                    ],
                                                  )
                                                : messageList[index]
                                                                .matchStatusFlg ==
                                                            "2" ||
                                                        messageList[index]
                                                                .friendStatusFlg ==
                                                            "2"
                                                    ? Column(
                                                        children: [
                                                          Text(
                                                              messageList[index]
                                                                  .message),
                                                          TextButton(
                                                              onPressed: () {
                                                                //受け入れ済なこと伝えるダイアログ出す？
                                                              },
                                                              child: Text(
                                                                "受け入れ済",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .purple),
                                                              ))
                                                        ],
                                                      )
                                                    : Text(messageList[index]
                                                        .message)),
                                    Text(
                                      intl.DateFormat('HH:mm').format(sendtime),
                                      style: TextStyle(fontSize: 12),
                                    )
                                  ],
                                ),
                              );
                            });
                      },
                    );
                  }),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Colors.black,
                height: menuHeight,
                child: Column(
                  children: [
                    _buildButton(),
                    Row(
                      children: [
                        Container(
                          height: 60,
                          color: Colors.black,
                          child: IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.add),
                            onPressed: () {
                              //試合申請・友達申請・チーム招待(追々)
                              addControl();
                            },
                          ),
                        ),
                        Expanded(
                            child: TextField(
                          style: TextStyle(color: Colors.white),
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "メッセージを入力",
                            hintStyle: TextStyle(color: Colors.white),
                            border: OutlineInputBorder(),
                          ),
                        )),
                        Container(
                          height: 60,
                          color: Colors.black,
                          child: IconButton(
                            color: Colors.white,
                            icon: Icon(Icons.send),
                            onPressed: () async {
                              print("送信");
                              if (controller.text.isNotEmpty) {
                                await FirestoreMethod.sendMessage(
                                    widget.room.roomId, controller.text);
                                controller.clear();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ));
  }

  void addControl() {
    if (addFlg == "0") {
      setState(() {
        menuHeight = 130.0;
        addFlg = "1";
      });
    } else {
      setState(() {
        menuHeight = 70.0;
        addFlg = "0";
      });
    }
  }

  Widget _buildButton() {
    if (addFlg == "1") {
      return Center(
        child: Row(children: [
          Container(
            height: 50,
            color: Colors.black,
            child: TextButton(
                child: Column(
                  children: [
                    Icon(
                      Icons.wifi_protected_setup_sharp,
                      size: 20,
                      color: Colors.white,
                    ),
                    Text(
                      '試合申請',
                      style: TextStyle(
                        color: Colors.white, //文字の色を白にする
                        fontWeight: FontWeight.bold, //文字を太字する
                        fontSize: 8.0, //文字のサイズを調整する
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  print("対戦メッセージ送信");
                  await FirestoreMethod.sendMatchMessage(widget.room.roomId);
                }),
          ),
          SizedBox(
            width: 20,
          ),
          Container(
            height: 50,
            color: Colors.black,
            child: TextButton(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    Text(
                      '友人申請',
                      style: TextStyle(
                        color: Colors.white, //文字の色を白にする
                        fontWeight: FontWeight.bold, //文字を太字する
                        fontSize: 8.0, //文字のサイズを調整する
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  print("友達登録メッセージ送信");
                  await FirestoreMethod.sendFriendMessage(widget.room.roomId);
                }),
          ),
          SizedBox(
            width: 20,
          ),
        ]),
      );
    } else {
      return SizedBox(
        height: 2,
      );
    }
  }
}
