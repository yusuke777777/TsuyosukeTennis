import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tsuyosuke_tennis_ap/Common/CHomePageVal.dart';
import 'package:tsuyosuke_tennis_ap/Page/CheckFeedBack.dart';
import 'package:tsuyosuke_tennis_ap/Page/QrScanView.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'FriendManagerPage.dart';
import 'ProfileSetting.dart';
import 'package:marquee/marquee.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
    HeaderConfig().init(context, "ホーム");
    DrawerConfig().init(context);

    uid = FirestoreMethod.getUid();

    Future<CHomePageVal>? futureList =
        FirestoreMethod.getNickNameAndTorokuRank(uid);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.account_circle_sharp,
              color: Colors.black,
              size: 40.0,
            ),
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
        iconTheme: IconThemeData(color: Colors.black),
      ),
      //ドロアー画面の処理
      drawer: DrawerConfig.drawer,
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: futureList,
          builder:
              (BuildContext context, AsyncSnapshot<CHomePageVal> snapshot) {
            {
              if (snapshot.connectionState != ConnectionState.done) {
                return new Align(
                    child: Center(
                  child: new CircularProgressIndicator(),
                ));
              } else if (snapshot.hasError) {
                return new Text('Error!!: ${snapshot.error!}');
              } else if (snapshot.hasData) {
                //取得したい値をリスト型で格納
                CHomePageVal? homePageVal = snapshot.data;
                return Center(
                  //全体をカラムとして表示させる。
                  child: Column(children: <Widget>[
                    const SizedBox(
                      height: 30,
                    ),
                    Expanded(
                        flex: 0,
                        child: SizedBox(
                          height: 30,
                          child: Marquee(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            text: homePageVal!.TOUSERMESSAGE,
                            style: TextStyle(
                              backgroundColor: Colors.green[50],
                              color: Colors.white24,
                              shadows: [
                                Shadow(
                                  blurRadius: 1 /*影の大きさ*/,
                                ),
                              ],
                            ), //表示するテキスト
                            velocity: 20,
                          ),
                        )),

                    //profile画像
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            height: 120,
                          ),
                          ClipOval(
                            child: GestureDetector(
                              //アイコン押下時の挙動
                              child: homePageVal?.PROFILEIMAGE == ""
                                  ? Image.asset(
                                      'images/upper_body-2.png',
                                      height: 100,
                                      width: 100,
                                    )
                                  : Image.network(
                                      homePageVal!.PROFILEIMAGE,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                            // This trailing comma makes auto-formatting nicer for build methods.
                          )
                        ]),

                    //名前
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            homePageVal!.NAME,
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ]),

                    //ID
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 30,
                          ),
                          homePageVal.MYUSERID == null
                              ? Text(
                                  "ID is not difine",
                                  style: TextStyle(fontSize: 15),
                                )
                              : Text(
                                  "ID:" + homePageVal.MYUSERID,
                                  style: TextStyle(fontSize: 15),
                                ),
                        ]),

                    //登録ランクタイトル
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Text('登録ランク',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              )),
                          // This trailing comma makes auto-formatting nicer for build methods.
                        ]),

                    //登録ランク値
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(homePageVal.TOROKURANK,
                              style: TextStyle(fontSize: 20)),
                          // This trailing comma makes auto-formatting nicer for build methods.
                        ]),

                    //シングルスランキングタイトル
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Text('Sランキング',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              )),
                          // This trailing comma makes auto-formatting nicer for build methods.
                        ]),

                    //Sランキング値
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          homePageVal?.SRANK == null
                              ? Text('-位', style: TextStyle(fontSize: 20))
                              : Text(homePageVal.SRANK.toString() + '位',
                                  style: TextStyle(fontSize: 20)),
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

                    //勝率タイトル
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Text('勝率',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              )),
                        ]),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          homePageVal.ADVANCEDWINRATE == null
                              ? Text('上級: -', style: TextStyle(fontSize: 20))
                              : Text(
                                  '上級:' +
                                      homePageVal.ADVANCEDWINRATE.toString() +
                                      '%/',
                                  style: TextStyle(fontSize: 20)),
                          homePageVal.MEDIUMWINRATE == null
                              ? Text('中級: -', style: TextStyle(fontSize: 20))
                              : Text(
                                  '中級:' +
                                      homePageVal.MEDIUMWINRATE.toString() +
                                      '%/',
                                  style: TextStyle(fontSize: 20)),
                          homePageVal.BEGINWINRATE == null
                              ? Text('初級: -', style: TextStyle(fontSize: 20))
                              : Text(
                                  '初級:' +
                                      homePageVal.BEGINWINRATE.toString() +
                                      '%',
                                  style: TextStyle(fontSize: 20)),
                        ]),

                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const <Widget>[
                          SizedBox(
                            height: 20,
                          ),
                          Text('↓↓今すぐ試合をするならこちら！↓↓',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              )),
                        ]),
                    QrImage(
                      data: uid.toString(),
                      version: QrVersions.auto,
                      foregroundColor: Colors.green,
                      embeddedImage:
                          Image.network('https://illustimage.com/photo/463.png')
                              .image,
                      //QRコードの真ん中に表示する画像
                      size: 90.0,
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QrScanView(),
                                ));
                          },
                        ),
                      ],
                    ),

                    //レビュー集計機能
                    Column(
                      children: [
                        Text('------------------------',
                            style: TextStyle(fontSize: 20)),
                        Text('スキルレベル',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            )),
                        //ストローク
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ストローク', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('フォア：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating:
                                  homePageVal.SKILL.STROKE_FOREHAND.isNaN
                                      ? 0
                                      : homePageVal.SKILL.STROKE_FOREHAND,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('バック：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating:
                                  homePageVal.SKILL.STROKE_BACKHAND.isNaN
                                      ? 0
                                      : homePageVal.SKILL.STROKE_BACKHAND,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //ボレー
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('ボレー', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('フォア：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating:
                                  homePageVal.SKILL.VOLLEY_FOREHAND.isNaN
                                      ? 0
                                      : homePageVal.SKILL.VOLLEY_FOREHAND,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('バック：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating:
                                  homePageVal.SKILL.VOLLEY_BACKHAND.isNaN
                                      ? 0
                                      : homePageVal.SKILL.VOLLEY_BACKHAND,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        //サーブ
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('サーブ', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('１ｓｔ：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating: homePageVal.SKILL.SERVE_1ST.isNaN
                                  ? 0
                                  : homePageVal.SKILL.SERVE_1ST,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('２ｎｄ：', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              ignoreGestures: true,
                              allowHalfRating: true,
                              initialRating: homePageVal.SKILL.SERVE_2ND.isNaN
                                  ? 0
                                  : homePageVal.SKILL.SERVE_2ND,
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.yellow,
                              ),
                              onRatingUpdate: (rating) {
                                //評価が更新されたときの処理を書く
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 300,
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.lightGreenAccent,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(80)),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    'フィードバックを確認',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CheckFeedBack(),
                                      ));
                                }),
                          ),
                        ),
                      ],
                    ),
                  ]),
                );
              } else {
                return Text("データが存在しません");
              }
            }
          },
        ),
      ),
    );
  }
}
