import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import 'package:tsuyosuke_tennis_ap/Page/ScoreRefPage.dart';

import '../Common/CfriendsList.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';
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
  List<FriendsListModel> friendsList = [];

  Future<void> createFriendsList() async {
    friendsList = await FirestoreMethod.getFriendsList(
        FirestoreMethod.auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "友人管理");

    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreMethod.friendsListSnapshot,
          builder: (context, snapshot) {
            return FutureBuilder(
              future: createFriendsList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                      itemCount: friendsList.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (value) {
                                    FirestoreMethod.delFriendsList(
                                        friendsList[index].FRIENDS_ID, context);
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                      child: InkWell(
                                        child: friendsList[index]
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
                                                    friendsList[index]
                                                        .YOUR_USER
                                                        .PROFILE_IMAGE),
                                                radius: 30),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileReference(
                                                          friendsList[index]
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
                                                friendsList[index]
                                                    .YOUR_USER
                                                    .NICK_NAME,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(
                                                friendsList[index].SAKUSEI_TIME,
                                                style: TextStyle(
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis)
                                          ],
                                        ),
                                        onTap: () async {
                                          //トーク画面へ
                                          TalkRoomModel room =
                                              await FirestoreMethod.getRoom(
                                                  friendsList[index]
                                                      .RECIPIENT_ID,
                                                  friendsList[index].SENDER_ID,
                                                  friendsList[index].YOUR_USER);
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      TalkRoom(room)));
                                        }),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.scoreboard,
                                        color: Colors.black,
                                        size: 30.0,
                                      ),
                                      onPressed: () async {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ScoreRefPage(
                                                      friendsList[index]
                                                          .YOUR_USER
                                                          .USER_ID)),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ));
                      });
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            );
          }),
    );
  }
}
