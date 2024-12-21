import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:tsuyosuke_tennis_ap/Page/ReLoginMessagePage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/SignupModel.dart';
import '../FireBase/TextDaialog.dart';
import '../FireBase/WillPopScope.dart';
import 'SigninPage.dart';

class SignUpPage extends StatefulWidget {
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();
  late String mail;
  late String password;
  late String confirm;

  SignUpPage.make() {}

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  //ページ1より
  var mailController = TextEditingController();
  var passwordController = TextEditingController();
  var confirmController = TextEditingController();
  var useridController = TextEditingController();
  late String myUserId;

  bool _isCheck = false;

  void _handleCheckbox(bool isCheck) {
    setState(() {
      _isCheck = isCheck;
    });
  }

  @override
  void dispose() {
    widget.mailController.dispose();
    widget.passwordController.dispose();
    widget.confirmController.dispose();
    useridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.of(context).size.height;
    final deviceWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: willPopCallback,
      child: ChangeNotifierProvider<SignUpModel>(
          create: (_) => SignUpModel()..init(),
          child: Scaffold(
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
            body: Consumer<SignUpModel>(
              builder: (context, model, child) {
                return Stack(children: [
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Padding(padding: EdgeInsets.all(50)),
                      Column(
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(children: <Widget>[
                                TextFormField(
                                  controller: mailController,
                                  onChanged: (text) {
                                    model.changeMail(text);
                                  },
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16),
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
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: passwordController,
                                  onChanged: (text) {
                                    model.changePassword(text);
                                  },
                                  obscureText: true,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16),
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
                                const SizedBox(
                                  height: 8,
                                ),
                                TextFormField(
                                  controller: confirmController,
                                  onChanged: (text) {
                                    model.changeConfirm(text);
                                  },
                                  obscureText: true,
                                  maxLines: 1,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    fillColor: Colors.white,
                                    filled: true,
                                    labelText: 'パスワード（確認用）',
                                    errorText: model.errorConfirm == ''
                                        ? null
                                        : model.errorConfirm,
                                    border: const OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Container(
                                  width: deviceWidth * 0.5,
                                  height: deviceHeight * 0.08,
                                  padding: const EdgeInsets.only(top: 20),
                                  child: ElevatedButton(
                                      child: const Text(
                                        '新規登録',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor:
                                            WidgetStateProperty.all<Color>(
                                                const Color(0xFF4CAF50)),
                                      ),
                                      onPressed: () async {
                                        try {
                                          await model.signUp();
                                          await FirestoreMethod
                                              .sendUserAuthMail();
                                          await Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  //TODO 引数消す
                                                  ReLoginMessagePage(),
                                            ),
                                          );
                                          model.endLoading();
                                        } catch (e) {
                                          showTextDialog(context, e);
                                          model.endLoading();
                                        }
                                      }),
                                ),
                                // FloatingActionButton.extended(
                                //   shape: RoundedRectangleBorder(
                                //     borderRadius:
                                //         BorderRadius.circular(5), //角の丸み
                                //   ),
                                //   label: const Text(
                                //     '新規登録',
                                //     style: TextStyle(
                                //         fontSize: 16, color: Colors.white),
                                //   ),
                                //   backgroundColor: const Color(0xFF4CAF50),
                                //   onPressed: model.agreeGuideline
                                //       ? () async {
                                //           try {
                                //             await model.signUp();
                                //             await FirestoreMethod
                                //                 .sendUserAuthMail();
                                //             await Navigator.pushReplacement(
                                //               context,
                                //               MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     //TODO 引数消す
                                //                     ReLoginMessagePage(),
                                //               ),
                                //             );
                                //             model.endLoading();
                                //           } catch (e) {
                                //             showTextDialog(context, e);
                                //             model.endLoading();
                                //           }
                                //         }
                                //       : null,
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                                Column(
                                  children: [
                                    Container(
                                      height: deviceHeight * 0.08,
                                      width: deviceWidth * 0.8,
                                      color: const Color(0xC876E590),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(
                                              child: Text("アカウントをお持ちの方",
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white)),
                                            ),
                                            InkWell(
                                              child: const SizedBox(
                                                child: Text("ログインはこちら",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.green,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        decoration:
                                                            TextDecoration
                                                                .underline,
                                                        decorationColor:
                                                            Colors.green)),
                                              ),
                                              onTap: () {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(builder: (context) => SignInPage()),
                                                      (route) => false, // 全てのルートを削除
                                                );

                                              },
                                            ),
                                          ]),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                ]);
              },
            ),
          )),
    );
  }
}

void _SignUprulesURL() async {
  const url =
      'https://spectacled-lan-4ae.notion.site/a20f927123de4185bf444025d095e525?pvs=4';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
