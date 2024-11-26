import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tsuyosuke_tennis_ap/Page/ThankYouPage.dart';

import '../PropSetCofig.dart';
import 'SigninPage.dart';

class UnsubscribePage extends StatefulWidget {
  @override
  _UnsubscribeState createState() => _UnsubscribeState();
}

class _UnsubscribeState extends State<UnsubscribePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "退会");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _showConfirmationDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // 背景色を設定
              ),
              child: Text('アカウント削除を行う'),
            ),
            Text(
              '⚠️退会するとこれまでのデータは失われます！',
              style: TextStyle(
                fontSize: 15,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),

    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('アカウント削除の確認'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'メールアドレス',
                  labelStyle: TextStyle(
                    color: Colors.green, // labelTextのテキスト色を設定
                  ),
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'パスワード',
                  labelStyle: TextStyle(
                    color: Colors.green, // labelTextのテキスト色を設定
                  ),),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // ダイアログを閉じる
              },
              child: Text('キャンセル',
                  style: TextStyle(
                    color: Colors.green, // 文字色を設定
                  ),),
            ),
            TextButton(
              onPressed: () async {
                // メールアドレスとパスワードで認証し、正しければアカウントを削除
                if (await _authenticateAndDelete()) {
                  Navigator.of(context).pop(); // ダイアログを閉じる
                  // ログアウト後の画面に遷移
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) =>  ThankYouPage()),
                        (Route<dynamic> route) => false,
                  );
                } else {
                  // 認証失敗時の処理
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('メールアドレスまたはパスワードが正しくありません'),
                    ),
                  );
                }
              },
              child: Text('削除',
                style: TextStyle(
        color: Colors.green, // 文字色を設定
        ),),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _authenticateAndDelete() async {
    try {
      String email = _emailController.text;
      String password = _passwordController.text;

      // 現在のユーザーを取得
      User? user = FirebaseAuth.instance.currentUser;
      FirebaseFirestore storeInst = FirebaseFirestore.instance;
      String userId = user!.uid;

      // パスワードで再認証
      var credential = EmailAuthProvider.credential(email: email, password: password);
      await user?.reauthenticateWithCredential(credential);

      //コレクションの該当データを削除
      //MySetting
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_MySetting =
      await storeInst.collection('MySetting').doc(userId).get();
      if(documentSnapshot_MySetting.exists){
        storeInst.collection('MySetting').doc(userId).delete();
      }
      //blockList
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_blockList =
      await storeInst.collection('blockList').doc(userId).get();
      if(documentSnapshot_blockList.exists){
        storeInst.collection('blockList').doc(userId).delete();
      }
      //friendList
      final collection_friendList = storeInst.collection('friendsList');
      try {
        final snapshot_friendList = await collection_friendList.where('FRIEND_USER_LIST', arrayContains: userId).get();
        for (var doc in snapshot_friendList.docs) {
          await doc.reference.delete();
        }
      }
      catch(e) {
        print("友人リスト削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //manSinglesRank
      //初級
      try {
        final subcollection_ShokyuRank_doc = storeInst.collection('manSinglesRank')
            .doc("ShokyuRank").collection("RankList").doc(userId);
        await subcollection_ShokyuRank_doc.delete();
      }
      catch(e) {
        print("初級データ削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //中級
      try {
        final subcollection_ChukyuRank_doc = storeInst.collection('manSinglesRank')
            .doc("ChukyuRank").collection("RankList").doc(userId);
        await subcollection_ChukyuRank_doc.delete();
      }
      catch(e) {
        print("中級データ削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //上級
      try {
        final subcollection_JyokyuRank_doc = storeInst.collection('manSinglesRank')
            .doc("JyokyuRank").collection("RankList").doc(userId);
        await subcollection_JyokyuRank_doc.delete();
      }
      catch(e) {
        print("上級データ削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //matchList
      final collection_matchList = storeInst.collection('matchList');
      try {
        final snapshot_matchList = await collection_matchList.where('MATCH_USER_LIST', arrayContains: userId).get();
        for (var doc in snapshot_matchList.docs) {
          await doc.reference.delete();
        }
      }
      catch(e) {
        print("マッチリスト削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //matchResult
      try {
        //matchResult
        final subcollection_matchResult_doc = storeInst.collection('matchResult').doc(userId);
        //opponentList
        final CollectionReference<Map<String, dynamic>> documentSnapshot_opponentList =
        await storeInst.collection('matchResult').doc(userId).collection("opponentList");
        final opponentListDocument = documentSnapshot_opponentList.get();
        QuerySnapshot<Map<String, dynamic>> opponentList = await opponentListDocument;

        //サブコレ対応
        opponentList.docs.forEach((doc) async {
          //daily取得
          final CollectionReference<Map<String, dynamic>> documentSnapshot_daily =
          doc.reference.collection('daily');
          final dailyDocument = documentSnapshot_daily.get();
          QuerySnapshot<Map<String, dynamic>> daily = await dailyDocument;
          //dailyを回しmatchDetailを取得
          daily.docs.forEach((doc_daily) async {
            //matchDetail取得
            final CollectionReference<Map<String, dynamic>> documentSnapshot_matchDetail =
            doc_daily.reference.collection('matchDetail');
            final matchDetailDocument = documentSnapshot_matchDetail.get();
            QuerySnapshot<Map<String, dynamic>> matchDetail = await matchDetailDocument;
            matchDetail.docs.forEach((doc_matchDetail) async {
              doc_matchDetail.reference.delete();
            });
            doc_daily.reference.delete();
          });
          doc.reference.delete();
        });
        await subcollection_matchResult_doc.delete();
      }
      catch(e) {
        print("matchResultデータ削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //myNotification
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_myNotification =
      await storeInst.collection('myNotification').doc(userId).get();
      final CollectionReference<Map<String, dynamic>> documentSnapshot_myNotificationSub =
      await storeInst.collection('myNotification').doc(userId).collection("talkNotification");
      final talkNotificationDocument = documentSnapshot_myNotificationSub.get();
      QuerySnapshot<Map<String, dynamic>> talkNotification = await talkNotificationDocument;
      if(documentSnapshot_myNotification.exists){
        //サブコレ削除
        talkNotification.docs.forEach((doc) {
          doc.reference.delete();
        });
        storeInst.collection('myNotification').doc(userId).delete();
      }
      //myProfile
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_myProfile =
      await storeInst.collection('myProfile').doc(userId).get();
      final CollectionReference<Map<String, dynamic>> documentSnapshot_myProfileSub =
      await storeInst.collection('myProfile').doc(userId).collection("activityList");
      final activListDocument = documentSnapshot_myProfileSub.get();
      if(documentSnapshot_myProfile.exists){
        //activityList削除
        QuerySnapshot<Map<String, dynamic>> activList = await activListDocument;
        activList.docs.forEach((doc) {
          doc.reference.delete();
        });
        //myProfileのdoc削除
        storeInst.collection('myProfile').doc(userId).delete();
      }
      //myProfileDetail
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_myProfileDetail =
      await storeInst.collection('myProfileDetail').doc(userId).get();
      if(documentSnapshot_myProfileDetail.exists){
        storeInst.collection('myProfileDetail').doc(userId).delete();
      }
      //talkRoom
      final collection_talkRoom = storeInst.collection('talkRoom');
      try {
        final snapshot_talkRoom = await collection_talkRoom.where('joined_user_ids', arrayContains: userId).get();
        for (var doc in snapshot_talkRoom.docs) {
          await doc.reference.delete();
        }
      }
      catch(e) {
        print("トークリスト削除に失敗" + userId + "を含むデータ");
        print(e);
      }
      //userLimitMgmt
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_userLimitMgmt =
      await storeInst.collection('userLimitMgmt').doc(userId).get();
      if(documentSnapshot_userLimitMgmt.exists){
        storeInst.collection('userLimitMgmt').doc(userId).delete();
      }
      //userTicketMgmt
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_userTicketMgmt =
      await storeInst.collection('userTicketMgmt').doc(userId).get();
      if(documentSnapshot_userTicketMgmt.exists){
        storeInst.collection('userTicketMgmt').doc(userId).delete();
      }
      //userTokenList
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot_userTokenList =
      await storeInst.collection('userTokenList').doc(userId).get();
      if(documentSnapshot_userTokenList.exists){
        storeInst.collection('userTokenList').doc(userId).delete();
      }
      //ストレージ配下のプロフィール画像削除
      final storageRef = FirebaseStorage.instance.ref();
      final deleteRef = storageRef.child("/myProfileImage/" + userId.toString() +"/photos/");
      final listResult = await deleteRef.listAll();
      // 各画像ファイルを削除
      for (final item in listResult.items) {
        await item.delete();
      }
      print('File deleted successfully.');


      // ユーザーアカウントを削除
      await user?.delete();

      print('ユーザーアカウントが削除されました');
      return true; // 認証成功
    } catch (e) {
      print('ユーザーアカウントの削除に失敗しました: $e');
      return false; // 認証失敗
    }
  }
}
