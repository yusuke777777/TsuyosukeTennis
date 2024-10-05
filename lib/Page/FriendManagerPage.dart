import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/singletons_data.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import 'package:tsuyosuke_tennis_ap/Page/ScoreRefPage.dart';

import '../Common/CfriendsList.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';
import 'Billing.dart';
import 'ProfileSetting.dart';
import 'TalkRoom.dart';

/**
 * 友人管理画面です
 */
class FriendManagerPage extends StatefulWidget {
  const FriendManagerPage({Key? key}) : super(key: key);

  @override
  State<FriendManagerPage> createState() => _FriendManagerPageState();
}

class _FriendManagerPageState extends State<FriendManagerPage> {
  List<FriendsListModel> friendsListAll = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  Future<void> createFriendsList() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('friendsList')
          .where('FRIEND_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: false)
          .limit(10)
          .get();

      List<FriendsListModel> friendsList = [];
      await Future.forEach<dynamic>(querySnapshot.docs, (doc) async {
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);

          FriendsListModel friends = FriendsListModel(
            FRIENDS_ID: doc.data()['FRIENDS_ID'],
            RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
            SENDER_ID: doc.data()['SENDER_ID'],
            SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
            FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
            MY_USER: myProfile,
            YOUR_USER: yourProfile,
          );
          friendsList.add(friends);
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          FriendsListModel friends = FriendsListModel(
            FRIENDS_ID: doc.data()['FRIENDS_ID'],
            RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
            SENDER_ID: doc.data()['SENDER_ID'],
            SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
            FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
            MY_USER: myProfile,
            YOUR_USER: yourProfile,
          );
          friendsList.add(friends);
        }
      });

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }
      setState(() {
        friendsListAll.addAll(friendsList);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    createFriendsList();
    _scrollController = ScrollController();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore) {
          _loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollControllerの解放
    super.dispose();
  }


  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      print("loadMoreData");
      print(_isLoadingMore);
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('friendsList')
          .where('FRIEND_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: false)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();

      List<FriendsListModel> friendsList = [];
      await Future.forEach<dynamic>(querySnapshot.docs, (doc) async {
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);

          FriendsListModel friends = FriendsListModel(
            FRIENDS_ID: doc.data()['FRIENDS_ID'],
            RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
            SENDER_ID: doc.data()['SENDER_ID'],
            SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
            FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
            MY_USER: myProfile,
            YOUR_USER: yourProfile,
          );
          friendsList.add(friends);
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          FriendsListModel friends = FriendsListModel(
            FRIENDS_ID: doc.data()['FRIENDS_ID'],
            RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
            SENDER_ID: doc.data()['SENDER_ID'],
            SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
            FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
            MY_USER: myProfile,
            YOUR_USER: yourProfile,
          );
          friendsList.add(friends);
        }
      });

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }

      setState(() {
        friendsListAll.addAll(friendsList);
        _isLoadingMore = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    HeaderConfig().init(context, "友人管理");
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: ListView.builder(
            controller: _scrollController,
            physics: RangeMaintainingScrollPhysics(),
            shrinkWrap: true,
            reverse: false,
            itemCount: friendsListAll.length + 1,
            itemBuilder: (context, index) {
              if (index == friendsListAll.length) {
                // ページネーションアイテムの場合
                if (_isLoadingMore) {
                  print(_isLoadingMore);
                  return Center(child: CircularProgressIndicator());
                } else {
                  print("ss");
                  return SizedBox();
                }
              } else {
                return Slidable(
                    endActionPane: ActionPane(
                      motion: DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (value) {
                            FirestoreMethod.delFriendsList(
                                friendsListAll[index].FRIENDS_ID, context);
                            // リストから削除して再描画
                            setState(() {
                               friendsListAll.removeAt(index); // 項目をリストから削除
                            });
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: '削除',
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        height: 70,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                                width: deviceWidth * 0.8,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                      child: InkWell(
                                        child: friendsListAll[index]
                                                    .YOUR_USER
                                                    .PROFILE_IMAGE ==
                                                ''
                                            ? CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                                radius: 30,
                                              )
                                            : CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    friendsListAll[index]
                                                        .YOUR_USER
                                                        .PROFILE_IMAGE),
                                                radius: 30),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileReference(
                                                          friendsListAll[index]
                                                              .YOUR_USER
                                                              .USER_ID)));
                                        },
                                      ),
                                    ),
                                    InkWell(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                friendsListAll[index]
                                                    .YOUR_USER
                                                    .NICK_NAME,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                friendsListAll[index]
                                                    .SAKUSEI_TIME,
                                                style: TextStyle(
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis)
                                          ],
                                        ),
                                        onTap: () async {
                                          //トーク画面へ
                                          TalkRoomModel room =
                                              await FirestoreMethod.getRoom(
                                                  friendsListAll[index]
                                                      .RECIPIENT_ID,
                                                  friendsListAll[index]
                                                      .SENDER_ID,
                                                  friendsListAll[index]
                                                      .YOUR_USER);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TalkRoom(room)));
                                        })
                                  ],
                                )),
                            Container(
                              width: deviceWidth * 0.1,
                              alignment: Alignment.centerRight,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.scoreboard,
                                  color: Colors.black,
                                  size: 30.0,
                                ),
                                onPressed: () async {
                                  if (appData.entitlementIsActive == true) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ScoreRefPage(
                                              friendsListAll[index]
                                                  .YOUR_USER
                                                  .USER_ID)),
                                    );
                                  } else {
                                    await showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            BillingShowDialogToDismiss(
                                              content: "友人との対戦成績を確認するためには、有料プランへの加入が必要です。有料プランを確認しますか",
                                            ));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ));
              }
            }));
  }
}
