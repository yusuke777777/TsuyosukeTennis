import 'package:flutter/material.dart';

import '../PropSetCofig.dart';
import 'SigninPage.dart';

class ThankYouPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "退会完了");
    DrawerConfig().init(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ご利用いただき、ありがとうございました。'),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SignInPage(),
                  ),
                );
              },
              child: Text('閉じる'),
            ),
          ],
        ),
      ),
    );
  }
}