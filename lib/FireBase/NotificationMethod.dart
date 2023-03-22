import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:http/http.dart' as http;
import 'package:flutter_app_badger/flutter_app_badger.dart';

class NotificationMethod {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userTokenListRef =
      _firestoreInstance.collection('userTokenList');

  //通知テーブル
  static final MyNotificationRef = _firestoreInstance.collection('myNotification');
  static final MyNotificationSnap = MyNotificationRef
      .doc(auth.currentUser!.uid)
      .collection('talkNotification').snapshots();


  static Future<String?> getMyTokenId() async {
    late final FirebaseMessaging _messaging;
    _messaging = FirebaseMessaging.instance;
    String? token = await _messaging.getToken();
    return token;
  }

  static Future<void> registerTokenID(String tokenId) async {
    try {
      await userTokenListRef.doc(auth.currentUser!.uid).set({
        'USER_ID': auth.currentUser!.uid,
        'TOKEN': tokenId,
      });
    } catch (e) {
      print('トークンの登録に失敗しました --- $e');
    }
  }

  static Future<String?> getTokenId(String userId) async {
    String token = "";
    //Tokenが登録されていない時の処理も記載する必要あり
    String tokenCheck = await NotificationMethod.checkTokenFlg(userId);
    if (tokenCheck == "1") {
      final snapShot = await userTokenListRef.doc(userId).get();
      token = snapShot.data()!['TOKEN'];
    } else {
      token = "";
    }
    return token;
  }

  //対戦結果_新規フラグ取得
  static Future<String> checkTokenFlg(String UserId) async {
    final snapshot = await userTokenListRef.get();
    String tokenCheck = "0";
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == UserId) {
        tokenCheck = "1";
      }
    });
    return tokenCheck;
  }

  static Future<void> sendMessage(
      String recipientToken, String message, String name) async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
    String serverKey =
        'AAAAsjXnpKQ:APA91bGhkNiydAXPg6rWfkGVXyOC7TQXuTJs0DrXJUXjTbuFvDf12cctlJb4lLh2BOeiJDBUu7zKe5VsVUDvnSsqU5O0b22OTJoJvdN6A-9LxNjXnXCnPAsda4kSI9aunT6dBlQ5az-e';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
    var data = {
      'notification': {
        'title': name,
        'body': message,
        'payload': auth.currentUser!.uid
      },
      "to": recipientToken
      // 通知をタップしたときに開く画面の指定など、必要に応じてカスタマイズできるキーと値を指定することができます。
    };

    var response = await http.post(Uri.parse(fcmUrl),
        headers: headers, body: json.encode(data));

    print(response.statusCode);
    print(response.body);
  }

  Future<void> setBadgeCount(int count) async {
    await FlutterAppBadger.updateBadgeCount(count);
  }

  //メッセージ通知_新規フラグ取得(GET)
  static Future<String> newFlgNotification(String senderId) async {
    final snapshot = await MyNotificationRef.get();
    String NEW_FLG = "1";
    for (final doc in snapshot.docs) {
      if (doc.id == auth.currentUser!.uid) {
        final mySnapshot = await MyNotificationRef
            .doc(auth.currentUser!.uid)
            .collection('talkNotification')
            .get();
        for (final doc in mySnapshot.docs) {
          if (doc.id == senderId) {
            NEW_FLG = "0";
          }
        }
      }
    }
    return NEW_FLG;
  }

  //メッセージ通知_新規フラグ取得(SEND)
  static Future<String> newFlgSendNotification(String senderId) async {
    final snapshot = await MyNotificationRef.get();
    String NEW_FLG = "1";
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == senderId) {
        final mySnapshot = await MyNotificationRef
            .doc(senderId)
            .collection('talkNotification')
            .get();
        await Future.forEach<dynamic>(mySnapshot.docs, (doc) async {
          if (doc.id == auth.currentUser!.uid) {
            NEW_FLG = "0";
          }
        });
      }
    });
    return NEW_FLG;
  }

  //メッセージ受信時に送信相手の通知数をカウントアップする
  //トークルームから戻るとき、入るときにリセットできるようにする
  static Future<int> unreadCount(String recipientId) async {
    int unreadCount = 0;
    //新規フラグチェック
    // String newFlg = await newFlgSendNotification(recipientId);
    String newFlg = "0";
    if (newFlg == "1") {
      unreadCount++;
    } else {
      try {
        final snapShot_notification = await MyNotificationRef
            .doc(recipientId)
            .collection('talkNotification')
            .doc(auth.currentUser!.uid)
            .get();
        unreadCount = await snapShot_notification.data()!['UNREAD_COUNT'];
        unreadCount++;
      } catch (e) {
        print('未読数のカウント数取得に失敗しました --- $e');
      }
    }
    //未読数を更新して登録する
    try {
      await MyNotificationRef
          .doc(recipientId)
          .collection('talkNotification')
          .doc(auth.currentUser!.uid)
          .set({
        'UNREAD_COUNT': unreadCount,
      });
    } catch (e) {
      print('未読数のカウント登録に失敗しました --- $e');
    }
    return unreadCount;
  }

  static Future<int> unreadCountGet(String senderId) async {
    int unreadCount = 0;
    //新規フラグチェック
    // String newFlg = await newFlgNotification(senderId);
    String newFlg = "0";

    if (newFlg == "1") {
      unreadCount = 0;
    } else {
      try {
        final snapShot_notification = await MyNotificationRef
            .doc(auth.currentUser!.uid)
            .collection('talkNotification')
            .doc(senderId)
            .get();
        unreadCount = await snapShot_notification.data()!['UNREAD_COUNT'];
      } catch (e) {
        print('未読数のカウント数取得に失敗しました --- $e');
      }
    }
    return unreadCount;
  }

  //未読メッセージを既読状態にする
  static Future<void> unreadCountRest(String yourUserId) async {
    int unreadCount = 0;
    try {
      await MyNotificationRef
          .doc(auth.currentUser!.uid)
          .collection('talkNotification')
          .doc(yourUserId)
          .set({
        'UNREAD_COUNT': unreadCount,
      });
    } catch (e) {
      print('未読数のリセット登録に失敗しました --- $e');
    }
  }
}
