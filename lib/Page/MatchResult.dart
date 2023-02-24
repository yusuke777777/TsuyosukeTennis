import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:tsuyosuke_tennis_ap/Common/CskilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/ProfileImage.dart';
import '../FireBase/TsMethod.dart';
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
  late double stroke_fore;
  late double stroke_back;
  late double volley_fore;
  late double volley_back;
  late double serve_1st;
  late double serve_2nd;

  @override
  Widget build(BuildContext context) {
    opponent_id = widget.yourProfile.USER_ID;
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
              title: Text('対戦結果入力'),
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
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                        ),
                        Container(
                          child: Text(
                            widget.myProfile.NICK_NAME,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                        ),
                        Container(
                          child: Text(
                            widget.yourProfile.NICK_NAME,
                            style: TextStyle(fontSize: 20, color: Colors.black),
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
                                    padding: const EdgeInsets.all(5.0),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextButton(
                                      child: Text(
                                        '${matchResultList[index].myGamePoint}',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
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
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: TextButton(
                                      child: Text(
                                        '${matchResultList[index].yourGamePoint}',
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
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
                            curTourokuNo = curTourokuNo + 1;
                            activityListAdd(curTourokuNo.toString());
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 40,
                        ),
                      ],
                    ),


                    //レビュー集計機能
                    Column(
                      children: [
                        Text('------------------------',
                            style: TextStyle(fontSize: 20)),
                        Text('レビュー', style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,)),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                            Text('2', style: TextStyle(fontSize: 20)),
                            RatingBar.builder(
                              itemBuilder: (context, index) =>
                              const Icon(Icons.star,color: Colors.yellow,),
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
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            ),
                          ),
                          onPressed: () {
                            String errorFlg = "0";
                            matchResultList.forEach((matchList) {
                              if(matchList.myGamePoint == matchList.yourGamePoint){
                                errorFlg = "1";
                              }
                            });
                            if(errorFlg == "1") {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('対戦結果に引き分けは入力できません'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.lightGreenAccent,
                                              onPrimary: Colors.black),
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                            }else{
                              //対戦結果を登録する
                              FirestoreMethod.makeMatchResult(widget.myProfile,
                                  widget.yourProfile, matchResultList);

                              //星数を登録する
                              CskilLevelSetting skill = new CskilLevelSetting(
                                  OPPONENT_ID: opponent_id, SERVE_1ST: serve_1st, SERVE_2ND: serve_2nd, STROKE_BACKHAND: stroke_back, STROKE_FOREHAND: stroke_fore, VOLLEY_BACKHAND: volley_back, VOLLEY_FOREHAND: volley_fore);

                              FirestoreMethod.registSkillLevel(skill);

                              Navigator.pop(context);
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
}
