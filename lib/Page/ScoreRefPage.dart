import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRef.dart';

import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'FriendManagerPage.dart';

class ScoreRefPage extends StatefulWidget {
  ScoreRefPage(this.opponent_id);

  // 検索画面　アカウントIDの入力値
  String opponent_id;

  @override
  State<ScoreRefPage> createState() => ScoreRefPageState(opponent_id);
}

class ScoreRefPageState extends State<ScoreRefPage> {
  ScoreRefPageState(this.opponent_id);

  String opponent_id;

  @override
  void dispose() {
    // 必要なリソースがあればここで解放する
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    HeaderConfig().init(context, "対戦成績");
    DrawerConfig().init(context);
    List<TextSpan> textSpans = [];

    Future<CScoreRef>? futureList =
        FirestoreMethod.getMatchResultScore(opponent_id);

    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: futureList,
          builder: (BuildContext context, AsyncSnapshot<CScoreRef> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return new Align(
                  child: Center(
                child: new CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return new Text('Error!!: ${snapshot.error!}');
            } else if (snapshot.hasData) {
              CScoreRef? scoreRef = snapshot.data;

              return Center(
                //メイン画面
                child: Column(children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "勝率 : " + scoreRef!.WIN_LATE.toString() + "%",
                          style: TextStyle(fontSize: 30),
                        ),
                      ]),
                  const SizedBox(
                    height: 20,
                  ),
                  //試合数
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal, //色
                          spreadRadius: 5,
                          blurRadius: 5,
                          offset: Offset(1, 1),
                        ),
                      ],
                      border: Border.all(
                          color: Colors.greenAccent,
                          style: BorderStyle.solid,
                          width: 3),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "試合数",
                            style: TextStyle(
                                fontSize: 25,
                                color: Colors.white70,
                                fontWeight: FontWeight.bold),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              scoreRef!.MATCH_COUNT.toString(),
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ]),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.orangeAccent,
                              style: BorderStyle.solid,
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red, //色
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "勝利数",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  scoreRef!.WIN_COUNT.toString(),
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.lightBlueAccent,
                              style: BorderStyle.solid,
                              width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent, //色
                              spreadRadius: 5,
                              blurRadius: 5,
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "敗北数",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  scoreRef!.LOSE_COUNT.toString(),
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ]),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  scoreRef.HISTORYLIST.length == 0
                      ? Container()
                      : Container(
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  "直近対戦結果",
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(bottom: 20),
                                width: deviceWidth * 0.95,
                                child: Column(
                                  children: scoreRef.HISTORYLIST
                                      .map((historyItem) => Column(
                                            children: [
                                                  Container(
                                                    alignment: Alignment.bottomLeft,
                                                    width: deviceWidth * 0.95,
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                          historyItem.TITLE + "(" + historyItem.KOUSHIN_TIME + ")",
                                                          style: TextStyle(
                                                              fontSize: 14)),
                                                    ),
                                                  ),
                                              // SCORE_POINTを繰り返し表示
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.black26),
                                                    color: Colors.white70),
                                                child: Row(
                                                  children: historyItem
                                                      .SCORE_POINT
                                                      .map((score) => Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    3),
                                                            child: Text(score,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14)),
                                                          ))
                                                      .toList(),
                                                ),
                                              ),
                                              historyItem.FEEDBACK_COMMENT != ''
                                                  ? Column(
                                                      children: [
                                                        Container(
                                                          alignment: Alignment
                                                              .bottomLeft,
                                                          child: Text(
                                                            "レビューコメント",
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                        Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.95,
                                                          alignment:
                                                              Alignment.topLeft,
                                                          height: 80,
                                                          decoration: BoxDecoration(
                                                              border: Border.all(
                                                                  color: Colors
                                                                      .black26),
                                                              color: Colors
                                                                  .white70),
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          child: SingleChildScrollView(
                                                            child: Text(
                                                              historyItem
                                                                  .FEEDBACK_COMMENT
                                                                  .toString(),
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                              textAlign:
                                                                  TextAlign.start,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  : Container()
                                              // 他の要素も必要に応じて表示できます
                                            ],
                                          ))
                                      .toList(),
                                ),
                              )
                            ],
                          ),
                        ),
                ]),
              );
            } else {
              return Text("データが存在しません");
            }
          },
        ),
      ),
    );
  }
}
