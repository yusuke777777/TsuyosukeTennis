import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'ProfileSetting.dart';
import 'SigninPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

class ReLoginMessagePage extends StatefulWidget {
  @override
  _ReLoginMessagePageState createState() => _ReLoginMessagePageState();
}

class _ReLoginMessagePageState extends State<ReLoginMessagePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '登録メールアドレスに承認メールを送信しました。\n承認後、再ログインをしてください。',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 背景色を設定
              ),
              child: Text(
                'ログイン画面に戻る',
                style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.green),
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SignInPage(),
                  ),
                );
              },
            ),
            SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () async {
                await FirestoreMethod.sendUserAuthMail();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 背景色を設定
              ),
              child: Text('承認メールを再度送信する'),
            ),
            Text(
              '※再送信メールが送信されない場合は\n5分以上間隔をあけ、再度ボタンを押してください。',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
