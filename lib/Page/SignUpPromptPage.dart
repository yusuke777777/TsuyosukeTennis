import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsuyosuke_tennis_ap/Page/LoginPage.dart';
import '../FireBase/urlMove.dart';
import 'SigninPage.dart';
import 'SignupPage.dart';

class SignUpPromptPage extends StatefulWidget {
  late String mail;
  late String password;
  late String confirm;

  @override
  _SignUpPromptPageState createState() => _SignUpPromptPageState();
}

class _SignUpPromptPageState extends State<SignUpPromptPage> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40.0),
          child: AppBar(
            backgroundColor: Colors.green,
            iconTheme: const IconThemeData(
              color: Colors.white, // 戻るボタンの色を白に設定
            ),
          ),
        ),
        body: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    height: deviceHeight * 0.3,
                    width: deviceWidth * 0.7,
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                      image: AssetImage('images/tenipoikun.png'),
                      fit: BoxFit.cover,
                    ))),
                Container(
                  width: deviceWidth * 0.8,
                  height: deviceHeight * 0.1,
                  child: const Text(
                    "ユーザー登録/ログインが必要な機能です。",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Container(
                  width: deviceWidth * 0.8,
                  height: deviceHeight * 0.08,
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      child: const Text(
                        'ユーザー登録/ログイン',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF4CAF50)),
                      ),
                      onPressed: () async {
                        try {
                          User? user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            await user.delete();
                            print('User deleted successfully.');
                          }
                        } catch (e) {
                          // ユーザー削除失敗時の処理
                          print('Error deleting user: $e');
                        }
                        //ログインページへの遷移
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                              (route) => false, // 全てのルートを削除
                        );
                      }),
                ),
              ],
            ),
          ),
        ));
  }
}
