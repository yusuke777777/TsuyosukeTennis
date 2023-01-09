import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Page/FriendManagerPage.dart';

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
          fontSize: 25,
          color: Colors.black),
    );
  }
}

//ヘッダー部左のドロアーの共通クラスです
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