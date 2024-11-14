import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PasswordResetPage extends StatefulWidget {
  @override
  _PasswordResetPageState createState() => _PasswordResetPageState();
}

class _PasswordResetPageState extends State<PasswordResetPage> {
  final _emailController = TextEditingController();

  Future<void> resetPassword() async {
    try {
      final _auth = FirebaseAuth.instance;
      final user = _auth.currentUser;
      //ログインユーザのメアドと一致すればリセットメールを送信
      if(user?.email == _emailController.text.trim()) {
        await _auth.sendPasswordResetEmail(
          email: _emailController.text.trim(),
        );
        // パスワードリセットメール送信成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('パスワードリセットメールを送信しました。'),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eメールが異なります。'),
          ),
        );
      }

    } on FirebaseAuthException catch (e) {
      // エラー処理
      print(e.message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    // コントローラを解放
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('パスワード再設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'メールアドレス'),
            ),
            ElevatedButton(
              onPressed: resetPassword,
              child: Text('パスワード再設定'),
            ),
          ],
        ),
      ),
    );
  }
}