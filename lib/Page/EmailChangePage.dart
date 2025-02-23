import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmailChangePage extends StatefulWidget {
  @override
  _EmailChangePageState createState() => _EmailChangePageState();
}

class _EmailChangePageState extends State<EmailChangePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _newEmailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmEmailController = TextEditingController();

  Future<void> updateEmail(String newEmail, String password) async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        // 現在のパスワードで認証
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);

        // 新しいメールアドレスに更新
        await user.verifyBeforeUpdateEmail(newEmail);
        print('確認メールを送信しました。');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('新しいメールアドレスに承認メールを送信しました。'),
          ),
        );
      } on FirebaseAuthException catch (e) {
        // エラー処理
        print(e.message);
        if(e.message.toString() == 'The supplied credentials do not correspond to the previously signed in user.'){
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('変更不可。再ログインをしてから変更してください。'),
              ),
          );
        }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('パスワードが誤っているか既に使用されているアドレスです。'),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // コントローラを解放
    _newEmailController.dispose();
    _newPasswordController.dispose();
    _passwordController.dispose();
    _confirmEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('メールアドレス変更'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText
                  : 'パスワード'),
            ),
            TextField(
              controller: _newEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '新しいメールアドレス'),
            ),
            TextField(
              controller: _confirmEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '新しいメールアドレス（確認）'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_newEmailController.text != _confirmEmailController.text) {
                  // メールアドレスが一致しない場合のエラー処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('新しいメールアドレスが一致しません。'),
                    ),
                  );
                  return;
                }
                await updateEmail(_confirmEmailController.text.trim(), _newPasswordController.text.trim());
              },
              child: Text('メールアドレス変更'),
            ),
          ],
        ),
      ),
    );
  }
}