import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tsuyosuke_tennis_ap/Page/bk_ProfileSetting.dart';

import '../Common/Cmessage.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/NotificationMethod.dart';
import '../UnderMenuMove.dart';
import 'TalkList.dart';

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
  bool friendflg = false;

  Future<void> getMessages() async {
    messageList = await FirestoreMethod.getMessages(widget.room.roomId);
    friendflg = await FirestoreMethod.checkFriends(widget.room.roomId);
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
                onPressed: () async {
                  await NotificationMethod.unreadCountRest(
                      widget.room.user.USER_ID);
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnderMenuMove.make(3)));
                })),
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
                              // String dateString = "";
                              // if (index == 0 || messageList[index - 1].sendTime.toDate().day != messageList[index].sendTime.toDate().day) {
                              //   dateString = intl.DateFormat("yyyy年M月d日").format(messageList[index].sendTime.toDate());
                              // }
                              // if (index == 0) {
                              //   dateString = intl.DateFormat("yyyy年M月d日")
                              //       .format(sendtime);
                              // } else {
                              //   Message _messageZen = messageList[index - 1];
                              //   DateTime sendtimeZen =
                              //       _messageZen.sendTime.toDate();
                              //   String dateStringWk1 =
                              //       intl.DateFormat("yyyy年M月d日")
                              //           .format(sendtime);
                              //   String dateStringWk2 =
                              //       intl.DateFormat("yyyy年M月d日")
                              //           .format(sendtimeZen);
                              //   if (dateStringWk1 != dateStringWk2) {
                              //     dateString = dateStringWk1;
                              //   }
                              // }
                              return Column(
                                children: [
                                  (index == messageList.length - 1 || messageList[index].sendTime.toDate().day != messageList[index + 1].sendTime.toDate().day)
                                      ? Container(
                                          child: Text(
                                            intl.DateFormat("yyyy年M月d日").format(messageList[index].sendTime.toDate()),
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          constraints: BoxConstraints(
                                              maxWidth: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.6),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.0, vertical: 6.0),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF1FFE4),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                        ): Container(),
                                  Padding(
                                    padding: EdgeInsets.only(
                                        top: 10.0,
                                        right: 10.0,
                                        left: 10,
                                        bottom: index == 0 ? 10.0 : 0.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
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
                                                horizontal: 10.0,
                                                vertical: 6.0),
                                            decoration: BoxDecoration(
                                                color: messageList[index].isMe
                                                    ? Color(0xFF3CB371)
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                            child:
                                                messageList[index]
                                                            .matchStatusFlg ==
                                                        "1"
                                                    ? Column(
                                                        children: [
                                                          Text(
                                                              messageList[index]
                                                                  .message),
                                                          TextButton(
                                                              onPressed: () {
                                                                if (messageList[
                                                                        index]
                                                                    .isMe) {
                                                                  print(
                                                                      "試合の受け入れメッセージ送信済");
                                                                } else {
                                                                  FirestoreMethod.matchAccept(
                                                                      widget
                                                                          .room,
                                                                      messageList[
                                                                              index]
                                                                          .messageId);
                                                                  //受け入れ処理を入れる
                                                                  FirestoreMethod
                                                                      .makeMatch(
                                                                          widget
                                                                              .room);
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
                                                                .friendStatusFlg ==
                                                            "1"
                                                        ? Column(
                                                            children: [
                                                              Text(messageList[
                                                                      index]
                                                                  .message),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    if (messageList[
                                                                            index]
                                                                        .isMe) {
                                                                      print(
                                                                          "自身の友人申請に自身で受け入れはできません");
                                                                    } else {
                                                                      friendflg ==
                                                                              true
                                                                          ? showDialog(
                                                                              context:
                                                                                  context,
                                                                              builder: (_) =>
                                                                                  AlertDialog(
                                                                                    content: Text("すでに友人登録済みです"),
                                                                                  ))
                                                                          :
                                                                          //受け入れ処理を入れる
                                                                          FirestoreMethod.friendAccept(
                                                                              widget.room,
                                                                              messageList[index].messageId);
                                                                      //友人一覧追記
                                                                      FirestoreMethod.makeFriends(
                                                                          widget
                                                                              .room);
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
                                                                  Text(messageList[
                                                                          index]
                                                                      .message),
                                                                  TextButton(
                                                                      onPressed:
                                                                          () {
                                                                        //受け入れ済なこと伝えるダイアログ出す？
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        "受け入れ済",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.purple),
                                                                      ))
                                                                ],
                                                              )
                                                            : messageList[index]
                                                                        .matchStatusFlg ==
                                                                    "4"
                                                                ? Column(
                                                                    children: [
                                                                      Text(messageList[
                                                                              index]
                                                                          .message),
                                                                      TextButton(
                                                                          onPressed:
                                                                              () {
                                                                            if (messageList[index].isMe) {
                                                                              print("対戦結果メッセージ送信済み");
                                                                            } else {
                                                                              FirestoreMethod.matchFeedAccept(widget.room, messageList[index].messageId);
                                                                              //フィードバック更新処理
                                                                              // FirestoreMethod.makeMatch(widget.room);
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            "フィードバックする",
                                                                            style:
                                                                                TextStyle(color: Colors.purple),
                                                                          ))
                                                                    ],
                                                                  )
                                                                : messageList[index].matchStatusFlg == "5"
                                                                    ? Column(
                                                                        children: [
                                                                          Text(messageList[index]
                                                                              .message),
                                                                          TextButton(
                                                                              onPressed: () {
                                                                                //受け入れ済なこと伝えるダイアログ出す？
                                                                              },
                                                                              child: Text(
                                                                                "フィードバック済",
                                                                                style: TextStyle(color: Colors.purple),
                                                                              ))
                                                                        ],
                                                                      )
                                                                    : Text(messageList[index].message)),
                                        Text(
                                          intl.DateFormat('HH:mm')
                                              .format(sendtime),
                                          style: TextStyle(fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
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
                              CprofileSetting myProfile =
                                  await FirestoreMethod.getProfile();
                              if (controller.text.isNotEmpty) {
                                await FirestoreMethod.sendMessage(
                                    widget.room, controller.text);
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
                  await FirestoreMethod.sendMatchMessage(widget.room);
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
                  await FirestoreMethod.sendFriendMessage(widget.room);
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
