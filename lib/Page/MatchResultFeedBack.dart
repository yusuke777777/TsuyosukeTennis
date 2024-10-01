import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
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
  InterstitialAd? _interstitialAd;
  AdInterstitial adInterstitial = new AdInterstitial();
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
  void initState() {
    super.initState();
    adInterstitial.createAd();

    @override
    void dispose() {
      super.dispose();
      _interstitialAd?.dispose();
    }

  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "フィードバック入力");
    final deviceWidth = MediaQuery.of(context).size.width;
    opponent_id = widget.yourProfile.USER_ID;
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
              appBar: AppBar(
                  backgroundColor: HeaderConfig.backGroundColor,
                  title: HeaderConfig.appBarText,
                  iconTheme: IconThemeData(color: Colors.black),
                  leading: HeaderConfig.backIcon),
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
                        Container(
                          width: deviceWidth * 0.8,
                          alignment: Alignment.center,
                          child:Text('感想・フィードバック',
                              style: TextStyle(fontSize: 20)),
                        ),
                            Container(
                              width: deviceWidth * 0.8,
                              height: 100,
                              alignment: Alignment.center,
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
                                                    foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
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
                                                    foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  } else {
                                    //広告を表示する
                                    await adInterstitial.showAd();
                                    adInterstitial.createAd();
                                    Navigator.pop(context);
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
        );
  }
}
