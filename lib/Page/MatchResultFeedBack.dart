import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

class MatchResultFeedBack extends StatefulWidget {
  late CprofileSetting myProfile;
  late CprofileSetting yourProfile;
  late List<CmatchResult> matchResultList;
  late String matchTitle;
  late String dayKey;
  late TalkRoomModel room;
  late String messageId;

  MatchResultFeedBack(
      this.myProfile, this.yourProfile, this.matchResultList, this.matchTitle,this.dayKey,this.messageId,this.room);

  @override
  _MatchResultFeedBackState createState() => _MatchResultFeedBackState();
}

class _MatchResultFeedBackState extends State<MatchResultFeedBack> {
  //評価数を格納
  late String opponent_id;
  double stroke_fore = 0;
  double stroke_back = 0;
  double volley_fore = 0;
  double volley_back = 0;
  double serve_1st = 0;
  double serve_2nd = 0;

  //フィードバックBOXに入力された値
  final inputWord = TextEditingController();

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦結果参照");
    opponent_id = widget.yourProfile.USER_ID;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: MaterialApp(
          home: Scaffold(
              appBar: AppBar(
                  backgroundColor: HeaderConfig.backGroundColor,
                  title: HeaderConfig.appBarText,
                  iconTheme: IconThemeData(color: Colors.black),
                  leading: HeaderConfig.backIcon),
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
                            height: MediaQuery.of(context).size.height * 0.1,
                            child: Text(
                              widget.matchTitle,
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
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
                            Text('対戦相手へフィードバックを送ろう',
                                style: TextStyle(
                                  fontSize: 15,
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
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  //ratingが星の数
                                  onRatingUpdate: (rating) {
                                    stroke_fore = rating;
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('バック：', style: TextStyle(fontSize: 20)),
                                RatingBar.builder(
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    stroke_back = rating;
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
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    volley_fore = rating;
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('バック：', style: TextStyle(fontSize: 20)),
                                RatingBar.builder(
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    volley_back = rating;
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
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    serve_1st = rating;
                                  },
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('２ｎｄ：', style: TextStyle(fontSize: 20)),
                                RatingBar.builder(
                                  allowHalfRating: true,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                  onRatingUpdate: (rating) {
                                    serve_2nd = rating;
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
                              width: 300,
                              height: 100,
                              child: TextFormField(
                                cursorColor: Colors.green,
                                controller: inputWord,
                                maxLines: 20,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
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
                                    '登録',
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                                onPressed: () async {
                                  if (serve_1st == 0 &&
                                      serve_2nd == 0 &&
                                      stroke_back == 0 &&
                                      stroke_fore == 0 &&
                                      volley_back == 0 &&
                                      volley_fore == 0) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('レビューを入力して下さい'),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary:
                                                        Colors.lightGreenAccent,
                                                    onPrimary: Colors.black),
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else if (inputWord.text.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('フィードバックを入力して下さい'),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    primary:
                                                        Colors.lightGreenAccent,
                                                    onPrimary: Colors.black),
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    //星数を登録する
                                    CSkilLevelSetting skill = CSkilLevelSetting(
                                      OPPONENT_ID: opponent_id,
                                      SERVE_1ST: serve_1st,
                                      SERVE_2ND: serve_2nd,
                                      STROKE_BACKHAND: stroke_back,
                                      STROKE_FOREHAND: stroke_fore,
                                      VOLLEY_BACKHAND: volley_back,
                                      VOLLEY_FOREHAND: volley_fore,
                                    );
                                    await FirestoreMethod.registSkillLevel(
                                        skill, widget.dayKey);
                                    await FirestoreMethod.registSkillSum(opponent_id);
                                    CFeedBackCommentSetting feedBack =
                                        CFeedBackCommentSetting(
                                      OPPONENT_ID: opponent_id,
                                      FEED_BACK: inputWord.text,
                                      DATE_TIME: widget.dayKey,
                                    );
                                    await FirestoreMethod.registFeedBack(
                                        feedBack,
                                        widget.myProfile,
                                        widget.yourProfile,
                                        widget.dayKey);
                                    Navigator.pop(context);
                                    //フィードバックを返したことを示すメッセージを記入する
                                    await FirestoreMethod.sendMatchResultFeedMessageReturn(widget.myProfile.USER_ID, widget.yourProfile.USER_ID, widget.dayKey);
                                    await FirestoreMethod.matchFeedAccept(widget.room, widget.messageId);
                                  }
                                }),
                          ),
                        ),
                      ]),
                ),
              )),
        ));
  }
}
