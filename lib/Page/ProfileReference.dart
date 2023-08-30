import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Common/CprofileDetail.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

/**
 * 他人のプロフィールを参照する用画面
 * 編集不可なのでテキストボックスとかもナシ
 */
class ProfileReference extends StatefulWidget {
  String user_id;

  //プロフィールを表示するためのidをもつ
  ProfileReference(this.user_id);

  @override
  _ProfileReferenceState createState() => _ProfileReferenceState(user_id);
}

class _ProfileReferenceState extends State<ProfileReference> {
  String user_id;

  _ProfileReferenceState(this.user_id);

  //対象ユーザのプロフィールをユーザIDをキーに取得
  late Future<CprofileDetail> yourProfileDetail =
      FirestoreMethod.getYourDetailProfile(user_id);

  double degreesToRadians(double degrees) {
    return degrees * (3.141592653589793238 / 180); // 度数からラジアンに変換
  }

  double startAngleRadians = 0;
  double startAngleDegrees = 0; // 0時を基準にした開始角度（度数）
  @override
  void initState() {
    super.initState();
    startAngleRadians = degreesToRadians(startAngleDegrees); // ラジアンに変換
    print(startAngleRadians);
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "プロフィール参照");
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: HeaderConfig.appBarText,
            elevation: 0.0,
            backgroundColor: Colors.white,
            leading: HeaderConfig.backIcon),
        body: FutureBuilder(
            future: yourProfileDetail,
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
                    isAlwaysShown: false,
                    child: SingleChildScrollView(
                        //プロフィール画像
                        child: Column(children: [
                      Container(
                          height: MediaQuery.of(context).size.height * 0.25,
                          child: Column(children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.only(left: 40, top: 20),
                                  alignment: Alignment.bottomCenter,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          profileDetailList.NICK_NAME,
                                          style: TextStyle(fontSize: 40),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.bottomLeft,
                                        child: Text(
                                          "   Age:" + profileDetailList.AGE,
                                          style: TextStyle(fontSize: 12),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "1",
                                              style: TextStyle(fontSize: 40),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.bottomLeft,
                                            child: Text(
                                              "TSP RANKING",
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  child: profileDetailList.PROFILE_IMAGE == ''
                                      ? CircleAvatar(
                                          backgroundColor: Colors.white,
                                          backgroundImage: NetworkImage(
                                              "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
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
                                padding: EdgeInsets.only(right: 30),
                                child: Text(
                                  'Category:' + profileDetailList.TOROKU_RANK,
                                  style: TextStyle(fontSize: 25),
                                )),
                          ])),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.12,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      '課金プレーヤー',
                                      style: TextStyle(fontSize: 25),
                                    )),
                                IconButton(
                                  icon: const Icon(
                                    Icons.read_more,
                                    color: Colors.black,
                                    size: 30.0,
                                  ),
                                  onPressed: () {
                                    //称号を表示する画面へ
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      '活動場所:' +
                                          profileDetailList
                                              .FIRST_TODOFUKEN_SICHOSON,
                                      style: TextStyle(fontSize: 15),
                                    )),
                                IconButton(
                                  icon: const Icon(
                                    Icons.read_more,
                                    color: Colors.black,
                                    size: 20.0,
                                  ),
                                  onPressed: () {
                                    //称号を表示する画面へ
                                  },
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                '勝率',
                                style: TextStyle(fontSize: 30),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.12,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.05),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text('初級'),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .SHOKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                                .SHOKYU_WIN_SU
                                                                .toString() +
                                                            '勝',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        profileDetailList
                                                                .SHOKYU_LOSE_SU
                                                                .toString() +
                                                            '敗',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
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
                                                    backgroundColor:
                                                        Colors.black12,
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
                                        padding: EdgeInsets.only(left: 20),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: Text('中級'),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .CHUKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                                .CHUKYU_WIN_SU
                                                                .toString() +
                                                            '勝',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        profileDetailList
                                                                .CHUKYU_LOSE_SU
                                                                .toString() +
                                                            '敗',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
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
                                                    backgroundColor:
                                                        Colors.black12,
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
                                        padding: EdgeInsets.only(left: 20),
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
                                        child: Text('上級'),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.25,
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
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .JYOKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                        '%',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                                .JYOKYU_WIN_SU
                                                                .toString() +
                                                            '勝',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        profileDetailList
                                                                .JYOKYU_LOSE_SU
                                                                .toString() +
                                                            '敗',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
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
                                                    backgroundColor:
                                                        Colors.black12,
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
                      Container(
                        height: MediaQuery.of(context).size.height * 0.43,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(
                          children: [
                            Container(
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                'ストローク',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('フォア',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.STROKE_FOREHAND_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      initialRating:
                                          profileDetailList.STROKE_FOREHAND_AVE,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('バック',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.STROKE_BACKHAND_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      initialRating:
                                          profileDetailList.STROKE_BACKHAND_AVE,
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
                              child: Text(
                                'ボレー',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('フォア',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.VOLLEY_FOREHAND_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      initialRating:
                                          profileDetailList.VOLLEY_FOREHAND_AVE,
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('バック',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.VOLLEY_BACKHAND_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
                                    RatingBar.builder(
                                      ignoreGestures: true,
                                      allowHalfRating: true,
                                      initialRating:
                                          profileDetailList.VOLLEY_BACKHAND_AVE,
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
                              child: Text(
                                'サーブ',
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('１st',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.SERVE_1ST_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 60,
                                        child: Text('２nd',
                                            style: TextStyle(fontSize: 17))),
                                    SizedBox(width: 20),
                                    Text(
                                        profileDetailList.SERVE_2ND_AVE
                                                .toString() +
                                            ' ',
                                        style: TextStyle(fontSize: 12)),
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
                      ),
                      Container(
                        height: MediaQuery.of(context).size.height * 0.3,
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: Column(children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'コメント',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Text(
                                  profileDetailList.COMENT,
                                  textAlign: TextAlign.start,
                                  softWrap: true,
                                  maxLines: 6,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ]),
                      )
                    ])));
              } else {
                return Text("データが存在しません");
              }
            }),
      ),
    );
  }
}
