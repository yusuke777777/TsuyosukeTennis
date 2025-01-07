import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../PropSetCofig.dart';
import 'ProfileReference.dart';
import 'SignUpPromptPage.dart';
import 'TalkRoom.dart';

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

  //アカウントID入力値から対象の名前を取得
  late Future<List<String>> futureList =
      FirestoreMethod.getUserByMyUserId(inputId);

  Future<double> _calculateTextHeight(String text, TextStyle style) async {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 5,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width * 0.7);
    return textPainter.height;
  }



  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "検索結果");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Stack(
        children: [
          Container(alignment:Alignment.center,height: 40, child: AdBanner(size: AdSize.banner)),
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: FutureBuilder(
              future: futureList,
              builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Align(
                        child: Center(
                      child: CircularProgressIndicator(),
                    ));
                  } else if (snapshot.hasError) {
                    print('Error: ${snapshot.error!}');
                    return const Text("対象ユーザーは存在しません");
                  } else if (snapshot.hasData) {
                    //取得したい値をリスト型で格納
                    List<String>? profileList = snapshot.data;
                    //該当するユーザが存在しない時

                    if (profileList!.isEmpty) {
                      return ListView(
                          padding: const EdgeInsets.all(8),
                          children: const <Widget>[
                            ListTile(title: Text("対象ユーザーは存在しません")),
                          ]);
                    } else {
                      return InkWell(
                        onTap: () async {
                          if (auth.currentUser!.isAnonymous) {
                            // ユーザーがログインしていない場合
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPromptPage()),
                            );
                            return; // ここで処理を終了。これより下のコードは実行されない
                          }
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                      profileList[0] +
                                          'さんとトークしてみますか'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                                      child: const Text('はい'),
                                      onPressed: () async{
                                        //トーク画面へ遷移
                                        TalkRoomModel room = await FirestoreMethod.makeRoom(
                                            auth.currentUser!.uid,
                                            profileList[2]);
                                        Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TalkRoom(room),
                                            ));
                                        await NotificationMethod.unreadCountRest(
                                            profileList[2]);
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                                      child: const Text('いいえ'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Card(
                          color: Colors.white,
                            child: FutureBuilder(
                                future: _calculateTextHeight(profileList[3], TextStyle(fontSize: 12)),
                              builder: (context,snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator(); // テキストの高さ計算中にローディング表示
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                double textHeight = snapshot.data as double;
                                print(textHeight);
                                return Container(
                                  height: profileList[3] == '' ? 70 : textHeight + 55,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                        const EdgeInsets.symmetric(horizontal: 8.0),
                                        //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                        child: InkWell(
                                          child:
                                          profileList[1] == ''
                                              ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                                "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Ftenipoikun.png?alt=media&token=46474a8b-ca79-4232-92ee-431042c19d10"),
                                            radius: 30,
                                          )
                                              : CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(
                                                  profileList[1]
                                                      ),
                                              radius: 30),
                                          onTap: () {
                                            if (auth.currentUser!.isAnonymous) {
                                              // ユーザーがログインしていない場合
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => SignUpPromptPage()),
                                              );
                                              return; // ここで処理を終了。これより下のコードは実行されない
                                            }
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => ProfileReference(
                                                        profileList[2]
                                                           )));
                                          },
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: deviceWidth * 0.7,
                                            height: 30,
                                            child: Text(profileList[0],
                                                textAlign: TextAlign.start,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis, // テキストが指定領域を超えた場合の挙動を設定CO
                                                maxLines: 1,
                                                style: const TextStyle(
                                                    fontSize: 20, fontWeight: FontWeight.bold)
                                            ),
                                          ),
                                          Container(
                                            width: deviceWidth * 0.7,
                                            child: Text(profileList[3],
                                                textAlign: TextAlign.start,
                                                softWrap: true,
                                                overflow: TextOverflow.ellipsis, // テキストが指定領域を超えた場合の挙動を設定CO
                                                maxLines: (textHeight/12).floor()> 5 ? 5 :(textHeight/12).floor(),
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }
                            ),
                        ),
                      );
                    }
                  } else {
                    return const Text("データが存在しません");
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    // 使用しているリソースの解放
    super.dispose();
  }

}
