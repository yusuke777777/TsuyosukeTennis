import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../Common/CHomePageSetting.dart';
import '../Common/CSinglesRankModel.dart';
import '../Common/CfriendsList.dart';
import '../Common/CmatchList.dart';
import '../Common/CmatchResult.dart';
import '../Common/Cmessage.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CactivityList.dart';
import '../Common/CtalkRoom.dart';
import 'TsMethod.dart';

class FirestoreMethod {
  String Uid = '';
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final profileRef = _firestoreInstance.collection('myProfile');
  static final matchRef = _firestoreInstance.collection('matchList');
  static final friendsListRef = _firestoreInstance.collection('friendsList');
  static final matchResultRef = _firestoreInstance.collection('matchResult');

  //ランキングリスト
  static final manSinglesRankRef =
      _firestoreInstance.collection('manSinglesRank');
  static final manRankSnapshot = manSinglesRankRef.snapshots();

  static final femailesSinglesRankRef =
      _firestoreInstance.collection('femailSinglesRank');

  //トークルームコレクション
  static final roomRef = _firestoreInstance.collection('talkRoom');
  static final roomSnapshot = roomRef.snapshots();
  static bool roomCheck = false;

  //マッチング一覧
  static final matchListSnapshot = matchRef.snapshots();

  //友人一覧
  static final friendsListSnapshot = friendsListRef.snapshots();

  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  //プロフィール情報設定
  static Future<void> makeProfile(CprofileSetting profile) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String today = outputFormat.format(now);

    try {
      await profileRef.doc(auth.currentUser!.uid).set({
        'USER_ID': auth.currentUser!.uid,
        'PROFILE_IMAGE': profile.PROFILE_IMAGE,
        'NICK_NAME': profile.NICK_NAME,
        'TOROKU_RANK': profile.TOROKU_RANK,
        'AGE': profile.AGE,
        'GENDER': profile.GENDER,
        'COMENT': profile.COMENT,
        'koushinYmd': today,
      });
    } catch (e) {
      print('ユーザー登録に失敗しました --- $e');
    }

