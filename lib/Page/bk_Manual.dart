import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../FireBase/urlMove.dart';
import '../PropSetCofig.dart';

class Manual extends StatefulWidget {
  const Manual({Key? key}) : super(key: key);

  @override
  State<Manual> createState() => _ManualState();
}

class _ManualState extends State<Manual> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "アプリ利用手順");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: const Text('ホーム画面参照方法',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('マッチング方法',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('対戦結果入力方法について',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('TSPランキングについて',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('チケット取得方法について',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('トークについて',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
              ListTile(
                title: const Text('FAQ',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
