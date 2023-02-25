import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import '../Common/CFeedBackCommentSetting.dart';
import '../PropSetCofig.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import 'ProfileReference.dart';

class CheckFeedBack extends StatefulWidget {
  const CheckFeedBack({Key? key}) : super(key: key);

  @override
  State<CheckFeedBack> createState() => _CheckFeedBackState();
}

class _CheckFeedBackState extends State<CheckFeedBack> {
  Future<List<CFeedBackCommentSetting>> feedBackList =
      FirestoreMethod.getFeedBack();


  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "フィードバック一覧");
    DrawerConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder(
          future: feedBackList,
          builder: (BuildContext context, AsyncSnapshot<List<CFeedBackCommentSetting>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return new Align(
                  child: Center(
                child: new CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return new Text('Error: ${snapshot.error!}');
            } else if (snapshot.hasData) {
              //取得したい値をリスト型で格納
              List<CFeedBackCommentSetting>? profileList = snapshot!.data;
              // print("aaaa" + profileList![0].HOME!.TOROKURANK.toString());
              //フィードバックが存在しない時
              if (profileList!.isEmpty) {
                return ListView(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(8),
                    children: <Widget>[
                      Text("フィードバックはありません。対戦してフィードバックをもらおう！"),
                    ]);
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: profileList.length,
                  // padding: const EdgeInsets.all(8),
                  itemBuilder: (BuildContext context, int index) {
                    //共通リストタイルの呼出
                    return Card(
                      elevation: 0,
                      child:ListTile(
                        tileColor: Colors.white24,
                        leading: ClipOval(
                          child: GestureDetector(
                            //アイコン押下時の挙動
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => HomePage(),
                              //     ));
                            },
                            child:Image.asset('images/upper_body-2.png', fit: BoxFit.cover)
                            // profileList[index].HOME!.PROFILEIMAGE == ""
                            //     ? Image.asset('images/upper_body-2.png', fit: BoxFit.cover)
                            //     : Image.network(
                            //   profileList[index].HOME!.PROFILEIMAGE,
                            //   width: 70,
                            //   height: 70,
                            //   fit: BoxFit.fill,
                            // ),
                          ),
                        ),
                          title:Text(profileList[index].FEED_BACK.toString()),
                          subtitle:Text("入力日時：" + profileList[index].DATE_TIME.toString().substring(0, 16))
                      ),
                    );
                  },
                );
              }
            }
            else {
              return ListView(
                  padding: const EdgeInsets.all(8),
                  children: <Widget>[
                    //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
                    ListTile(title: Text("フィードバックはありません。対戦してフィードバックをもらおう！")),
                  ]);
            }
          },
        ),
      ),

      //   child: ListView.builder(
      //     itemCount: 1,
      //     // padding: const EdgeInsets.all(8),
      //     itemBuilder: (BuildContext context, int index) {
      //       //共通リストタイルの呼出
      //       return Card(
      //         elevation: 0,
      //         child: ListTileConfig.listTile,
      //       );
      //     },
      //   ),
      //
      // ),
    );
  }
}
