import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Common/CtalkRoom.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../PropSetCofig.dart';
import 'ProfileReference.dart';
import 'TalkRoom.dart';

class TalkList extends StatefulWidget {
  const TalkList({Key? key}) : super(key: key);

  @override
  _TalkListState createState() => _TalkListState();
}

class _TalkListState extends State<TalkList> {
  List<TalkRoomModel> talkList = [];
  late StreamSubscription<QuerySnapshot> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = FirebaseFirestore.instance
        .collection('myNotification')
        .doc(FirestoreMethod.auth.currentUser!.uid)
        .collection('talkNotification')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> createRooms() async {
    print("aaa");
    talkList =
        await FirestoreMethod.getRooms(FirestoreMethod.auth.currentUser!.uid);
    print(talkList.length);
    print("bbb");
  }

  @override
  void dispose() {
    _subscription.cancel(); // リスナーを破棄する
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "トーク一覧");
    DrawerConfig().init(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          drawer: DrawerConfig.drawer,
          body: Stack(
            children: [
              Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: AdBanner(size: AdSize.banner)),
              Padding(
                padding: EdgeInsets.only(top: 40),
                child: FutureBuilder(
                  future: createRooms(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return ListView.builder(
                          itemCount: talkList.length,
                          itemBuilder: (context, index) {
                            return Slidable(
                                endActionPane: ActionPane(
                                  motion: const DrawerMotion(),
                                  children: [
                                    SlidableAction(
                                      onPressed: (value) {
                                        FirestoreMethod.addBlockList(
                                            talkList[index].user.USER_ID);
                                        setState(() {
                                        });
                                      },
                                      backgroundColor: Colors.grey,
                                      icon: Icons.block_flipped,
                                      label: 'ブロック',
                                      foregroundColor: Colors.white,
                                    ),
                                    SlidableAction(
                                      onPressed: (value) {
                                        // リストから削除して再描画
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: const Text('本当に削除して宜しいですか'),
                                                actions: <Widget>[
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.black,
                                                        backgroundColor: Colors
                                                            .lightGreenAccent),
                                                    child: const Text('はい'),
                                                    onPressed: () async {
                                                      try {
                                                        await FirestoreMethod
                                                            .delTalkRoom(
                                                            talkList[index]
                                                                .roomId);
                                                        Navigator.pop(context);
                                                        // 戻ってきたら未読数をリセット
                                                        await NotificationMethod.unreadCountRest(
                                                            talkList[index].user.USER_ID);
                                                        // トークリストを更新
                                                        await createRooms();
                                                        setState(() {});
                                                      }catch(e){
                                                        showDialog(
                                                            context: context,
                                                            builder: (BuildContext context) => const ShowDialogToDismiss(
                                                              content: "トークルームの削除に失敗しました",
                                                              buttonText: "はい",
                                                            ));
                                                      }
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                        foregroundColor:
                                                            Colors.black,
                                                        backgroundColor: Colors
                                                            .lightGreenAccent),
                                                    child: const Text('いいえ'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      backgroundColor: Colors.red,
                                      icon: Icons.delete,
                                      label: '削除',
                                    ),
                                  ],
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TalkRoom(talkList[index])));
                                    await NotificationMethod.unreadCountRest(
                                        talkList[index].user.USER_ID);
                                    // トークリストを再取得してリフレッシュ
                                    setState(() {
                                      // 最新のトークルームリストを再取得
                                      createRooms();
                                    });
                                  },
                                  child: Card(
                                    color: Colors.white,
                                    child: Container(
                                      height: 70,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: InkWell(
                                              child: talkList[index]
                                                          .user
                                                          .PROFILE_IMAGE ==
                                                      ''
                                                  ? const CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage: NetworkImage(
                                                          "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                                      radius: 30,
                                                    )
                                                  : CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      backgroundImage:
                                                          NetworkImage(talkList[
                                                                  index]
                                                              .user
                                                              .PROFILE_IMAGE),
                                                      radius: 30,
                                                    ),
                                              onTap: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ProfileReference(
                                                                talkList[index]
                                                                    .user
                                                                    .USER_ID)));
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                    child: Text(
                                                        talkList[index]
                                                            .user
                                                            .NICK_NAME,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold))),
                                                Container(
                                                    child: Text(
                                                  talkList[index].lastMessage,
                                                  style: const TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 13),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                ))
                                              ],
                                            ),
                                          ),
                                          talkList[index].unReadCnt == 0
                                              ? Container()
                                              : Container(
                                                  alignment: Alignment.center,
                                                  width: 25.0,
                                                  height: 25.0,
                                                  decoration: const BoxDecoration(
                                                    color: Colors.green,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    talkList[index]
                                                        .unReadCnt
                                                        .toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  ),
                                                ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
                          });
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
            ],
          )),
    );
  }
}
