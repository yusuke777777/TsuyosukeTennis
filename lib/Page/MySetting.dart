import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

class MySetting extends StatefulWidget {
  const MySetting({Key? key}) : super(key: key);

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {

  @override
  void initState() {
    super.initState();
    FirestoreMethod.getReviewFeatureEnabled().then((enabled) {
      setState(() {
        FirestoreMethod.reviewFeatureEnabled = enabled;
      });
    });
    FirestoreMethod.getSearchFeatureEnabled().then((enabled2) {
      setState(() {
        FirestoreMethod.searchFeatureEnabled = enabled2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "設定");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('利用規約',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            onTap: () {
              //利用規約を記入する
            },
          ),
          ListTile(
            title: Text('問い合わせ',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            onTap: () {
              //問い合わせホームを作成する
            },
          ),
          ListTile(
            title: Text('Follow us!!',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            onTap: () {
              //つよすけテニスチャンネルのフォロー？
            },
          ),
          ListTile(
            title: Text('ライセンス', style: TextStyle(fontSize: 20, color: Colors.black)),
            onTap: () {
              showLicensePage(
                context: context,
                applicationName: 'テニポイ',
                applicationVersion: '1.0.0',
              );
            },
          ),
          ListTile(
            title: Text("レビュー機能（OFF/ON）",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            trailing: CupertinoSwitch(
              value: FirestoreMethod.reviewFeatureEnabled,
              onChanged: (bool? value) {
                setState(() {
                  FirestoreMethod.reviewFeatureEnabled = value ?? true;
                  FirestoreMethod.putReviewFeatureEnabled(FirestoreMethod.reviewFeatureEnabled);
                });
              },
            ),
          ),
          ListTile(
            title: Text("マルチ検索機能（OFF/ON）",
                style: TextStyle(fontSize: 20, color: Colors.black)),
            trailing: CupertinoSwitch(
              value: FirestoreMethod.searchFeatureEnabled,
              onChanged: (bool? value) {
                setState(() {
                  FirestoreMethod.searchFeatureEnabled = value ?? true;
                  FirestoreMethod.putSearchFeatureEnabled(FirestoreMethod.searchFeatureEnabled);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
