import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRef.dart';

import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

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
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦成績");
    DrawerConfig().init(context);
    List<TextSpan> textSpans = [];

    Future<CScoreRef>? futureList = FirestoreMethod.getMatchResultScore(opponent_id);

    /**
     * score 6
     * index 0~5
     */
    List<TextSpan> makeHistoryList(CScoreRef? scoreRef) {
      bool isFirst = true;
      //日付毎に表示するスコアをもつ変数
      String dispScore = '';
      String time = '';
      int scoreRefCnt = 0;
      int roopCount = 0;


      scoreRef!.HISTORYLIST.forEach((scoreRefHistoryElement) {
        roopCount ++;
        if(isFirst){
          dispScore = scoreRefHistoryElement.MY_POINT.toString() + "-" + scoreRefHistoryElement.YOUR_POINT.toString();
          time = scoreRefHistoryElement.KOUSHIN_TIME;
          isFirst = false;
        }
        else {
          if (scoreRefHistoryElement.KOUSHIN_TIME == time) {
            dispScore = dispScore + "," + scoreRefHistoryElement.MY_POINT.toString() + "-" + scoreRefHistoryElement.YOUR_POINT.toString();
            time = scoreRefHistoryElement.KOUSHIN_TIME;

            if (roopCount == scoreRef!.HISTORYLIST.length) {
              textSpans.add(
                TextSpan(
                  children: [
                    TextSpan(text: scoreRefHistoryElement.KOUSHIN_TIME),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text: scoreRef.TITLE[scoreRefCnt].isEmpty ? 'NoTitle' : scoreRef.TITLE[scoreRefCnt+1]),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text:dispScore),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),

                  ],
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              );
            }

          }

          else {

            if (roopCount == scoreRef!.HISTORYLIST.length) {
              textSpans.add(
                TextSpan(
                  children: [
                    TextSpan(text: scoreRefHistoryElement.KOUSHIN_TIME),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text: scoreRef.TITLE[scoreRefCnt].isEmpty ? 'NoTitle' : scoreRef.TITLE[scoreRefCnt+1]),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text:scoreRefHistoryElement.MY_POINT.toString() + "-" + scoreRefHistoryElement.YOUR_POINT.toString()),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),

                  ],
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              );
            }

            else {
              textSpans.add(
                TextSpan(
                  children: [
                    TextSpan(text: time),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text: scoreRef.TITLE[scoreRefCnt].isEmpty ? 'NoTitle' : scoreRef.TITLE[scoreRefCnt]),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),
                    TextSpan(text:dispScore),
                    TextSpan(text: '\n', style: TextStyle(height: 0.0)),

                  ],
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              );

            }
            scoreRefCnt++;
            time = scoreRefHistoryElement.KOUSHIN_TIME;
            dispScore = scoreRefHistoryElement.MY_POINT.toString() + "-" + scoreRefHistoryElement.YOUR_POINT.toString();
          }
        }
      });
      return textSpans;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
      ),
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
                  //試合数
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "試合数 : " + scoreRef!.MATCH_COUNT.toString(),
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ]),

                  const SizedBox(
                    height: 10,
                  ),

                  //試合数
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "勝利数 : " + scoreRef!.WIN_COUNT.toString(),
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ]),

                  const SizedBox(
                    height: 10,
                  ),

                  //試合数
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "敗北数 : " + scoreRef!.LOSE_COUNT.toString(),
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ]),

                  const SizedBox(
                    height: 10,
                  ),

                  //試合数
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "勝率 : " + scoreRef!.WIN_LATE.toString() + "%",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ]),

                  const SizedBox(
                    height: 30,
                  ),

                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "対戦履歴",
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ]),

                  Container(
                    height: 500,
                    child: ListView(
                        children: [
                          RichText(
                            text: TextSpan(
                              children: makeHistoryList(scoreRef),
                            ),
                          )
                        ]
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
