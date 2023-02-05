import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Common/CtalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchResult.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileSetting.dart';
import '../Common/CmatchList.dart';
import '../FireBase/FireBase.dart';
import 'TalkRoom.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  List<MatchListModel> matchList = [];

  Future<void> createMatchList() async {
    try {
      matchList = await FirestoreMethod.getMatchList(
          FirestoreMethod.auth.currentUser!.uid);
    }catch(e){
      print("マッチ一覧の取得に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF2FFE4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3CB371),
          title: Text('マッチング一覧'),
        ),
        drawer: Drawer(
            child: ListView(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(top: 10.0)),
            Container(
              height: 60.0,
              child: DrawerHeader(
                child: Text("メニュー"),
                decoration: BoxDecoration(),
              ),
            ),
            ListTile(
              title: Text('利用規約同意書', style: TextStyle(color: Colors.black54)),
              // onTap: _manualURL,
            ),
            ListTile(
              title: Text('アプリ操作手順書', style: TextStyle(color: Colors.black54)),
              // onTap: _FAQURL,
            )
          ],
        )),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirestoreMethod.matchListSnapshot,
            builder: (context, snapshot) {
              return FutureBuilder(
                future: createMatchList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        itemCount: matchList.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                              endActionPane: ActionPane(
                                motion: DrawerMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (value) {
                                      FirestoreMethod.delMatchList(matchList[index].MATCH_ID,context);
                                    },
                                    backgroundColor: Colors.red,
                                    icon: Icons.delete,
                                    label: '削除',
                                  ),
                                ],
                              ),
                              child: Card(
                                color: const Color(0xFFF2FFE4),
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
                                          child: matchList[index]
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
                                                      matchList[index]
                                                          .YOUR_USER
                                                          .PROFILE_IMAGE),
                                                  radius: 30),
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileSetting.Edit(
                                                            matchList[index]
                                                                .YOUR_USER)));
                                          },
                                        ),
                                      ),
                                      InkWell(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                matchList[index]
                                                    .YOUR_USER
                                                    .NICK_NAME,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(matchList[index].SAKUSEI_TIME,
                                                style: TextStyle(
                                                    color: Colors.grey),
                                                overflow: TextOverflow.ellipsis)
                                          ],
                                        ),
                                        onTap: () {
                                          //対戦結果入力画面へ遷移
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MatchResult(
                                                          matchList[index]
                                                              .MY_USER,
                                                          matchList[index]
                                                              .YOUR_USER)));
                                        },
                                      ),
                                      SizedBox(
                                        width: 120,
                                      ),
                                      //トーク画面へ遷移
                                      IconButton(
                                          icon: const Icon(
                                            Icons.message,
                                            color: Colors.black,
                                            size: 30.0,
                                          ),
                                          onPressed: () async {
                                            TalkRoomModel room =
                                                await FirestoreMethod.getRoom(
                                                    matchList[index]
                                                        .RECIPIENT_ID,
                                                    matchList[index].SENDER_ID,
                                                    matchList[index].YOUR_USER);
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        TalkRoom(room)));
                                          })
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
            }));
  }
}
