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
 * ブロックリスト画面です
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

  Future<bool> isUserExist(String uid) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('myProfileDetail') // コレクション名を変更してください
        .doc(uid)
        .get();

    return docSnapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "ブロックリスト");

    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: FutureBuilder(
          future: createBlockList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return ListView.builder(
                  itemCount: blockList.length,
                  itemBuilder: (context, index) {
                    return Slidable(
                        endActionPane: ActionPane(
                          motion: const DrawerMotion(),
                          children: [
                            SlidableAction(
                              onPressed: (value) async {
                                await FirestoreMethod.delBlockList(
                                    blockList[index].BLOCK_USER_ID);
                                setState(() {});
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
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                        ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                                "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Ftenipoikun.png?alt=media&token=46474a8b-ca79-4232-92ee-431042c19d10"),
                                            radius: 30,
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              blockList[index]
                                                  .YOUR_USER
                                                  .PROFILE_IMAGE,
                                              width:
                                                  60, // CircleAvatar の直径に合わせて調整
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage(
                                                      'images/tenipoikun.png'),
                                                  radius: 30,
                                                );
                                              },
                                            ),
                                          ),
                                    onTap: () async {
                                      print(blockList[index].YOUR_USER.USER_ID.toString());
                                      print(await isUserExist(blockList[index].YOUR_USER.USER_ID.toString()));
                                      if(await isUserExist(blockList[index].YOUR_USER.USER_ID.toString())) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileReference(
                                                        blockList[index]
                                                            .YOUR_USER
                                                            .USER_ID)));
                                      }
                                      else {
                                        showDialog(
                                            context: context,
                                            builder: (_) => const AlertDialog(
                                              title: Text("エラー"),
                                              content: Text("退会済みユーザーです"),
                                            ));
                                      }
                                    },
                                  ),
                                ),
                                Container(
                                  child: Text(
                                      blockList[index].YOUR_USER.NICK_NAME,
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ));
                  });
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }

  @override
  void dispose() {
    // 必要なリソースを解放する処理をここに追加
    super.dispose();
  }
}
