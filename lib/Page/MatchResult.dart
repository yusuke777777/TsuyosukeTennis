import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CtalkRoom.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class MatchResult extends StatefulWidget {
  late CprofileSetting myProfile;
  late CprofileSetting yourProfile;
  late String matchId;

  MatchResult(this.myProfile, this.yourProfile, this.matchId);

  @override
  _MatchResultState createState() => _MatchResultState();
}

class _MatchResultState extends State<MatchResult> {
  InterstitialAd? _interstitialAd; // インタースティシャル広告
  AdInterstitial adInterstitial = AdInterstitial(); // インタースティシャル広告のラッパークラス

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
  bool _feedbackFlg = true;

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
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    inputWord.dispose();
    inputTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦結果入力");
    opponent_id = widget.yourProfile.USER_ID;
    final deviceWidth = MediaQuery.of(context).size.width;
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
                    Center(
                      child: Container(
                        alignment: Alignment.center,
                        width: deviceWidth * 0.8,
                        height: 100,
                        child: TextField(
                          cursorColor: Colors.green,
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.green),
                              ),
                              labelText: "タイトル",
                              labelStyle:
                                  TextStyle(color: Colors.black, fontSize: 20),
                              hintText: "（例）◯◯市民大会の1回戦"),
                          style: const TextStyle(
                              fontSize: 20, color: Colors.black),
                          controller: inputTitle,
                          maxLength: 20,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(right: 10),
                          width: deviceWidth * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: deviceWidth * 0.3,
                                child: widget.myProfile.PROFILE_IMAGE == ''
                                    ? const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            AssetImage("images/tenipoikun.png"),
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
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.myProfile.NICK_NAME,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: matchResultList
                              .map((matchResult) => Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: deviceWidth * 0.12,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextButton(
                                              child: Text(
                                                '${matchResult.myGamePoint}',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                              onPressed: () {
                                                _showModalMyPointPicker(context,
                                                    int.parse(matchResult.No));
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Container(
                                            width: deviceWidth * 0.1,
                                            child: const Center(
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: TextButton(
                                              child: Text(
                                                '${matchResult.yourGamePoint}',
                                                style: const TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.black),
                                              ),
                                              onPressed: () {
                                                _showModalYourPointPicker(
                                                    context,
                                                    int.parse(matchResult.No));
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ))
                              .toList(),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10),
                          width: deviceWidth * 0.3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: deviceWidth * 0.3,
                                child: widget.yourProfile.PROFILE_IMAGE == ''
                                    ? const CircleAvatar(
                                        backgroundColor: Colors.white,
                                        backgroundImage:
                                            AssetImage("images/tenipoikun.png"),
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
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    widget.yourProfile.NICK_NAME,
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            //登録Noを更新
                            // curTourokuNo = curTourokuNo + 1;
                            activityListAdd(matchResultList.length.toString());
                            print(matchResultList.length);
                            setState(() {});
                          },
                        ),
                        const SizedBox(
                          width: 40,
                        ),
                      ],
                    ),
                    //レビュー集計機能
                    yourReviewFeatureEnabled == true
                        ? Column(children: [
                            Column(
                              children: [
                                const Text('------------------------',
                                    style: TextStyle(fontSize: 20)),
                                const Text('対戦相手へフィードバックを送ろう',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    )),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    const Text('フィードバックを入力しない',
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
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('ストローク',
                                        style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('フォア：',
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('バック：',
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
                                  height: 10,
                                ),
                                //ボレー
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('ボレー', style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('フォア：',
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('バック：',
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
                                  height: 10,
                                ),
                                //サーブ
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('サーブ', style: TextStyle(fontSize: 20)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('１ｓｔ：',
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('２ｎｄ：',
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
                              height: 10,
                            ),
                            Container(
                              width: deviceWidth * 0.8,
                              alignment: Alignment.center,
                              child: const Text('感想・フィードバック',
                                  style: TextStyle(fontSize: 20)),
                            ),
                            Container(
                              width: deviceWidth * 0.8,
                              height: 160,
                              alignment: Alignment.center,
                              child: TextFormField(
                                cursorColor: Colors.green,
                                controller: inputWord,
                                maxLines: 20,
                                decoration: const InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.green),
                                  ),
                                    hintText: "（例）1stサーブの種類が豊富で返すのにかなり苦戦しました。なので、2ndサーブで攻めるようにしてました！2ndサーブも精度が更に高まると1stサーブの強みをもっと活かせると思いました！お互い頑張りましょう💪"
                                ),
                              ),
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
                              const Text('フィードバックを希望する',
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
                        padding: const EdgeInsets.only(bottom: 20),
                        width: deviceWidth * 0.8,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.lightGreenAccent,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(80)),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              '登録',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                          onPressed: () async {
                            String errorFlg = "0";
                            matchResultList.forEach((matchList) {
                              if (matchResultList.length != 1 &&
                                  matchList.myGamePoint == 0 &&
                                  matchList.yourGamePoint == 0) {
                              } else if (matchList.myGamePoint ==
                                  matchList.yourGamePoint) {
                                errorFlg = "1";
                              }
                            });
                            if (errorFlg == "1") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('対戦結果に引き分けは入力できません'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor:
                                                  Colors.lightGreenAccent),
                                          child: const Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else if (yourReviewFeatureEnabled &&
                                !_flag &&
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
                                      title: const Text(
                                          'フィードバックが未記入です。\nフィードバックをしない場合は「フィードバックを入力しない」にチェックをつけてください。'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor:
                                                  Colors.lightGreenAccent),
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            } else if (yourReviewFeatureEnabled &&
                                !_flag &&
                                inputWord.text.isEmpty) {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                          'フィードバックが未記入です。\nフィードバックをしない場合は「フィードバックを入力しない」にチェックをつけてください。'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              foregroundColor: Colors.black,
                                              backgroundColor:
                                                  Colors.lightGreenAccent),
                                          child: const Text('OK'),
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
                                        title: const Text('タイトルが未記入です'),
                                        actions: <Widget>[
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.black,
                                                backgroundColor:
                                                    Colors.lightGreenAccent),
                                            child: const Text('OK'),
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
                                //広告を表示する
                                await adInterstitial.showAd();
                                adInterstitial.createAd();
                                //マッチリストを削除する
                                FirestoreMethod.delMatchListAuto(
                                    widget.matchId);
                                //マッチ画面へ戻る
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            UnderMenuMove.make(2)));
                                await FirestoreMethod.makeMatchResult(
                                    widget.myProfile,
                                    widget.yourProfile,
                                    matchResultList,
                                    dayKey,
                                    inputTitle.text);
                                //星数を登録する
                                if (yourReviewFeatureEnabled && !_flag) {
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
                                      skill, dayKey);
                                  await FirestoreMethod.registSkillSum(
                                      opponent_id);

                                  if (yourReviewFeatureEnabled &&
                                      !inputWord.text.isEmpty) {
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

                                await FirestoreMethod.makeRoom(
                                    widget.myProfile.USER_ID,
                                    widget.yourProfile.USER_ID);

                                //対戦結果のメッセージを送信する
                                if (_feedbackFlg &&
                                    FirestoreMethod.reviewFeatureEnabled) {
                                  FirestoreMethod.sendMatchResultFeedMessage(
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
    );
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
    "7",
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
    "7",
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
    if (int.parse(No) >= 5) {
      showDialog(
          context: context,
          builder: (BuildContext context) => const ShowDialogToDismiss(
                content: "一度に5セット以上の対戦結果の入力はできません",
                buttonText: "はい",
              ));
    } else {
      matchResultList
          .add(CmatchResult(No: No, myGamePoint: 0, yourGamePoint: 0));
      myGamePoint = 0;
      yourGamePoint = 0;
    }
  }
}
