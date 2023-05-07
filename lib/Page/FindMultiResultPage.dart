import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class FindMultiResultPage extends StatefulWidget {
  FindMultiResultPage(this.todoufuken, this.shichoson, this.gender, this.rank,
      this.age);

  // 検索画面　
  String todoufuken;
  String shichoson;
  String gender;
  String rank;
  String age;

  @override
  State<FindMultiResultPage> createState() =>
      _FindMultiResultPageState(todoufuken, shichoson, gender, rank, age);
}

class _FindMultiResultPageState extends State<FindMultiResultPage> {
  _FindMultiResultPageState(this.todoufuken, this.shichoson, this.gender,
      this.rank, this.age);

  // 検索画面　アカウントIDの入力値
  String todoufuken;
  String shichoson;
  String gender;
  String rank;
  String age;

  //ログイン中のユーザーのIDを取得
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  String myUserID = auth.currentUser!.uid;

  //入力値から対象レコードリストを取得
  late Future<List<List<String>>> futureList = FirestoreMethod.getFindMultiResult(
      todoufuken, shichoson, gender, rank,age);

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "検索結果");
    DrawerConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon
      ),
      body: FutureBuilder(
        future: futureList,
        builder: (BuildContext context, AsyncSnapshot<List<List<String>>> snapshot) {
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
              List<List<String>>? profileList = snapshot.data;
              //該当するユーザが存在しない時
              if (profileList!.isEmpty) {
                return ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
                      ListTile(title: Text("対象ユーザーは存在しません")),
                    ]);
              } else {
                List<String> nameList = profileList[0];
                List<String> imageList = profileList[1];
                List<String> idList = profileList[2];
                return ListView.builder(
                  itemCount: nameList.length,
                  // padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    //共通リストタイルの呼出
                    ListTileConfig().init(context, nameList[index], imageList[index], idList[index], myUserID);
                    return Card(
                      elevation: 0,
                      child: ListTileConfig.listTile,
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
