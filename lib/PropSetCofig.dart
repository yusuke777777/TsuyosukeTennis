import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Common/CtalkRoom.dart';
import 'FireBase/FireBase.dart';
import 'Page/FriendManagerPage.dart';
import 'Page/ProfileReference.dart';
import 'Page/TalkRoom.dart';

/**
 * ヘッダ部の共通クラスです
 */
class HeaderConfig{
  //ヘッダー部の背景色
  static late Color backGroundColor;
  //ヘッダー部の中身
  static late Text appBarText;

  void init(BuildContext context,String inputTitle){
    backGroundColor = Colors.white;

    appBarText = Text( inputTitle,
      style: TextStyle(
          fontSize: 20,
          color: Colors.black),
    );
  }
}

/**
 * ヘッダー部左のドロアーの共通クラスです
 */
class DrawerConfig {
  static late Drawer drawer;
  void init(BuildContext context) {
    drawer = Drawer(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FriendManagerPage(),
            ),
          );
        },
        child: Container(
          child: Text('友人管理'),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}

/**
 * 検索結果リストの共通化クラスです
 */
class ListTileConfig {
  static late ListTile listTile;

  void init(BuildContext context, String name, String profile, String docId, String loginUserId) {
    listTile = ListTile(
      tileColor: Colors.white24,
      leading: ClipOval(
        child: GestureDetector(
          //アイコン押下時の挙動
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileReference(docId),
                ));
          },
          child: profile == ""
              ? Image.asset('images/upper_body-2.png',
              fit: BoxFit.cover)
              : Image.network(
            profile,
            width: 70,
            height: 70,
            fit: BoxFit.fill,
          ),
        ),
      ),
      title: Text(name,
          style: TextStyle(fontSize: 20)),
      //リスト押下時の挙動
      onTap: () async {
        TalkRoomModel room = await FirestoreMethod.makeRoom(loginUserId, docId);
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TalkRoom(room),
            ));
      },
    );

  }
}