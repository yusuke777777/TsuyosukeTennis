import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:http/http.dart' as http;

import '../constant.dart';
import 'FireBase.dart';

class NotificationMethod {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userTokenListRef =
      _firestoreInstance.collection('userTokenList');
  static final blockListRef =
  _firestoreInstance.collection('blockList');


  //通知テーブル
  static final MyNotificationRef =
      _firestoreInstance.collection('myNotification');
  static final MyNotificationSnap = MyNotificationRef.doc(auth.currentUser!.uid)
      .collection('talkNotification')
      .snapshots();

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

  // static Future<String> getAccessToken() async {
  //   final currentDirectory = Directory.current.path;
  //   print('Current directory: $currentDirectory');
  //   // サービスアカウントのJSONファイルのパス
  //   final serviceAccountJson = File(
  //       '${currentDirectory}ios/Runner/tsuyosuketest-a7f339ffc481.json')
  //       .readAsStringSync();
  //
  //   // サービスアカウントの認証情報を取得
  //   final credentials = GoogleAuth.ServiceAccountCredentials.fromJson(
  //       serviceAccountJson);
  //
  //   // スコープを指定
  //   final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
  //
  //   // HTTPクライアントを作成
  //   final client = http.Client();
  //
  //   // サービスアカウントを使用してアクセストークンを取得
  //   final accessToken = await GoogleAuth
  //       .obtainAccessCredentialsViaServiceAccount(credentials, scopes, client)
  //       .then((GoogleAuth.AccessCredentials credentials) {
  //     return credentials.accessToken.data;
  //   });
  //
  //   // クライアントを閉じる
  //   client.close();
  //
  //   return accessToken;
  // }

// Crude counter to make messages unique

  static String constructFCMPayload(
      String? token, String message, String name) {
    return jsonEncode({
      'token': token,
      'data': {
        'senderUid': auth.currentUser!.uid,
      },
      'notification': {
        'title': name,
        'body': message,
      },
    });
  }