    profile.activityList.forEach((a) async {
      try {
        await profileRef
            .doc(auth.currentUser!.uid)
            .collection("activityList")
            .doc("ActivityNo" + a.No)
            .set({
          'No': a.No,
          'TODOFUKEN': a.TODOFUKEN,
          'SHICHOSON': a.SHICHOSON.text
        });
      } catch (e) {
        print('ユーザー登録に失敗しました --- $e');
      }
    });
  }

  /**
   * ログインしているユーザのドキュメントを取得するメソッド
   */
  static String? getUid() {
    final snapshot = FirebaseAuth.instance.currentUser;
    return snapshot?.uid;
  }

  /**
   *ドキュメントをキーに指定コレクションから指定フィールドを取得するメソッド
   * uid ドキュメント
   * collection 取得したいFireBaseのコレクション
   * field 取得したいコレクション内のuidがもつフィールド
   * return
   */
  static Future<String> getMyProfileRecord(uid, collection, field) async {
    String fieldValue = '';
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(uid)
          .get();
      fieldValue = snapShot.data()![field];
    } catch (e) {
      return fieldValue;
    }
    return fieldValue;
  }

  /**
   *ドキュメントをキーに指定コレクションから指定フィールドをリスト型で取得するメソッド
   * uid ドキュメント
   * return　フィールドプロパティのリスト
   */
  static Future<List<String>> getNickNameAndTorokuRank(uid) async {
    List<String> stringList = [];
    final snapShot =
        await FirebaseFirestore.instance.collection('myProfile').doc(uid).get();
    String name = snapShot.data()!['NICK_NAME'];
    String rank = snapShot.data()!['TOROKU_RANK'];
    String id = snapShot.data()!['USER_ID'];
    String image = snapShot.data()!['PROFILE_IMAGE'];

    late String manSingleRank;
    if (rank =="初級") {
      manSingleRank ="ShokyuRank";
    }
    else if (rank =="中級"){
      manSingleRank ="ChukyuRank";
    }

    else if (rank =="上級") {
      manSingleRank ="JoukyuRank";
    }

    final snapShot_msr =
    await FirebaseFirestore.instance.collection('manSinglesRank').doc(manSingleRank).collection('RankList').doc(id).get();

    int rank_no = snapShot_msr.data()!['RANK_NO'];

    if (snapShot == null) {
      return stringList;
    }

    stringList.add(name);
    stringList.add(rank);
    stringList.add(id);
    stringList.add(image);
    stringList.add(rank_no.toString());


    return stringList;
  }

  /**
   *ドキュメントをキーに指定コレクションから指定フィールドをリスト型で取得するメソッド
   * uid ドキュメント
   * return　フィールドプロパティのリスト
   */
  static Future<List<String>> getNickNameAndProfile(uid) async {
    List<String> stringList = [];
    final snapShot =
        await FirebaseFirestore.instance.collection('myProfile').doc(uid).get();

    if (snapShot.data() == null) {
      return stringList;
    }

    String name = snapShot.data()!['NICK_NAME'];
    String profile = snapShot.data()!['PROFILE_IMAGE'];
    if (snapShot == null) {
      return stringList;
    }

    stringList.add(name);
    stringList.add(profile);
    return stringList;
  }

  /**
   *ドキュメントをキーに指定コレクションから指定フィールドをリスト型で取得するメソッド
   * uid ドキュメント
   * return　フィールドプロパティのリスト
   */
  static Future<CHomePageSetting> getHomePageStatus(
      uid, todofuken, sicyouson, rank) async {
    final snapShot =
        await FirebaseFirestore.instance.collection('myProfile').doc(uid).get();
    String name = snapShot.data()!['NICK_NAME'];
    String rank = snapShot.data()!['TOROKU_RANK'];
    return CHomePageSetting(NICK_NAME: name, TOROKU_RANK: rank);
  }

  static Future<CprofileSetting> getProfile() async {
    final snapShot = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(auth.currentUser!.uid)
        .get();

    String USER_ID = auth.currentUser!.uid;
    String PROFILE_IMAGE = snapShot.data()!['PROFILE_IMAGE'];
    String NICK_NAME = snapShot.data()!['NICK_NAME'];
    String TOROKU_RANK = snapShot.data()!['TOROKU_RANK'];
    String AGE = snapShot.data()!['AGE'];
    String GENDER = snapShot.data()!['GENDER'];
    String COMENT = snapShot.data()!['COMENT'];

    final snapShotActivity = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(auth.currentUser!.uid)
        .collection("activityList")
        .get();

    List<CativityList> activityList = [];

    await Future.forEach<dynamic>(snapShotActivity.docs, (doc) async {
      activityList.add(CativityList(
        No: doc.data()['No'],
        TODOFUKEN: doc.data()['TODOFUKEN'],
        SHICHOSON: TextEditingController(text: doc.data()['SHICHOSON']),
      ));
    });

    CprofileSetting cprofileSet = await CprofileSetting(
        USER_ID: USER_ID,
        PROFILE_IMAGE: PROFILE_IMAGE,
        NICK_NAME: NICK_NAME,
        TOROKU_RANK: TOROKU_RANK,
        activityList: activityList,
        AGE: AGE,
        GENDER: GENDER,
        COMENT: COMENT);

    return cprofileSet;
  }

  static Future<CprofileSetting> getYourProfile(String userId) async {
    final snapShot = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(userId)
        .get();

    String USER_ID = userId;
    String PROFILE_IMAGE = snapShot.data()!['PROFILE_IMAGE'];
    String NICK_NAME = snapShot.data()!['NICK_NAME'];
    String TOROKU_RANK = snapShot.data()!['TOROKU_RANK'];
    String AGE = snapShot.data()!['AGE'];
    String GENDER = snapShot.data()!['GENDER'];
    String COMENT = snapShot.data()!['COMENT'];

    final snapShotActivity = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(userId)
        .collection("activityList")
        .get();

    List<CativityList> activityList = [];

    await Future.forEach<dynamic>(snapShotActivity.docs, (doc) async {
      activityList.add(CativityList(
        No: doc.data()['No'],
        TODOFUKEN: doc.data()['TODOFUKEN'],
        SHICHOSON: TextEditingController(text: doc.data()['SHICHOSON']),
      ));
    });

    CprofileSetting cprofileSet = await CprofileSetting(
        USER_ID: USER_ID,
        PROFILE_IMAGE: PROFILE_IMAGE,
        NICK_NAME: NICK_NAME,
        TOROKU_RANK: TOROKU_RANK,
        activityList: activityList,
        AGE: AGE,
        GENDER: GENDER,
        COMENT: COMENT);

    return cprofileSet;
  }

  static Future<String> upload(File? profileImage) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String imageURL = '';
    try {
      if (profileImage != null) {
        await storage
            .ref()
            .child('myProfileImage/${auth.currentUser!.uid}/photos')
            .child("myProfile.jpg")
            .putFile(profileImage);
      }
      imageURL = await storage
          .ref()
          .child('myProfileImage/${auth.currentUser!.uid}/photos')
          .child("myProfile.jpg")
          .getDownloadURL();
    } catch (e) {
      print(e);
    }
    return imageURL;
  }

  /**
   * トークルームを作成するメソッドです
   * myuserID ログインユーザのID
   * youruserID トーク相手のID
   * TalkRoom.dartの引数となるTalkRoomModelを返す
   */
  static Future<TalkRoomModel> makeRoom(
      String myuserId, String youruserID) async {
    late TalkRoomModel room;
    await checkRoom(myuserId, youruserID);
    if (roomCheck) {
      room = await getRoomBySearchResult(myuserId, youruserID);
      return room;
    } else {
      try {
        await roomRef.add({
          'joined_user_ids': [myuserId, youruserID],
          'updated_time': Timestamp.now()
        });
        room = await getRoomBySearchResult(myuserId, youruserID);
      } catch (e) {
        print('トークルーム作成に失敗しました --- $e');
      }
      return room;
    }
  }

  /**
   * 相手とのトークルームが既に存在するかどうかチェックするメソッドです
   */
  static Future<void> checkRoom(String myUserId, String yourUserID) async {
    final snapshot = await roomRef.get();
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId)) {
        doc.data()['joined_user_ids'].forEach((id) {
          if (id == yourUserID) {
            roomCheck = true;
          }
          return;
        });
      }
    });
  }

  /**
   * 検索結果一覧からトークルームを取得するメソッド
   * myuserID ログインユーザのID
   * youruserID トーク相手のID
   * talkRoomコレクションを回して該当するデータのprofileを引数にTalkRoomModelを生成
   *
   */
  static Future<TalkRoomModel> getRoomBySearchResult(
      String myUserId, String yourUserId) async {
    final snapshot = await roomRef.get();
    late TalkRoomModel room;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId) &&
          doc.data()['joined_user_ids'].contains(yourUserId)) {
        CprofileSetting yourProfile = await getYourProfile(yourUserId);
        room = TalkRoomModel(
            roomId: doc.id,
            user: yourProfile,
            lastMessage: doc.data()['last_message'] ?? '');
      }
    });
    return room;
  }

  static Future<List<TalkRoomModel>> getRooms(String myUserId) async {
    final snapshot = await roomRef.get();
    List<TalkRoomModel> roomList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId)) {
        late String yourUserId;
        doc.data()['joined_user_ids'].forEach((id) {
          if (id != myUserId) {
            yourUserId = id;
            return;
          }
        });
        CprofileSetting yourProfile = await getYourProfile(yourUserId);
        TalkRoomModel room = TalkRoomModel(
            roomId: doc.id,
            user: yourProfile,
            lastMessage: doc.data()['last_message'] ?? '');
        roomList.add(room);
      }
    });
    return roomList;
  }

  static Future<TalkRoomModel> getRoom(String RECIPIENT_ID, String SENDER_ID,
      CprofileSetting yourProfile) async {
    final snapshot = await roomRef.get();
    late TalkRoomModel room;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      late String yourUserId;
      if (doc.data()['joined_user_ids'].contains(RECIPIENT_ID)) {
        if (doc.data()['joined_user_ids'].contains(SENDER_ID)) {
          room = TalkRoomModel(
              roomId: doc.id,
              user: yourProfile,
              lastMessage: doc.data()['last_message'] ?? '');
        }
      }
    });
    return room;
  }

  static Future<List<Message>> getMessages(String roomId) async {
    final messageRef = roomRef
        .doc(roomId)
        .collection('message')
        .orderBy('send_time', descending: true);
    List<Message> messageList = [];
    final snapshot = await messageRef.get();
    Future.forEach<dynamic>(snapshot.docs, (doc) async {
      bool isMe;
      if (doc.data()['sender_id'] == auth.currentUser!.uid) {
        isMe = true;
      } else {
        isMe = false;
      }
      Message message = Message(
          messageId: doc.id,
          message: doc.data()['message'],
          isMe: isMe,
          sendTime: doc.data()['send_time'],
          matchStatusFlg: doc.data()['matchStatusFlg'],
          friendStatusFlg: doc.data()['friendStatusFlg']);
      messageList.add(message);
    });
    messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));
    return messageList;
  }

  static Future<void> sendMessage(String roomId, String message) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = auth.currentUser!.uid;
    await messageRef.add({
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0"
    }).then((value) {
      messageRef.doc(value.id).update({'messageId': value.id});
    });
    roomRef.doc(roomId).update({'last_message': message});
  }

  static Stream<QuerySnapshot> messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }

  //試合申請メッセージ
  static Future<void> sendMatchMessage(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = auth.currentUser!.uid;
    await messageRef.add({
      'message': "対戦お願いします！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "1",
      'friendStatusFlg': "0"
    }).then((value) {
      messageRef.doc(value.id).update({'messageId': value.id});
    });
    roomRef.doc(roomId).update({'last_message': "対戦お願いします！"});
  }

  static Future<void> sendFriendMessage(String roomId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = auth.currentUser!.uid;
    await messageRef.add({
      'message': "友達登録お願いします！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "1"
    }).then((value) {
      messageRef.doc(value.id).update({'messageId': value.id});
    });
    roomRef.doc(roomId).update({'last_message': "友達登録お願いします！"});
  }

  /**
   * 条件で検索時の入力値を参照して対象データの名前を取得するメソッドです
   * 都道府県
   * 市町村
   * 性別
   * ランク
   * 年齢
   * 市町村以外は''で来ることはない
   */
  static Future<List<List<String>>> getFindMultiResult(String todofuken,
      String shichoson, String gender, String rank, String age) async {
    List<List<String>> resultList = [];
    List<String> nameList = [];
    List<String> profileList = [];
    List<String> idList = [];

    //コレクション「myProfile」から該当データを絞る
    final snapShot = await FirebaseFirestore.instance
        .collection('myProfile')
        .where('GENDER', isEqualTo: gender)
        .where('TOROKU_RANK', isEqualTo: rank)
        .where('AGE', isEqualTo: age)
        .get();

    await Future.forEach<dynamic>(snapShot.docs, (document) async {
      final snapShot_sub = await FirebaseFirestore.instance
          .collection('myProfile')
          .doc(document.id)
          .collection('activityList')
          .get();

      //各ユーザーの表示回数を１回に制限
      int count = 0;
      await Future.forEach<dynamic>(snapShot_sub.docs, (doc) async {
        if (doc.data()['TODOFUKEN'] == todofuken && count == 0) {
          if (shichoson == '') {
            nameList.add(document.get('NICK_NAME'));
            profileList.add(document.get('PROFILE_IMAGE'));
            idList.add(document.get('USER_ID'));
            resultList.add(nameList);
            resultList.add(profileList);
            resultList.add(idList);
            count++;
          } else if (doc.data()['SHICHOSON'] == shichoson && count == 0) {
            nameList.add(document.get('NICK_NAME'));
            profileList.add(document.get('PROFILE_IMAGE'));
            idList.add(document.get('USER_ID'));
            resultList.add(nameList);
            resultList.add(profileList);
            resultList.add(idList);
            count++;
          }
        }
      });
    });
    return resultList;
  }

  //試合申請受け入れ
  static Future<void> matchAccept(String roomId, String messageId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = auth.currentUser!.uid;

    await messageRef.doc(messageId).update({'matchStatusFlg': "2"});

    await messageRef.add({
      'message': "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0"
    }).then((value) {
      messageRef.doc(value.id).update({'messageId': value.id});
    });
    ;
    roomRef
        .doc(roomId)
        .update({'last_message': "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！"});
  }

  //友人申請受け入れ
  static Future<void> friendAccept(String roomId, String messageId) async {
    final messageRef = roomRef.doc(roomId).collection('message');
    String? myUid = auth.currentUser!.uid;

    await messageRef.doc(messageId).update({'friendStatusFlg': "2"});

    await messageRef.add({
      'message': "友人申請を受け入れました。\n友人一覧を確認してみよう！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0"
    }).then((value) {
      messageRef.doc(value.id).update({'messageId': value.id});
    });
    roomRef
        .doc(roomId)
        .update({'last_message': "友人申請を受け入れました。\n友人一覧を確認してみよう！"});
  }

  static Future<void> addMatchList(String roomId) async {
    final snapShot = await roomRef.doc(roomId).get();
    String joinedUser1 = snapShot.data()!['joined_user_ids'][0];
    String joinedUser2 = snapShot.data()!['joined_user_ids'][1];
    late String myUserId;
    late String yourUserID;
    if (joinedUser1 == auth.currentUser!.uid) {
      myUserId = joinedUser1;
      yourUserID = joinedUser2;
    } else {
      myUserId = joinedUser2;
      yourUserID = joinedUser1;
    }

    try {
      await roomRef.add({
        'joined_user_ids': [myUserId, yourUserID],
        'updated_time': Timestamp.now()
      });
    } catch (e) {
      print('マッチング一覧の作成に失敗しました --- $e');
    }
  }

  //対戦マッチ一覧に追加
  static Future<void> makeMatch(TalkRoomModel talkRoom) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);

    try {
      await matchRef.add({
        'RECIPIENT_ID': auth.currentUser!.uid,
        'SENDER_ID': talkRoom.user.USER_ID,
        'SAKUSEI_TIME': today,
        'MATCH_FLG': '1',
      }).then((value) {
        matchRef.doc(value.id).update({'MATCH_ID': value.id});
      });
    } catch (e) {
      print('マッチングに失敗しました --- $e');
    }
  }

  static Future<List<MatchListModel>> getMatchList(String myUserId) async {
    final snapshot = await matchRef.get();
    List<MatchListModel> matchList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['RECIPIENT_ID'].contains(myUserId)) {
        CprofileSetting yourProfile =
            await getYourProfile(doc.data()['SENDER_ID']);
        CprofileSetting myProfile =
            await getYourProfile(doc.data()['RECIPIENT_ID']);

        MatchListModel match = MatchListModel(
          MATCH_ID: doc.data()['MATCH_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          MATCH_FLG: doc.data()['MATCH_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
        matchList.add(match);
        print("aa");
      } else if (doc.data()['SENDER_ID'].contains(myUserId)) {
        CprofileSetting yourProfile =
            await getYourProfile(doc.data()['RECIPIENT_ID']);
        CprofileSetting myProfile =
            await getYourProfile(doc.data()['SENDER_ID']);
        MatchListModel match = MatchListModel(
          MATCH_ID: doc.data()['MATCH_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          MATCH_FLG: doc.data()['MATCH_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
        matchList.add(match);
      }
    });
    return matchList;
  }

  //マッチング一覧削除
  static void delMatchList(String delId, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('本当に削除して宜しいですか'),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent, onPrimary: Colors.black),
                child: Text('はい'),
                onPressed: () {
                  matchRef.doc(delId).delete();
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent, onPrimary: Colors.black),
                child: Text('いいえ'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  //対戦結果作成
  static Future<void> makeMatchResult(CprofileSetting myProfile,
      CprofileSetting yourProfile, List<CmatchResult> matchResultList) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);
    //勝ち負けフラグ 勝った場合にフラグ１とする
    late int MY_WIN_FLG;
    late int YOUR_WIN_FLG;
    //1試合あたりに加算されるTSPポイント
    int MY_TS_POINT_FUYO = 0;
    int YOUR_TS_POINT_FUYO = 0;
    //対戦結果登録で付与されるTSPポイント
    int MY_TS_POINT_FUYO_SUM = 0;
    int YOUR_TS_POINT_FUYO_SUM = 0;
    //現在のTSPポイント
    late int MY_TS_POINT_CUR;
    late int YOUR_TS_POINT_CUR;
    //対戦結果登録後のTSPポイント
    late int MY_TS_POINT;
    late int YOUR_TS_POINT;

    matchResultList.forEach((a) async {
      try {
        if (a.myGamePoint > a.yourGamePoint) {
          MY_WIN_FLG = 1;
          YOUR_WIN_FLG = 0;
          //付与TSポイントの算出
          MY_TS_POINT_FUYO = TsMethod.tsPointCalculation(
              myProfile.TOROKU_RANK, yourProfile.TOROKU_RANK, 1, 15);
          MY_TS_POINT_FUYO_SUM = MY_TS_POINT_FUYO_SUM + MY_TS_POINT_FUYO;
          YOUR_TS_POINT_FUYO = 0;
        } else {
          YOUR_WIN_FLG = 1;
          MY_WIN_FLG = 0;
          //付与TSポイントの算出
          YOUR_TS_POINT_FUYO = TsMethod.tsPointCalculation(
              yourProfile.TOROKU_RANK, myProfile.TOROKU_RANK, 15, 1);
          YOUR_TS_POINT_FUYO_SUM = YOUR_TS_POINT_FUYO_SUM + YOUR_TS_POINT_FUYO;
          MY_TS_POINT_FUYO = 0;
          print(YOUR_TS_POINT_FUYO);
        }
        matchResultRef
            .doc(myProfile.USER_ID)
            .collection('opponentList')
            .doc(yourProfile.USER_ID)
            .collection('matchDetail')
            .add({
          'MY_POINT': a.myGamePoint,
          'YOUR_POINT': a.yourGamePoint,
          'WIN_FLG': MY_WIN_FLG,
          'TS_POINT': MY_TS_POINT_FUYO,
          'KOUSHIN_TIME': today
        });
        matchResultRef
            .doc(yourProfile.USER_ID)
            .collection('opponentList')
            .doc(myProfile.USER_ID)
            .collection('matchDetail')
            .add({
          'MY_POINT': a.yourGamePoint,
          'YOUR_POINT': a.myGamePoint,
          'WIN_FLG': YOUR_WIN_FLG,
          'TS_POINT': YOUR_TS_POINT_FUYO,
          'KOUSHIN_TIME': today
        });
      } catch (e) {
        print('対戦結果入力に失敗しました --- $e');
      }
    });
    try {
      final mySnapShot = await matchResultRef.doc(myProfile.USER_ID).get();
      MY_TS_POINT_CUR = mySnapShot.data()!['TS_POINT'];
      final yourSnapShot = await matchResultRef.doc(yourProfile.USER_ID).get();
      YOUR_TS_POINT_CUR = yourSnapShot.data()!['TS_POINT'];
    } catch (e) {
      print('TSPポイントの取得に失敗しました --- $e');
    }
    try {
      MY_TS_POINT = MY_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
      YOUR_TS_POINT = YOUR_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
      matchResultRef.doc(myProfile.USER_ID).set({'TS_POINT': MY_TS_POINT,'TOROKU_RANK': myProfile.TOROKU_RANK});
      matchResultRef.doc(yourProfile.USER_ID).set({'TS_POINT': YOUR_TS_POINT,'TOROKU_RANK': yourProfile.TOROKU_RANK});
//      matchResultRef.doc(myProfile.USER_ID).set({'TOROKU_RANK': myProfile.TOROKU_RANK});
//      matchResultRef.doc(yourProfile.USER_ID).set({'TOROKU_RANK': yourProfile.TOROKU_RANK});
    } catch (e) {
      print('TSPポイントの付与に失敗しました --- $e');
    }
  }

  //友達一覧に追加
  static Future<void> makeFriends(TalkRoomModel talkRoom) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);

    try {
      await friendsListRef.add({
        'RECIPIENT_ID': auth.currentUser!.uid,
        'SENDER_ID': talkRoom.user.USER_ID,
        'SAKUSEI_TIME': today,
        'FRIENDS_FLG': '1',
      }).then((value) {
        friendsListRef.doc(value.id).update({'FRIENDS_ID': value.id});
      });
    } catch (e) {
      print('友達登録に失敗しました --- $e');
    }
  }

  //友人リスト取得
  static Future<List<FriendsListModel>> getFriendsList(String myUserId) async {
    final snapshot = await friendsListRef.get();
    List<FriendsListModel> friendsList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['RECIPIENT_ID'].contains(myUserId)) {
        CprofileSetting yourProfile =
            await getYourProfile(doc.data()['SENDER_ID']);
        CprofileSetting myProfile =
            await getYourProfile(doc.data()['RECIPIENT_ID']);

        FriendsListModel friends = FriendsListModel(
          FRIENDS_ID: doc.data()['FRIENDS_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
        friendsList.add(friends);
      } else if (doc.data()['SENDER_ID'].contains(myUserId)) {
        CprofileSetting yourProfile =
            await getYourProfile(doc.data()['RECIPIENT_ID']);
        CprofileSetting myProfile =
            await getYourProfile(doc.data()['SENDER_ID']);
        FriendsListModel friends = FriendsListModel(
          FRIENDS_ID: doc.data()['FRIENDS_ID'],
          RECIPIENT_ID: doc.data()['RECIPIENT_ID'],
          SENDER_ID: doc.data()['SENDER_ID'],
          SAKUSEI_TIME: doc.data()['SAKUSEI_TIME'],
          FRIENDS_FLG: doc.data()['FRIENDS_FLG'],
          MY_USER: myProfile,
          YOUR_USER: yourProfile,
        );
        friendsList.add(friends);
      }
    });
    return friendsList;
  }

  //友人リスト削除
  static void delFriendsList(String delId, BuildContext context) async {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('本当に削除して宜しいですか'),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent, onPrimary: Colors.black),
                child: Text('はい'),
                onPressed: () {
                  friendsListRef.doc(delId).delete();
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.lightGreenAccent, onPrimary: Colors.black),
                child: Text('いいえ'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  //男性シングルス・ランキングテーブルGET
  static Future<List<RankModel>> getManSinglesRank(String RankLevel) async {
    final snapshot =
        await manSinglesRankRef.doc(RankLevel).collection('RankList').get();
    List<RankModel> rankList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      String userId = doc.data()['USER_ID'];
      CprofileSetting yourProfile = await getYourProfile(userId);

      try {
        RankModel rankListWork = RankModel(
          rankNo: doc.data()['RANK_NO'],
          user: yourProfile,
          tpPoint: doc.data()['TS_POINT'],
        );
        rankList.add(rankListWork);
        rankList.sort((a, b) => b.rankNo.compareTo(a.rankNo));
      } catch (e) {
        print(e.toString());
      }
    });
    return rankList;
  }

  //女子シングルス・ランキングテーブルGET
  static Future<List<RankModel>> getFemailSinglesRank(String RankLevel) async {
    final snapshot = await femailesSinglesRankRef
        .doc(RankLevel)
        .collection('RankList')
        .get();
    List<RankModel> rankList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      String userId = doc.data()['USER_ID'];
      CprofileSetting yourProfile = await getYourProfile(userId);
      RankModel rankListWork = RankModel(
        rankNo: doc.data()['RANK_NO'],
        user: yourProfile,
        tpPoint: doc.data()['TP_POINT'],
      );
      rankList.add(rankListWork);
      rankList.sort((a, b) => b.rankNo.compareTo(a.rankNo));
    });
    return rankList;
  }

