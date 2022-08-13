import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'TalkRoom.dart';

class TalkList extends StatefulWidget {
  const TalkList({Key? key}) : super(key: key);
  @override
  _TalkListState createState() => _TalkListState();
}

class _TalkListState extends State<TalkList> {
  List<TalkRoomModel> talkList = [];

  Future<void> createRooms() async{
    talkList = await FirestoreMethod.getRooms(FirestoreMethod.auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFF2FFE4),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3CB371),
          title: Text('トーク履歴'),
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
            stream: FirestoreMethod.roomSnapshot,
            builder: (context, snapshot) {
              return FutureBuilder(
                future: createRooms(),
                builder:(context,snapshot){
                  if(snapshot.connectionState == ConnectionState.done){
                    return  ListView.builder(
                        itemCount: talkList.length,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TalkRoom(talkList[index])));
                            },
                            child: Container(
                              height: 70,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: talkList[index].user.PROFILE_IMAGE == '' ? CircleAvatar(backgroundColor:Colors.white,backgroundImage: NetworkImage("https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),radius: 30,): CircleAvatar(backgroundColor:Colors.white,backgroundImage: NetworkImage(talkList[index].user.PROFILE_IMAGE),
                                      radius: 30,),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(talkList[index].user.NICK_NAME,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold)),
                                      Text(talkList[index].lastMessage,style: TextStyle(color: Colors.grey),overflow: TextOverflow.ellipsis)
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

