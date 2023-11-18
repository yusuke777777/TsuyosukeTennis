import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../Common/CprofileDetail.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    HeaderConfig().init(context, "プロフィール参照");
    return Scaffold(
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
                              height: 230,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('images/kori.jpg'),
                                ),
                              ),
                              child: Column(children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(left: 40, top: 20),
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
                                                style: TextStyle(fontSize: 40),
                                              ),
                                            ),
                                          ),
                                          profileDetailList.RANK_NO == 0 ?
                                          Row(
                                            children: [
                                              Container(
                                                width: deviceWidth * 0.1,
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  "NO ",
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              Container(
                                                width: deviceWidth * 0.32,
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  "TSP RANKING",
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                            ],
                                          )
                                              :profileDetailList.RANK_NO < 100 ? Column(
                                                children: [
                                                  Row(
                                            children: [
                                                  Container(
                                                    width: deviceWidth * 0.12,
                                                    alignment: Alignment.bottomCenter,
                                                    child: FittedBox(
                                                      alignment:Alignment.bottomLeft,
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        NumberFormat('#,###').format(profileDetailList.RANK_NO).toString(),
                                                        style: TextStyle(fontSize: 40),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    width: deviceWidth * 0.32,
                                                    alignment: Alignment.bottomLeft,
                                                    child: FittedBox(
                                                      alignment:Alignment.bottomLeft,
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        "TSP RANKING",
                                                        style: TextStyle(fontSize: 30),
                                                      ),
                                                    ),
                                                  ),
                                            ],
                                          ),
                                                      Container(
                                                        width: deviceWidth * 0.44,
                                                        alignment: Alignment.bottomRight,
                                                        child: FittedBox(
                                                          alignment:Alignment.bottomRight,
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            "(Total:" + NumberFormat('#,###').format(profileDetailList.TS_POINT).toString() + " p)",
                                                            style: TextStyle(fontSize: 15),
                                                          ),
                                                        ),
                                                      ),
                                                ],
                                              ):
                                          Row(
                                            children: [
                                              Container(
                                                width: deviceWidth * 0.15,
                                                alignment: Alignment.bottomCenter,
                                                child: FittedBox(
                                                  alignment:Alignment.bottomLeft,
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    NumberFormat('#,###').format(profileDetailList.RANK_NO).toString(),
                                                    style: TextStyle(fontSize: 40),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: deviceWidth * 0.25,
                                                alignment: Alignment.bottomLeft,
                                                child: FittedBox(
                                                  alignment:Alignment.bottomLeft,
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    "TSP RANKING",
                                                    style: TextStyle(fontSize: 30),
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
                                    padding: EdgeInsets.only(right: 23),
                                    child: Text(
                                      'Category:' + profileDetailList.TOROKU_RANK,
                                      style: TextStyle(fontSize: 25),
                                    )),
                              ])),
                      Container(
                        height: 120,
                        width: deviceWidth * 0.8,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                    alignment: Alignment.bottomLeft,
                                    child: Text(
                                      profileDetailList.TITLE == ''? '称号設定なし':
                                      profileDetailList.TITLE,
                                      style: TextStyle(fontSize: 20),
                                    )),
                              ],
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
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Container(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                "性別：" + profileDetailList.GENDER,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                            '活動場所：' +
                                                profileDetailList
                                                    .FIRST_TODOFUKEN_SICHOSON,
                                            style: TextStyle(fontSize: 15),
                                            overflow: TextOverflow.ellipsis, // テキストが指定領域を超えた場合の挙動を設定
                                            maxLines: 2, // 表示する行数を指定
                                          ),
                                        ),
                                      ],
                                    )),
                          ],
                        ),
                      ),
                      Container(
                        height: 180,
                        width: deviceWidth * 0.8,
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
                              height: 100,
                              width: deviceWidth * 0.8,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                      width: deviceWidth *
                                          0.05),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: deviceWidth *
                                            0.25,
                                        padding: EdgeInsets.only(left: 20),
                                        child: Text('初級'),
                                      ),
                                      SizedBox(
                                        width: deviceWidth *
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
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .SHOKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      Text(
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
                                                            .format(profileDetailList
                                                            .SHOKYU_WIN_SU)
                                                            .toString() +
                                                            '勝 ' +  NumberFormat('#,###')
                                                            .format(profileDetailList
                                                            .SHOKYU_LOSE_SU)
                                                            .toString() +
                                                            '敗',
                                                        style: TextStyle(
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
                                        width: deviceWidth *
                                            0.25,
                                        child: Text('中級'),
                                      ),
                                      SizedBox(
                                        width: deviceWidth *
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
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .CHUKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      Text(
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
                                                            .format(profileDetailList
                                                            .CHUKYU_WIN_SU)
                                                            .toString() +
                                                            '勝 ' +  NumberFormat('#,###')
                                                            .format(profileDetailList
                                                            .CHUKYU_LOSE_SU)
                                                            .toString() +
                                                            '敗',
                                                        style: TextStyle(
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
                                        width: deviceWidth *
                                            0.25,
                                        child: Text('上級'),
                                      ),
                                      SizedBox(
                                        width: deviceWidth *
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
                                                    MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        profileDetailList
                                                            .JYOKYU_WIN_RATE
                                                            .toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                            FontWeight.bold),
                                                      ),
                                                      Text(
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
                                                            .format(profileDetailList
                                                            .JYOKYU_WIN_SU)
                                                            .toString() +
                                                            '勝 '
                                                            +  NumberFormat('#,###')
                                                            .format(profileDetailList
                                                            .JYOKYU_LOSE_SU)
                                                            .toString() +
                                                            '敗',
                                                        style: TextStyle(
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
                          profileDetailList.REVIEW_ENABLED == true ? Container(
                            height: 380,
                            width: deviceWidth * 0.8,
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
                                    style: TextStyle(fontSize: 25,),
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
                          ) : Container(),
                      Container(
                        height: 250,
                        width: deviceWidth * 0.8,
                        child: Column(children: [
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              'コメント',
                              style: TextStyle(fontSize: 30),
                            ),
                          ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                width: deviceWidth * 0.8,
                                height: MediaQuery.of(context).size.height * 0.2,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: SingleChildScrollView(
                                  child: Text(
                                    profileDetailList.COMENT,
                                    textAlign: TextAlign.start,
                                    softWrap: true,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                      )
                    ])));
              } else {
                return Text("データが存在しません");
              }
            }),
      );
  }
}
