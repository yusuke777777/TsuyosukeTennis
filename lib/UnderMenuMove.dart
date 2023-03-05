import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tsuyosuke_tennis_ap/Page/FindPage.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import 'Common/CPushNotification.dart';
import 'FireBase/NotificationMethod.dart';
import 'FireBase/Notification_badge.dart';
import 'Page/MatchList.dart';
import 'Page/RankList.dart';
import 'Page/TalkList.dart';
import 'Page/manSinglesRankList.dart';

/**
 * 下部メニューの動きを制御するクラス
 */

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
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

  late int _totalNotifications;
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

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        CPushNotification notification = CPushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
        setState(() {
          _notificationInfo = notification;
          _totalNotifications++;
        });
        // if (_notificationInfo != null) {
        //   showSimpleNotification(Text(_notificationInfo!.title!),
        //       leading:
        //       NotificationBadge(totalNotifications: _totalNotifications),
        //       subtitle: Text(_notificationInfo!.body!),
        //       background: Colors.cyan.shade700,
        //       duration: Duration(seconds: 2));
        // }
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
        _totalNotifications++;
      });
    });

    _totalNotifications = 0;
    super.initState();
  }


}