// static Future<void> downloadImage(String PresentValueWk) async {
//   FirebaseStorage storage = FirebaseStorage.instance;
//   // Reference imageRef = storage.ref().child("picture").child(PresentValueWk).child("que_004.jpg");
//   // imageUrl = await imageRef.getDownloadURL();
//
//   final result = await storage.ref().child("picture")
//       .child(PresentValueWk)
//       .listAll();
//   result.items.forEach((Reference ref) async {
//     await ref.getDownloadURL().then((value) {
//       String val = value.toString();
//       print(val);
//       // imageUrls.add(val);
//     });
//   });
// }

//   //各ユーザー歩数情報の取得
//   static Future<Pedmeter> getPedmeter() async {
//     DocumentSnapshot _PedmeterDoc =
//     await pedmeterRef.doc('${auth.currentUser!.uid}').get();
//     String zenStepDatewk = _PedmeterDoc.get('ZEN_STEPS_DATE');
//     DateTime now = DateTime.now();
//     DateTime tomorrow = DateTime(now.year, now.month, now.day + 1);
//     DateTime midnight = DateTime(now.year, now.month, now.day);
//     DateFormat outputFormat = DateFormat('yyyy-MM-dd');
//     String today = outputFormat.format(now);
//     int plusSteps = 0;
//     int zenSteps = 0;
//     zenSteps = _PedmeterDoc.get('TODAY_STEPS');
//
//     await HelthInfo().fetchStepData(now, midnight);
//
//     try {
//       housing = _PedmeterDoc.get('HOUSING');
//       todaySteps = HelthInfo.steps!.toInt();
//       todayKm = (todaySteps / 1290 * 100).round() / 100;
//       int sumStepsWk = _PedmeterDoc.get('SUM_STEPS');
//       int preSumStepsWk = _PedmeterDoc.get('PRESUMSTEPS');
//
//       if (today.compareTo(zenStepDatewk) == 1) {
//         plusSteps = todaySteps;
//       } else {
//         plusSteps = todaySteps - zenSteps;
//       }
//       sumSteps = sumStepsWk + plusSteps;
//       PreSumSteps = preSumStepsWk + plusSteps;
//
//       sumKm = (sumSteps / 1290 * 100).round() / 100;
//       ProgressRate = (PreSumSteps / PrezentVpedometer * 100).round() / 100;
//       print(ProgressRate);
//     } catch (e) {
//       print('歩数取得に失敗しました --- $e');
//     }
//     if (PreSumSteps >= PrezentVpedometer) {
//       await changePrefectures();
//       await getPedometer_manage();
//     } else {
//       try {
//         await pedmeterRef.doc(auth.currentUser!.uid).set({
//           'USER_ID': auth.currentUser!.uid,
//           'HOUSING': housing,
//           'TODAY_STEPS': todaySteps,
//           'SUM_STEPS': sumSteps,
//           'PRESENTV': PresentV,
//           'PRESUMSTEPS': PreSumSteps,
//           'ZEN_STEPS_DATE': today,
//         });
//       } catch (e) {
//         print('ユーザー登録に失敗しました --- $e');
//       }
//       PresentValue = OtherMethod().todofukenHenkanMethod(PresentV);
//       NextPresentValue =
//           OtherMethod().todofukenHenkanMethod(PrezentVnextPrefectures);
//     }
//
//
//     //画像データ取得
//     await downloadImage(PresentV);
//     // await buildTodofukenImage(imageUrls);
//
//     Pedmeter myPedmeter = Pedmeter(
//       USER_ID: _PedmeterDoc.get('USER_ID'),
//       HOUSING: _PedmeterDoc.get('HOUSING'),
//       TODAY_STEPS: _PedmeterDoc.get('TODAY_STEPS'),
//       SUM_STEPS: _PedmeterDoc.get('SUM_STEPS'),
//       PRESENTV: _PedmeterDoc.get('PRESENTV'),
//       PRESUMSTEPS: _PedmeterDoc.get('PRESUMSTEPS'),
//       ZEN_STEPS_DATE: _PedmeterDoc.get('ZEN_STEPS_DATE'),
//     );
//     return myPedmeter;
//   }
//
//   //歩数テーブルのスナップショット取得
//   static Stream<QuerySnapshot> pedmeterSnapshot() {
//     return pedmeterRef
//         .doc(auth.currentUser!.uid)
//         .collection('PEDOMETER_TBL')
//         .snapshots();
//   }
//
//   Map<String, String> todofukenHenkan = {
//     "北海道": "Hokkaido",
//     "青森県": "Aomori",
//     "岩手県": "Iwate",
//     "宮城県": "Miyagi",
//     "秋田県": "Akita",
//     "山形県": "Yamagata",
//     "福島県": "Fukushima",
//     "茨城県": "Ibaraki",
//     "栃木県": "Tochigi",
//     "群馬県": "Gunma",
//     "埼玉県": "Saitama",
//     "千葉県": "Chiba",
//     "東京都": "Tokyo",
//     "神奈川県": "Kanagawa",
//     "新潟県": "Nigata",
//     "富山県": "Toyama",
//     "石川県": "Ishikawa",
//     "福井県": "Hukui",
//     "山梨県": "Yamanashi",
//     "長野県": "Nagano",
//     "岐阜県": "Gifu",
//     "静岡県": "Shizuoka",
//     "愛知県": "Aichi",
//     "三重県": "Mie",
//     "滋賀県": "Shiga",
//     "京都府": "Kyoto",
//     "大阪府": "Osaka",
//     "兵庫県": "Hyogo",
//     "奈良県": "Nara",
//     "和歌山県": "Wakayama",
//     "鳥取県": "Tottori",
//     "島根県": "Shimane",
//     "岡山県": "Okayama",
//     "広島県": "Hiroshima",
//     "山口県": "Yamaguchi",
//     "徳島県": "Tokushima",
//     "香川県": "Kagawa",
//     "愛媛県": "Ehime",
//     "高知県": "Kochi",
//     "福岡県": "Fukuoka",
//     "佐賀県": "Saga",
//     "長崎県": "Nagasaki",
//     "熊本県": "Kumamoto",
//     "大分県": "Oita",
//     "宮崎県": "Miyazaki",
//     "鹿児島県": "Kagoshima",
//     "沖縄県": "Okinawa"
//   };
//
//   //都道府県名称(日本語)からKEY(アルファベット)へ変換
//   Future<void> todofukenHenkanMethod(String taishoTodofuken) async {
//     String? todofukenHenkango = "0";
//     todofukenHenkango = todofukenHenkan[taishoTodofuken].toString();
//     PresentV = todofukenHenkango;
//   }
//
//   //現在地の取得
//   static Future<void> getPresentValue() async {
//     DocumentSnapshot _PedmeterDoc =
//     await pedmeterRef.doc('${auth.currentUser!.uid}').get();
//     try {
//       PresentV = _PedmeterDoc.get('PRESENTV');
//     } catch (e) {
//       print('現在地の取得に失敗しました --- $e');
//     }
//   }
//
//   //現在の都道府県の情報を取得する
//   static Future<void> getPedometer_manage() async {
//     DocumentSnapshot _PedmeterManageDoc =
//     await pedometer_manageRef.doc(PresentV).get();
//     try {
//       PrezentVnextPrefectures = _PedmeterManageDoc.get('NextPrefectures');
//       PrezentVimagePath = _PedmeterManageDoc.get('ImagePath');
//       PrezentVpedometer = _PedmeterManageDoc.get('Pedometer');
//     } catch (e) {
//       print('現在の情報の取得に失敗しました --- $e');
//     }
//   }
//
//   //現在の都道府県に必要な歩数に達した時に実行し、ユーザーの歩数テーブル情報を更新する
//   static Future<void> changePrefectures() async {
//     PresentV = PrezentVnextPrefectures;
//     PreSumSteps = PreSumSteps - PrezentVpedometer;
//     DateTime now = DateTime.now();
//     DateFormat outputFormat = DateFormat('yyyy-MM-dd');
//     String today = outputFormat.format(now);
//     try {
//       await pedmeterRef.doc(auth.currentUser!.uid).set({
//         'USER_ID': auth.currentUser!.uid,
//         'HOUSING': housing,
//         'TODAY_STEPS': todaySteps,
//         'SUM_STEPS': sumSteps,
//         'PRESENTV': PresentV,
//         'PRESUMSTEPS': PreSumSteps,
//         'ZEN_STEPS_DATE': today,
//       });
//     } catch (e) {
//       print('ユーザー登録に失敗しました --- $e');
//     }
//     PresentValue = OtherMethod().todofukenHenkanMethod(PresentV);
//     NextPresentValue =
//         OtherMethod().todofukenHenkanMethod(PrezentVnextPrefectures);
//     ProgressRate = (PreSumSteps / PrezentVpedometer * 100).round() / 100;
//   }
//
//   static Future<void> downloadImage(String PresentValueWk) async {
//     FirebaseStorage storage = FirebaseStorage.instance;
//     // Reference imageRef = storage.ref().child("picture").child(PresentValueWk).child("que_004.jpg");
//     // imageUrl = await imageRef.getDownloadURL();
//
//     final result = await storage.ref().child("picture")
//         .child(PresentValueWk)
//         .listAll();
//     result.items.forEach((Reference ref) async {
//       await ref.getDownloadURL().then((value) {
//         String val = value.toString();
//         print(val);
//         imageUrls.add(val);
//       });
//     });
//   }
//
// // static List<Widget> buildTodofukenImage(List<String> list) {
// //   List<Widget> todofukenImageList = [];
// //   for (var i = 0; i < list.length; i++) {
// //     todofukenImageList.add(Container(
// //         child:
// //         Image.network(
// //             FirestoreMethod.imageUrls[0],
// //             fit: BoxFit.cover,
// //             width: 300,
// //             height: 200)));
// //   }
// //   return todofukenImageList;
// // }
}
