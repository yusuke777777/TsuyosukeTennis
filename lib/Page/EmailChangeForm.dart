import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../FireBase/SignupModel.dart';
import '../PropSetCofig.dart';

class EmailChangeForm extends StatefulWidget {
  @override
  _EmailChangeFormState createState() => _EmailChangeFormState();
}

class _EmailChangeFormState extends State<EmailChangeForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _emailController_now = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "メールアドレス変更");
    final FocusNode _focusNode = FocusNode();
    final FocusNode _focusNode_now = FocusNode();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),

        //メイン画面実装
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    focusNode: _focusNode_now,
                    controller: _emailController_now,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: '現在のメールアドレス',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '現在のメールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    focusNode: _focusNode,
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      labelText: '新しいメールアドレス',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'メールアドレスを入力してください';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // background
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final user = _auth.currentUser;
                        final email = _emailController.text.trim();
                        final email_now = _emailController_now.text.trim();

                        if (email_now == user!.email) {
                          try {
                            SignUpModel().changeMail(email);
                            await user!.updateEmail(email);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('メールアドレスを変更しました')),
                            );
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnderMenuMove.make(0),
                                ));
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "メールアドレス変更に失敗しました\n入力したメールアドレスの確認をしてください"),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('現在のメールアドレスが異なります')),
                          );
                        }
                      }
                      ;
                    },
                    child: Text('メールアドレスを変更する'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.green, // background
                    ),
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UnderMenuMove.make(0),
                          ));
                    },
                    child: Text('ホームへ戻る'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
