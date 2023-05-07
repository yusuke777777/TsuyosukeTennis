import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';

import '../Common/CblockList.dart';
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
class BlockList extends StatefulWidget {
  const BlockList({Key? key}) : super(key: key);

  @override
  State<BlockList> createState() => _BlockListState();
}

class _BlockListState extends State<BlockList> {
  List<BlockListModel> blockList = [];
  Future<void> createBlockList() async {
    blockList = await FirestoreMethod.getBlockList(
        FirestoreMethod.auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "ブロックリスト");


    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon
      ),

      body: StreamBuilder<QuerySnapshot>(
          stream: FirestoreMethod.friendsListSnapshot,
          builder: (context, snapshot) {
            return FutureBuilder(
              future: createBlockList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return ListView.builder(
                      itemCount: blockList.length,
                      itemBuilder: (context, index) {
                        return Slidable(
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (value) async{
                                    await FirestoreMethod.delBlockList(blockList[index].BLOCK_USER_ID);
                                    setState(() {
                                    });
                                  },
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: '解除',
                                ),
                              ],
                            ),
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
                                      //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                      child: InkWell(
                                        child: blockList[index]
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
                                                blockList[index]
                                                    .YOUR_USER
                                                    .PROFILE_IMAGE),
                                            radius: 30),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileReference(
                                                          blockList[index]
                                                              .YOUR_USER
                                                              .USER_ID)
                                              )
                                          );
                                        },
                                      ),
                                    ),
                                   Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                blockList[index]
                                                    .YOUR_USER
                                                    .NICK_NAME,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                          ],
                                        )
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
          }
      ),
    );
  }
}
