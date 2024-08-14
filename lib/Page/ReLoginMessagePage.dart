import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../FireBase/FireBase.dart';
import '../FireBase/SigninModel.dart';
import '../FireBase/singletons_data.dart';
import '../PropSetCofig.dart';
import 'ProfileSetting.dart';
import 'SigninPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:tsuyosuke_tennis_ap/FireBase/native_dialog.dart';

class ReLoginMessagePage extends StatefulWidget {

  @override
  _ReLoginMessagePageState createState() => _ReLoginMessagePageState();
}

class _ReLoginMessagePageState extends State<ReLoginMessagePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  late Stream<List<QueryDocumentSnapshot>> _Stream;


  @override
  void initState() {
    super.initState();

  }

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
                '承認しました',
                style: TextStyle(
                    color: Colors.white,
                    backgroundColor: Colors.green),
              ),
              onPressed: () async {
                try {
                  //ボタンを押したタイミングでリロードをかけてメアドの認証チェックをする
                  User? currentUser = auth.currentUser;
                  await currentUser!.reload();
                  User? currentUser_reload = auth.currentUser;

                  if(currentUser_reload!.emailVerified == true){
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) =>  ProfileSetting.Make()),
                          (Route<dynamic> route) => false,
                    );
                  }
                  else{
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ShowDialogToDismiss(
                            title: "承認されていません",
                            buttonText: 'OK',
                            content: 'メアド承認が済んでいる場合は再度ボタンを押してください',));
                  }
                } on PlatformException catch (e) {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => ShowDialogToDismiss(
                          title: "Error",
                          content: e.message ?? "Unknown error",
                          buttonText: 'OK'));
                }
              },
            ),
            SizedBox(
              height: 16,
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
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                //課金機能ログアウト
                try {
                  await Purchases.logOut();
                  appData.appUserID = await Purchases.appUserID;
                  print("ログアウト"+appData.appUserID );
                } on PlatformException catch (e) {
                  await showDialog(
                      context: context,
                      builder: (BuildContext context) => ShowDialogToDismiss(
                          title: "Error",
                          content: e.message ?? "Unknown error",
                          buttonText: 'OK'));
                }
                // ログアウト後の画面に遷移
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) =>  SignInPage()),
                      (Route<dynamic> route) => false,
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
