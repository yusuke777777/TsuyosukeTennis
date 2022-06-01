import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'ConvertErrorMessage.dart';

class ForgetPasswordModel extends ChangeNotifier {
  String mail = '';
  String errorMail = '';
  bool isLoading = false;
  bool isMailValid = false;

  Future sendResetEmail() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: mail,
      );
    } on FirebaseAuthException catch (e) {
      print('${e.code}: $e');
      throw (convertErrorMessage(e.code));
    }
  }

  void changeMail(text) {
    this.mail = text.trim();
    if (text.length == 0) {
      this.isMailValid = false;
      this.errorMail = 'メールアドレスを入力して下さい。';
    } else {
      this.isMailValid = true;
      this.errorMail = '';
    }
    notifyListeners();
  }

  void startLoading() {
    this.isLoading = true;
    notifyListeners();
  }

  void endLoading() {
    this.isLoading = false;
    notifyListeners();
  }
}