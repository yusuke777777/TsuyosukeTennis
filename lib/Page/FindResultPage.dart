import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import 'package:tsuyosuke_tennis_ap/Page/FindPage.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import 'package:tsuyosuke_tennis_ap/Page/TalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

class FindResultPage extends StatefulWidget {
  FindResultPage(this.inputId);

  // 検索画面　アカウントIDの入力値
  String inputId;

  @override
  State<FindResultPage> createState() => _FindResultPageState(inputId);
}

class _FindResultPageState extends State<FindResultPage> {
  _FindResultPageState(this.inputId);

  // 検索画面　アカウントIDの入力値
  String inputId;

  //ログイン中のユーザーのIDを取得
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  String myUserID = auth.currentUser!.uid;


  //アカウントID入力値から対象の名前を取得
  late Future<List<String>> futureList =
      FirestoreMethod.getNickNameAndProfile(inputId);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("検索結果"),
      ),
      body: FutureBuilder(
        future: futureList,
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          {
            if (snapshot.connectionState != ConnectionState.done) {
              return new Align(
                  child: Center(
                child: new CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error!}');
            } else if (snapshot.hasData) {
              //取得したい値をリスト型で格納
              List<String>? profileList = snapshot.data;
              //該当するユーザが存在しない時
              if (profileList!.isEmpty) {
                return ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
                      ListTile(title: Text("対象ユーザーは存在しません")),
                    ]);
              } else {
                return ListView.builder(
                  itemCount: 1,
                  // padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      child: ListTile(
                        leading: ClipOval(
                          child: GestureDetector(
                            //アイコン押下時の挙動
                            onTap: () {
                              Navigator.push(
                                  context,
                                  //TODO 仮実装で検索画面へ遷移させている
                                  MaterialPageRoute(
                                    builder: (context) => ProfileReference(inputId),
                                  ));
                            },
                            child: profileList[1] == ""
                                ? Image.asset('images/upper_body-2.png',
                                    fit: BoxFit.cover)
                                : Image.network(
                                    profileList[1],
                                    width: 70,
                                    height: 70,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        title: Text(profileList[0],
                            style: TextStyle(fontSize: 30)),
                        //リスト押下時の挙動
                        onTap: () async {
                          TalkRoomModel room = await FirestoreMethod.makeRoom(myUserID, inputId);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TalkRoom(room),
                              ));
                        },
                      ),
                    );
                  },
                );
              }
            } else {
              return Text("データが存在しません");
            }
          }
        },
      ),
    );
  }
}
