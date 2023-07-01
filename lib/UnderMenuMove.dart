import 'package:app_tracking_transparency/app_tracking_transparency.dart';
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
  String _authStatus = 'Unknown';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.green,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: 'マッチ'),
            BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble), label: 'トーク'),
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

      FirebaseMessaging.onMessage.listen((RemoteMessage message)  {
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
      });
    }
  }

  // 通知メッセージに応じて画面遷移
  Future<void> notificationMove(BuildContext context, String senderId) async {
    TalkRoomModel room = await FirestoreMethod.getRoomBySearchResult(
        FirestoreMethod.auth.currentUser!.uid, senderId);
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => TalkRoom(room)));
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
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) => initPlugin());
  }
  Future<void> initPlugin() async {
    final TrackingStatus status =
    await AppTrackingTransparency.trackingAuthorizationStatus;
    setState(() => _authStatus = '$status');
    // If the system can show an authorization request dialog
    if (status == TrackingStatus.notDetermined) {
      // Show a custom explainer dialog before the system dialog
      await showCustomTrackingDialog(context);
      // Wait for dialog popping animation
      await Future.delayed(const Duration(milliseconds: 200));
      // Request system's tracking authorization dialog
      final TrackingStatus status =
      await AppTrackingTransparency.requestTrackingAuthorization();
      setState(() => _authStatus = '$status');
    }

    final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
    print("UUID: $uuid");
  }

  Future<void> showCustomTrackingDialog(BuildContext context) async =>
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. We keep this app free by showing ads. '
                'Can we continue to use your data to tailor ads for you?\n\nYou can change your choice anytime in the app settings. '
                'Our partners will collect data and use a unique identifier on your device to show you ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Continue'),
            ),
          ],
        ),
      );
}
