import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../PropSetCofig.dart';

class MatchResultSansho extends StatefulWidget {
  late CprofileSetting myProfile;
  late CprofileSetting yourProfile;
  late List<CmatchResult> matchResultList;
  String? feedBackMessage;
  late CSkilLevelSetting SkillLevel;
  late String matchTitle;

  MatchResultSansho(this.myProfile, this.yourProfile, this.matchResultList,
      this.feedBackMessage, this.SkillLevel, this.matchTitle);

  @override
  _MatchResultSanshoState createState() => _MatchResultSanshoState();
}

class _MatchResultSanshoState extends State<MatchResultSansho> {
  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦結果参照");
    final deviceWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
              appBar: AppBar(
                backgroundColor: HeaderConfig.backGroundColor,
                title: HeaderConfig.appBarText,
                iconTheme: IconThemeData(color: Colors.black),
                leading: HeaderConfig.backIcon
              ),
              body: Scrollbar(
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 80,
                        ),
                        Center(
                          child: Container(
                            alignment: Alignment.center,
                            width: deviceWidth * 0.8,
                            height: 100,
                            child: Text(
                              widget.matchTitle,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              width: deviceWidth * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: deviceWidth * 0.3,
                                    child: widget.myProfile.PROFILE_IMAGE == ''
                                        ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                      radius: 30,
                                    )
                                        : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          widget.myProfile.PROFILE_IMAGE),
                                      radius: 30,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: deviceWidth * 0.3,
                                    child: FittedBox(
                                      alignment: Alignment.bottomCenter,
                                      fit:BoxFit.scaleDown,
                                      child: Text(
                                        widget.myProfile.NICK_NAME,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ) ,
                            Column(
                              children: widget.matchResultList
                                  .map((matchResult) => Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        width: deviceWidth * 0.12,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Colors.grey),
                                        ),
                                          child: Text(
                                            '${matchResult.myGamePoint}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                      ),
                                      Container(
                                        width: deviceWidth * 0.1,
                                        child: Center(
                                          child: Text(
                                            "-",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        width: deviceWidth * 0.12,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border:
                                          Border.all(color: Colors.grey),
                                        ),
                                          child: Text(
                                            '${matchResult.yourGamePoint}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                      ),
                                    ],
                                  ),
                                ],
                              )).toList(),
                            ),
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              width: deviceWidth * 0.3,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    width: deviceWidth * 0.3,
                                    child: widget.yourProfile.PROFILE_IMAGE == ''
                                        ? CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                      radius: 30,
                                    )
                                        : CircleAvatar(
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(
                                          widget.yourProfile.PROFILE_IMAGE),
                                      radius: 30,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    width: deviceWidth * 0.3,
                                    child: FittedBox(
                                      alignment: Alignment.bottomCenter,
                                      fit:BoxFit.scaleDown,
                                      child: Text(
                                        widget.yourProfile.NICK_NAME,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        //レビュー集計機能
                        Column(
                          children: [
                            Text('------------------------',
                                style: TextStyle(fontSize: 20)),
                            const SizedBox(
                              height: 20,
                            ),
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
                                      widget.SkillLevel.STROKE_FOREHAND.isNaN
                                          ? 0
                                          : widget.SkillLevel.STROKE_FOREHAND,
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
                                      widget.SkillLevel.STROKE_BACKHAND.isNaN
                                          ? 0
                                          : widget.SkillLevel.STROKE_BACKHAND,
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
                                      widget.SkillLevel.VOLLEY_FOREHAND.isNaN
                                          ? 0
                                          : widget.SkillLevel.VOLLEY_FOREHAND,
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
                                      widget.SkillLevel.VOLLEY_BACKHAND.isNaN
                                          ? 0
                                          : widget.SkillLevel.VOLLEY_BACKHAND,
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
                                  initialRating:
                                      widget.SkillLevel.SERVE_1ST.isNaN
                                          ? 0
                                          : widget.SkillLevel.SERVE_1ST,
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
                                  initialRating:
                                      widget.SkillLevel.SERVE_2ND.isNaN
                                          ? 0
                                          : widget.SkillLevel.SERVE_2ND,
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
                        Container(
                          alignment: Alignment.center,
                          child:
                            Text('感想・フィードバック', style: TextStyle(fontSize: 20)),
                        ),
                            Container(
                              alignment: Alignment.topLeft,
                              color: Colors.white,
                              width: deviceWidth * 0.8,
                              height: 100,
                              child: SingleChildScrollView(
                                child: Text(
                                  widget.feedBackMessage ?? "",
                                  textAlign:
                                  TextAlign.start,
                                  softWrap: true,
                                ),
                              ),
                            ),
                        const SizedBox(
                          height: 20,
                        ),
                      ]),
                ),
              )),
        );
  }
}
