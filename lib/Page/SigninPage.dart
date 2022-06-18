import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../FireBase/SigninModel.dart';
import '../FireBase/TextDaialog.dart';
import '../FireBase/WillPopScope.dart';

import 'ProfileSetting.dart';
import 'SignupPage.dart';
import 'PasswordForgetPage.dart';


class SignInPage extends StatelessWidget {
  final mailController = TextEditingController();
  final passwordController = TextEditingController();
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
                              child: RaisedButton(
                                child: Text('ログイン'),
                                color: Color(0xFF4CAF50),
                                textColor: Colors.white,
                                onPressed: model.isMailValid &&
                                    model.isPasswordValid
                                    ? () async {
                                  model.startLoading();
                                  try {
                                    await model.login();
                                    //ダウンロードテスト
                                    // await FirestoreMethod().downloadImage();
                                    await Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(

                                        builder: (context) => ProfileSetting(),
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
                            FlatButton(
                              child: Text(
                                '新規登録はこちら',
                              ),
                              textColor: Color(0xFF4CAF50),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SignUpPage.make(),
                                  ),
                                );
                              },
                            ),
                            FlatButton(
                              child: Text(
                                'パスワードを忘れた場合',
                              ),
                              textColor: Colors.grey,
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