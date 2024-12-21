import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/SigninModel.dart';
import '../FireBase/TextDaialog.dart';
import '../FireBase/WillPopScope.dart';

import '../UnderMenuMove.dart';
import 'LoginPage.dart';
import 'ProfileSetting.dart';
import 'ReLoginMessagePage.dart';
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
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<SignInModel>(
        create: (_) => SignInModel(),
        child: Scaffold(
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: AppBar(backgroundColor: Colors.green),
          ),
          body: Consumer<SignInModel>(
            builder: (context, model, child) {
              return Stack(
                children: [
                  //背景画像をセット
                  Container(
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                    colorFilter: ColorFilter.mode(
                      Colors.white,
                      BlendMode.dstATop,
                    ),
                    image: AssetImage('images/haikei_katakana.png'),
                    fit: BoxFit.cover,
                  ))),
                  Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                             SizedBox(
                              height: deviceHeight * 0.2,
                            ),
                            SizedBox(
                              width:deviceWidth *0.9,
                              child: TextFormField(
                                controller: mailController,
                                onChanged: (text) {
                                  model.changeMail(text);
                                },
                                maxLines: 1,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  errorText: model.errorMail == ''
                                      ? null
                                      : model.errorMail,
                                  labelText: 'メールアドレス',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width:deviceWidth *0.9,
                              child: TextFormField(
                                controller: passwordController,
                                onChanged: (text) {
                                  model.changePassword(text);
                                },
                                obscureText: true,
                                maxLines: 1,
                                decoration: InputDecoration(
                                  fillColor: Colors.white,
                                  filled: true,
                                  errorText: model.errorPassword == ''
                                      ? null
                                      : model.errorPassword,
                                  labelText: 'パスワード',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            SizedBox(
                              width:deviceWidth *0.9,
                              height: 50,
                              child: ElevatedButton(
                                child: const Text(
                                  'ログイン',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          const Color(0xFF4CAF50)),
                                ),
                                onPressed: model.isMailValid &&
                                        model.isPasswordValid
                                    ? () async {
                                        model.startLoading();
                                        try {
                                          await model.login();
                                          bool isAuth = await FirestoreMethod
                                              .checkUserAuth();
                                          if (isAuth) {
                                            await FirestoreMethod.isProfile();
                                          } else {
                                            await Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  //TODO 引数消す
                                                  builder: (context) =>
                                                      ReLoginMessagePage(),
                                                ));
                                          }
                                          await Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  FirestoreMethod.isprofile
                                                      ? UnderMenuMove.make(0)
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
                              height: deviceHeight *0.05,
                              width: deviceWidth *0.9,
                              child: TextButton(
                                child: const Text(
                                  'パスワードを忘れた場合',
                                  style: TextStyle(color: Colors.white70,decoration: TextDecoration
                                    .underline,decorationColor: Colors.white70),
                                ),
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ForgetPasswordPage(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 20),
                                height: deviceHeight * 0.18,
                                width: deviceWidth * 0.8,
                                child: Column(children: [
                                  Container(
                                    height: deviceHeight * 0.08,
                                    width: deviceWidth * 0.8,
                                    color: const Color(0xC876E590),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(
                                            child: Text("アカウントをお持ちでない方",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white)),
                                          ),
                                          InkWell(
                                            child: const SizedBox(
                                              child: Text("新規登録",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      decorationColor:
                                                          Colors.green)),
                                            ),
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LoginPage(),
                                                ),
                                              );
                                            },
                                          ),
                                        ]),
                                  )
                                ])),
                          ],
                        ),
                      ),
                    ),
                  ),
                  model.isLoading
                      ? Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Center(
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
