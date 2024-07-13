import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/urlMove.dart';
import '../PropSetCofig.dart';
import 'Billing.dart';
import 'UnsubscribePage.dart';

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
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('ユーザー登録方法',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //利用規約を記入する
                  UrlMove().UrlMoving(
                      'https://www.notion.so/54a20356702e41cca956b9b72b9f9c4c?pvs=4#afa3f8e21f994e8a95157e42bbeba613');
                },
              ),
              ListTile(
                title: Text('ホーム画面参照方法',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //利用規約を記入する
                  UrlMove().UrlMoving(
                      'https://www.notion.so/54a20356702e41cca956b9b72b9f9c4c?pvs=4#f8a6601d4dd24584916db0a7550f498b');
                },
              ),
              ListTile(
                title: Text('マッチング方法',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //利用規約を記入する
                  UrlMove().UrlMoving(
                      'https://www.notion.so/54a20356702e41cca956b9b72b9f9c4c?pvs=4#7c50cbe1a469427590789b2d1438d8f6');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
