import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../PropSetCofig.dart';

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
      FirestoreMethod.getUserByMyUserId(inputId);

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
              print('Error: ${snapshot.error!}');
              return new Text("対象ユーザーは存在しません");
            } else if (snapshot.hasData) {
              //取得したい値をリスト型で格納
              List<String>? profileList = snapshot.data;
              //該当するユーザが存在しない時
              if (profileList!.isEmpty) {
                return ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      ListTile(title: Text("対象ユーザーは存在しません")),
                    ]);
              } else {
                //共通リストタイルの呼出
                ListTileConfig().init(context, profileList![0], profileList![1], profileList[2], myUserID);
                return ListView.builder(
                  itemCount: 1,
                  // padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
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
