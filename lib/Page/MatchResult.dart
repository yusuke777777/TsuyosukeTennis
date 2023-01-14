import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
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

  @override
  Widget build(BuildContext context) {
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
                              FirestoreMethod.makeMatchResult(widget.myProfile,
                                  widget.yourProfile, matchResultList);
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
