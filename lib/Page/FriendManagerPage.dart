import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../FireBase/FireBase.dart';
import '../UnderMenuMove.dart';

/**
 * 友人管理画面です
 */
class FriendManagerPage extends StatefulWidget {
  const FriendManagerPage({Key? key}) : super(key: key);

  @override
  State<FriendManagerPage> createState() => _FriendManagerPageState();
}

class _FriendManagerPageState extends State<FriendManagerPage> {
  //TODO 仮実装です　友人一覧データを取得する予定
  late Future<List<String>> futureList =
      FirestoreMethod.getNickNameAndTorokuRank('1HwhZ3H1lNW4QkcfLQHJFVlA40j1');

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
              if (profileList == null) {
                return ListView(
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
                      ListTile(title: Text("対象ユーザーは存在しません")),
                    ]);
              } else {
                return Slidable(
                  endActionPane: ActionPane(
                    motion: DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (value) {},
                        backgroundColor: Colors.blue,
                        icon: Icons.share,
                        label: 'シェア',
                      ),
                      SlidableAction(
                        onPressed: (value) {},
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: '削除',
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    itemCount: 1,
                    // padding: const EdgeInsets.all(8),
                    itemBuilder: (BuildContext context, int index) {
                      return Card(
                        child: ListTile(
                          leading: ClipOval(
                            child: Image.asset(
                              'images/ans_032.jpg',
                              width: 70,
                              height: 70,
                              fit: BoxFit.fill,
                            ),
                          ),
                          title: Text(profileList[0],
                              style: TextStyle(fontSize: 30)),
                          onTap: () {
                            Navigator.push(
                                context,
                                //TODO 仮実装で検索画面へ遷移させている
                                MaterialPageRoute(
                                  builder: (context) => UnderMenuMove(),
                                ));
                          },
                        ),
                      );
                    },
                  ),
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
