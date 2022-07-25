import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import 'FindPage.dart';
import 'ProfileSetting.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? uid = '';

  void viewHomePage() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    uid = FirestoreMethod.getUid();
    Future<List<String>>? futureList =
        FirestoreMethod.getNickNameAndTorokuRank(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Home",
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
          ),
        ),
        leading: const Icon(
          Icons.menu,
          color: Colors.black,
        ),
        elevation: 0.0,
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_sharp,color: Colors.black,size: 40.0,),
            onPressed: () async {
              CprofileSetting myProfile = await FirestoreMethod.getProfile();
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileSetting.Edit(myProfile),
                ),
              );
            },
          )
        ],
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
              return Center(
                //全体をカラムとして表示させる。
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 100,
                            ),
                            Text('名前：' + profileList![0],
                                style: TextStyle(fontSize: 30)),
                            // This trailing comma makes auto-formatting nicer for build methods.
                            SizedBox(
                              width: 10,
                            ),
                            ClipOval(
                              child: Image.asset(
                                'images/ans_032.jpg',
                                width: 70,
                                height: 70,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ]),

                      //登録ランク表示
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            Text('登録ランク：' + profileList[1],
                                style: TextStyle(fontSize: 30)),
                            // This trailing comma makes auto-formatting nicer for build methods.
                          ]),
                      //シングルスランキング表示
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            SizedBox(
                              height: 30,
                            ),
                            Text('Sランキング:XX位', style: TextStyle(fontSize: 30)),
                            // This trailing comma makes auto-formatting nicer for build methods.
                          ]),

                      //TODO バージョンアップで対応
                      //ダブルスランキング表示
                      // Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                      //   SizedBox(
                      //     height: 50,
                      //   ),
                      //   Text('Dランキング:XX位', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                      // ]
                      // ),
                      // //ミックスランキング表示
                      // Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                      //   SizedBox(
                      //     height: 50,
                      //   ),
                      //   Text('Mランキング:XX位', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                      // ]
                      // ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const <Widget>[
                            SizedBox(
                              height: 50,
                            ),
                            Text('勝率：', style: TextStyle(fontSize: 30)),
                            Text('上級：', style: TextStyle(fontSize: 30))
                            // This trailing comma makes auto-formatting nicer for build methods.
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const <Widget>[
                            Text('　　　', style: TextStyle(fontSize: 30)),
                            Text('中級：', style: TextStyle(fontSize: 30))
                            // This trailing comma makes auto-formatting nicer for build methods.
                          ]),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: const <Widget>[
                            Text('　　　', style: TextStyle(fontSize: 30)),
                            Text('初級：', style: TextStyle(fontSize: 30))
                            // This trailing comma makes auto-formatting nicer for build methods.
                          ]),

                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const <Widget>[
                            SizedBox(
                              height: 80,
                            ),
                            Text('現在X連勝中', style: TextStyle(fontSize: 50))
                          ])
                    ]),
              );
            } else {
              return Text("データが存在しません");
            }
          }
        },
      ),
    );
  }
}
