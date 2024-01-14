import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/SigninModel.dart';
import '../FireBase/TextDaialog.dart';
import '../FireBase/WillPopScope.dart';

import '../FireBase/native_dialog.dart';
import '../FireBase/singletons_data.dart';
import '../UnderMenuMove.dart';
import 'ProfileSetting.dart';
import 'SignupPage.dart';
import 'PasswordForgetPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;


class SignInPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();

  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final profileRef = _firestoreInstance.collection('myProfile');

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(40.0),
            child: AppBar(
                backgroundColor: Colors.green),
          ),
          body: Consumer<SignInModel>(
            builder: (context, model, child) {
              return Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 120,
                                  child:
                                  Image.asset('images/ans_032.jpg'),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 16.0,
                            ),
                            TextFormField(
                              controller: mailController,
                              onChanged: (text) {
                                model.changeMail(text);
                              },
                              maxLines: 1,
                              decoration: InputDecoration(
                                errorText: model.errorMail == ''
                                    ? null
                                    : model.errorMail,
                                labelText: 'メールアドレス',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextFormField(
                              controller: passwordController,
                              onChanged: (text) {
                                model.changePassword(text);
                              },
                              obscureText: true,
                              maxLines: 1,
                              decoration: InputDecoration(
                                errorText: model.errorPassword == ''
                                    ? null
                                    : model.errorPassword,
                                labelText: 'パスワード',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                child: Text('ログイン',style: TextStyle(color: Colors.white,),),
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF4CAF50)),
                                ),
                                onPressed: model.isMailValid &&
                                    model.isPasswordValid
                                    ? () async {
                                  model.startLoading();
                                  try {
                                    await model.login();
                                    await FirestoreMethod.isProfile();
                                    //ダウンロードテスト
                                    // await FirestoreMethod().downloadImage();

                                    // //課金機能　RevenueCat
                                    try {
                                      await Purchases.logIn(
                                          auth.currentUser!.uid);
                                      appData.appUserID =
                                      await Purchases.appUserID;
                                    }on PlatformException catch (e) {
                                      await showDialog(
                                          context: context,
                                          builder: (BuildContext context) => ShowDialogToDismiss(
                                              title: "Error",
                                              content: e.message ?? "Unknown error",
                                              buttonText: 'OK'));
                                    }

                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        FirestoreMethod.isprofile
                                            ?
                                        UnderMenuMove.make(0)
                                            : ProfileSetting.Make(),
                                      ),
                                    );
                                  } catch (e) {
                                    showTextDialog(context, e.toString());
                                    model.endLoading();
                                  }
                                }
                                    : null,
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            TextButton(
                              child: Text(
                                '新規登録はこちら',
                             style: TextStyle(color:Color(0xFF4CAF50) ), ),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage.make(),
                                  ),
                                );
                              },
                            ),
                            TextButton(
                              child: Text(
                                'パスワードを忘れた場合',
                              style: TextStyle(color:Colors.grey),),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPasswordPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  model.isLoading
                      ? Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                      : SizedBox(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}