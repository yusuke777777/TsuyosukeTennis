import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsuyosuke_tennis_ap/UnderMenuMove.dart';
import '../FireBase/SignupModel.dart';
import '../PropSetCofig.dart';

class PassWordChangeForm extends StatefulWidget {
  @override
  _PassWordChangeFormState createState() => _PassWordChangeFormState();
}

class _PassWordChangeFormState extends State<PassWordChangeForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _passWordController = TextEditingController();
  final _passWordController_comfirm = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode_2 = FocusNode();


  @override
  void dispose() {
    _passWordController.dispose(); // TextEditingControllerの解放
    _passWordController_comfirm.dispose(); // TextEditingControllerの解放
    _focusNode.dispose(); // FocusNodeの解放
    _focusNode_2.dispose(); // FocusNodeの解放
    super.dispose(); // スーパークラスのdisposeを呼び出す
  }


  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "パスワード変更");
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon
        ),

        //メイン画面実装
        body: Scrollbar(
          child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: 16),
                    TextFormField(
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          //日本語入力禁止
                            RegExp('[\u3040-\u309F]')),
                      ],
                      focusNode: _focusNode,
                      controller: _passWordController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                        color: Colors.black,
                      ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: '新しいパスワード(英数字のみ可)',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(
                          //日本語入力禁止
                            RegExp('[\u3040-\u309F]')),
                      ],
                      focusNode: _focusNode_2,
                      controller: _passWordController_comfirm,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(
                          color: Colors.black,
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        labelText: 'パスワード確認',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green, // background
                      ),
                      onPressed: () async {
                          final user = _auth.currentUser;
                          final newPassWord = _passWordController.text.trim();
                          final comfirmPassWord = _passWordController_comfirm.text.trim();


                            try {
                              if (newPassWord.length < 8 || newPassWord.length > 20) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('パスワードは8文字以上20文字以内です。')),
                                );
                              }
                              else if (newPassWord != comfirmPassWord){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('パスワードが一致しません。')),
                                );
                              }
                              else {
                                await user!.updatePassword(newPassWord);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (
                                          context) =>  UnderMenuMove.make(0),
                                    ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('パスワードを変更しました')),
                                );

                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("パスワード変更に失敗しました\n入力パスワードの確認をしてください"),),
                              );
                            }
                        },
                      child: Text('パスワードを変更する',style: TextStyle(color: Colors.white),),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green, // background
                      ),
                      onPressed: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnderMenuMove.make(0),
                                ));
                      },
                      child: Text('ホームへ戻る',style: TextStyle(color: Colors.white),),
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
