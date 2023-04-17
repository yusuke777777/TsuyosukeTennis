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
    print("kkkk");
    HeaderConfig().init(context, "対戦成績");
    DrawerConfig().init(context);

    Future<CScoreRef>? futureList = FirestoreMethod.getMatchResultScore(opponent_id);

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
                          child: ListView.builder(
                            itemCount: scoreRef!.HISTORYLIST.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(text: scoreRef!.HISTORYLIST[index].KOUSHIN_TIME),
                                      TextSpan(text: '\n', style: TextStyle(height: 0.0)), // 改行を追加
                                      TextSpan(text: scoreRef!.HISTORYLIST[index].MY_POINT.toString() + "-" + scoreRef!.HISTORYLIST[index].YOUR_POINT.toString()),
                                    ],
                                  ),
                                ),
                              );
                            },
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
