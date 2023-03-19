import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/FireBase.dart';

import 'ConvertErrorMessage.dart';

class SignUpModel extends ChangeNotifier {
  SignUpModel() {
    this.agreeGuideline = false;
    this.showingDialog = false;
    this.mail = '';
    this.password = '';
    this.confirm = '';
    this.errorMail = '';
    this.errorPassword = '';
    this.errorMyUserId = '';
    this.errorConfirm = '';
    this.errorTeamName = '';
    this.errorMission = '';
    this.errorAddress = '';
    this.isLoading = false;
    this.isMailValid = false;
    this.isPasswordValid = false;
    this.isConfirmValid = false;
    this.isTeamNameValid = false;
    this.isMissionValid = false;
    this.isAddressValid = false;
    // this.userCredential = null;
    this.isGuestAllowed = false;
    // this.teamPass = '';
    this.teamName = '';
    // this.memberName = '';
    this.level = '';
    this.activeLocation = '';
    this.mission = '';
    this.address = '';
  }

  late bool agreeGuideline;
  late bool showingDialog;
  late String mail;
  late String password;
  late String myUserId;
  late String confirm;
  late String errorMail;
  late String errorPassword;
  late String errorMyUserId;
  late String errorConfirm;
  late String errorTeamName;
  late String errorMission;
  late String errorAddress;
  late bool isLoading;
  late bool isMailValid;
  late bool isPasswordValid;
  late bool isMyUserIdValid;
  late bool isConfirmValid;
  late bool isTeamNameValid;
  late bool isMissionValid;
  late bool isAddressValid;
  late UserCredential userCredential;
  late bool isGuestAllowed;
  // late String teamPass;
  late String teamName;
  // late String memberName;
  late String level;
  late String activeLocation;
  late String mission;
  late String address;

  Future<void> init() async {
    // DocumentSnapshot _doc = await FirebaseFirestore.instance
    //     .collection('settings')
    //     .doc('guest_mode')
    //     .get();
    // this.isGuestAllowed = _doc.data()['guest_allowed'];
    notifyListeners();
  }

  Future signUp(
      ) async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }

    /// 入力されたメール, パスワードで UserCredential を作成
    try {
      this.userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: this.mail,
        password: this.password,
      );
    } on FirebaseAuthException catch (e) {
      print('エラーコード：${e.code}\nエラー：$e');
      throw (convertErrorMessage(e.code));
    }

    /// UserCredential の null チェック
    if (this.userCredential == null) {
      print('UserCredential が見つからないエラー');
      throw ('エラーが発生しました。');
    }

    /// users コレクションにユーザーデータを保存
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

  void changePassword(text) {
    this.password = text;
    if (text.length == 0) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードを入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isPasswordValid = false;
      this.errorPassword = 'パスワードは8文字以上20文字以内です。';
    } else {
      isPasswordValid = true;
      this.errorPassword = '';
    }
    notifyListeners();
  }

  Future<void> changeMyUserID(text) async {
    bool isDoubleMyUserId = false;
    isDoubleMyUserId = await FirestoreMethod.checkDoubleMyUserID(text, isDoubleMyUserId);
    print("aa"+isDoubleMyUserId.toString());
    this.myUserId = text;
    if (text.length == 0) {
      isMyUserIdValid= false;
      this.errorMyUserId = 'ユーザーIDを設定してください(英数字のみ可)';
    } else if(isDoubleMyUserId){
      isMyUserIdValid= false;
      this.errorMyUserId = '既に存在するユーザーIDです';
    }
    else if (text.length < 5 || text.length > 20) {
      isMyUserIdValid = false;
      this.errorMyUserId = 'ユーザーIDは5文字以上20文字以内です。';
    }
    else {
      isMyUserIdValid = true;
      this.errorMyUserId = '';
    }
    notifyListeners();
  }

  void changeConfirm(text) {
    this.confirm = text;
    if (text.length == 0) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードを再入力して下さい。';
    } else if (text.length < 8 || text.length > 20) {
      isConfirmValid = false;
      this.errorConfirm = 'パスワードは8文字以上20文字以内です。';
    } else {
      isConfirmValid = true;
      this.errorConfirm = '';
    }
    notifyListeners();
  }

  void changeTeamName(text) {
    this.teamName = text.trim();
    if (text.length == 0) {
      this.isTeamNameValid = false;
      this.errorTeamName = 'チーム名称を入力して下さい。';
    } else {
      this.isTeamNameValid = true;
      this.errorTeamName = '';
    }
    notifyListeners();
  }

  void changeMission(text) {
    this.mission = text.trim();
    if (text.length == 0) {
      this.isMissionValid = false;
      this.errorMission = 'チーム目標を入力して下さい。';
    } else {
      this.isMissionValid = true;
      this.errorMission = '';
    }
    notifyListeners();
  }

  void changeAddress(text) {
    this.address = text.trim();
    if (text.length == 0) {
      this.isAddressValid = false;
      this.errorAddress = '連絡先を入力して下さい。';
    } else {
      this.isAddressValid = true;
      this.errorAddress = '';
    }
    notifyListeners();
  }


  void tapAgreeCheckBox(val) {
    this.agreeGuideline = val;
    notifyListeners();
  }

  void showDialog() {
    this.showingDialog = true;
    notifyListeners();
  }

  void hideDialog() {
    this.showingDialog = false;
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
  Future passWordCheck(
      ) async {
    if (this.password != this.confirm) {
      throw ('パスワードが一致しません。');
    }
  }

  Future<void> sendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

}