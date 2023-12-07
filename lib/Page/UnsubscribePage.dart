import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../PropSetCofig.dart';
import 'SigninPage.dart';

class UnsubscribePage extends StatefulWidget {
  @override
  _UnsubscribeState createState() => _UnsubscribeState();
}

class _UnsubscribeState extends State<UnsubscribePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "退会");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _showConfirmationDialog(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // 背景色を設定
          ),
          child: Text('アカウントを削除'),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('アカウント削除の確認'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  labelStyle: TextStyle(
                    color: Colors.green, // labelTextのテキスト色を設定
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  labelStyle: TextStyle(
                    color: Colors.green, // labelTextのテキスト色を設定
                  ),),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル',
                  style: TextStyle(
                    color: Colors.green, // 文字色を設定
                  ),),
            ),
            TextButton(
              onPressed: () async {
                // メールアドレスとパスワードで認証し、正しければアカウントを削除
                if (await _authenticateAndDelete()) {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  // ログアウト後の画面に遷移
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) =>  SignInPage()),
                        (Route<dynamic> route) => false,
                  );
                } else {
                  // 認証失敗時の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('メールアドレスまたはパスワードが正しくありません'),
                    ),
                  );
                }
              },
              child: Text('削除',
                style: TextStyle(
        color: Colors.green, // 文字色を設定
        ),),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _authenticateAndDelete() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      // 現在のユーザーを取得
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user!.uid;

      // パスワードで再認証
      var credential = EmailAuthProvider.credential(email: email, password: password);
      await user?.reauthenticateWithCredential(credential);

      //コレクションの該当データを削除
      // //myProfileDetail
      // final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_myProfileDetail =
      // await FirebaseFirestore.instance.collection('myProfileDetail').doc(userId).get();
      // if(documentSnapshot_myProfileDetail.exists){
      //   FirebaseFirestore.instance.collection('myProfileDetail').doc(userId).delete();
      // }
      // //MySetting
      // final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_MySetting =
      // await FirebaseFirestore.instance.collection('MySetting').doc(userId).get();
      // if(documentSnapshot_MySetting.exists){
      //   FirebaseFirestore.instance.collection('MySetting').doc(userId).delete();
      // }
      // //blockList
      // final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_blockList =
      // await FirebaseFirestore.instance.collection('blockList').doc(userId).get();
      // if(documentSnapshot_blockList.exists){
      //   FirebaseFirestore.instance.collection('blockList').doc(userId).delete();
      // }

      // ユーザーアカウントを削除
      await user?.delete();

      print('ユーザーアカウントが削除されました');
      return true; // 認証成功
    } catch (e) {
      print('ユーザーアカウントの削除に失敗しました: $e');
      return false; // 認証失敗
    }
  }
}