  //ここ
  static Future<void> sendMessage(
      String recipientToken, String message, String name, String myUid, String yourUid) async {
    if (recipientToken == null) {
      print('Unable to send FCM message, no token exists.');
      return;
    }
    bool blockFlg = await FirestoreMethod.isBlock_yours(myUid, yourUid);

    try {
      if(blockFlg){
        //対象をブロックしていない
        print("Send OK！");
        final response = await http.post(
          Uri.parse(functionUrl),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: constructFCMPayload(recipientToken, message, name),
        );
        if (response.statusCode == 200) {
          print('Message sent successfully');
        } else {
          print('Failed to send message: ${response.body}');
        }
      }
      else{
        print("Block！");
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  // static Future<void> sendMessage(String recipientToken, String message,
  //   String name) async {
  //     final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  //     String fcmUrl = 'https://fcm.googleapis.com/v1/projects/tsuyosuketest/messages:send';
  //     // String serverKey =
  //     //     'AAAAsjXnpKQ:APA91bGhkNiydAXPg6rWfkGVXyOC7TQXuTJs0DrXJUXjTbuFvDf12cctlJb4lLh2BOeiJDBUu7zKe5VsVUDvnSsqU5O0b22OTJoJvdN6A-9LxNjXnXCnPAsda4kSI9aunT6dBlQ5az-e';
  //     // String accessToken = await getAccessToken();
  //     // print("accessToken" + accessToken);
  //     var headers = {
  //       'Content-Type': 'application/json',
  //       // 'Authorization': 'key=$serverKey',
  //       'Authorization': 'Bearer ' + accessToken
  //     };
  //     var data = {
  //       // 'notification': {
  //       //   'title': name,
  //       //   'body': message,
  //       // },
  //       'message': {
  //         'token': recipientToken,
  //         'notification': {
  //           'title': name,
  //           'body': message
  //         },
  //         'data': {
  //           // auth.currentUser!.uidを受信者に送信
  //           'senderUid': auth.currentUser!.uid,
  //         },
  //         // 通知をタップしたときに開く画面の指定など、必要に応じてカスタマイズできるキーと値を指定することができます。
  //       }
  //     };
  //
  //     var response = await http.post(Uri.parse(fcmUrl),
  //         headers: headers, body: json.encode(data));
  //
  //   print(response.statusCode);
  //   print(response.body);
  // }

  //メッセージ通知_新規フラグ取得(GET)
  static Future<String> newFlgNotification(String senderId) async {
    final snapshot = await MyNotificationRef.get();
    String NEW_FLG = "1";
    for (final doc in snapshot.docs) {
      if (doc.id == auth.currentUser!.uid) {
        final mySnapshot = await MyNotificationRef.doc(auth.currentUser!.uid)
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
    String NEW_FLG = "1";
    final snapshot =
        await _firestoreInstance.collection('myNotification').get();

    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == senderId) {
        final mySnapshot = await MyNotificationRef.doc(senderId)
            .collection('talkNotification')
            .get();
        print(doc.id);
        await Future.forEach<dynamic>(mySnapshot.docs, (childDoc) async {
          if (childDoc.id == auth.currentUser!.uid) {
            NEW_FLG = "0";
            print("childDoc" + childDoc.id);
            return;
          }
        });
      } else {
        return;
      }
    });
    return NEW_FLG;
  }

  // //メッセージ受信時に自分の通知数をカウントアップする
  // static Future<void> unreadCountTotal() async {
  //   int unreadCountTotal = 0;
  //   try {
  //     final snapShot_notification =
  //     await MyNotificationRef.doc(auth.currentUser!.uid).get();
  //
  //     if (snapShot_notification.exists) {
  //       unreadCountTotal = await snapShot_notification.data()!['TALK_UNREAD_COUNT_TOTAL'] ?? 0;
  //       unreadCountTotal++;
  //     }else{
  //       unreadCountTotal++;
  //     }
  //   } catch (e) {
  //     print('未読数のカウント数取得に失敗しました --- $e');
  //   }
  //   print("unreadCountTotal" + unreadCountTotal.toString());
  //   //未読数を更新して登録する
  //   try {
  //     //自分の通知数の未読数を更新する
  //     await MyNotificationRef.doc(auth.currentUser!.uid)
  //         .set({'USER_ID': auth.currentUser!.uid,
  //       'TALK_UNREAD_COUNT_TOTAL': unreadCountTotal,
  //     });
  //   } catch (e) {
  //     print('未読数のカウント登録に失敗しました --- $e');
  //   }
  //   FlutterAppBadge.count(unreadCountTotal);
  // }

  //メッセージ送信時に送信相手の通知数をカウントアップする
  static Future<int> unreadCount(String recipientId) async {
    int unreadCount = 0;
    //新規フラグチェック
    String newFlg = "0";
    newFlg = await newFlgSendNotification(recipientId);
    print("newFlg" + newFlg);
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
    print("unreadCount" + unreadCount.toString());
    //未読数を更新して登録する
    try {
      await MyNotificationRef
          .doc(recipientId)
          .collection('talkNotification')
          .doc(auth.currentUser!.uid)
          .set({
        'UNREAD_COUNT': unreadCount,
      });
      await MyNotificationRef
          .doc(recipientId)
          .set({
        'USER_ID': recipientId
      });
    } catch (e) {
      print('未読数のカウント登録に失敗しました --- $e');
    }
    return unreadCount;
  }

  static Future<int> unreadCountGet(String senderId) async {
    int unreadCount = 0;
    //新規フラグチェック
    String newFlg = "0";
    newFlg = await newFlgNotification(senderId);

    if (newFlg == "1") {
      unreadCount = 0;
    } else {
      try {
        final snapShot_notificationSender =
            await MyNotificationRef.doc(auth.currentUser!.uid)
                .collection('talkNotification')
                .doc(senderId)
                .get();
        unreadCount = await snapShot_notificationSender.data()!['UNREAD_COUNT']  ?? 0;
      } catch (e) {
        print('未読数のカウント数取得に失敗しました --- $e');
      }
    }
    return unreadCount;
  }

  //未読メッセージを既読状態にする
  static Future<void> unreadCountRest(String yourUserId) async {
    int unreadCountReset = 0;
    // int unreadCount = 0;
    // int unreadCountTotal = 0;
    // int unreadCountTotalNew = 0;
    try {
      // //対戦相手の未読数を取得
      // final snapShot_notificationSender =
      // await MyNotificationRef.doc(auth.currentUser!.uid)
      //     .collection('talkNotification')
      //     .doc(yourUserId)
      //     .get();

      //
      // if (snapShot_notificationSender.exists) {
      //   unreadCount = await snapShot_notificationSender.data()!['UNREAD_COUNT'] ?? 0;
      // }

      // //自分の未読数のトータルを取得
      // final snapShot_notification =
      // await MyNotificationRef.doc(auth.currentUser!.uid).get();
      // if (snapShot_notification.exists) {
      //   unreadCountTotal = await snapShot_notification.data()!['TALK_UNREAD_COUNT_TOTAL'] ?? 0;
      // }
      //対戦相手の未読数をリセット
      await MyNotificationRef.doc(auth.currentUser!.uid)
          .collection('talkNotification')
          .doc(yourUserId)
          .set({
        'UNREAD_COUNT': unreadCountReset,
      });
      // //自分の未読数のトータルを減算する
      // unreadCountTotalNew = unreadCountTotal - unreadCount;
      // if(unreadCountTotalNew<0){
      //   unreadCountTotalNew = 0;
      // }
      // await MyNotificationRef.doc(auth.currentUser!.uid)
      //     .set({'USER_ID': auth.currentUser!.uid,
      //   'TALK_UNREAD_COUNT_TOTAL': unreadCountTotalNew,
      // });
    } catch (e) {
      print('未読数のリセット登録に失敗しました --- $e');
    }
  }

  void setting() async {
    NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }
}
