import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:intl/intl.dart' as intl;
import 'package:tsuyosuke_tennis_ap/Common/CticketList.dart';

import '../Common/CSkilLevelSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/Cmessage.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../FireBase/singletons_data.dart';
import '../FireBase/userLimitMgmt.dart';
import '../FireBase/userTicketMgmt.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';
import 'MatchResultFeedBack.dart';
import 'MatchResultSansho.dart';
import 'TalkList.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

class TalkRoom extends StatefulWidget {
  final TalkRoomModel room;

  TalkRoom(this.room);

  @override
  _TalkRoomState createState() => _TalkRoomState();
}


class _TalkRoomState extends State<TalkRoom> {
  TextEditingController controller = TextEditingController();
  late ScrollController _scrollController;
  late Stream<List<QueryDocumentSnapshot>> _messagesStream;
  List<QueryDocumentSnapshot> _messages = [];
  bool _isLoadingMore = false;
  List<Message> messageList = [];


  //プラスボタンを押した時に試合申請ボタン・友人申請ボタンを表示する
  String addFlg = "0";
  double menuHeight = 70.0;

  @override
  void initState() {
    super.initState();
    //メッセージの上限数を制御する
    checkAndResetDailyLimitIfNeeded(FirestoreMethod.auth.currentUser!.uid);
    _scrollController = ScrollController();
    _messagesStream = _getMessagesStream();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreMessages();
      }
    });
  }
  @override
  void dispose() {
    _scrollController.dispose(); // スクロールコントローラーを破棄
    super.dispose();
  }


  Stream<List<QueryDocumentSnapshot>> _getMessagesStream() {
    return FirestoreMethod.roomRef
        .doc(widget.room.roomId)
        .collection('message')
        .orderBy('send_time', descending: true)
        .limit(10)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    QuerySnapshot snapshot = await FirestoreMethod.roomRef
        .doc(widget.room.roomId)
        .collection('message')
        .orderBy('send_time', descending: true)
        .startAfterDocument(_messages.last)
        .limit(10)
        .get();

    setState(() {
      _isLoadingMore = false;
      _messages.addAll(snapshot.docs);
    });
  }

  @override
  Widget build(BuildContext context) {
      return
        Scaffold(
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
                      Navigator.pop(context);
                      // await Navigator.push(
                      //     context,
                      //     MaterialPageRoute(
                      //         builder: (context) => UnderMenuMove.make(3)));
                    })),
            body: Stack(
              children: [
                Container(alignment:Alignment.center,height: 40, child: AdBanner(size: AdSize.banner)),
                Padding(
                  padding: EdgeInsets.only(top: 40, bottom: menuHeight),
                  child: StreamBuilder<List<QueryDocumentSnapshot>>(
                      stream: _messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}'),
                          );
                        }
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        _messages = snapshot.data ?? [];
                        if (snapshot.connectionState == ConnectionState.active) {
                          return ListView.builder(
                              controller: _scrollController,
                              physics: const RangeMaintainingScrollPhysics(),
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: _messages.length + 1,
                              itemBuilder: (context, index) {
                                if (index == _messages.length) {
                                  if (_isLoadingMore) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  } else {
                                    return SizedBox();
                                  }
                                }
                                Message _messageDetail = Message(
                                    messageId: (_messages[index].data() as Map<
                                        String,
                                        dynamic>)['messageId'] as String,
                                    message: (_messages[index].data() as Map<
                                        String,
                                        dynamic>)['message'] as String,
                                    isMe: (_messages[index].data() as Map<
                                        String,
                                        dynamic>)['sender_id'] as String ==
                                        FirestoreMethod.auth.currentUser!.uid
                                        ? true
                                        : false,
                                    sendTime: (_messages[index].data() as Map<
                                        String,
                                        dynamic>)['send_time'] as Timestamp,
                                    matchStatusFlg: (_messages[index]
                                        .data() as Map<
                                        String,
                                        dynamic>)['matchStatusFlg'] as String,
                                    friendStatusFlg: (_messages[index]
                                        .data() as Map<
                                        String,
                                        dynamic>)['friendStatusFlg'] as String);
                                DateTime sendtime = _messageDetail.sendTime
                                    .toDate();

                                return Column(
                                  children: [
                                    (index == _messages.length - 1 ||
                                        intl.DateFormat("yyyy年M月d日").format(
                                            ((_messages[index].data() as Map<
                                                String,
                                                dynamic>)['send_time'] as Timestamp)
                                                .toDate()) !=
                                            intl.DateFormat("yyyy年M月d日")
                                                .format(
                                                ((_messages[index + 1]
                                                    .data() as Map<
                                                    String,
                                                    dynamic>)['send_time'] as Timestamp)
                                                    .toDate()))
                                        ? Container(
                                      child: Text(
                                        intl.DateFormat("yyyy年M月d日")
                                            .format(
                                            ((_messages[index].data() as Map<
                                                String,
                                                dynamic>)['send_time'] as Timestamp)
                                                .toDate()),
                                        style: TextStyle(fontSize: 12),
                                      ),
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery
                                              .of(context)
                                              .size
                                              .width *
                                              0.6),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                          vertical: 6.0),
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF1FFE4),
                                          borderRadius:
                                          BorderRadius.circular(20)),
                                    )
                                        : Container(),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: 10.0,
                                          right: 10.0,
                                          left: 10,
                                          bottom: index == 0 ? 10.0 : 0.0),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                        textDirection: _messageDetail.isMe
                                            ? TextDirection.rtl
                                            : TextDirection.ltr,
                                        children: [
                                          Container(
                                              constraints: BoxConstraints(
                                                  maxWidth: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .width *
                                                      0.6),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10.0,
                                                  vertical: 6.0),
                                              decoration: BoxDecoration(
                                                  color: _messageDetail.isMe
                                                      ? Color(0xFF3CB371)
                                                      : Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      20)),
                                              child:
                                              _messageDetail
                                                  .matchStatusFlg ==
                                                  "1"
                                                  ? Column(
                                                children: [
                                                  Text(_messageDetail
                                                      .message),
                                                  TextButton(
                                                      onPressed: () async {
                                                        if (_messageDetail
                                                            .isMe) {
                                                          print(
                                                              "試合の受け入れメッセージ送信済");
                                                        } else {
                                                          //受け入れ処理を入れる
                                                          try {
                                                            String ticketFlg = await FirestoreMethod
                                                                .makeMatch(
                                                                widget.room);
                                                            if (ticketFlg == "0") {
                                                              FirestoreMethod
                                                                  .matchAccept(
                                                                  widget
                                                                      .room,
                                                                  (_messages[index]
                                                                      .data() as Map<
                                                                      String,
                                                                      dynamic>)['messageId'] as String
                                                              );
                                                            } else
                                                            if (ticketFlg == "1") {
                                                              if (appData
                                                                  .entitlementIsActive ==
                                                                  true) {
                                                                await showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) =>
                                                                        ShowDialogToDismiss(
                                                                          content: "チケットが不足しています。",
                                                                          buttonText: "はい",
                                                                        ));
                                                              } else {
                                                                await showDialog(
                                                                    context: context,
                                                                    builder: (
                                                                        BuildContext context) =>
                                                                        BillingShowDialogToDismiss(
                                                                            content: "チケットが不足しています。有料プランを確認しますか"
                                                                        ));
                                                              }
                                                            } else {
                                                              await showDialog(
                                                                  context: context,
                                                                  builder: (
                                                                      BuildContext context) =>
                                                                      ShowDialogToDismiss(
                                                                        content: "対戦相手のチケットが不足しています。",
                                                                        buttonText: "はい",
                                                                      ));
                                                              FirestoreMethod
                                                                  .matchAcceptTicketError(
                                                                  widget
                                                                      .room,
                                                                  (_messages[index]
                                                                      .data() as Map<
                                                                      String,
                                                                      dynamic>)['messageId'] as String
                                                              );
                                                            }
                                                          } catch (e) {
                                                            await showDialog(
                                                                context: context,
                                                                builder: (
                                                                    BuildContext context) =>
                                                                    ShowDialogToDismiss(
                                                                      content: e
                                                                          .toString(),
                                                                      buttonText: "はい",
                                                                    ));
                                                          }
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
                                                  : _messageDetail
                                                  .friendStatusFlg ==
                                                  "1"
                                                  ? Column(
                                                children: [
                                                  Text(_messageDetail
                                                      .message),
                                                  TextButton(
                                                      onPressed:
                                                          () async {
                                                        if (_messageDetail
                                                            .isMe) {
                                                          print(
                                                              "自身の友人申請に自身で受け入れはできません");
                                                        } else {
                                                          bool friendflg = await FirestoreMethod
                                                              .checkFriends(
                                                              widget.room.roomId);
                                                          if (friendflg ==
                                                              true) {
                                                            showDialog(
                                                                context: context,
                                                                builder: (_) =>
                                                                    AlertDialog(
                                                                      content: Text(
                                                                          "すでに友人登録済みです"),
                                                                    ));
                                                          } else {
                                                            //受け入れ処理を入れる
                                                            FirestoreMethod
                                                                .friendAccept(
                                                                widget.room,
                                                                (_messages[index]
                                                                    .data() as Map<
                                                                    String,
                                                                    dynamic>)['messageId'] as String
                                                            );
                                                            //友人一覧追記
                                                            FirestoreMethod
                                                                .makeFriends(
                                                                widget.room);
                                                          }
                                                        }
                                                      },
                                                      child: Text(
                                                        "受け入れる",
                                                        style: TextStyle(
                                                            color:
                                                            Colors.purple),
                                                      ))
                                                ],
                                              )
                                                  : _messageDetail
                                                  .matchStatusFlg ==
                                                  "2" ||
                                                  _messageDetail
                                                      .friendStatusFlg ==
                                                      "2"
                                                  ? Column(
                                                children: [
                                                  Text(_messageDetail
                                                      .message),
                                                  TextButton(
                                                      onPressed:
                                                          () {
                                                        //受け入れ済なこと伝えるダイアログ出す？
                                                      },
                                                      child:
                                                      Text(
                                                        "受け入れ済",
                                                        style:
                                                        TextStyle(
                                                            color: Colors.purple),
                                                      ))
                                                ],
                                              )
                                                  : _messageDetail
                                                  .matchStatusFlg ==
                                                  "4"
                                                  ? Column(
                                                children: [
                                                  Text(_messageDetail
                                                      .message),
                                                  TextButton(
                                                      onPressed:
                                                          () async {
                                                        if (_messageDetail.isMe) {
                                                          print(
                                                              "対戦結果メッセージ送信済み");
                                                        } else {
                                                          //フィードバック確認する処理
                                                          //フィードバック結果を取得する
                                                          String feedBackComment = await FirestoreMethod
                                                              .getFeedBack(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String
                                                              ,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          //対戦結果リストを取得する
                                                          List<
                                                              CmatchResult> matchResultList = await FirestoreMethod
                                                              .getMatchResult(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String
                                                              ,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          //レビュー結果を取得する
                                                          CSkilLevelSetting skillLevel = await FirestoreMethod
                                                              .getSkillLevel(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String
                                                              ,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          CprofileSetting myProfile = await FirestoreMethod
                                                              .getProfile();
                                                          CprofileSetting yourProfile = await FirestoreMethod
                                                              .getYourProfile(
                                                              widget.room.user
                                                                  .USER_ID);
                                                          String matchTitle = await FirestoreMethod
                                                              .getMatchTitle(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String
                                                              ,
                                                              widget.room.user
                                                                  .USER_ID);

                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      MatchResultSansho(
                                                                          myProfile,
                                                                          yourProfile,
                                                                          matchResultList,
                                                                          feedBackComment,
                                                                          skillLevel,
                                                                          matchTitle)));

                                                          // FirestoreMethod.makeMatch(widget.room);
                                                        }
                                                      },
                                                      child:
                                                      Text(
                                                        "確認する",
                                                        style: TextStyle(
                                                            color: Colors.purple),
                                                      )),
                                                  TextButton(
                                                      onPressed:
                                                          () async {
                                                        if (_messageDetail.isMe) {
                                                          print(
                                                              "対戦結果メッセージ送信済み");
                                                        } else {
                                                          //レビュー・フィードバックを記入する
                                                          List<
                                                              CmatchResult> matchResultList = await FirestoreMethod
                                                              .getMatchResult(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          CprofileSetting myProfile = await FirestoreMethod
                                                              .getProfile();
                                                          CprofileSetting yourProfile = await FirestoreMethod
                                                              .getYourProfile(
                                                              widget.room.user
                                                                  .USER_ID);
                                                          String matchTitle = await FirestoreMethod
                                                              .getMatchTitle(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);

                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      MatchResultFeedBack(
                                                                          myProfile,
                                                                          yourProfile,
                                                                          matchResultList,
                                                                          matchTitle,
                                                                          (_messages[index]
                                                                              .data() as Map<
                                                                              String,
                                                                              dynamic>)['dayKey'] as String
                                                                          ,
                                                                          (_messages[index]
                                                                              .data() as Map<
                                                                              String,
                                                                              dynamic>)['messageId'] as String
                                                                          ,
                                                                          widget
                                                                              .room)));
                                                        }
                                                      },
                                                      child:
                                                      Text(
                                                        "フィードバックする",
                                                        style: TextStyle(
                                                            color: Colors.purple),
                                                      ))
                                                ],
                                              )
                                                  : _messageDetail
                                                  .matchStatusFlg ==
                                                  "3"
                                                  ? Column(
                                                children: [
                                                  Text(_messageDetail.message),
                                                  TextButton(
                                                      onPressed: () async {
                                                        if (_messageDetail.isMe) {
                                                          print(
                                                              "対戦結果メッセージ送信済み");
                                                        } else {
                                                          //フィードバック結果を取得する
                                                          String feedBackComment = await FirestoreMethod
                                                              .getFeedBack(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          //対戦結果リストを取得する
                                                          List<
                                                              CmatchResult> matchResultList = await FirestoreMethod
                                                              .getMatchResult(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          //レビュー結果を取得する
                                                          CSkilLevelSetting skillLevel = await FirestoreMethod
                                                              .getSkillLevel(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);
                                                          CprofileSetting myProfile = await FirestoreMethod
                                                              .getProfile();
                                                          CprofileSetting yourProfile = await FirestoreMethod
                                                              .getYourProfile(
                                                              widget.room.user
                                                                  .USER_ID);
                                                          String matchTitle = await FirestoreMethod
                                                              .getMatchTitle(
                                                              (_messages[index]
                                                                  .data() as Map<
                                                                  String,
                                                                  dynamic>)['dayKey'] as String,
                                                              widget.room.user
                                                                  .USER_ID);

                                                          await Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder: (
                                                                      context) =>
                                                                      MatchResultSansho(
                                                                          myProfile,
                                                                          yourProfile,
                                                                          matchResultList,
                                                                          feedBackComment,
                                                                          skillLevel,
                                                                          matchTitle)));
                                                        }
                                                      },
                                                      child: Text(
                                                        "確認する",
                                                        style: TextStyle(
                                                            color: Colors.purple),
                                                      )),
                                                ],
                                              )
                                                  : Text(_messageDetail
                                                  .message)),
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
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
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
                                  await handleSendMessage();
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
            )
      );
  }

  Future<void> handleSendMessage() async {
    String sendMessage = controller.text;
    controller.clear();

    if (sendMessage.isNotEmpty) {
      // 上限数を減算してから更新する
      bool MessageLimitFlg = await updateDailyMessageLimit(
          FirestoreMethod.auth.currentUser!.uid);

      if (MessageLimitFlg) {
        try {
          await FirestoreMethod.sendMessage(
              widget.room, sendMessage);
        } catch (e) {
          print("TalkRoom :" + e.toString());
        }
      } else {
        if (appData.entitlementIsActive == true) {
          await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  ShowDialogToDismiss(
                    content: "1日の上限メッセージ数を超えました。", buttonText: 'はい',
                  ));
        } else {
          await showDialog(
              context: context,
              builder: (BuildContext context) =>
                  BillingShowDialogToDismiss(
                    content: "1日の上限メッセージ数を超えました。上限数を上げたい場合、有料プランへの加入が必要です。有料プランを確認しますか ",
                  ));
        }
      }
    }
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
                  CTicketModel myCurTicketSu = await getTicketSu(
                      FirestoreMethod.auth.currentUser!.uid);
                  if (myCurTicketSu.TICKET_SU > 0) {
                    await FirestoreMethod.sendMatchMessage(widget.room);
                  } else {
                    if (appData
                        .entitlementIsActive ==
                        true) {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              ShowDialogToDismiss(
                                content: "チケットが不足してるため、対戦申し込みができません",
                                buttonText: "はい",
                              ));
                    } else {
                      await showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              BillingShowDialogToDismiss(
                                  content: "チケットが不足してるため、対戦申し込みができません。有料プランを確認しますか"
                              ));
                    }
                  }
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
                  bool friendflg = await FirestoreMethod
                      .checkFriends(
                      widget.room.roomId);
                  if (friendflg ==
                      true) {
                    showDialog(
                        context: context,
                        builder: (_) =>
                            AlertDialog(
                              content: Text(
                                  "すでに友人登録済みです"),
                            ));
                  } else {
                    print("友達登録メッセージ送信");
                    await FirestoreMethod.sendFriendMessage(widget.room);
                  }
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
