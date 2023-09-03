import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Common/CSinglesRankModel.dart';
import '../FireBase/FireBase.dart';
import 'package:intl/intl.dart';
import 'ProfileReference.dart';
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
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF3CB371),
        //   title: Text('ランキング'),
        // ),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                  height: 40,
                  decoration: BoxDecoration(color: Colors.white,border: const Border(bottom: const BorderSide(color: Colors.grey,width: 1))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(10)),
                      Container(
                        width: 60,
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
                  stream: FirestoreMethod.manRankSnapshot,
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
                                  color: Colors.white,
                                  child: Container(
                                    height: 70,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Padding(padding: EdgeInsets.all(10)),
                                        Container(
                                          width: 20 ,
                                          child: FittedBox(
                                            alignment:Alignment.bottomCenter,
                                            fit: BoxFit.scaleDown,
                                            child: Text(RankModelList[index].rankNo.toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ),
                                        Padding(padding: EdgeInsets.fromLTRB(50,0,0,0)),
                                        InkWell(
                                          child: Padding(
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
                                                    radius: 20,
                                                  )
                                                : CircleAvatar(
                                                    backgroundColor: Colors.white,
                                                    backgroundImage: NetworkImage(
                                                        RankModelList[index]
                                                            .user
                                                            .PROFILE_IMAGE),
                                                    radius: 20,
                                                  ),
                                          ),
                                          onTap:(){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileReference(
                                                            RankModelList[index].user.USER_ID)));
                                          },
                                        ),
                                        Container(
                                          width: 180,
                                          child: FittedBox(
                                            alignment:Alignment.bottomLeft,
                                            fit: BoxFit.scaleDown, // 子ウィジェットを親ウィジェットにフィットさせる
                                            child: Text(
                                                RankModelList[index].user.NICK_NAME,
                                                style: TextStyle(
                                                    fontSize: 15,color: Colors.teal
                                                )),
                                          ),
                                        ),
                                        Container(
                                          width: 50,
                                          child: FittedBox(
                                            alignment:Alignment.bottomRight,
                                            fit: BoxFit.scaleDown, // 子ウィジェットを親ウィジェットにフィットさせる
                                            child: Text(
                                              NumberFormat('#,###').format(RankModelList[index]
                                                    .tpPoint)
                                                    .toString(),
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                                overflow: TextOverflow.ellipsis),
                                          ),
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
