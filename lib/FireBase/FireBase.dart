import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tsuyosuke_tennis_ap/Common/CHomePageVal.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRef.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRefHistory.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';

import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CHomePageSetting.dart';
import '../Common/CSinglesRankModel.dart';
import '../Common/CblockList.dart';
import '../Common/CfriendsList.dart';
import '../Common/CmatchList.dart';
import '../Common/CmatchResult.dart';
import '../Common/CmatchResultsList.dart';
import '../Common/Cmessage.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CactivityList.dart';
import '../Common/CtalkRoom.dart';
import 'NotificationMethod.dart';
import 'TsMethod.dart';

class FirestoreMethod {
  String Uid = '';
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final profileRef = _firestoreInstance.collection('myProfile');
  static final matchRef = _firestoreInstance.collection('matchList');
  static final friendsListRef = _firestoreInstance.collection('friendsList');
  static final matchResultRef = _firestoreInstance.collection('matchResult');
  static final skilLevelRef = _firestoreInstance.collection('SkilLevel');
  static final feedBackRef = _firestoreInstance.collection('feedBack');
  static final blockRef = _firestoreInstance.collection('blockList');
  static final settingRef = _firestoreInstance.collection('MySetting');

  //ランキングリスト
  static final manSinglesRankRef =
      _firestoreInstance.collection('manSinglesRank');
  static final manRankSnapshot = manSinglesRankRef.snapshots();

  static final femailesSinglesRankRef =
      _firestoreInstance.collection('femailSinglesRank');

  //トークルームコレクション
  static final roomRef = _firestoreInstance.collection('talkRoom');
  static final roomSnapshot = roomRef.snapshots();

  //マッチング一覧
  static final matchListSnapshot = matchRef.snapshots();

  //マッチング結果一覧
  static final matchResultListSnapshot = matchResultRef.snapshots();

  //友人一覧
  static final friendsListSnapshot = friendsListRef.snapshots();

  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  //ブロックリスト
  static final blockListRef = _firestoreInstance.collection('blockList');

