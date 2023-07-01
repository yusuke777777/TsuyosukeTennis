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
import '../FireBase/FireBase.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../FireBase/ProfileImage.dart';
import '../FireBase/TsMethod.dart';
import '../PropSetCofig.dart';
import 'MatchList.dart';

class MatchResult extends StatefulWidget {
  late CprofileSetting myProfile;
  late CprofileSetting yourProfile;

  MatchResult(this.myProfile, this.yourProfile);

  @override
  _MatchResultState createState() => _MatchResultState();
}

class _MatchResultState extends State<MatchResult> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  InterstitialAd? _interstitialAd;
  AdInterstitial adInterstitial = new AdInterstitial();

  //アクティビィリスト
  List<CmatchResult> matchResultList = [
    CmatchResult(No: "0", myGamePoint: 0, yourGamePoint: 0)
  ];

  //現在登録中の登録No
  int curTourokuNo = 0;
  int myGamePoint = 0;
  int yourGamePoint = 0;

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

  //タイトル
  final inputTitle = TextEditingController();

  //対戦相手のレビュー機能ONOFF
  bool yourReviewFeatureEnabled = true;

  //フィードバックを入力しないかどうかフラグ(true=入力しない)
  bool _flag = false;
  bool _feedbackFlg = false;

  void _handleCheckbox(bool? e) {
    setState(() {
      _flag = e!;
    });
  }

  void _handleCheckbox2(bool? e) {
    setState(() {
      _feedbackFlg = e!;
    });
  }

  @override
  void initState() {
    super.initState();
    adInterstitial.createAd();
    FirestoreMethod.getYourReviewFeatureEnabled(widget.yourProfile.USER_ID)
        .then((enabled) {
      setState(() {
        yourReviewFeatureEnabled = enabled;
      });
    });
    FirestoreMethod.getReviewFeatureEnabled().then((enabled) {
      setState(() {
        FirestoreMethod.reviewFeatureEnabled = enabled;
      });
    });

    @override
    void dispose() {
      super.dispose();
      _interstitialAd?.dispose();
    }

  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦結果入力");
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
                            child: TextField(
                              cursorColor: Colors.green,
                              decoration: InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                  labelText: "タイトル",
                                  labelStyle: TextStyle(
                                      color: Colors.black, fontSize: 20),
                                  hintText: "(例)◯◯市民大会の1回戦"),
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                              controller: inputTitle,
                              maxLength: 20,
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
                            itemCount: matchResultList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Column(
                                children: [
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
                                        child: TextButton(
                                          child: Text(
                                            '${matchResultList[index].myGamePoint}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {
                                            _showModalMyPointPicker(
                                                context,
                                                int.parse(
                                                    matchResultList[index].No));
                                            setState(() {});
                                          },
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
                                        child: TextButton(
                                          child: Text(
                                            '${matchResultList[index].yourGamePoint}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                          onPressed: () {
                                            _showModalYourPointPicker(
                                                context,
                                                int.parse(
                                                    matchResultList[index].No));
                                            setState(() {});
                                          },
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                //登録Noを更新
                                // curTourokuNo = curTourokuNo + 1;
                                activityListAdd(matchResultList.length.toString());
                                print(matchResultList.length);
                                setState(() {});
                              },
                            ),
                            SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                        //レビュー集計機能
                        yourReviewFeatureEnabled == true
                            ? Column(children: [
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
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text('フィードバックを入力しない',
                                            style: TextStyle(fontSize: 10)),
                                        Checkbox(
                                          activeColor: Colors.blue,
                                          // Onになった時の色を指定
                                          value: _flag,
                                          onChanged: _handleCheckbox,
                                        )
                                      ],
                                    ),
                                    //ストローク
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('ストローク',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('フォア：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('バック：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('ボレー',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('フォア：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('バック：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('サーブ',
                                            style: TextStyle(fontSize: 20)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('１ｓｔ：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('２ｎｄ：',
                                            style: TextStyle(fontSize: 20)),
                                        RatingBar.builder(
                                          allowHalfRating: true,
                                          itemBuilder: (context, index) =>
                                              const Icon(
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
                                    Text('感想・フィードバック',
                                        style: TextStyle(fontSize: 20)),
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
                                            borderSide:
                                                BorderSide(color: Colors.green),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ])
                            : Container(),
                        const SizedBox(
                          height: 20,
                        ),
                        FirestoreMethod.reviewFeatureEnabled == true
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('フィードバックを希望しますか？',
                                      style: TextStyle(fontSize: 16)),
                                  Checkbox(
                                    activeColor: Colors.blue, // Onになった時の色を指定
                                    value: _feedbackFlg,
                                    onChanged: _handleCheckbox2,
                                  )
                                ],
                              )
                            : Container(),
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
                                String errorFlg = "0";
                                String deleteFlg = "0";
                                matchResultList.forEach((matchList) {
                                  if(matchResultList.length != 1 && matchList.myGamePoint == 0 && matchList.yourGamePoint == 0){
                                    deleteFlg = "1";
                                  }else if (matchList.myGamePoint ==
                                      matchList.yourGamePoint) {
                                    errorFlg = "1";
                                  }
                                });
                                if (errorFlg == "1") {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('対戦結果に引き分けは入力できません'),
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
                                } else if (yourReviewFeatureEnabled && !_flag &&
                                    serve_1st == 0 &&
                                    serve_2nd == 0 &&
                                    stroke_back == 0 &&
                                    stroke_fore == 0 &&
                                    volley_back == 0 &&
                                    volley_fore == 0) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'フィードバックが未記入です。\nフィードバックをしない場合は「フィードバックを入力しない」にチェックをつけてください。'),
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
                                } else if (yourReviewFeatureEnabled && !_flag && inputWord.text.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                              'フィードバックが未記入です。\nフィードバックをしない場合は「フィードバックを入力しない」にチェックをつけてください。'),
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
                                  if (inputTitle.text.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('タイトルが未記入です'),
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
                                    //対戦結果を登録する
                                    String dayKey = DateTime.now().toString();
                                    await FirestoreMethod.makeMatchResult(
                                        widget.myProfile,
                                        widget.yourProfile,
                                        matchResultList,
                                        dayKey,
                                        inputTitle.text);
                                    //星数を登録する
                                    if (yourReviewFeatureEnabled && !_flag) {
                                      CSkilLevelSetting skill =
                                          CSkilLevelSetting(
                                        OPPONENT_ID: opponent_id,
                                        SERVE_1ST: serve_1st,
                                        SERVE_2ND: serve_2nd,
                                        STROKE_BACKHAND: stroke_back,
                                        STROKE_FOREHAND: stroke_fore,
                                        VOLLEY_BACKHAND: volley_back,
                                        VOLLEY_FOREHAND: volley_fore,

                                      );
                                      await FirestoreMethod.registSkillLevel(
                                          skill, dayKey);

                                      if (yourReviewFeatureEnabled && !inputWord.text.isEmpty) {
                                        CFeedBackCommentSetting feedBack =
                                            CFeedBackCommentSetting(
                                          OPPONENT_ID: opponent_id,
                                          FEED_BACK: inputWord.text,
                                          DATE_TIME: dayKey,
                                        );
                                        await FirestoreMethod.registFeedBack(
                                            feedBack,
                                            widget.myProfile,
                                            widget.yourProfile,
                                            dayKey);
                                      }
                                    }
                                    //広告を表示する
                                    await adInterstitial.showAd();
                                    adInterstitial.createAd();

                                    Navigator.pop(context);
                                    //対戦結果のメッセージを送信する
                                    if (_feedbackFlg && FirestoreMethod.reviewFeatureEnabled) {
                                      FirestoreMethod
                                          .sendMatchResultFeedMessage(
                                              widget.myProfile.USER_ID,
                                              widget.yourProfile.USER_ID,
                                              dayKey);
                                    } else {
                                      FirestoreMethod.sendMatchResultMessage(
                                          widget.myProfile.USER_ID,
                                          widget.yourProfile.USER_ID,
                                          dayKey);
                                    }
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ]),
                ),
              )),
        ));
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _showModalMyPointPicker(BuildContext context, int No) {
    curTourokuNo = No;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _myPoint.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedMyPointChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _myPoint = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
  ];

  void _showModalYourPointPicker(BuildContext context, int No) {
    curTourokuNo = No;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _yourPoint.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedYourPointChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _yourPoint = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
  ];

  void _onSelectedMyPointChanged(int index) {
    myGamePoint = int.parse(_myPoint[index]);
    matchResultList[curTourokuNo].myGamePoint = myGamePoint;
    setState(() {});
  }

  void _onSelectedYourPointChanged(int index) {
    yourGamePoint = int.parse(_yourPoint[index]);
    matchResultList[curTourokuNo].yourGamePoint = yourGamePoint;
    setState(() {});
  }

  activityListAdd(String No) {
    print("No" + No);
    matchResultList.add(CmatchResult(No: No, myGamePoint: 0, yourGamePoint: 0));
    myGamePoint = 0;
    yourGamePoint = 0;
  }

  void regi() {}
}
