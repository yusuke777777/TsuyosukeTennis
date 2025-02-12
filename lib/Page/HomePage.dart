import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Common/CHomePageVal.dart';
import 'package:tsuyosuke_tennis_ap/Page/CheckFeedBack.dart';
import 'package:tsuyosuke_tennis_ap/Page/MyTitlePage.dart';
import 'package:tsuyosuke_tennis_ap/Page/QrScanView.dart';
import '../Common/CprofileDetail.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../PropSetCofig.dart';
import 'FriendManagerPage.dart';
import 'ProfileSetting.dart';

// import 'package:marquee/marquee.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  late Future<CprofileDetail> myProfileDetail;

  @override
  void initState() {
    super.initState();
    myProfileDetail = FirestoreMethod.getMyDetailProfile(auth.currentUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "ホーム");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;

    return PopScope(
      canPop: false,
      child: Scaffold(
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
                Navigator.push(
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
        body: FutureBuilder(
            future: myProfileDetail,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return new Align(
                    child: Center(
                  child: new CircularProgressIndicator(),
                ));
              } else if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error!}');
              } else if (snapshot.hasData) {
                CprofileDetail profileDetailList = snapshot.data;
                return Scrollbar(
                    child: SingleChildScrollView(
                        //プロフィール画像
                        child: Column(children: [
                  Container(
                      alignment: Alignment.center,
                      height: 40,
                      child: AdBanner(size: AdSize.banner)),
                  Container(
                      height: 230,
                      width: deviceWidth,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('images/kori.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(left: 40, top: 20),
                              alignment: Alignment.bottomCenter,
                              width: deviceWidth * 0.55,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: deviceWidth * 0.5,
                                    alignment: Alignment.bottomLeft,
                                    child: FittedBox(
                                      alignment: Alignment.bottomLeft,
                                      fit: BoxFit.scaleDown,
                                      // 子ウィジェットを親ウィジェットにフィットさせる
                                      child: Text(
                                        profileDetailList.NICK_NAME,
                                        style: const TextStyle(fontSize: 40),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: deviceWidth * 0.5,
                                    alignment: Alignment.bottomLeft,
                                    child:
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Row(
                                            children: [
                                              Text(
                                                "   ID: " +
                                                    profileDetailList.MY_USER_ID
                                                        .toString(),
                                                style:
                                                    const TextStyle(fontSize: 15),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.copy,
                                                  color: Colors.black,
                                                  size: 20.0,
                                                ),
                                                onPressed: () {
                                                  String uid = profileDetailList
                                                      .USER_ID.toString();
                                                  final String profileUrl = 'https://tsuyosuketeniss.web.app/profile?uid=$uid';

                                                  Clipboard.setData(ClipboardData(
                                                      text: profileUrl));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                        content: Text(
                                                            'プロフィールURLがコピーされました！')),
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                                  profileDetailList.RANK_NO == 0 ||
                                          (profileDetailList.RANK_TOROKU_RANK !=
                                              profileDetailList.TOROKU_RANK)
                                      ? Row(
                                          children: [
                                            Container(
                                              width: deviceWidth * 0.1,
                                              alignment: Alignment.bottomLeft,
                                              child: const Text(
                                                "NO ",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Container(
                                              width: deviceWidth * 0.32,
                                              alignment: Alignment.bottomLeft,
                                              child: const Text(
                                                "TSP RANKING",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                          ],
                                        )
                                      : profileDetailList.RANK_NO < 100
                                          ? Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: deviceWidth * 0.12,
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: FittedBox(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          NumberFormat('#,###')
                                                              .format(
                                                                  profileDetailList
                                                                      .RANK_NO)
                                                              .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 40),
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: deviceWidth * 0.32,
                                                      alignment:
                                                          Alignment.bottomLeft,
                                                      child: const FittedBox(
                                                        alignment: Alignment
                                                            .bottomLeft,
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          "TSP RANKING",
                                                          style: TextStyle(
                                                              fontSize: 30),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Container(
                                                  width: deviceWidth * 0.44,
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      "(Total:" +
                                                          NumberFormat('#,###')
                                                              .format(
                                                                  profileDetailList
                                                                      .TS_POINT)
                                                              .toString() +
                                                          " p)",
                                                      style: const TextStyle(
                                                          fontSize: 15),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Row(
                                              children: [
                                                Container(
                                                  width: deviceWidth * 0.15,
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: FittedBox(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      NumberFormat('#,###')
                                                          .format(
                                                              profileDetailList
                                                                  .RANK_NO)
                                                          .toString(),
                                                      style: const TextStyle(
                                                          fontSize: 40),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: deviceWidth * 0.25,
                                                  alignment:
                                                      Alignment.bottomLeft,
                                                  child: const FittedBox(
                                                    alignment:
                                                        Alignment.bottomLeft,
                                                    fit: BoxFit.scaleDown,
                                                    child: Text(
                                                      "TSP RANKING",
                                                      style: TextStyle(
                                                          fontSize: 30),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                ],
                              ),
                            ),
                            Container(
                              width: deviceWidth * 0.4,
                              child: profileDetailList.PROFILE_IMAGE == ''
                                  ? const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage:
                                          AssetImage("images/tenipoikun.png"),
                                      radius: 80,
                                    )
                                  : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          profileDetailList.PROFILE_IMAGE),
                                      radius: 80,
                                    ),
                            ),
                          ],
                        ),
                        Container(
                            alignment: Alignment.bottomRight,
                            padding: const EdgeInsets.only(right: 23),
                            child: Text(
                              'Category:' + profileDetailList.TOROKU_RANK,
                              style: const TextStyle(fontSize: 25),
                            )),
                      ])),
                  //称号と称号ボタンのコンテナ
                  Container(
                    alignment: Alignment.bottomLeft,
                    width: deviceWidth * 0.8,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child:
                          //Column(
                          //children: [
                          Row(
                        children: [
                          Container(
                              //fit: BoxFit.scaleDown,
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                profileDetailList.TITLE == ''
                                    ? '称号設定なし'
                                    : profileDetailList.TITLE,
                                style: const TextStyle(fontSize: 20),
                              )),
                          Container(
                            //fit: BoxFit.scaleDown,
                            alignment: Alignment.bottomLeft,
                            //width: deviceWidth * 0.8,
                            child: IconButton(
                              alignment: Alignment.bottomRight,
                              icon: const Icon(
                                Icons.read_more,
                                color: Colors.black,
                                size: 30.0,
                              ),
                              onPressed: () {
                                //称号を表示する画面へ
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyTitlePage(),
                                    ));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      alignment: Alignment.bottomLeft,
                      width: deviceWidth * 0.8,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "年齢：" + profileDetailList.AGE,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  "性別：" + profileDetailList.GENDER,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              '活動場所：' +
                                  profileDetailList.FIRST_TODOFUKEN_SICHOSON,
                              style: const TextStyle(fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                              // テキストが指定領域を超えた場合の挙動を設定
                              maxLines: 2, // 表示する行数を指定
                            ),
                          ),
                        ],
                      )),
                  Container(
                    height: 180,
                    width: deviceWidth * 0.8,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomLeft,
                          child: const Text(
                            '勝率',
                            style: TextStyle(fontSize: 30),
                          ),
                        ),
                        Container(
                          height: 100,
                          width: deviceWidth * 0.8,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(width: deviceWidth * 0.05),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: deviceWidth * 0.25,
                                    padding: const EdgeInsets.only(left: 20),
                                    child: const Text('初級'),
                                  ),
                                  SizedBox(
                                    width: deviceWidth * 0.25,
                                    child: Stack(children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profileDetailList
                                                        .SHOKYU_WIN_RATE
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Text(
                                                    '%',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: 70,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    NumberFormat('#,###')
                                                            .format(
                                                                profileDetailList
                                                                    .SHOKYU_WIN_SU)
                                                            .toString() +
                                                        '勝 ' +
                                                        NumberFormat('#,###')
                                                            .format(profileDetailList
                                                                .SHOKYU_LOSE_SU)
                                                            .toString() +
                                                        '敗',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: CircularProgressIndicator(
                                                value: profileDetailList
                                                        .SHOKYU_WIN_RATE /
                                                    100,
                                                color: Colors.greenAccent,
                                                backgroundColor: Colors.black12,
                                                strokeWidth: 4.0),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    width: deviceWidth * 0.25,
                                    child: const Text('中級'),
                                  ),
                                  SizedBox(
                                    width: deviceWidth * 0.25,
                                    child: Stack(children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profileDetailList
                                                        .CHUKYU_WIN_RATE
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Text(
                                                    '%',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: 70,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    NumberFormat('#,###')
                                                            .format(
                                                                profileDetailList
                                                                    .CHUKYU_WIN_SU)
                                                            .toString() +
                                                        '勝 ' +
                                                        NumberFormat('#,###')
                                                            .format(profileDetailList
                                                                .CHUKYU_LOSE_SU)
                                                            .toString() +
                                                        '敗',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: CircularProgressIndicator(
                                                value: profileDetailList
                                                        .CHUKYU_WIN_RATE /
                                                    100,
                                                color: Colors.greenAccent,
                                                backgroundColor: Colors.black12,
                                                strokeWidth: 4.0),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(left: 20),
                                    width: deviceWidth * 0.25,
                                    child: const Text('上級'),
                                  ),
                                  SizedBox(
                                    width: deviceWidth * 0.25,
                                    child: Stack(children: [
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profileDetailList
                                                        .JYOKYU_WIN_RATE
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  const Text(
                                                    '%',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: 70,
                                                child: FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    NumberFormat('#,###')
                                                            .format(
                                                                profileDetailList
                                                                    .JYOKYU_WIN_SU)
                                                            .toString() +
                                                        '勝 ' +
                                                        NumberFormat('#,###')
                                                            .format(profileDetailList
                                                                .JYOKYU_LOSE_SU)
                                                            .toString() +
                                                        '敗',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 70,
                                        height: 70,
                                        child: Center(
                                          child: SizedBox(
                                            width: 70,
                                            height: 70,
                                            child: CircularProgressIndicator(
                                                value: profileDetailList
                                                        .JYOKYU_WIN_RATE /
                                                    100,
                                                color: Colors.greenAccent,
                                                backgroundColor: Colors.black12,
                                                strokeWidth: 4.0),
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  profileDetailList.REVIEW_ENABLED == true
                      ? Container(
                          height: 380,
                          width: deviceWidth * 0.8,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: const Text(
                                  'ストローク',
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('フォア',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.STROKE_FOREHAND_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating: profileDetailList
                                            .STROKE_FOREHAND_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('バック',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.STROKE_BACKHAND_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating: profileDetailList
                                            .STROKE_BACKHAND_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: const Text(
                                  'ボレー',
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('フォア',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.VOLLEY_FOREHAND_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating: profileDetailList
                                            .VOLLEY_FOREHAND_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('バック',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.VOLLEY_BACKHAND_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating: profileDetailList
                                            .VOLLEY_BACKHAND_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: const Text(
                                  'サーブ',
                                  style: TextStyle(
                                    fontSize: 25,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('１st',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.SERVE_1ST_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating:
                                            profileDetailList.SERVE_1ST_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          width: 60,
                                          child: const Text('２nd',
                                              style: TextStyle(fontSize: 17))),
                                      const SizedBox(width: 20),
                                      Text(
                                          profileDetailList.SERVE_2ND_AVE
                                                  .toString() +
                                              ' ',
                                          style: const TextStyle(fontSize: 12)),
                                      RatingBar.builder(
                                        ignoreGestures: true,
                                        allowHalfRating: true,
                                        initialRating:
                                            profileDetailList.SERVE_2ND_AVE,
                                        itemBuilder: (context, index) =>
                                            const Icon(
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
                            ],
                          ),
                        )
                      : Container(),
                  profileDetailList.REVIEW_ENABLED == true
                      ? Container(
                          height: 130,
                          width: deviceWidth * 0.8,
                          child: Column(
                            children: [
                              Container(
                                width: deviceWidth * 0.8,
                                child: const FittedBox(
                                  alignment: Alignment.bottomLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text('-----------------------------',
                                      style: TextStyle(
                                          fontSize: 30, color: Colors.black26)),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  const Icon(Icons.feed,
                                      color: Colors.black38, size: 80),
                                  Container(
                                    width: deviceWidth * 0.5,
                                    alignment: Alignment.center,
                                    child: TextButton(
                                        child: const FittedBox(
                                          alignment: Alignment.bottomLeft,
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            '過去の対戦相手の\nフィードバックを確認',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const CheckFeedBack(),
                                              ));
                                        }),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Container(
                    height: 220,
                    width: deviceWidth * 0.8,
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.bottomCenter,
                          child: const FittedBox(
                            alignment: Alignment.bottomLeft,
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '↓↓今すぐ試合をするならこちら！↓↓',
                              style: TextStyle(fontSize: 17),
                            ),
                          ),
                        ),
                        QrImageView(
                          data: auth.currentUser!.uid,
                          version: QrVersions.auto,
                          foregroundColor: Colors.green,
                          embeddedImage: Image.network(
                                  'https://illustimage.com/photo/463.png')
                              .image,
                          embeddedImageStyle: QrEmbeddedImageStyle(
                            size: Size(20, 20),
                          ),
                          errorCorrectionLevel: QrErrorCorrectLevel.H,
                          // 誤り訂正レベルを最大に
                          //QRコードの真ん中に表示する画像
                          size: 120.0,
                        ),
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const QrScanView(),
                                ));
                          },
                        ),
                      ],
                    ),
                  )
                ])));
              } else {
                return const Text("データが存在しません");
              }
            }),
      ),
    );
  }

  @override
  void dispose() {
    // 必要なリソースを解放する処理をここに追加
    super.dispose();
  }
}