  //ユーザー向けメッセージ取得
  static final toUserMessageRef =
      _firestoreInstance.collection('toUserMessage');

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
        'MY_USER_ID': profile.MY_USER_ID
      });
    } catch (e) {
      print('ユーザー登録に失敗しました --- $e');
    }

    //アクティビティリスト削除
    final snapshot = await profileRef
        .doc(auth.currentUser!.uid)
        .collection("activityList")
        .get();

    final snapshotActivity =
        await profileRef.doc(auth.currentUser!.uid).collection("activityList");

    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      snapshotActivity.doc(doc.id).delete();
    });

    int No = 0;

    for (int index = 0; index < profile.activityList.length; index++) {
      if (profile.activityList[index].TODOFUKEN != "") {
        try {
          await profileRef
              .doc(auth.currentUser!.uid)
              .collection("activityList")
              .doc("ActivityNo" + No.toString())
              .set({
            'No': No.toString(),
            'TODOFUKEN': profile.activityList[index].TODOFUKEN,
            'SHICHOSON': profile.activityList[index].SHICHOSON.text
          });
        } catch (e) {
          print('ユーザー登録に失敗しました --- $e');
        }
        No = No + 1;
      }
    }
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
  static Future<CHomePageVal> getNickNameAndTorokuRank(uid) async {
    final snapShot =
        await FirebaseFirestore.instance.collection('myProfile').doc(uid).get();

    String name = snapShot.data()!['NICK_NAME'];
    String rank = snapShot.data()!['TOROKU_RANK'];
    String id = snapShot.data()!['USER_ID'];
    String myid = snapShot.data()!['MY_USER_ID'];
    String image = snapShot.data()!['PROFILE_IMAGE'];
    CSkilLevelSetting skill = await getAvgSkillLevel();
    String toUserMessage = await FirestoreMethod.getToUserMessage();

    CHomePageVal homePageval = CHomePageVal(
        NAME: name,
        MYUSERID: myid,
        TOROKURANK: rank,
        PROFILEIMAGE: image,
        SKILL: skill,
        TOUSERMESSAGE: toUserMessage);

    late String manSingleRank;
    if (rank == "初級") {
      manSingleRank = "ShokyuRank";
    } else if (rank == "中級") {
      manSingleRank = "ChukyuRank";
    } else if (rank == "上級") {
      manSingleRank = "JyokyuRank";
    }

    final snapShot_msr = await FirebaseFirestore.instance
        .collection('manSinglesRank')
        .doc(manSingleRank)
        .collection('RankList')
        .doc(id)
        .get();

    if (!snapShot_msr.exists) {
      return homePageval;
    }

    int rank_no = snapShot_msr.data()!['RANK_NO'];

    homePageval.SRANK = rank_no;

    final snapShot_matchResult = await FirebaseFirestore.instance
        .collection('matchResult')
        .doc(uid)
        .get();

    //初級の勝率
    homePageval.BEGINWINRATE = snapShot_matchResult.data()!['SHOKYU_WIN_RATE'];
    //中級の勝率
    homePageval.MEDIUMWINRATE = snapShot_matchResult.data()!['CHUKYU_WIN_RATE'];
    //上級の勝率
    homePageval.ADVANCEDWINRATE =
        snapShot_matchResult.data()!['JYOKYU_WIN_RATE'];

    return homePageval;
  }

  /**
   *ドキュメントをキーに指定コレクションから指定フィールドをリスト型で取得するメソッド
   * uid ドキュメント
   * return　フィールドプロパティのリスト
   */
  static Future<List<String>> getNickNameAndProfile(uid) async {
    List<String> stringList = [];
    final snapShot = await profileRef.doc(uid).get();

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
    String MY_USER_ID = snapShot.data()!['MY_USER_ID'];

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
        COMENT: COMENT,
        MY_USER_ID: MY_USER_ID);

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
    String MY_USER_ID = snapShot.data()!['MY_USER_ID'];

    final snapShotActivity = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(userId)
        .collection("activityList")
        .get();

    List<CativityList> activityList = [];
    try {
      await Future.forEach<dynamic>(snapShotActivity.docs, (doc) async {
        activityList.add(CativityList(
          No: doc.data()!['No'],
          TODOFUKEN: doc.data()!['TODOFUKEN'],
          SHICHOSON: TextEditingController(text: doc.data()!['SHICHOSON']),
        ));
      });
    } catch (e) {
      print("アクティビティリストの登録に失敗しました");
    }

    CprofileSetting cprofileSet = await CprofileSetting(
        USER_ID: USER_ID,
        PROFILE_IMAGE: PROFILE_IMAGE,
        NICK_NAME: NICK_NAME,
        TOROKU_RANK: TOROKU_RANK,
        activityList: activityList,
        AGE: AGE,
        GENDER: GENDER,
        COMENT: COMENT,
        MY_USER_ID: MY_USER_ID);

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
    bool roomCheck = false;
    late TalkRoomModel room;
    roomCheck = await checkRoom(myuserId, youruserID, roomCheck);
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

  //トークルーム削除
  static void delTalkRoom(String delId, BuildContext context) async {
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
                  roomRef.doc(delId).delete();
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

  /**
   * 相手とのトークルームが既に存在するかどうかチェックするメソッドです
   */
  static Future<bool> checkRoom(
      String myUserId, String yourUserID, bool roomCheck) async {
    final snapshot = await roomRef.get();
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId)) {
        doc.data()['joined_user_ids'].forEach((id) {
          if (id == yourUserID) {
            roomCheck = true;
          }
        });
      }
    });
    return roomCheck;
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
    late int count;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId) &&
          doc.data()['joined_user_ids'].contains(yourUserId)) {
        CprofileSetting yourProfile = await getYourProfile(yourUserId);
        try {
          count = await NotificationMethod.unreadCountGet(yourUserId);
        } catch (e) {
          print("未読メッセージ数を正しく取得できませんでした");
        }
        room = TalkRoomModel(
            roomId: doc.id,
            user: yourProfile,
            lastMessage: doc.data()['last_message'] ?? '',
            unReadCnt: count,
            updated_time: doc.data()['updated_time'] ?? '');
      }
    });
    return room;
  }

  static Future<List<TalkRoomModel>> getRooms(String myUserId) async {
    final snapshot = await roomRef.get();
    List<TalkRoomModel> roomList = [];
    late int count;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(myUserId)) {
        late String yourUserId;
        doc.data()['joined_user_ids'].forEach((id) {
          if (id != myUserId) {
            yourUserId = id;
            return;
          }
        });
        try {
          count = await NotificationMethod.unreadCountGet(yourUserId);
        } catch (e) {
          print("未読メッセージ数を正しく取得できませんでした");
        }
        //ブロックリストに存在しない場合に表示する
        String blockUserChk = await getBlockListChk(yourUserId);
        if (blockUserChk == "0") {
          try {
            CprofileSetting yourProfile = await getYourProfile(yourUserId);
            TalkRoomModel room = await TalkRoomModel(
                roomId: doc.id,
                user: yourProfile,
                lastMessage: doc.data()['last_message'] ?? '',
                unReadCnt: count,
                updated_time: doc.data()['updated_time'] ?? '');
            roomList.add(room);
          } catch (e) {
            print("トークルームの取得に失敗しました");
            print(e);
          }
        }
      }
    });
    roomList.sort((a, b) => b.updated_time.compareTo(a.updated_time));
    return roomList;
  }

  static Future<TalkRoomModel> getRoom(String RECIPIENT_ID, String SENDER_ID,
      CprofileSetting yourProfile) async {
    final snapshot = await roomRef.get();
    late TalkRoomModel room;
    late int count;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      late String yourUserId;
      if (doc.data()['joined_user_ids'].contains(RECIPIENT_ID)) {
        if (doc.data()['joined_user_ids'].contains(SENDER_ID)) {
          try {
            count =
                await NotificationMethod.unreadCountGet(yourProfile.USER_ID);
          } catch (e) {
            print("未読メッセージ数を正しく取得できませんでした");
            print(e);
          }
          room = TalkRoomModel(
              roomId: doc.id,
              user: yourProfile,
              lastMessage: doc.data()['last_message'] ?? '',
              unReadCnt: count,
              updated_time: doc.data()['updated_time'] ?? '');
        }
      }
    });
    return room;
  }

  // static Future<List<Message>> getMessages(String roomId) async {
  //   final messageRef = roomRef
  //       .doc(roomId)
  //       .collection('message')
  //       .orderBy('send_time', descending: true)
  //       .limit(10); // 1ページあたりのメッセージ数;
  //   List<Message> messageList = [];
  //   final snapshot = await messageRef.get();
  //   Future.forEach<dynamic>(snapshot.docs, (doc) async {
  //     bool isMe;
  //     if (doc.data()['sender_id'] == auth.currentUser!.uid) {
  //       isMe = true;
  //     } else {
  //       isMe = false;
  //     }
  //     Message message = Message(
  //         messageId: doc.id,
  //         message: doc.data()['message'],
  //         isMe: isMe,
  //         sendTime: doc.data()['send_time'],
  //         matchStatusFlg: doc.data()['matchStatusFlg'],
  //         friendStatusFlg: doc.data()['friendStatusFlg'],
  //         dayKey:
  //             doc.data().containsKey('dayKey') ? doc.data()['dayKey'] : null);
  //     messageList.add(message);
  //   });
  //   // messageList.sort((a, b) => b.sendTime.compareTo(a.sendTime));
  //
  //   return messageList;
  // }

  // Future<int> getUnreadMessageCount(String roomId) async {
  //   final messageRef = roomRef.doc(roomId).collection('message');
  //   final snapshot = await messageRef.get();
  //   int count = 0;
  //   await Future.forEach<dynamic>(snapshot.docs, (doc) async {
  //     bool isMe;
  //     if (doc.data()['sender_id'] == auth.currentUser!.uid) {
  //       isMe = true;
  //     } else {
  //       isMe = false;
  //     }
  //     print(isMe);
  //     print(doc.data()['sender_id']);
  //     print(doc.data()['isRead']);
  //     if (isMe == false && doc.data()['isRead'] == false) {
  //       count++;
  //     }
  //   });
  //   return count;
  // }

  static Future<void> sendMessage(TalkRoomModel room, String message) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます
    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': message,
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0",
    });
    roomRef
        .doc(room.roomId)
        .update({'last_message': message, 'updated_time': Timestamp.now()});
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    print(tokenId);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, message, myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  static Stream<QuerySnapshot> messageSnapshot(String roomId) {
    return roomRef.doc(roomId).collection('message').snapshots();
  }

  //試合申請メッセージ
  static Future<void> sendMatchMessage(TalkRoomModel room) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます
    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': "対戦お願いします！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "1",
      'friendStatusFlg': "0",
    });
    roomRef
        .doc(room.roomId)
        .update({'last_message': "対戦お願いします！", 'updated_time': Timestamp.now()});
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "対戦お願いします！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //対戦結果入力メッセージ(フィードバック入力希望しない場合)
  static Future<void> sendMatchResultMessage(
      String myUserId, String yourUserId, String dayKey) async {
    TalkRoomModel room = await getRoomBySearchResult(myUserId, yourUserId);
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます
    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': "対戦結果が入力されました！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "3",
      'friendStatusFlg': "0",
      'dayKey': dayKey
    });
    roomRef.doc(room.roomId).update(
        {'last_message': "対戦結果が入力されました！", 'updated_time': Timestamp.now()});
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "対戦結果が入力されました！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //対戦結果入力メッセージ(フィードバック入力希望の場合)
  static Future<void> sendMatchResultFeedMessage(
      String myUserId, String yourUserId, String dayKey) async {
    TalkRoomModel room = await getRoomBySearchResult(myUserId, yourUserId);
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます
    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': "対戦結果が入力されました！\n評価の入力、感想・フィードバックの記入お願いします！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "4",
      'friendStatusFlg': "0",
      'dayKey': dayKey
    });
    roomRef.doc(room.roomId).update({
      'last_message': "対戦結果が入力されました！\n評価の入力、感想・フィードバックの記入お願いします！",
      'updated_time': Timestamp.now()
    });
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(tokenId!,
          "対戦結果が入力されました！\n評価の入力、感想・フィードバックの記入お願いします！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  static Future<void> sendFriendMessage(TalkRoomModel room) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます
    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': "友達登録お願いします！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "1",
    });
    roomRef.doc(room.roomId).update(
        {'last_message': "友達登録お願いします！", 'updated_time': Timestamp.now()});
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "友達登録お願いします！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //対戦結果入力メッセージ(フィードバック入力希望の場合)
  static Future<void> sendMatchResultFeedMessageReturn(
      String myUserId, String yourUserId, String dayKey) async {
    TalkRoomModel room = await getRoomBySearchResult(myUserId, yourUserId);
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます

    String? myUid = auth.currentUser!.uid;
    await newMessageRef.set({
      'messageId': newMessageRef.id,
      'message': "評価・フィードバックを入力しました！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "3",
      'friendStatusFlg': "0",
      'dayKey': dayKey
    });
    roomRef.doc(room.roomId).update({
      'last_message': "評価・フィードバックを入力しました！",
      'updated_time': Timestamp.now()
    });
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "評価・フィードバックを入力しました！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
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
    List<String> blockList = [];
    final snapShot_self = await profileRef
        .where('USER_ID', isEqualTo: auth.currentUser!.uid)
        .get();

    final snapShot_block = await blockRef
        .doc(auth.currentUser!.uid)
        .collection('blockUserList')
        .get();

    await Future.forEach<dynamic>(snapShot_block.docs, (document) async {
      blockList.add(document.data()['BLOCK_USER']);
    });

    //コレクション「myProfile」から該当データを絞る
    final snapShot = await FirebaseFirestore.instance
        .collection('myProfile')
        .where('GENDER', isEqualTo: gender)
        .where('TOROKU_RANK', isEqualTo: rank)
        .where('AGE', isEqualTo: age)
        .get();

    await Future.forEach<dynamic>(snapShot.docs, (document) async {
      if (blockList.contains(document.data()['USER_ID'])) {
        return;
      }
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
            if (document.get('USER_ID') !=
                snapShot_self.docs.first.get('USER_ID')) {
              nameList.add(document.get('NICK_NAME'));
              profileList.add(document.get('PROFILE_IMAGE'));
              idList.add(document.get('USER_ID'));
              resultList.add(nameList);
              resultList.add(profileList);
              resultList.add(idList);
              count++;
            }
          } else if (doc.data()['SHICHOSON'] == shichoson && count == 0) {
            if (document.get('USER_ID') !=
                snapShot_self.docs.first.get('USER_ID')) {
              nameList.add(document.get('NICK_NAME'));
              profileList.add(document.get('PROFILE_IMAGE'));
              idList.add(document.get('USER_ID'));
              resultList.add(nameList);
              resultList.add(profileList);
              resultList.add(idList);
              count++;
            }
          }
        }
      });
    });
    return resultList;
  }

  /**
   * MyUserIDを使ってユーザー情報を取得
   */
  static Future<List<String>> getUserByMyUserId(String myUserID) async {
    List<String> resultList = [];

    final snapShot_self = await profileRef
        .where('USER_ID', isEqualTo: auth.currentUser!.uid)
        .get();
    if (myUserID == snapShot_self.docs.first.get('MY_USER_ID')) {
      return resultList;
    }
    //コレクション「myProfile」から該当データを絞る
    final snapShot =
        await profileRef.where('MY_USER_ID', isEqualTo: myUserID).get();

    if (snapShot.docs.first == null) {
      return resultList;
    }

    String id = snapShot.docs.first.id;
    final snapShot_block = await blockRef
        .doc(auth.currentUser!.uid)
        .collection('blockUserList')
        .where('BLOCK_USER', isEqualTo: id)
        .get();

    print("aaa" + snapShot_block.size.toString());
    if (snapShot_block.size != 0) {
      return resultList;
    }

    String name = snapShot.docs.first!['NICK_NAME'];
    String profile = snapShot.docs.first!['PROFILE_IMAGE'];
    resultList.add(name);
    resultList.add(profile);
    resultList.add(id);

    return resultList;
  }

  //試合申請受け入れ
  static Future<void> matchAccept(TalkRoomModel room, String messageId) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます

    String? myUid = auth.currentUser!.uid;

    await messageRef.doc(messageId).update({'matchStatusFlg': "2"});

    await newMessageRef.set({
      'messageId': newMessageRef.id, // ドキュメントのフィールドにIDを保存します
      'message': "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0"
    });
    ;
    roomRef.doc(room.roomId).update({
      'last_message': "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！",
      'updated_time': Timestamp.now()
    });
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //マッチフィードバック受け入れ
  static Future<void> matchFeedAccept(
      TalkRoomModel room, String messageId) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');

    await messageRef.doc(messageId).update({'matchStatusFlg': "3"});
  }

  //友人申請受け入れ
  static Future<void> friendAccept(TalkRoomModel room, String messageId) async {
    final messageRef = roomRef.doc(room.roomId).collection('message');
    final DocumentReference newMessageRef =
        messageRef.doc(); // ランダムなドキュメントIDが自動生成されます

    String? myUid = auth.currentUser!.uid;

    await messageRef.doc(messageId).update({'friendStatusFlg': "2"});

    await newMessageRef.set({
      'messageId': newMessageRef.id, // ドキュメントのフィールドにIDを保存します
      'message': "友人申請を受け入れました。\n友人一覧を確認してみよう！",
      'sender_id': myUid,
      'send_time': Timestamp.now(),
      'matchStatusFlg': "0",
      'friendStatusFlg': "0"
    });

    roomRef.doc(room.roomId).update({
      'last_message': "友人申請を受け入れました。\n友人一覧を確認してみよう！",
      'updated_time': Timestamp.now()
    });
    CprofileSetting myProfile = await FirestoreMethod.getProfile();
    String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
    if (tokenId == "") {
      //トークンIDが登録されていない場合
    } else {
      //トークンIDが登録されている場合
      await NotificationMethod.sendMessage(
          tokenId!, "友人申請を受け入れました。\n友人一覧を確認してみよう！", myProfile.NICK_NAME);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
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

  //対戦マッチ一覧に追加
  static Future<void> makeMatchByQrScan(String yourUserId) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);

    try {
      await matchRef.add({
        'RECIPIENT_ID': auth.currentUser!.uid,
        'SENDER_ID': yourUserId,
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
      print(matchList.length);
    });
    matchList.sort((a, b) => b.SAKUSEI_TIME.compareTo(a.SAKUSEI_TIME));
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

  //マッチリザルト削除フラグ更新
  static void delMatchResultList(
      String yourUserId, String delId, BuildContext context) async {
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

  //対戦結果_新規フラグ取得
  static Future<String> newFlgMatchResult(String UserId) async {
    final snapshot = await matchResultRef.get();
    String NEW_FLG = "1";
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == UserId) {
        NEW_FLG = "0";
      }
    });
    return NEW_FLG;
  }

  //個人対戦結果_新規フラグ取得
  static Future<String> individualNewFlgMatch(
      String myUserId, String yourUserId) async {
    final snapshot =
        await matchResultRef.doc(myUserId).collection('opponentList').get();
    String NEW_FLG = "1";
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == yourUserId) {
        NEW_FLG = "0";
      }
    });
    return NEW_FLG;
  }

  //ランキング_新規フラグ取得
  static Future<String> rankNewFlgMatch(String myUserId, String rank) async {
    late String manSingleRank;
    if (rank == "初級") {
      manSingleRank = "ShokyuRank";
    } else if (rank == "中級") {
      manSingleRank = "ChukyuRank";
    } else if (rank == "上級") {
      manSingleRank = "JoukyuRank";
    }
    final rankSnap = await FirebaseFirestore.instance
        .collection('manSinglesRank')
        .doc(manSingleRank)
        .collection('RankList')
        .get();
    String NEW_FLG = "1";
    await Future.forEach<dynamic>(rankSnap.docs, (doc) async {
      if (doc.id == myUserId) {
        NEW_FLG = "0";
      }
    });
    return NEW_FLG;
  }

  //ランキング取得
  static Future<int> rankingGet(String UserId) async {
    final myProfileSnap = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(UserId)
        .get();
    String rank = myProfileSnap.data()!['TOROKU_RANK'];
    int rank_no = 0;

    late String manSingleRank;
    String NEW_FLG = await rankNewFlgMatch(UserId, rank);
    if (NEW_FLG == "1") {
      rank_no = 0;
    } else {
      if (rank == "初級") {
        manSingleRank = "ShokyuRank";
      } else if (rank == "中級") {
        manSingleRank = "ChukyuRank";
      } else if (rank == "上級") {
        manSingleRank = "JoukyuRank";
      }
      final rankSnap = await FirebaseFirestore.instance
          .collection('manSinglesRank')
          .doc(manSingleRank)
          .collection('RankList')
          .doc(UserId)
          .get();
      rank_no = rankSnap.data()!['RANK_NO'];
    }
    return rank_no;
  }

  //各レベルの勝率算出メソッド
  static Future<void> winRateUpdate(
      CprofileSetting myProfile, CprofileSetting yourProfile) async {
    final snapshotDetail = await matchResultRef
        .doc(myProfile.USER_ID)
        .collection('opponentList')
        .doc(yourProfile.USER_ID)
        .collection('matchDetail')
        .get();
    int winSu = 0;
    int matchSu = 0;
    await Future.forEach<dynamic>(snapshotDetail.docs, (doc) async {
      if (doc.data()['TOROKU_RANK'].contains(yourProfile.TOROKU_RANK)) {
        winSu = doc.data()['WIN_FLG'] + winSu;
        matchSu = matchSu + 1;
      } else {
        matchSu = matchSu + 1;
      }
    });
    final snapshotResult = await matchResultRef.doc(myProfile.USER_ID);

    int loseSu = matchSu - winSu;
    int winRate = ((winSu / matchSu) * 100).round();

    switch (yourProfile.TOROKU_RANK) {
      case '初級':
        try {
          snapshotResult.update({'SHOKYU_WIN_SU': winSu});
          snapshotResult.update({'SHOKYU_LOSE_SU': loseSu});
          snapshotResult.update({'SHOKYU_MATCH_SU': matchSu});
          snapshotResult.update({'SHOKYU_WIN_RATE': winRate});
        } catch (e) {
          print('初級TSPポイントの付与に失敗しました --- $e');
        }
        break;
      case '中級':
        try {
          snapshotResult.update({'CHUKYU_WIN_SU': winSu});
          snapshotResult.update({'CHUKYU_LOSE_SU': loseSu});
          snapshotResult.update({'CHUKYU_MATCH_SU': matchSu});
          snapshotResult.update({'CHUKYU_WIN_RATE': winRate});
        } catch (e) {
          print('中級TSPポイントの付与に失敗しました --- $e');
        }
        break;
      case '上級':
        try {
          snapshotResult.update({'JYOKYU_WIN_SU': winSu});
          snapshotResult.update({'JYOKYU_LOSE_SU': loseSu});
          snapshotResult.update({'JYOKYU_MATCH_SU': matchSu});
          snapshotResult.update({'JYOKYU_WIN_RATE': winRate});
        } catch (e) {
          print('上級TSPポイントの付与に失敗しました --- $e');
        }
        break;
    }
  }

  //対戦結果作成
  static Future<void> makeMatchResult(
      CprofileSetting myProfile,
      CprofileSetting yourProfile,
      List<CmatchResult> matchResultList,
      String dayKey,
      String matchTitle) async {
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
    //現在の生涯TSPポイント
    late int MY_ALL_TS_POINT_CUR;
    late int YOUR_ALL_TS_POINT_CUR;
    //対戦結果登録後のTSPポイント
    late int MY_TS_POINT;
    late int YOUR_TS_POINT;
    //対戦結果登録後の生涯TSPポイント
    late int MY_ALL_TS_POINT;
    late int YOUR_ALL_TS_POINT;

    //現在の登録ランク
    late String MY_TOROKU_RANK_CUR;
    late String YOUR_TOROKU_RANK_CUR;
    //現在の初級TSPポイント
    late int MY_SHOKYU_TS_POINT_CUR;
    late int YOUR_SHOKYU_TS_POINT_CUR;
    //現在の生涯初級TSPポイント
    late int MY_ALL_SHOKYU_TS_POINT_CUR;
    late int YOUR_ALL_SHOKYU_TS_POINT_CUR;

    //現在の中級TSPポイント
    late int MY_CHUKYU_TS_POINT_CUR;
    late int YOUR_CHUKYU_TS_POINT_CUR;
    //現在の生涯中級TSPポイント
    late int MY_ALL_CHUKYU_TS_POINT_CUR;
    late int YOUR_ALL_CHUKYU_TS_POINT_CUR;

    //現在の上級TSPポイント
    late int MY_JYOKYU_TS_POINT_CUR;
    late int YOUR_JYOKYU_TS_POINT_CUR;
    //現在の生涯上級TSPポイント
    late int MY_ALL_JYOKYU_TS_POINT_CUR;
    late int YOUR_ALL_JYOKYU_TS_POINT_CUR;

    //新規フラグ
    late String MY_NEW_FLG;
    late String YOUR_NEW_FLG;
    //初対戦フラグ
    late String MY_NEW_MATCH_FLG;
    late String YOUR_NEW_MATCH_FLG;

    //TSPポイントランキング
    late int MY_RANK;
    late int YOUR_RANK;

    //各レベルの勝利数/敗戦数/試合数/勝率
    late int MY_SHOKYU_WIN_SU;
    late int MY_SHOKYU_LOSE_SU;
    late int MY_SHOKYU_MATCH_SU;
    late int MY_SHOKYU_WIN_RATE;

    late int MY_CHUKYU_WIN_SU;
    late int MY_CHUKYU_LOSE_SU;
    late int MY_CHUKYU_MATCH_SU;
    late int MY_CHUKYU_WIN_RATE;

    late int MY_JYOKYU_WIN_SU;
    late int MY_JYOKYU_LOSE_SU;
    late int MY_JYOKYU_MATCH_SU;
    late int MY_JYOKYU_WIN_RATE;

    late int YOUR_SHOKYU_WIN_SU;
    late int YOUR_SHOKYU_LOSE_SU;
    late int YOUR_SHOKYU_MATCH_SU;
    late int YOUR_SHOKYU_WIN_RATE;

    late int YOUR_CHUKYU_WIN_SU;
    late int YOUR_CHUKYU_LOSE_SU;
    late int YOUR_CHUKYU_MATCH_SU;
    late int YOUR_CHUKYU_WIN_RATE;

    late int YOUR_JYOKYU_WIN_SU;
    late int YOUR_JYOKYU_LOSE_SU;
    late int YOUR_JYOKYU_MATCH_SU;
    late int YOUR_JYOKYU_WIN_RATE;

    //各レベルの勝利数/敗戦数/試合数/勝率
    late int MY_SHOKYU_WIN_SU_CUR;
    late int MY_SHOKYU_LOSE_SU_CUR;
    late int MY_SHOKYU_MATCH_SU_CUR;
    late int MY_SHOKYU_WIN_RATE_CUR;

    late int MY_CHUKYU_WIN_SU_CUR;
    late int MY_CHUKYU_LOSE_SU_CUR;
    late int MY_CHUKYU_MATCH_SU_CUR;
    late int MY_CHUKYU_WIN_RATE_CUR;

    late int MY_JYOKYU_WIN_SU_CUR;
    late int MY_JYOKYU_LOSE_SU_CUR;
    late int MY_JYOKYU_MATCH_SU_CUR;
    late int MY_JYOKYU_WIN_RATE_CUR;

    late int YOUR_SHOKYU_WIN_SU_CUR;
    late int YOUR_SHOKYU_LOSE_SU_CUR;
    late int YOUR_SHOKYU_MATCH_SU_CUR;
    late int YOUR_SHOKYU_WIN_RATE_CUR;

    late int YOUR_CHUKYU_WIN_SU_CUR;
    late int YOUR_CHUKYU_LOSE_SU_CUR;
    late int YOUR_CHUKYU_MATCH_SU_CUR;
    late int YOUR_CHUKYU_WIN_RATE_CUR;

    late int YOUR_JYOKYU_WIN_SU_CUR;
    late int YOUR_JYOKYU_LOSE_SU_CUR;
    late int YOUR_JYOKYU_MATCH_SU_CUR;
    late int YOUR_JYOKYU_WIN_RATE_CUR;

    //新規フラグ取得メソッド結果を取得
    MY_NEW_FLG = await newFlgMatchResult(myProfile.USER_ID);
    YOUR_NEW_FLG = await newFlgMatchResult(yourProfile.USER_ID);

    //ランキング取得メソッド
    MY_RANK = await rankingGet(myProfile.USER_ID);
    print('MY_RANK' + MY_RANK.toString());
    YOUR_RANK = await rankingGet(yourProfile.USER_ID);

    //個人対戦結果勝率
    late int MY_WIN_SU = 0;
    late int MY_LOSE_SU = 0;
    late int MY_MATCH_SU = 0;
    late int MY_WIN_RATE = 0;

    late int YOUR_WIN_SU = 0;
    late int YOUR_LOSE_SU = 0;
    late int YOUR_MATCH_SU = 0;
    late int YOUR_WIN_RATE = 0;

    //個人対戦結果勝率
    late int MY_WIN_SU_CUR;
    late int MY_LOSE_SU_CUR;
    late int MY_MATCH_SU_CUR;
    late int MY_WIN_RATE_CUR;
    //個人対戦結果勝率_合計
    late int MY_WIN_SU_SUM;
    late int MY_LOSE_SU_SUM;
    late int MY_MATCH_SU_SUM;
    late int YOUR_WIN_SU_SUM;
    late int YOUR_LOSE_SU_SUM;
    late int YOUR_MATCH_SU_SUM;

    late int YOUR_WIN_SU_CUR;
    late int YOUR_LOSE_SU_CUR;
    late int YOUR_MATCH_SU_CUR;
    late int YOUR_WIN_RATE_CUR;
    int MATCH_NO = 0;
    matchResultList.forEach((a) async {
      try {
        if (a.myGamePoint > a.yourGamePoint) {
          //勝利フラグ更新
          MY_WIN_FLG = 1;
          YOUR_WIN_FLG = 0;
          //勝利数カウント
          MY_WIN_SU = MY_WIN_SU + 1;
          //試合数カウント
          MY_MATCH_SU = MY_MATCH_SU + 1;
          YOUR_MATCH_SU = YOUR_MATCH_SU + 1;
          //付与TSポイントの算出
          MY_TS_POINT_FUYO = TsMethod.tsPointCalculation(myProfile.TOROKU_RANK,
              yourProfile.TOROKU_RANK, MY_RANK, YOUR_RANK);
          MY_TS_POINT_FUYO_SUM = MY_TS_POINT_FUYO_SUM + MY_TS_POINT_FUYO;
          YOUR_TS_POINT_FUYO = 0;
        } else {
          //勝利フラグ更新
          YOUR_WIN_FLG = 1;
          MY_WIN_FLG = 0;
          //勝利数カウント
          YOUR_WIN_SU = YOUR_WIN_SU + 1;
          //試合数カウント
          MY_MATCH_SU = MY_MATCH_SU + 1;
          YOUR_MATCH_SU = YOUR_MATCH_SU + 1;

          //付与TSポイントの算出
          YOUR_TS_POINT_FUYO = TsMethod.tsPointCalculation(
              yourProfile.TOROKU_RANK,
              myProfile.TOROKU_RANK,
              YOUR_RANK,
              MY_RANK);
          YOUR_TS_POINT_FUYO_SUM = YOUR_TS_POINT_FUYO_SUM + YOUR_TS_POINT_FUYO;
          MY_TS_POINT_FUYO = 0;
          print(YOUR_TS_POINT_FUYO);
        }
        if (a.myGamePoint != a.yourGamePoint) {
          matchResultRef
              .doc(myProfile.USER_ID)
              .collection('opponentList')
              .doc(yourProfile.USER_ID)
              .collection('daily')
              .doc(dayKey)
              .collection('matchDetail')
              .add({
            'No': MATCH_NO.toString(),
            'MY_POINT': a.myGamePoint,
            'YOUR_POINT': a.yourGamePoint,
            'WIN_FLG': MY_WIN_FLG,
            'TS_POINT': MY_TS_POINT_FUYO,
            'YOUR_TOROKU_RANK': yourProfile.TOROKU_RANK,
            'YOUR_RANK_NO': YOUR_RANK,
            'MY_TOROKU_RANK': myProfile.TOROKU_RANK,
            'MY_RANK_NO': MY_RANK,
            'KOUSHIN_TIME': today,
            'TSP_VALID_FLG': '1'
          });
          matchResultRef
              .doc(yourProfile.USER_ID)
              .collection('opponentList')
              .doc(myProfile.USER_ID)
              .collection('daily')
              .doc(dayKey)
              .collection('matchDetail')
              .add({
            'No': MATCH_NO.toString(),
            'MY_POINT': a.yourGamePoint,
            'YOUR_POINT': a.myGamePoint,
            'WIN_FLG': YOUR_WIN_FLG,
            'TS_POINT': YOUR_TS_POINT_FUYO,
            'YOUR_TOROKU_RANK': myProfile.TOROKU_RANK,
            'YOUR_RANK_NO': MY_RANK,
            'MY_TOROKU_RANK': yourProfile.TOROKU_RANK,
            'MY_RANK_NO': YOUR_RANK,
            'KOUSHIN_TIME': today,
            'TSP_VALID_FLG': '1'
          });
          MATCH_NO = MATCH_NO + 1;
        }
      } catch (e) {
        print('対戦結果入力に失敗しました --- $e');
      }
    });

    //デイリー対戦結果更新
    try {
      matchResultRef
          .doc(myProfile.USER_ID)
          .collection('opponentList')
          .doc(yourProfile.USER_ID)
          .collection('daily')
          .doc(dayKey)
          .set({
        'matchTitle': matchTitle,
        'dailyId':dayKey,
        'userId':myProfile.USER_ID,
        'opponentId':yourProfile.USER_ID
      });
    } catch (e) {
      print('日別タイトルの登録に失敗しました --- $e');
    }
    try {
      matchResultRef
          .doc(yourProfile.USER_ID)
          .collection('opponentList')
          .doc(myProfile.USER_ID)
          .collection('daily')
          .doc(dayKey)
          .set({
        'matchTitle': matchTitle,
        'dailyId':dayKey,
        'userId':yourProfile.USER_ID,
        'opponentId':myProfile.USER_ID
      });
    } catch (e) {
      print('日別タイトルの登録に失敗しました --- $e');
    }

    //個人対戦結果更新
    final myResultSnap = await matchResultRef
        .doc(myProfile.USER_ID)
        .collection('opponentList')
        .doc(yourProfile.USER_ID);

    final yourResultSnap = await matchResultRef
        .doc(yourProfile.USER_ID)
        .collection('opponentList')
        .doc(myProfile.USER_ID);

    //初対戦フラグ取得メソッド結果を取得(メソッドは作る必要あり)
    MY_NEW_MATCH_FLG =
        await individualNewFlgMatch(myProfile.USER_ID, yourProfile.USER_ID);
    YOUR_NEW_MATCH_FLG =
        await individualNewFlgMatch(yourProfile.USER_ID, myProfile.USER_ID);
    MY_LOSE_SU = MY_MATCH_SU - MY_WIN_SU;
    if (MY_NEW_MATCH_FLG == "1") {
      MY_WIN_SU_SUM = 0 + MY_WIN_SU;
      MY_LOSE_SU_SUM = 0 + MY_LOSE_SU;
      MY_MATCH_SU_SUM = 0 + MY_MATCH_SU;

      MY_WIN_RATE = ((MY_WIN_SU_SUM / MY_MATCH_SU_SUM) * 100).round();

      try {
        await myResultSnap.set({
          'WIN_SU': MY_WIN_SU_SUM,
          'LOSE_SU': MY_LOSE_SU_SUM,
          'MATCH_SU': MY_MATCH_SU_SUM,
          'WIN_RATE': MY_WIN_RATE
        });
      } catch (e) {
        print("初対戦の勝率の入力に失敗しました");
      }
    } else {
      //現在の勝利数・敗北数など取得
      final myResultSnapGet = await myResultSnap.get();
      MY_WIN_SU_CUR = myResultSnapGet.data()!['WIN_SU'];
      MY_LOSE_SU_CUR = myResultSnapGet.data()!['LOSE_SU'];
      MY_MATCH_SU_CUR = myResultSnapGet.data()!['MATCH_SU'];
      MY_WIN_SU_SUM = MY_WIN_SU_CUR + MY_WIN_SU;
      MY_LOSE_SU_SUM = MY_LOSE_SU_CUR + MY_LOSE_SU;
      MY_MATCH_SU_SUM = MY_MATCH_SU_CUR + MY_MATCH_SU;
      MY_WIN_RATE = ((MY_WIN_SU_SUM / MY_MATCH_SU_SUM) * 100).round();
      try {
        myResultSnap.update({
          'WIN_SU': MY_WIN_SU_SUM,
          'LOSE_SU': MY_LOSE_SU_SUM,
          'MATCH_SU': MY_MATCH_SU_SUM,
          'WIN_RATE': MY_WIN_RATE
        });
      } catch (e) {
        print("個人勝率の更新に失敗しました");
      }
    }
    YOUR_LOSE_SU = YOUR_MATCH_SU - YOUR_WIN_SU;

    if (YOUR_NEW_MATCH_FLG == "1") {
      YOUR_WIN_SU_SUM = 0 + YOUR_WIN_SU;
      YOUR_LOSE_SU_SUM = 0 + YOUR_LOSE_SU;
      YOUR_MATCH_SU_SUM = 0 + YOUR_MATCH_SU;

      YOUR_WIN_RATE = ((YOUR_WIN_SU_SUM / YOUR_MATCH_SU_SUM) * 100).round();

      try {
        await yourResultSnap.set({
          'WIN_SU': YOUR_WIN_SU_SUM,
          'LOSE_SU': YOUR_LOSE_SU_SUM,
          'MATCH_SU': YOUR_MATCH_SU_SUM,
          'WIN_RATE': YOUR_WIN_RATE
        });
      } catch (e) {
        print("初対戦の勝率の入力に失敗しました");
      }
    } else {
      //現在の勝利数・敗北数など取得
      final yourResultSnapGet = await yourResultSnap.get();
      YOUR_WIN_SU_CUR = yourResultSnapGet.data()!['WIN_SU'];
      YOUR_LOSE_SU_CUR = yourResultSnapGet.data()!['LOSE_SU'];
      YOUR_MATCH_SU_CUR = yourResultSnapGet.data()!['MATCH_SU'];
      YOUR_WIN_SU_SUM = YOUR_WIN_SU_CUR + YOUR_WIN_SU;
      YOUR_LOSE_SU_SUM = YOUR_LOSE_SU_CUR + YOUR_LOSE_SU;
      YOUR_MATCH_SU_SUM = YOUR_MATCH_SU_CUR + YOUR_MATCH_SU;
      YOUR_WIN_RATE = ((YOUR_WIN_SU_SUM / YOUR_MATCH_SU_SUM) * 100).round();
      try {
        yourResultSnap.update({
          'WIN_SU': YOUR_WIN_SU_SUM,
          'LOSE_SU': YOUR_LOSE_SU_SUM,
          'MATCH_SU': YOUR_MATCH_SU_SUM,
          'WIN_RATE': YOUR_WIN_RATE
        });
      } catch (e) {
        print("個人勝率の更新に失敗しました");
      }
    }
    if (MY_NEW_FLG == "1") {
      //新規の場合
      MY_TS_POINT_CUR = 0;
      MY_TOROKU_RANK_CUR = myProfile.TOROKU_RANK;
      MY_SHOKYU_TS_POINT_CUR = 0;
      MY_CHUKYU_TS_POINT_CUR = 0;
      MY_JYOKYU_TS_POINT_CUR = 0;

      MY_ALL_TS_POINT_CUR = 0;
      MY_ALL_SHOKYU_TS_POINT_CUR = 0;
      MY_ALL_CHUKYU_TS_POINT_CUR = 0;
      MY_ALL_JYOKYU_TS_POINT_CUR = 0;

      MY_SHOKYU_WIN_SU_CUR = 0;
      MY_SHOKYU_LOSE_SU_CUR = 0;
      MY_SHOKYU_MATCH_SU_CUR = 0;
      MY_SHOKYU_WIN_RATE_CUR = 0;

      MY_CHUKYU_WIN_SU_CUR = 0;
      MY_CHUKYU_LOSE_SU_CUR = 0;
      MY_CHUKYU_MATCH_SU_CUR = 0;
      MY_CHUKYU_WIN_RATE_CUR = 0;

      MY_JYOKYU_WIN_SU_CUR = 0;
      MY_JYOKYU_LOSE_SU_CUR = 0;
      MY_JYOKYU_MATCH_SU_CUR = 0;
      MY_JYOKYU_WIN_RATE_CUR = 0;

      await matchResultRef.doc(myProfile.USER_ID).set({
        'TS_POINT': MY_TS_POINT_CUR,
        'ALL_TS_POINT': MY_ALL_TS_POINT_CUR,
        'TOROKU_RANK': MY_TOROKU_RANK_CUR,
        'SHOKYU_TS_POINT': MY_SHOKYU_TS_POINT_CUR,
        'CHUKYU_TS_POINT': MY_CHUKYU_TS_POINT_CUR,
        'JYOKYU_TS_POINT': MY_JYOKYU_TS_POINT_CUR,
        'ALL_SHOKYU_TS_POINT': MY_ALL_SHOKYU_TS_POINT_CUR,
        'ALL_CHUKYU_TS_POINT': MY_ALL_CHUKYU_TS_POINT_CUR,
        'ALL_JYOKYU_TS_POINT': MY_ALL_JYOKYU_TS_POINT_CUR,
        'SHOKYU_WIN_SU': MY_SHOKYU_WIN_SU_CUR,
        'SHOKYU_LOSE_SU': MY_SHOKYU_LOSE_SU_CUR,
        'SHOKYU_MATCH_SU': MY_SHOKYU_MATCH_SU_CUR,
        'SHOKYU_WIN_RATE': MY_SHOKYU_WIN_RATE_CUR,
        'CHUKYU_WIN_SU': MY_CHUKYU_WIN_SU_CUR,
        'CHUKYU_LOSE_SU': MY_CHUKYU_LOSE_SU_CUR,
        'CHUKYU_MATCH_SU': MY_CHUKYU_MATCH_SU_CUR,
        'CHUKYU_WIN_RATE': MY_CHUKYU_WIN_RATE_CUR,
        'JYOKYU_WIN_SU': MY_JYOKYU_WIN_SU_CUR,
        'JYOKYU_LOSE_SU': MY_JYOKYU_LOSE_SU_CUR,
        'JYOKYU_MATCH_SU': MY_JYOKYU_MATCH_SU_CUR,
        'JYOKYU_WIN_RATE': MY_JYOKYU_WIN_RATE_CUR,
      });
    } else {
      //現在の登録情報を取得
      try {
        final mySnapShot = await matchResultRef.doc(myProfile.USER_ID).get();
        //現在のTSPポイントの取得
        MY_TS_POINT_CUR = mySnapShot.data()!['TS_POINT'];
        //現在の生涯TSPポイントの取得
        MY_ALL_TS_POINT_CUR = mySnapShot.data()!['ALL_TS_POINT'];
        //現在の登録ランクを取得
        MY_TOROKU_RANK_CUR = mySnapShot.data()!['TOROKU_RANK'];
        //現在の初級TSPポイントの取得
        MY_SHOKYU_TS_POINT_CUR = mySnapShot.data()!['SHOKYU_TS_POINT'];
        //現在の中級TSPポイントの取得
        MY_CHUKYU_TS_POINT_CUR = mySnapShot.data()!['CHUKYU_TS_POINT'];
        //現在の上級TSPポイントの取得
        MY_JYOKYU_TS_POINT_CUR = mySnapShot.data()!['JYOKYU_TS_POINT'];
        //現在の生涯初級TSPポイントの取得
        MY_ALL_SHOKYU_TS_POINT_CUR = mySnapShot.data()!['ALL_SHOKYU_TS_POINT'];
        //現在の生涯中級TSPポイントの取得
        MY_ALL_CHUKYU_TS_POINT_CUR = mySnapShot.data()!['ALL_CHUKYU_TS_POINT'];
        //現在の生涯上級TSPポイントの取得
        MY_ALL_JYOKYU_TS_POINT_CUR = mySnapShot.data()!['ALL_JYOKYU_TS_POINT'];
        //現在の勝率・勝利数・試合数などを取得
        MY_SHOKYU_WIN_SU_CUR = mySnapShot.data()!['SHOKYU_WIN_SU'];
        MY_SHOKYU_LOSE_SU_CUR = mySnapShot.data()!['SHOKYU_LOSE_SU'];
        MY_SHOKYU_MATCH_SU_CUR = mySnapShot.data()!['SHOKYU_MATCH_SU'];
        MY_SHOKYU_WIN_RATE_CUR = mySnapShot.data()!['SHOKYU_WIN_RATE'];
        MY_CHUKYU_WIN_SU_CUR = mySnapShot.data()!['CHUKYU_WIN_SU'];
        MY_CHUKYU_LOSE_SU_CUR = mySnapShot.data()!['CHUKYU_LOSE_SU'];
        MY_CHUKYU_MATCH_SU_CUR = mySnapShot.data()!['CHUKYU_MATCH_SU'];
        MY_CHUKYU_WIN_RATE_CUR = mySnapShot.data()!['CHUKYU_WIN_RATE'];
        MY_JYOKYU_WIN_SU_CUR = mySnapShot.data()!['JYOKYU_WIN_SU'];
        MY_JYOKYU_LOSE_SU_CUR = mySnapShot.data()!['JYOKYU_LOSE_SU'];
        MY_JYOKYU_MATCH_SU_CUR = mySnapShot.data()!['JYOKYU_MATCH_SU'];
        MY_JYOKYU_WIN_RATE_CUR = mySnapShot.data()!['JYOKYU_WIN_RATE'];
      } catch (e) {
        print('各種情報の取得に失敗しました --- $e');
      }
    }
    if (YOUR_NEW_FLG == "1") {
      //新規の場合
      YOUR_TS_POINT_CUR = 0;
      YOUR_TOROKU_RANK_CUR = yourProfile.TOROKU_RANK;
      YOUR_SHOKYU_TS_POINT_CUR = 0;
      YOUR_CHUKYU_TS_POINT_CUR = 0;
      YOUR_JYOKYU_TS_POINT_CUR = 0;

      YOUR_ALL_TS_POINT_CUR = 0;
      YOUR_ALL_SHOKYU_TS_POINT_CUR = 0;
      YOUR_ALL_CHUKYU_TS_POINT_CUR = 0;
      YOUR_ALL_JYOKYU_TS_POINT_CUR = 0;

      YOUR_SHOKYU_WIN_SU_CUR = 0;
      YOUR_SHOKYU_LOSE_SU_CUR = 0;
      YOUR_SHOKYU_MATCH_SU_CUR = 0;
      YOUR_SHOKYU_WIN_RATE_CUR = 0;

      YOUR_CHUKYU_WIN_SU_CUR = 0;
      YOUR_CHUKYU_LOSE_SU_CUR = 0;
      YOUR_CHUKYU_MATCH_SU_CUR = 0;
      YOUR_CHUKYU_WIN_RATE_CUR = 0;

      YOUR_JYOKYU_WIN_SU_CUR = 0;
      YOUR_JYOKYU_LOSE_SU_CUR = 0;
      YOUR_JYOKYU_MATCH_SU_CUR = 0;
      YOUR_JYOKYU_WIN_RATE_CUR = 0;

      await matchResultRef.doc(yourProfile.USER_ID).set({
        'TS_POINT': YOUR_TS_POINT_CUR,
        'ALL_TS_POINT': YOUR_ALL_TS_POINT_CUR,
        'TOROKU_RANK': YOUR_TOROKU_RANK_CUR,
        'SHOKYU_TS_POINT': YOUR_SHOKYU_TS_POINT_CUR,
        'CHUKYU_TS_POINT': YOUR_CHUKYU_TS_POINT_CUR,
        'JYOKYU_TS_POINT': YOUR_JYOKYU_TS_POINT_CUR,
        'ALL_SHOKYU_TS_POINT': YOUR_ALL_SHOKYU_TS_POINT_CUR,
        'ALL_CHUKYU_TS_POINT': YOUR_ALL_CHUKYU_TS_POINT_CUR,
        'ALL_JYOKYU_TS_POINT': YOUR_ALL_JYOKYU_TS_POINT_CUR,
        'SHOKYU_WIN_SU': YOUR_SHOKYU_WIN_SU_CUR,
        'SHOKYU_LOSE_SU': YOUR_SHOKYU_LOSE_SU_CUR,
        'SHOKYU_MATCH_SU': YOUR_SHOKYU_MATCH_SU_CUR,
        'SHOKYU_WIN_RATE': YOUR_SHOKYU_WIN_RATE_CUR,
        'CHUKYU_WIN_SU': YOUR_CHUKYU_WIN_SU_CUR,
        'CHUKYU_LOSE_SU': YOUR_CHUKYU_LOSE_SU_CUR,
        'CHUKYU_MATCH_SU': YOUR_CHUKYU_MATCH_SU_CUR,
        'CHUKYU_WIN_RATE': YOUR_CHUKYU_WIN_RATE_CUR,
        'JYOKYU_WIN_SU': YOUR_JYOKYU_WIN_SU_CUR,
        'JYOKYU_LOSE_SU': YOUR_JYOKYU_LOSE_SU_CUR,
        'JYOKYU_MATCH_SU': YOUR_JYOKYU_MATCH_SU_CUR,
        'JYOKYU_WIN_RATE': YOUR_JYOKYU_WIN_RATE_CUR,
      });
    } else {
      try {
        final yourSnapShot =
            await matchResultRef.doc(yourProfile.USER_ID).get();
        //現在のTSPポイントの取得
        YOUR_TS_POINT_CUR = yourSnapShot.data()!['TS_POINT'];
        //現在の生涯TSPポイントの取得
        YOUR_ALL_TS_POINT_CUR = yourSnapShot.data()!['ALL_TS_POINT'];
        //現在の登録ランクを取得
        YOUR_TOROKU_RANK_CUR = yourSnapShot.data()!['TOROKU_RANK'];
        //現在の初級TSPポイントの取得
        YOUR_SHOKYU_TS_POINT_CUR = yourSnapShot.data()!['SHOKYU_TS_POINT'];
        //現在の中級TSPポイントの取得
        YOUR_CHUKYU_TS_POINT_CUR = yourSnapShot.data()!['CHUKYU_TS_POINT'];
        //現在の上級TSPポイントの取得
        YOUR_JYOKYU_TS_POINT_CUR = yourSnapShot.data()!['JYOKYU_TS_POINT'];

        //現在の生涯初級TSPポイントの取得
        YOUR_ALL_SHOKYU_TS_POINT_CUR =
            yourSnapShot.data()!['ALL_SHOKYU_TS_POINT'];
        //現在の生涯中級TSPポイントの取得
        YOUR_ALL_CHUKYU_TS_POINT_CUR =
            yourSnapShot.data()!['ALL_CHUKYU_TS_POINT'];
        //現在の生涯上級TSPポイントの取得
        YOUR_ALL_JYOKYU_TS_POINT_CUR =
            yourSnapShot.data()!['ALL_JYOKYU_TS_POINT'];

        //現在の勝率・勝利数・試合数などを取得
        YOUR_SHOKYU_WIN_SU_CUR = yourSnapShot.data()!['SHOKYU_WIN_SU'];
        YOUR_SHOKYU_LOSE_SU_CUR = yourSnapShot.data()!['SHOKYU_LOSE_SU'];
        YOUR_SHOKYU_MATCH_SU_CUR = yourSnapShot.data()!['SHOKYU_MATCH_SU'];
        YOUR_SHOKYU_WIN_RATE_CUR = yourSnapShot.data()!['SHOKYU_WIN_RATE'];
        YOUR_CHUKYU_WIN_SU_CUR = yourSnapShot.data()!['CHUKYU_WIN_SU'];
        YOUR_CHUKYU_LOSE_SU_CUR = yourSnapShot.data()!['CHUKYU_LOSE_SU'];
        YOUR_CHUKYU_MATCH_SU_CUR = yourSnapShot.data()!['CHUKYU_MATCH_SU'];
        YOUR_CHUKYU_WIN_RATE_CUR = yourSnapShot.data()!['CHUKYU_WIN_RATE'];
        YOUR_JYOKYU_WIN_SU_CUR = yourSnapShot.data()!['JYOKYU_WIN_SU'];
        YOUR_JYOKYU_LOSE_SU_CUR = yourSnapShot.data()!['JYOKYU_LOSE_SU'];
        YOUR_JYOKYU_MATCH_SU_CUR = yourSnapShot.data()!['JYOKYU_MATCH_SU'];
        YOUR_JYOKYU_WIN_RATE_CUR = yourSnapShot.data()!['JYOKYU_WIN_RATE'];
      } catch (e) {
        print('TSPポイントの取得に失敗しました --- $e');
      }
    }
    if (MY_TOROKU_RANK_CUR == myProfile.TOROKU_RANK) {
      //登録ランクを変更しなかった場合
      MY_TS_POINT = MY_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
      MY_ALL_TS_POINT = MY_ALL_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
      try {
        matchResultRef
            .doc(myProfile.USER_ID)
            .update({'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});
      } catch (e) {
        print('TSPポイントの付与に失敗しました --- $e');
      }

      //各ランクのTSPポイントを更新
      switch (myProfile.TOROKU_RANK) {
        case '初級':
          try {
            matchResultRef.doc(myProfile.USER_ID).update({
              'SHOKYU_TS_POINT': MY_TS_POINT,
              'ALL_SHOKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            matchResultRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            matchResultRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            print('上級TSPポイントの付与に失敗しました --- $e');
          }
          break;
      }
    } else {
      //登録ランクを変更した場合
      switch (myProfile.TOROKU_RANK) {
        case '初級':
          try {
            MY_TS_POINT = MY_SHOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            MY_ALL_TS_POINT = MY_ALL_SHOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            matchResultRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});
            matchResultRef.doc(myProfile.USER_ID).update({
              'SHOKYU_TS_POINT': MY_TS_POINT,
              'ALL_SHOKYU_TS_POINT': MY_ALL_TS_POINT
            });
            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            MY_TS_POINT = MY_CHUKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            MY_ALL_TS_POINT = MY_ALL_CHUKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            matchResultRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});
            matchResultRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });
            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            MY_TS_POINT = MY_JYOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            MY_ALL_TS_POINT = MY_ALL_JYOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            matchResultRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});
            matchResultRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });
            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            print('上級TSPポイントの付与に失敗しました --- $e');
          }
          break;
      }
    }
    if (YOUR_TOROKU_RANK_CUR == yourProfile.TOROKU_RANK) {
      //登録ランクを変更しなかった場合
      YOUR_TS_POINT = YOUR_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
      YOUR_ALL_TS_POINT = YOUR_ALL_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
      try {
        matchResultRef.doc(yourProfile.USER_ID).update(
            {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});
      } catch (e) {
        print('TSPポイントの付与に失敗しました --- $e');
      }

      //各ランクのTSPポイントを更新
      switch (yourProfile.TOROKU_RANK) {
        case '初級':
          try {
            matchResultRef.doc(yourProfile.USER_ID).update({
              'SHOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_SHOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            matchResultRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            matchResultRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            print('上級TSPポイントの付与に失敗しました --- $e');
          }
          break;
      }
    } else {
      //登録ランクを変更した場合
      switch (yourProfile.TOROKU_RANK) {
        case '初級':
          try {
            YOUR_TS_POINT = YOUR_SHOKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            YOUR_ALL_TS_POINT =
                YOUR_ALL_SHOKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            matchResultRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});
            matchResultRef.doc(yourProfile.USER_ID).update({
              'SHOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_SHOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            YOUR_TS_POINT = YOUR_CHUKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            YOUR_ALL_TS_POINT =
                YOUR_ALL_CHUKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            matchResultRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});
            matchResultRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            YOUR_TS_POINT = YOUR_JYOKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            YOUR_ALL_TS_POINT =
                YOUR_ALL_JYOKYU_TS_POINT_CUR + YOUR_TS_POINT_FUYO_SUM;
            matchResultRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});
            matchResultRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            print('上級TSPポイントの付与に失敗しました --- $e');
          }
          break;
      }
    }

    //各ランクの勝率を更新(自分)
    switch (yourProfile.TOROKU_RANK) {
      case '初級':
        try {
          MY_SHOKYU_WIN_SU = MY_SHOKYU_WIN_SU_CUR + MY_WIN_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_WIN_SU': MY_SHOKYU_WIN_SU});
          MY_SHOKYU_LOSE_SU = MY_SHOKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': MY_SHOKYU_LOSE_SU});
          MY_SHOKYU_MATCH_SU = MY_SHOKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': MY_SHOKYU_MATCH_SU});

          MY_SHOKYU_WIN_RATE =
              ((MY_SHOKYU_WIN_SU / MY_SHOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': MY_SHOKYU_WIN_RATE});
        } catch (e) {
          print('初級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '中級':
        try {
          MY_CHUKYU_WIN_SU = MY_CHUKYU_WIN_SU_CUR + MY_WIN_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': MY_CHUKYU_WIN_SU});
          MY_CHUKYU_LOSE_SU = MY_CHUKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': MY_CHUKYU_LOSE_SU});
          MY_CHUKYU_MATCH_SU = MY_CHUKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': MY_CHUKYU_MATCH_SU});

          MY_CHUKYU_WIN_RATE =
              ((MY_CHUKYU_WIN_SU / MY_CHUKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': MY_CHUKYU_WIN_RATE});
        } catch (e) {
          print('中級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '上級':
        try {
          MY_JYOKYU_WIN_SU = MY_JYOKYU_WIN_SU_CUR + MY_WIN_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': MY_JYOKYU_WIN_SU});
          MY_JYOKYU_LOSE_SU = MY_JYOKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': MY_JYOKYU_LOSE_SU});
          MY_JYOKYU_MATCH_SU = MY_JYOKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': MY_JYOKYU_MATCH_SU});

          MY_JYOKYU_WIN_RATE =
              ((MY_JYOKYU_WIN_SU / MY_JYOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': MY_JYOKYU_WIN_RATE});
        } catch (e) {
          print('上級の勝率の付与に失敗しました --- $e');
        }
        break;
    }

    //各ランクの勝率を更新
    switch (myProfile.TOROKU_RANK) {
      case '初級':
        try {
          YOUR_SHOKYU_WIN_SU = YOUR_SHOKYU_WIN_SU_CUR + YOUR_WIN_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_WIN_SU': YOUR_SHOKYU_WIN_SU});
          YOUR_SHOKYU_LOSE_SU = YOUR_SHOKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': YOUR_SHOKYU_LOSE_SU});
          YOUR_SHOKYU_MATCH_SU = YOUR_SHOKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': YOUR_SHOKYU_MATCH_SU});

          YOUR_SHOKYU_WIN_RATE =
              ((YOUR_SHOKYU_WIN_SU / YOUR_SHOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': YOUR_SHOKYU_WIN_RATE});
        } catch (e) {
          print('初級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '中級':
        try {
          YOUR_CHUKYU_WIN_SU = YOUR_CHUKYU_WIN_SU_CUR + YOUR_WIN_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': YOUR_CHUKYU_WIN_SU});
          YOUR_CHUKYU_LOSE_SU = YOUR_CHUKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': YOUR_CHUKYU_LOSE_SU});
          YOUR_CHUKYU_MATCH_SU = YOUR_CHUKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': YOUR_CHUKYU_MATCH_SU});

          YOUR_CHUKYU_WIN_RATE =
              ((YOUR_CHUKYU_WIN_SU / YOUR_CHUKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': YOUR_CHUKYU_WIN_RATE});
        } catch (e) {
          print('中級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '上級':
        try {
          YOUR_JYOKYU_WIN_SU = YOUR_JYOKYU_WIN_SU_CUR + YOUR_WIN_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': YOUR_JYOKYU_WIN_SU});
          YOUR_JYOKYU_LOSE_SU = YOUR_JYOKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': YOUR_JYOKYU_LOSE_SU});
          YOUR_JYOKYU_MATCH_SU = YOUR_JYOKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': YOUR_JYOKYU_MATCH_SU});

          YOUR_JYOKYU_WIN_RATE =
              ((YOUR_JYOKYU_WIN_SU / YOUR_JYOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': YOUR_JYOKYU_WIN_RATE});
        } catch (e) {
          print('上級の勝率の付与に失敗しました --- $e');
        }
        break;
    }
    //フィードバックを
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

  /**
   * 友人済みか確認する
   */
  static Future<bool> checkFriends(String roomID) async {
    final doc = await roomRef.doc(roomID).get();
    bool alreadyFriendflg = false;
    List<String> checkList = [];
    checkList.add(doc.data()!['joined_user_ids'][0]);
    checkList.add(doc.data()!['joined_user_ids'][1]);

    final snapshot = await friendsListRef.get();
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if ((doc.data()['RECIPIENT_ID'].contains(checkList[0]) &&
              doc.data()['SENDER_ID'].contains(checkList[1])) ||
          (doc.data()['RECIPIENT_ID'].contains(checkList[1]) &&
              doc.data()['SENDER_ID'].contains(checkList[0]))) {
        alreadyFriendflg = true;
      }
    });
    return alreadyFriendflg;
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

  /**
   * スキル評価登録メソッドです
   * skill.OPPONENT_ID 評価される側のユーザ
   * auth.currentUser!.uid 評価している(入力中ユーザ)
   */
  static Future<void> registSkillLevel(
      CSkilLevelSetting skill, String dayKey) async {
    try {
      await matchResultRef
          .doc(skill.OPPONENT_ID)
          .collection('opponentList')
          .doc(auth.currentUser!.uid)
          .update({
        'STROKE_FOREHAND': skill.STROKE_FOREHAND,
        'STROKE_BACKHAND': skill.STROKE_BACKHAND,
        'VOLLEY_FOREHAND': skill.VOLLEY_FOREHAND,
        'VOLLEY_BACKHAND': skill.VOLLEY_BACKHAND,
        'SERVE_1ST': skill.SERVE_1ST,
        'SERVE_2ND': skill.SERVE_2ND,
      });
    } catch (e) {
      print('スキルレベル登録に失敗しました --- $e');
    }
    try {
      matchResultRef
          .doc(skill.OPPONENT_ID)
          .collection('opponentList')
          .doc(auth.currentUser!.uid)
          .collection('daily')
          .doc(dayKey)
          .update({
        'STROKE_FOREHAND': skill.STROKE_FOREHAND,
        'STROKE_BACKHAND': skill.STROKE_BACKHAND,
        'VOLLEY_FOREHAND': skill.VOLLEY_FOREHAND,
        'VOLLEY_BACKHAND': skill.VOLLEY_BACKHAND,
        'SERVE_1ST': skill.SERVE_1ST,
        'SERVE_2ND': skill.SERVE_2ND,
      });
    } catch (e) {
      print('日別スキルレベル登録に失敗しました --- $e');
    }
  }

  /**
   * もらった評価の平均を取りホーム画面に表示する
   */
  static Future<CSkilLevelSetting> getAvgSkillLevel() async {
    //対戦相手の評価フィールドを持つドキュメントIDを全て取得
    late CSkilLevelSetting skill;
    double stroke_fore_total = 0;
    double stroke_back_total = 0;
    double volley_fore_total = 0;
    double volley_back_total = 0;
    double serve_1st_total = 0;
    double serve_2nd_total = 0;
    double stroke_fore_avg = 0;
    double stroke_back_avg = 0;
    double volley_fore_avg = 0;
    double volley_back_avg = 0;
    double serve_1st_avg = 0;
    double serve_2nd_avg = 0;
    double count = 0;
    try {
      final opponentListsnapShot = await matchResultRef
          .doc(auth.currentUser!.uid)
          .collection('opponentList')
          .get();
      await Future.forEach<dynamic>(opponentListsnapShot.docs, (doc) async {
        //0~5以外は入り得ない
        double fore = await doc.data()?['STROKE_FOREHAND'] ?? 10;
        if (fore == 10) {
          return;
        } else {
          count++;
          stroke_fore_total = stroke_fore_total + doc.get('STROKE_FOREHAND');
          stroke_back_total = stroke_back_total + doc.get('STROKE_BACKHAND');
          volley_fore_total = volley_fore_total + doc.get('VOLLEY_FOREHAND');
          volley_back_total = volley_back_total + doc.get('VOLLEY_BACKHAND');
          serve_1st_total = serve_1st_total + doc.get('SERVE_1ST');
          serve_2nd_total = serve_2nd_total + doc.get('SERVE_2ND');
        }
      });
      stroke_fore_avg = stroke_fore_total / count;
      stroke_back_avg = stroke_back_total / count;
      volley_fore_avg = volley_fore_total / count;
      volley_back_avg = volley_back_total / count;
      serve_1st_avg = serve_1st_total / count;
      serve_2nd_avg = serve_2nd_total / count;
    } catch (e) {
      print(e);
    }
    return CSkilLevelSetting(
        SERVE_1ST: serve_1st_avg,
        SERVE_2ND: serve_2nd_avg,
        STROKE_BACKHAND: stroke_back_avg,
        STROKE_FOREHAND: stroke_fore_avg,
        VOLLEY_BACKHAND: volley_back_avg,
        VOLLEY_FOREHAND: volley_fore_avg);
  }

  /**
   * フィードバックコメント登録メソッドです
   * OPPONENT_ID 評価される側のユーザ
   * auth.currentUser!.uid 評価している(入力中ユーザ)
   */
  static Future<void> registFeedBack(
      CFeedBackCommentSetting feedBack,
      CprofileSetting myProfile,
      CprofileSetting yourProfile,
      String dayKey) async {
    print(feedBack.FEED_BACK);
    try {
      await matchResultRef
          .doc(yourProfile.USER_ID)
          .collection('opponentList')
          .doc(myProfile.USER_ID)
          .collection('daily')
          .doc(dayKey)
          .update({
        'FEEDBACK_COMMENT': feedBack.FEED_BACK,
      });
    } catch (e) {
      print('フィードバックの登録に失敗しました --- $e');
    }
  }

  /**
   * ログインユーザに対してのフィードバックのリストを取得
   */
  static Future<List<CFeedBackCommentSetting>> getFeedBacks() async {
    List<CFeedBackCommentSetting> feedBackList = [];
    try {
      final matchResultSnap = await matchResultRef
          .doc(auth.currentUser!.uid)
          .collection('opponentList')
          .get();
      await Future.forEach<dynamic>(matchResultSnap.docs, (doc) async {
        final matchResultSnapWk = await matchResultRef
            .doc(auth.currentUser!.uid)
            .collection('opponentList')
            .doc(doc.id)
            .collection('daily')
            .get();
        await Future.forEach<dynamic>(matchResultSnapWk.docs, (doc2) async {
          CHomePageVal home = await getNickNameAndTorokuRank(doc.id);
          String feedBackComment = await doc2.data()?['FEEDBACK_COMMENT'] ?? "";
          String matchTitle = await doc2.data()?['matchTitle'] ?? "";
          if (feedBackComment != "") {
            feedBackList.add(CFeedBackCommentSetting(
                OPPONENT_ID: doc.id,
                FEED_BACK: feedBackComment,
                DATE_TIME: doc2.id,
                MATCH_TITLE: matchTitle,
                HOME: home));
          }
        });
      });
    } catch (e) {
      print('フィードバックリスト取得に失敗しました --- $e');
    }
    return feedBackList;
  }

  /**
   * 特定のフィードバックの取得
   */
  static Future<String> getFeedBack(String? dayKey, String yourUserId) async {
    String feedBackComment = "";
    if (dayKey != null) {
      try {
        final snapShot = await matchResultRef
            .doc(auth.currentUser!.uid)
            .collection('opponentList')
            .doc(yourUserId)
            .collection('daily')
            .doc(dayKey)
            .get();
        feedBackComment = snapShot.data()?['FEEDBACK_COMMENT'] ?? "";
      } catch (e) {
        print('フィードバックリスト取得に失敗しました --- $e');
      }
    } else {
      feedBackComment = "";
    }
    return feedBackComment;
  }

  /**
   * 特定のスキルレビュー結果の取得
   */
  static Future<CSkilLevelSetting> getSkillLevel(
      String? dayKey, String yourUserId) async {
    late CSkilLevelSetting skillLevel;
    if (dayKey != null) {
      try {
        final snapShot = await matchResultRef
            .doc(auth.currentUser!.uid)
            .collection('opponentList')
            .doc(yourUserId)
            .collection('daily')
            .doc(dayKey)
            .get();
        skillLevel = CSkilLevelSetting(
            SERVE_1ST: snapShot.data()?['STROKE_FOREHAND'] ?? 0,
            SERVE_2ND: snapShot.data()?['STROKE_BACKHAND'] ?? 0,
            STROKE_BACKHAND: snapShot.data()?['VOLLEY_FOREHAND'] ?? 0,
            STROKE_FOREHAND: snapShot.data()?['VOLLEY_BACKHAND'] ?? 0,
            VOLLEY_BACKHAND: snapShot.data()?['SERVE_1ST'] ?? 0,
            VOLLEY_FOREHAND: snapShot.data()?['SERVE_2ND'] ?? 0);
      } catch (e) {
        print('個別スキルレベル取得に失敗しました --- $e');
      }
    } else {
      skillLevel = CSkilLevelSetting(
          SERVE_1ST: 0,
          SERVE_2ND: 0,
          STROKE_BACKHAND: 0,
          STROKE_FOREHAND: 0,
          VOLLEY_BACKHAND: 0,
          VOLLEY_FOREHAND: 0);
    }
    return skillLevel;
  }

  /**
   * 特定の対戦結果を取得する
   */
  static Future<List<CmatchResult>> getMatchResult(
      String? dayKey, String yourUserId) async {
    //アクティビィリスト
    List<CmatchResult> matchResultList = [];
    if (dayKey != null) {
      try {
        final snapShot = await matchResultRef
            .doc(auth.currentUser!.uid)
            .collection('opponentList')
            .doc(yourUserId)
            .collection('daily')
            .doc(dayKey)
            .collection('matchDetail')
            .orderBy('No')
            .get();
        await Future.forEach<dynamic>(snapShot.docs, (document) async {
          matchResultList.add(CmatchResult(
            No: document.data()['No'],
            myGamePoint: document.data()['MY_POINT'],
            yourGamePoint: document.data()['YOUR_POINT'],
          ));
        });
      } catch (e) {
        print('対戦結果取得に失敗しました --- $e');
      }
    }
    return matchResultList;
  }

  /**
   * 対戦結果一覧を取得する
   */
  static Future<List<CmatchResultList>> getMatchResults() async {
    List<CmatchResultList> matchResultList = [];
    try {
      final snapShotWk = await FirebaseFirestore.instance
          .collectionGroup('daily')
          .where('userId', isEqualTo: auth.currentUser!.uid)
          .orderBy('dailyId', descending: true)
          .limit(5)
          .get();

      await Future.forEach<dynamic>(snapShotWk.docs, (doc2) async {
        CprofileSetting yourProfile =
            await FirestoreMethod.getYourProfile(doc2.data()?['opponentId'] ?? "");
        matchResultList.add(CmatchResultList(
            YOUR_USER: yourProfile,
            dayKey: doc2.id,
            matchTitle: doc2.data()?['matchTitle'] ?? ""));
      });
    } catch (e) {
      print('対戦結果LIST取得に失敗しました --- $e');
    }
    matchResultList.sort((a, b) => b.dayKey.compareTo(a.dayKey));
    return matchResultList;
  }

  // static Future<List<CmatchResultList>> getMatchResults() async {
  //   List<CmatchResultList> matchResultList = [];
  //   try {
  //     final snapShot = await matchResultRef
  //         .doc(auth.currentUser!.uid)
  //         .collection('opponentList')
  //         .get();
  //     await Future.forEach<dynamic>(snapShot.docs, (doc1) async {
  //       final snapShotWk = await matchResultRef
  //           .doc(auth.currentUser!.uid)
  //           .collection('opponentList')
  //           .doc(doc1.id)
  //           .collection('daily')
  //           .limit(1)
  //           .get();
  //       await Future.forEach<dynamic>(snapShotWk.docs, (doc2) async {
  //         CprofileSetting yourProfile =
  //             await FirestoreMethod.getYourProfile(doc1.id);
  //         matchResultList.add(CmatchResultList(
  //             YOUR_USER: yourProfile,
  //             dayKey: doc2.id,
  //             matchTitle: doc2.data()?['matchTitle'] ?? ""));
  //       });
  //     });
  //   } catch (e) {
  //     print('対戦結果LIST取得に失敗しました --- $e');
  //   }
  //   matchResultList.sort((a, b) => b.dayKey.compareTo(a.dayKey));
  //   return matchResultList;
  // }

  static Future<String> getMatchTitle(String? dayKey, String yourUserId) async {
    //タイトル取得
    String matchTitle = "";
    if (dayKey != null) {
      final snapShot = await matchResultRef
          .doc(auth.currentUser!.uid)
          .collection('opponentList')
          .doc(yourUserId)
          .collection('daily')
          .doc(dayKey)
          .get();
      String matchTitle = await snapShot.data()?['matchTitle'] ?? "";
      return matchTitle;
    } else {
      return matchTitle;
    }
  }

  /**
   * MyUserIdの重複チェックを行うメソッドです
   */
  static Future<bool> checkDoubleMyUserID(
      String inputText, bool isDoubleMyUserId) async {
    final snapShot =
        await profileRef.where('MY_USER_ID', isEqualTo: inputText).get();

    print("bb" + snapShot.docs.toString());
    if (snapShot.size != 0) {
      isDoubleMyUserId = true;
    }
    return isDoubleMyUserId;
  }

//ブロックリスト追加処理
  static Future<void> addBlockList(String userId) async {
//ブロックリストチェック
    String newFlg =
        await FirestoreMethod.newFlgBlockList(auth.currentUser!.uid);

    if (newFlg == "0") {
      final snapshot = await blockListRef
          .doc(auth.currentUser!.uid)
          .collection('blockUserList')
          .get();
      await Future.forEach<dynamic>(snapshot.docs, (doc) async {
        if (doc.data()['blockUser'].contains(userId)) {
          print("既にブロック済みです");
        } else {
          await blockListRef
              .doc(auth.currentUser!.uid)
              .collection('blockUserList')
              .add({'BLOCK_USER': userId});
        }
      });
    } else {
      await blockListRef
          .doc(auth.currentUser!.uid)
          .collection('blockUserList')
          .add({'BLOCK_USER': userId});
    }
  }

//ブロックリスト解除
  static Future<void> delBlockList(String userId) async {
    QuerySnapshot querySnapshot = await blockListRef
        .doc(auth.currentUser!.uid)
        .collection('blockUserList')
        .where('BLOCK_USER', isEqualTo: userId)
        .get();

    querySnapshot.docs.forEach((doc) {
      blockListRef
          .doc(auth.currentUser!.uid)
          .collection('blockUserList')
          .doc(doc.id)
          .delete();
    });
  }

//ブロックリスト_新規フラグ取得
  static Future<String> newFlgBlockList(String userId) async {
    final snapshot = await blockListRef.get();
    String newFlg = "1";
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.id == userId) {
        newFlg = "0";
      }
    });
    return newFlg;
  }

//ブロックリストチェック
  static Future<String> getBlockListChk(String userId) async {
    int blockListCount = await blockListRef
        .doc(auth.currentUser!.uid)
        .collection('blockUserList')
        .where('BLOCK_USER', isEqualTo: userId)
        .get()
        .then((querySnapshot) => querySnapshot.size);
    if (blockListCount > 0) {
      return "1";
    } else {
      return "0";
    }
  }

//ブロックリスト取得
  static Future<List<BlockListModel>> getBlockList(String myUserId) async {
    final snapshot = await await blockListRef
        .doc(auth.currentUser!.uid)
        .collection('blockUserList')
        .get();
    List<BlockListModel> blockList = [];
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      CprofileSetting yourProfile =
          await getYourProfile(doc.data()['BLOCK_USER']);
      try {
        BlockListModel blockUser = BlockListModel(
          BLOCK_USER_ID: doc.data()['BLOCK_USER'],
          YOUR_USER: yourProfile,
        );
        blockList.add(blockUser);
      } catch (e) {
        print('ブロックリスト追加に失敗しました --- $e');
      }
    });
    return blockList;
  }

//開発者からユーザーへのメッセージ
  static Future<String> getToUserMessage() async {
    final snapShot = await toUserMessageRef.doc("message").get();
    String userToMessage = snapShot.data()!["userMessage"];
    return userToMessage;
  }

  /**
   * 自分のユーザIDをキーに指定対戦相手との対戦結果を取得するメソッド
   *  userId 自身のユーザーID
   */
  static Future<CScoreRef> getMatchResultScore(String oponent_UserId) async {
    late List<CScoreRefHistory> historyList = [];
    late QuerySnapshot snapShot;
    late List<QuerySnapshot> queryList = [];
    late List<String> titleList = [];

    //対戦結果を取得
    final doc = await matchResultRef
        .doc(auth.currentUser!.uid)
        .collection('opponentList')
        .doc(oponent_UserId)
        .get();

    // final snapShot_date = await matchResultRef
    //     .doc(auth.currentUser!.uid)
    //     .collection('opponentList')
    //     .doc(oponent_UserId)
    //     .collection('daily')
    //     .orderBy(FieldPath.documentId).get();
    //

    final snapShot_daily = await matchResultRef
        .doc(auth.currentUser!.uid)
        .collection('opponentList')
        .doc(oponent_UserId)
        .collection('daily');

    final snapShot_date = await matchResultRef
        .doc(auth.currentUser!.uid)
        .collection('opponentList')
        .doc(oponent_UserId)
        .collection('daily')
        .orderBy(FieldPath.documentId)
        .get();

    await Future.forEach<dynamic>(snapShot_date.docs, (doc_date) async {
      titleList.add(doc_date.data()['matchTitle'] ?? "");
    });

    QuerySnapshot snapShot_date_doc = await snapShot_daily.get();

    for (QueryDocumentSnapshot documentSnapshot in snapShot_date_doc.docs) {
      snapShot = await documentSnapshot.reference
          .collection('matchDetail')
          .orderBy('KOUSHIN_TIME')
          .get();

      queryList.add(snapShot);
      // Do something with subQuerySnapshot
    }
    //matchDetailをdaily毎に配列で取得して全件ループ
    for (QuerySnapshot matchDetail_Snapshot in queryList) {
      await Future.forEach<dynamic>(matchDetail_Snapshot.docs, (doc_his) async {
        CScoreRefHistory history = new CScoreRefHistory(
            KOUSHIN_TIME: doc_his['KOUSHIN_TIME'],
            MY_POINT: doc_his['MY_POINT'],
            YOUR_POINT: doc_his['YOUR_POINT']);

        historyList.add(history);
      });
    }
    CScoreRef result = new CScoreRef(
        MATCH_COUNT: doc!['MATCH_SU'],
        WIN_COUNT: doc!['WIN_SU'],
        LOSE_COUNT: doc!['LOSE_SU'],
        WIN_LATE: doc!['WIN_RATE'],
        HISTORYLIST: historyList,
        TITLE: titleList);

    return result;
  }

  static bool reviewFeatureEnabled = true;

  static Future<bool> getReviewFeatureEnabled() async {
    final settingSnapshot = await settingRef.doc(auth.currentUser!.uid).get();

    if (settingSnapshot == null || !settingSnapshot.exists) {
      reviewFeatureEnabled = true;
      // データが存在しない場合、初期値を使用する
      return true;
    }

    reviewFeatureEnabled = settingSnapshot.data()?["REVIEW_ENABLED"] ?? true;

    return reviewFeatureEnabled; // Firestoreのデータがnullの場合は初期値を使用する
  }

  static Future<void> putReviewFeatureEnabled(bool reviewFeatureEnabled) async {
    final settingSnapshot = await settingRef.doc(auth.currentUser!.uid);

    settingSnapshot.set({"REVIEW_ENABLED": reviewFeatureEnabled});
  }

  static Future<bool> getYourReviewFeatureEnabled(String userId) async {
    final settingSnapshot = await settingRef.doc(userId).get();
    bool yourReviewFeatureEnabled = true;

    if (settingSnapshot == null || !settingSnapshot.exists) {
      // データが存在しない場合、初期値を使用する
      return true;
    }
    yourReviewFeatureEnabled =
        settingSnapshot.data()?["REVIEW_ENABLED"] ?? true;

    return yourReviewFeatureEnabled; // Firestoreのデータがnullの場合は初期値を使用する
  }

  //ログインするユーザーがプロフィール登録を完了しているか確認
static bool isprofile = false;
  static Future<void> isProfile() async {
    print("AAA");
    DocumentReference docRef = await profileRef.doc(auth.currentUser!.uid);
    DocumentSnapshot docSnapshot = await docRef.get();
    print("XXX" + docSnapshot.exists.toString());
    isprofile = docSnapshot.exists;
  }
}
