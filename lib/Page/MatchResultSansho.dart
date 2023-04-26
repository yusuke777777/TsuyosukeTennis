import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/ProfileImage.dart';
import '../FireBase/TsMethod.dart';
import 'MatchList.dart';

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
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp(
          home: Scaffold(
              appBar: AppBar(
                  title: Text('対戦結果参照'),
                  backgroundColor: const Color(0xFF3CB371),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.reply,
                      color: Colors.black,
                      size: 40.0,
                    ),
                    onPressed: () => {Navigator.pop(context)},
                  )),
              body: Scrollbar(
                isAlwaysShown: false,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    SizedBox(
                    width: 80,
                  ),
                  Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.8,
                        height:MediaQuery.of(context).size.height * 0.1,
                        child: Text(widget.matchTitle,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                  ),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                            ),
                            Container(
                              child: Text(
                                widget.myProfile.NICK_NAME,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: 80,
                            ),
                            Container(
                              child: Text(
                                widget.yourProfile.NICK_NAME,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(8),
                            // ②配列のデータ数分カード表示を行う
                            itemCount: widget.matchResultList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
                                  SizedBox(
                                    width: 80,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                      ),
                                      Container(
                                        alignment: Alignment.center,
                                        padding: const EdgeInsets.all(5.0),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          '${widget.matchResultList[index].myGamePoint}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                      Container(
                                        width: 80,
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
                                        padding: const EdgeInsets.all(5.0),
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Text(
                                          '${widget.matchResultList[index].yourGamePoint}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 80,
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('感想・フィードバック', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              color: Colors.white,
                              width: 300,
                              height: 100,
                              child: Text(
                                widget.feedBackMessage ?? "",
                                maxLines: 20,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ]),
                ),
              )),
        ));
  }
}
