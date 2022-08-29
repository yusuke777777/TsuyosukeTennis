import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Common/CmatchList.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'TalkRoom.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);
  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  List<MatchListModel> matchList = [];

  Future<void> createMatchList() async{
    matchList = await FirestoreMethod.getMatchList(FirestoreMethod.auth.currentUser!.uid);
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
        body:
        StreamBuilder<QuerySnapshot>(
            stream: FirestoreMethod.matchListSnapshot,
            builder: (context, snapshot) {
              return FutureBuilder(
                future: createMatchList(),
                builder:(context,snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    return  ListView.builder(
                        itemCount: matchList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              //対戦結果入力画面へ遷移させる
                            },
                            child: Container(
                              height: 70,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: matchList[index].user.PROFILE_IMAGE == '' ? CircleAvatar(backgroundColor:Colors.white,backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),radius: 30,): CircleAvatar(backgroundColor:Colors.white,backgroundImage: NetworkImage(matchList[index].user.PROFILE_IMAGE),
                                      radius: 30,),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(matchList[index].user.NICK_NAME,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                      Text(matchList[index].SAKUSEI_YMD,style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis)
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        });
                  }else{
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            }
        ));
  }
}

