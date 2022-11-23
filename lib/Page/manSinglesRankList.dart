import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Common/CSinglesRankModel.dart';
import '../FireBase/FireBase.dart';
import 'TalkRoom.dart';

class manSinglesRankList extends StatefulWidget {
  final String rank;

  manSinglesRankList(this.rank);

  @override
  _manSinglesRankListState createState() => _manSinglesRankListState();
}

class _manSinglesRankListState extends State<manSinglesRankList> {
  List<RankModel> RankModelList = [];

  Future<void> createRankList() async {
    RankModelList = await FirestoreMethod.getManSinglesRank(widget.rank);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF2FFE4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3CB371),
          title: Text('ランキング'),
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
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(color: const Color(0xFFEAFFE4),border: const Border(bottom: const BorderSide(color: Colors.grey,width: 1))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      Container(
                        child: Text("ランク",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            overflow: TextOverflow.ellipsis),
                      ),
                      Padding(padding: EdgeInsets.fromLTRB(50,0,0,0)),
                      Container(
                        width: 150,
                        child: Text("選手名",
                            style:
                                TextStyle(fontSize: 20)),
                      ),
                      Container(
                        width: 100,
                        child: Text("ポイント",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirestoreMethod.roomSnapshot,
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: createRankList(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return ListView.builder(
                              physics: RangeMaintainingScrollPhysics(),
                              shrinkWrap: true,
                              reverse: true,
                              itemCount: RankModelList.length,
                              itemBuilder: (context, index) {
                                return Card(
                                  color: const Color(0xFFF2FFE4),
                                  child: Container(
                                    height: 70,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(padding: EdgeInsets.all(10)),
                                        Container(
                                          child: Text(RankModelList[index].rankNo,
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  color: Colors.black),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        Padding(padding: EdgeInsets.fromLTRB(50,0,0,0)),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          child: RankModelList[index]
                                                      .user
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
                                                      RankModelList[index]
                                                          .user
                                                          .PROFILE_IMAGE),
                                                  radius: 30,
                                                ),
                                        ),
                                        Container(
                                          width: 150,
                                          child: Text(
                                              RankModelList[index].user.NICK_NAME,
                                              style: TextStyle(
                                                  fontSize: 25,color: Colors.teal
                                              )),
                                        ),
                                        Container(
                                          width: 100,
                                          child: Text(
                                              RankModelList[index]
                                                  .tpPoint
                                                  .toString(),
                                              style: TextStyle(
                                                  fontSize: 30,
                                                  color: Colors.black),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    );
                  }),
            ),
          ],
        ));
  }
}
