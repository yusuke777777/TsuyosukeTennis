import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:http/http.dart' as http;

class NotificationMethod {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final userTokenListRef =
      _firestoreInstance.collection('userTokenList');

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
    if(tokenCheck =="1"){
      final snapShot = await userTokenListRef.doc(userId).get();
       token = snapShot.data()!['TOKEN'];
    }else{
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

  static Future<void> sendMessage(String recipientToken, String message,String name) async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    String fcmUrl = 'https://fcm.googleapis.com/fcm/send';
    String serverKey = 'AAAAsjXnpKQ:APA91bGhkNiydAXPg6rWfkGVXyOC7TQXuTJs0DrXJUXjTbuFvDf12cctlJb4lLh2BOeiJDBUu7zKe5VsVUDvnSsqU5O0b22OTJoJvdN6A-9LxNjXnXCnPAsda4kSI9aunT6dBlQ5az-e';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
    var data = {
      'notification': {
        'title': name,
        'body': message,
      },
      "to": recipientToken
      // 通知をタップしたときに開く画面の指定など、必要に応じてカスタマイズできるキーと値を指定することができます。
    };

    var response = await http.post(Uri.parse(fcmUrl),
        headers: headers, body: json.encode(data));

    print(response.statusCode);
    print(response.body);
  }
}
