import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tsuyosuke_tennis_ap/Page/FindPage.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import 'Common/CPushNotification.dart';
import 'Common/CtalkRoom.dart';
import 'FireBase/FireBase.dart';
import 'FireBase/NotificationMethod.dart';
import 'FireBase/Notification_badge.dart';
import 'Page/MatchList.dart';
import 'Page/RankList.dart';
import 'Page/TalkList.dart';
import 'Page/TalkRoom.dart';
import 'Page/manSinglesRankList.dart';

/**
 * 下部メニューの動きを制御するクラス
 */

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  // 通知を受信して行いたい処理
  //残メッセージ数を取得メソッドを作成する
  //メッセージ送信時に送信者のIDを持たせられないか検討(payloadを用いればできる)
}

class UnderMenuMove extends StatefulWidget {
  // const UnderMenuMove({Key? key}) : super(key: key);
   int selectedIndex = 0;
  UnderMenuMove.make(this.selectedIndex);

  @override
  State<UnderMenuMove> createState() => _UnderMenuMoveState();
}

class _UnderMenuMoveState extends State<UnderMenuMove> {
  static final _screens = [
    HomePage(),
    FindPage(),
    MatchList(),
    TalkList(),
    RankList(),
  ];
  late int _selectedIndex;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  late final FirebaseMessaging _messaging;
  CPushNotification? _notificationInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor : Colors.green,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: 'マッチ'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'トーク'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'ランク'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }

  void requestAndRegisterNotification() async {
    await Firebase.initializeApp();
    _messaging = FirebaseMessaging.instance;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      String? myTokenId = await NotificationMethod.getMyTokenId();
      await NotificationMethod.registerTokenID(myTokenId!);

      print("The token is " + myTokenId!);

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async{
        CPushNotification notification = CPushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
        setState(() {
          _notificationInfo = notification;
          // int _totalNotifications = 5;
          // //残メッセージ数を取得メソッドを作成する
          // FlutterAppBadger.updateBadgeCount(_totalNotifications);
        });
        // 遷移先の画面を指定する
        String senderId = await message.data['key'];
        TalkRoomModel room = await FirestoreMethod.getRoomBySearchResult(FirestoreMethod.auth.currentUser!.uid,senderId);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TalkRoom(room)),
        );

      });

    }
  }
  @override
  void initState() {
    _selectedIndex = widget.selectedIndex;
    requestAndRegisterNotification();
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      CPushNotification notification = CPushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        // _totalNotifications++;
        // FlutterAppBadger.updateBadgeCount(_totalNotifications);
      });
    });
    // _totalNotifications = 0;
    super.initState();
  }


}