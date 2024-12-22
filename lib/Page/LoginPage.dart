import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../FireBase/urlMove.dart';
import 'SigninPage.dart';
import 'SignupPage.dart';

class LoginPage extends StatefulWidget {
  late String mail;
  late String password;
  late String confirm;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
        ),

      ),
      body: Scaffold(
          body: Column(
        children: [
          Container(
            alignment: Alignment.center,
              height: deviceHeight * 0.3,
              width: deviceWidth * 0.7,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('images/tenipoikun.png'),
                fit: BoxFit.cover,
              ))),
          Container(
            alignment: Alignment.center,
            height: deviceHeight * 0.1,
            width: deviceWidth * 0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "アカウントを登録して",
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
                const Text(
                  "ランキング上位を目指そう！！",
                  style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Container(
            height: deviceHeight * 0.18,
            width: deviceWidth * 0.8,
            child: Column(
              children: [
                Container(
                  height: deviceHeight * 0.08,
                  width: deviceWidth * 0.8,
                  color: const Color(0xC876E590),
                  child: Column(
                      mainAxisAlignment:MainAxisAlignment.center,
                      children: [
                    const SizedBox(
                      child: Text("アカウントをお持ちの方",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                    InkWell(
                      child: const SizedBox(
                        child: Text("ログインはこちら",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.green)),
                      ),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignInPage(),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
                Container(
                  width: deviceWidth *0.8,
                  height: deviceHeight * 0.08,
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                      child: const Text(
                        'メールアドレスで登録',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(
                            const Color(0xFF4CAF50)),
                      ),
                      onPressed: () async {
                        //新規登録画面への遷移
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage.make(),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          Container(
              height: deviceHeight *0.05,
              child: Row(
               mainAxisAlignment: MainAxisAlignment.center ,
            children: [
              TextButton(
                  onPressed: () {
                    //プライバシーポリシーを記入する
                    UrlMove().UrlMoving(
                        'https://spectacled-lan-4ae.notion.site/09dca252ef2e4ba7bd692f1e0228acc1?pvs=4');
                  },
                  child: Text("プライバシーポリシー",style: TextStyle(fontSize: 12),)),
              Text("と",style: TextStyle(fontSize: 12),),
              TextButton(
                  onPressed: () {
                    //利用規約を記入する
                    UrlMove().UrlMoving(
                        'https://spectacled-lan-4ae.notion.site/a20f927123de4185bf444025d095e525?pvs=4');
                  },
                  child: Text("利用規約",style: TextStyle(fontSize: 12),)),
              Text("に同意する",style: TextStyle(fontSize: 12),)
            ],
          )),
          Container(
            child: Text("あとで登録する",style: TextStyle(fontSize: 12,color: Colors.grey),),
          )
        ],
      )),
    );
  }
}
