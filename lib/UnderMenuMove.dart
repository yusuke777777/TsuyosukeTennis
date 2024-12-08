import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badge/flutter_app_badge.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tsuyosuke_tennis_ap/Page/FindPage.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import 'BillingThreshold.dart';
import 'Common/CPushNotification.dart';
import 'Common/CtalkRoom.dart';
import 'Component/native_dialog.dart';
import 'FireBase/FireBase.dart';
import 'FireBase/NotificationMethod.dart';
import 'FireBase/NotificationProvider.dart';
import 'FireBase/singletons_data.dart';
import 'Page/MatchList.dart';
import 'Page/RankList.dart';
import 'Page/SigninPage.dart';
import 'Page/TalkList.dart';
import 'Page/TalkRoom.dart';
import 'Page/manSinglesRankList.dart';
import 'constant.dart';
import 'package:intl/intl.dart';

/**
 * 下部メニューの動きを制御するクラス
 */

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
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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
        });
      });
  }

  // 通知メッセージに応じて画面遷移
  Future<void> notificationMove(BuildContext context, String? senderId) async {
    TalkRoomModel room = await FirestoreMethod.getRoomBySearchResult(
        FirestoreMethod.auth.currentUser!.uid, senderId.toString());
    // 現在のウェジット取得
    final widget = context.widget;

    if(widget.toString() != 'TalkRoom'){
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => TalkRoom(room)));
    }

    await NotificationMethod.unreadCountRest(
        senderId.toString());
  }

  void checkForInitialMessage() async {
    // アプリが通知から起動された場合、そのメッセージを取得
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      // 通知からアプリが起動された際の処理を実装
      print('Notification clicked while app was terminated: ${initialMessage.messageId}');
      // 例: 通知内容に応じて特定の画面を表示
      CPushNotification notification = CPushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
        String? senderId = initialMessage.data['senderUid'];
        notificationMove(context, senderId);
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
        String? senderId = message.data['senderUid'];
        print(senderId);
        notificationMove(context, senderId);
      });
    });
    //課金処理
    initPlatformState();
    // _totalNotifications = 0;
    //トラッキングチェック処理
    super.initState();
    // アプリの初期化時に、通知からの起動をチェック
    checkForInitialMessage();

    WidgetsFlutterBinding.ensureInitialized()
        .addPostFrameCallback((_) => initPlugin());
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

  //課金機能
  Future<void> initPlatformState() async {
    appData.appUserID = await Purchases.appUserID;
    print("appUserId" + appData.appUserID);
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      // if(!appData.isPurchasing) {
        if (FirebaseAuth.instance.currentUser != null) {
          //課金ユーザーへログイン
          await Purchases.logIn(FirebaseAuth.instance.currentUser!.uid);
          appData.appUserID = await Purchases.appUserID;
          print("appData.appUserIDログイン" + appData.appUserID);
          //appUserIdをセットする
          appData.appUserID = await Purchases.appUserID;
          //現在の課金フラグを取得する
          String BILLING_FLG = await FirestoreMethod.getBillingFlg();
          //現在の課金状態をチェックする
          CustomerInfo customerInfo = await Purchases.getCustomerInfo();
          EntitlementInfo? entitlement =
          customerInfo.entitlements.all[entitlementID];
          appData.entitlementIsActive = entitlement?.isActive ?? false;
          print(appData.entitlementIsActive.toString());
          if (BILLING_FLG == "0" && appData.entitlementIsActive == true) {
            //プレミアム会員へ更新する
            try {
              //トーク上限数のリセット
              await FirebaseFirestore.instance
                  .runTransaction((transaction) async {
                //プレミアム会員登録時に、トークメッセージの上限数でリセット
                // 現在のタイムスタンプを取得
                Timestamp currentTimestamp = Timestamp.now();

                // Firestoreのユーザードキュメントを更新してリセット
                DocumentReference userLimitMgmtDocRef = FirebaseFirestore
                    .instance
                    .collection('userLimitMgmt')
                    .doc(FirestoreMethod.auth.currentUser!.uid);

                try {
                  await transaction.set(
                      userLimitMgmtDocRef,
                      {
                        'dailyMessageLimit': messagePremiumLimit,
                        // リセット後のデフォルト上限を設定
                        'lastResetTimestamp': currentTimestamp,
                      },
                      SetOptions(merge: true));
                } catch (e) {
                  throw ("メッセージ数のリセットに失敗しました $e");
                }

                //プレミアム会員登録時に、チケットの上限数でリセット
                DocumentReference userTicketMgmDocRef = FirebaseFirestore
                    .instance
                    .collection('userTicketMgmt')
                    .doc(FirestoreMethod.auth.currentUser!.uid);

                DateTime now = DateTime.now();
                DateFormat outputFormat = DateFormat('yyyy-MM-dd');
                String today = outputFormat.format(now);
                int zengetsuTicketSu = 0;
                DocumentSnapshot userTicketMgmDoc =
                await userTicketMgmDocRef.get();

                if (userTicketMgmDoc.exists) {
                  zengetsuTicketSu = userTicketMgmDoc['zengetsuTicketSu'];
                }
                int ticketSuSum = ticketPremiumLimit + zengetsuTicketSu;
                //当月のプレミアム会員のチケット数だけ更新する
                try {
                  transaction.set(
                      userTicketMgmDocRef,
                      {
                        'ticketSu': ticketSuSum,
                        'togetsuTicketSu': ticketPremiumLimit,
                        'zengetsuTicketSu': zengetsuTicketSu,
                        'ticketKoushinYmd': today
                      },
                      SetOptions(merge: true));
                  // throw ("エラー");
                } catch (e) {
                  throw ("TSPプレミアム会員のチケット発行に失敗しました $e");
                }
              }).then((value) =>
                  print("DocumentSnapshot successfully updated!"),
                  onError: (e) => throw ("課金処理の更新に失敗しました $e"));
              try {
                await FirestoreMethod.updateBillingFlg();
              } catch (e) {
                throw ("課金処理のDB更新に失敗しました");
              }
            } catch (e) {
              print("有料会員への更新に失敗しました");
            }
          } else
          if (BILLING_FLG == "1" && appData.entitlementIsActive == false) {
            //プレミアム会員から退会する
            try {
              await FirestoreMethod.updateBillingFlg();
            } catch (e) {
              print("退会処理のDB更新に失敗しました");
            }
          }
        }
      // }
    });
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
