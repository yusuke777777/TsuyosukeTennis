import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void viewHomePage() {
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(title: const Text("Home",
          style: TextStyle(
            color:Colors.black,
            fontSize: 30,
          ),
        ),
            leading: const Icon(Icons.menu,
                color:Colors.black),
            elevation: 0.0,
            backgroundColor: Colors.white,
            shadowColor:Colors.white),

        body: Center(
          //全体をカラムとして表示させる。
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
                  SizedBox(
                    height: 100,
                  ),
                  Text('名前:新井クソ介', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                  SizedBox(
                    width:10,
                  ),
                  ClipOval(
                    child: Image.asset(
                      'images/ans_032.jpg',
                      width: 70,
                      height: 70,
                      fit: BoxFit.fill,
                    ),
                  ),
                ]
                ),


                //登録ランク表示
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text('登録ランク:初級', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                //シングルスランキング表示
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                  SizedBox(
                    height: 30,
                  ),
                  Text('Sランキング:XX位', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                //ダブルスランキング表示
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text('Dランキング:XX位', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                //ミックスランキング表示
                Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text('Mランキング:XX位', style: TextStyle(fontSize: 30)), // This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: const <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Text('勝率：', style: TextStyle(fontSize: 30)),
                  Text('上級：', style: TextStyle(fontSize: 30))// This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: const <Widget>[
                  Text('　　　', style: TextStyle(fontSize: 30)),
                  Text('中級：', style: TextStyle(fontSize: 30))// This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),
                Row(mainAxisAlignment: MainAxisAlignment.start, children: const <Widget>[
                  Text('　　　', style: TextStyle(fontSize: 30)),
                  Text('初級：', style: TextStyle(fontSize: 30))// This trailing comma makes auto-formatting nicer for build methods.
                ]
                ),

                Row(mainAxisAlignment: MainAxisAlignment.center, children: const <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                  Text('現在X連勝中', style: TextStyle(fontSize: 50))
                ])
              ]
          ),
        )
    );
  }
}
