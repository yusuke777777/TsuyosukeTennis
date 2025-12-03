import 'package:flutter/foundation.dart';
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
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tsuyosuke_tennis_ap/Common/CHomePageVal.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRef.dart';
import 'package:tsuyosuke_tennis_ap/Common/CScoreRefHistory.dart';
import 'package:tsuyosuke_tennis_ap/Common/CSkilLevelSetting.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/singletons_data.dart';
import 'package:yaml/yaml.dart';

import '../Common/CFeedBackCommentSetting.dart';
import '../Common/CHomePageSetting.dart';
import '../Common/CSinglesRankModel.dart';
import '../Common/CTitle.dart';
import '../Common/CblockList.dart';
import '../Common/CfriendsList.dart';
import '../Common/CmatchList.dart';
import '../Common/CmatchResult.dart';
import '../Common/CmatchResultsList.dart';
import '../Common/Cmessage.dart';
import '../Common/CprofileDetail.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CactivityList.dart';
import '../Common/CtalkRoom.dart';
import '../Common/TournamentQrPayload.dart';
import '../Common/TodoListModel.dart';
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
  static final profileDetailRef =
      _firestoreInstance.collection('myProfileDetail');
  static final tournamentsRef = _firestoreInstance.collection('tournaments');
  //static final todosRef = _firestoreInstance.collection('todos');

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

  //大会参加者管理
  static CollectionReference<Map<String, dynamic>> tournamentParticipantsRef(
          String tournamentId) =>
      tournamentsRef.doc(tournamentId).collection('participants');

  static Stream<QuerySnapshot<Map<String, dynamic>>>
      tournamentParticipantsSnapshot(String tournamentId) {
    return tournamentParticipantsRef(tournamentId)
        .orderBy('joinedAt', descending: false)
        .snapshots();
  }

  static Future<void> addTournamentParticipant({
    required String tournamentId,
    required String hostUserId,
    required CprofileSetting profile,
  }) async {
    final userId = profile.USER_ID;
    final now = FieldValue.serverTimestamp();

    // 大会ドキュメントがなくても作成しておく（最低限のメタ情報だけ）
    await tournamentsRef.doc(tournamentId).set({
      'hostUserId': hostUserId,
      'updatedAt': now,
    }, SetOptions(merge: true));

    await tournamentParticipantsRef(tournamentId).doc(userId).set({
      'userId': userId,
      'displayName': profile.NICK_NAME,
      'profileImage': profile.PROFILE_IMAGE,
      'joinedAt': now,
      'hostUserId': hostUserId,
    }, SetOptions(merge: true));
  }

  static Future<String> createTournament({
    required String title,
    required int participantLimit,
    required String format,
    required String description,
    bool includeHost = false,
  }) async {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      throw ('ログインが必要です');
    }
    final docRef = tournamentsRef.doc();
    final now = FieldValue.serverTimestamp();
    final qrPayload = TournamentQrPayload(
            tournamentId: docRef.id, hostUserId: currentUser.uid)
        .encode();
    await docRef.set({
      'title': title,
      'participantLimit': participantLimit,
      'participantCount': includeHost ? 1 : 0,
      'format': format,
      'description': description,
      'hostUserId': currentUser.uid,
      'status': 'planned',
      'qrPayload': qrPayload,
      'createdAt': now,
      'updatedAt': now,
      'includeHost': includeHost,
    });
    if (includeHost) {
      final hostProfile = await getProfile();
      await addTournamentParticipant(
          tournamentId: docRef.id,
          hostUserId: currentUser.uid,
          profile: hostProfile);
    }
    return docRef.id;
  }

  //課金フラグの更新
  static Future<void> updateBillingFlg() async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String today = outputFormat.format(now);
    DateFormat outputFormat2 = DateFormat('yyyy/MM/dd HH:mm');
    String todayTime = outputFormat2.format(now);

    try {
      final profileSnapshot = await profileRef.doc(auth.currentUser!.uid).get();
      if (profileSnapshot.exists) {
        await profileSnapshot.reference.set({
          "BILLING_FLG": appData.entitlementIsActive == true ? "1" : "0",
          "koushinYmd": today
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw ("課金フラグの更新に失敗しました");
    }
    try {
      final profileDetailSnapshot =
          await profileDetailRef.doc(auth.currentUser!.uid).get();
      if (profileDetailSnapshot.exists) {
        await profileDetailSnapshot.reference.set({
          "BILLING_FLG": appData.entitlementIsActive == true ? "1" : "0",
          "KOUSHIN_TIME": todayTime
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw ("課金フラグの更新に失敗しました");
    }
  }

  //課金フラグ取得
  static Future<String> getBillingFlg() async {
    String BILLING_FLG = "0";
    try {
      final profileSnapshot = await profileRef.doc(auth.currentUser!.uid).get();
      if (profileSnapshot.exists) {
        BILLING_FLG = profileSnapshot.data()!['BILLING_FLG'];
      } else {
        BILLING_FLG = "0";
      }
    } catch (e) {
      throw ("課金フラグの取得失敗しました");
    }
    return BILLING_FLG;
  }

  static Future<void> updateFirstTimeBenefitFlg() async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String today = outputFormat.format(now);

    try {
      final profileSnapshot = await profileRef.doc(auth.currentUser!.uid).get();
      if (profileSnapshot.exists) {
        await profileSnapshot.reference.set({
          "FIRST_TIME_BENEFIT_FLG": "1",
          "koushinYmd": today
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw ("課金フラグの更新に失敗しました");
    }
  }

  //初回課金フラグ取得
  static Future<String> getFirstTimeBenefitFlg() async {
    String FIRST_TIME_BENEFIT_FLG = "0";
    try {
      final profileSnapshot = await profileRef.doc(auth.currentUser!.uid).get();
      if (profileSnapshot.exists) {
        FIRST_TIME_BENEFIT_FLG = profileSnapshot.data()!['FIRST_TIME_BENEFIT_FLG'] ?? "0";
      } else {
        FIRST_TIME_BENEFIT_FLG = "0";
      }
    } catch (e) {
      throw ("初回特典フラグの取得失敗しました");
    }
    return FIRST_TIME_BENEFIT_FLG;
  }


  //プロフィール情報設定
  static Future<void> makeProfile(CprofileSetting profile) async {
    print("ggg");
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy-MM-dd');
    String today = outputFormat.format(now);
    print("hhh");
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
        'MY_USER_ID': profile.MY_USER_ID,
        'TITLE': profile.TITLE,
        'FEEDBACK_COUNT': 0,
        'BILLING_FLG': appData.entitlementIsActive == true ? "1" : "0"
      });
    } catch (e) {
      print('ユーザー登録に失敗しました --- $e');
      throw ('ユーザー登録に失敗しました --- $e');
    }
    //アクティビティリスト削除
    final snapshot = await profileRef
        .doc(auth.currentUser!.uid)
        .collection("activityList")
        .get();
    print("iiii");
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

  //プロフィール情報設定
  static Future<void> makeProfileDetail(
      CprofileSetting profile, String koushinFlg) async {
    try {
      print("===makeProfileDetail開始===");
      DateTime now = DateTime.now();
      DateFormat outputFormat = DateFormat('yyyy-MM-dd');
      DateFormat outputFormat2 = DateFormat('yyyy/MM/dd HH:mm');
      String todayTime = outputFormat2.format(now);

      String today = outputFormat.format(now);

      int No = 0;
      List<String> todofukenList = [];
      List<String> shichosonList = [];
      List<String> todofukenShichosonList = [];
      String todofukenShichoson = "";
      for (int index = 0; index < profile.activityList.length; index++) {
        if (profile.activityList[index].TODOFUKEN != "") {
          todofukenList.add(profile.activityList[index].TODOFUKEN);
          if (profile.activityList[index].SHICHOSON.text != "") {
            shichosonList.add(profile.activityList[index].SHICHOSON.text);
            todofukenShichosonList.add(profile.activityList[index].TODOFUKEN +
                "(" +
                profile.activityList[index].SHICHOSON.text +
                ")");
            if (profile.activityList.length - 1 != index) {
              todofukenShichoson = todofukenShichoson +
                  profile.activityList[index].TODOFUKEN +
                  "(" +
                  profile.activityList[index].SHICHOSON.text +
                  ")" +
                  "、";
            } else {
              todofukenShichoson = todofukenShichoson +
                  profile.activityList[index].TODOFUKEN +
                  "(" +
                  profile.activityList[index].SHICHOSON.text +
                  ")";
            }
          } else {
            todofukenShichosonList.add(profile.activityList[index].TODOFUKEN);
            if (profile.activityList.length - 1 != index) {
              todofukenShichoson = todofukenShichoson +
                  profile.activityList[index].TODOFUKEN +
                  "、";
            } else {
              todofukenShichoson =
                  todofukenShichoson + profile.activityList[index].TODOFUKEN;
            }
            shichosonList.add("");
          }
          No = No + 1;
        }
      }
      if (koushinFlg == "1") {
        print("makeDetailにて更新フラグは１");
        // await profileDetailRef.doc(auth.currentUser!.uid).set({
        //   'USER_ID': auth.currentUser!.uid,
        //   'PROFILE_IMAGE': profile.PROFILE_IMAGE,
        //   'NICK_NAME': profile.NICK_NAME,
        //   'TOROKU_RANK': profile.TOROKU_RANK,
        //   'AGE': profile.AGE,
        //   'GENDER': profile.GENDER,
        //   'COMENT': profile.COMENT,
        //   'KOUSHIN_TIME': todayTime,
        //   'MY_USER_ID': profile.MY_USER_ID,
        //   'TODOFUKEN_LIST':todofukenList,
        //   'SHICHOSON_LIST':shichosonList,
        //   'FIRST_TODOFUKEN_SICHOSON':shichosonList[0] == "" ? todofukenList[0] : todofukenList[0] + '(' + shichosonList[0] + ')',
        //   //マッチリザルト系の結果
        //   'TS_POINT': 0,
        //   'ALL_TS_POINT': 0,
        //   'TOROKU_RANK': profile.TOROKU_RANK,
        //   'SHOKYU_TS_POINT': 0,
        //   'CHUKYU_TS_POINT': 0,
        //   'JYOKYU_TS_POINT': 0,
        //   'ALL_SHOKYU_TS_POINT': 0,
        //   'ALL_CHUKYU_TS_POINT': 0,
        //   'ALL_JYOKYU_TS_POINT': 0,
        //   'SHOKYU_WIN_SU': 0,
        //   'SHOKYU_LOSE_SU': 0,
        //   'SHOKYU_MATCH_SU': 0,
        //   'SHOKYU_WIN_RATE': 0,
        //   'CHUKYU_WIN_SU': 0,
        //   'CHUKYU_LOSE_SU': 0,
        //   'CHUKYU_MATCH_SU': 0,
        //   'CHUKYU_WIN_RATE': 0,
        //   'JYOKYU_WIN_SU': 0,
        //   'JYOKYU_LOSE_SU': 0,
        //   'JYOKYU_MATCH_SU': 0,
        //   'JYOKYU_WIN_RATE': 0,
        //   'STROKE_FOREHAND_AVE': 0.0,
        //   'STROKE_BACKHAND_AVE': 0.0,
        //   'VOLLEY_FOREHAND_AVE': 0.0,
        //   'VOLLEY_BACKHAND_AVE': 0.0,
        //   'SERVE_1ST_AVE': 0.0,
        //   'SERVE_2ND_AVE': 0.0
        ////ランクNoの結果
        //'RANK_NO':0.0,
        //'TITLE':profile.TITLE,
        //レビューセッティング
        //"REVIEW_ENABLED":true
        //サーチセッティング
        //"SEARCH_ENABLED":true
        // });
        //KOUSHIN_TIME更新なし

        //末尾が「、」だった場合除去する
        if (todofukenShichoson.endsWith("、")) {
          todofukenShichoson =
              todofukenShichoson.substring(0, todofukenShichoson.length - 1);
        }

        await profileDetailRef.doc(auth.currentUser!.uid).update({
          'USER_ID': auth.currentUser!.uid,
          'PROFILE_IMAGE': profile.PROFILE_IMAGE,
          'NICK_NAME': profile.NICK_NAME,
          'TOROKU_RANK': profile.TOROKU_RANK,
          'AGE': profile.AGE,
          'GENDER': profile.GENDER,
          'COMENT': profile.COMENT,
          // 'KOUSHIN_TIME': todayTime,
          'TODOFUKEN_LIST': todofukenList,
          'SHICHOSON_LIST': shichosonList,
          'TODOFUKEN_SHICHOSON_LIST': todofukenShichosonList,
          'FIRST_TODOFUKEN_SICHOSON': todofukenShichoson,
          'BILLING_FLG': appData.entitlementIsActive == true ? "1" : "0",
        });
      } else {
        //KOUSHIN_TIME更新あり(初回)
        await profileDetailRef.doc(auth.currentUser!.uid).set({
          'USER_ID': auth.currentUser!.uid,
          'PROFILE_IMAGE': profile.PROFILE_IMAGE,
          'NICK_NAME': profile.NICK_NAME,
          'TOROKU_RANK': profile.TOROKU_RANK,
          'AGE': profile.AGE,
          'GENDER': profile.GENDER,
          'COMENT': profile.COMENT,
          'KOUSHIN_TIME': todayTime,
          'TODOFUKEN_LIST': todofukenList,
          'SHICHOSON_LIST': shichosonList,
          'TODOFUKEN_SHICHOSON_LIST': todofukenShichosonList,
          'FIRST_TODOFUKEN_SICHOSON': todofukenShichoson,
          //マッチリザルト系の結果
          'TS_POINT': 0,
          'ALL_TS_POINT': 0,
          'SHOKYU_TS_POINT': 0,
          'CHUKYU_TS_POINT': 0,
          'JYOKYU_TS_POINT': 0,
          'ALL_SHOKYU_TS_POINT': 0,
          'ALL_CHUKYU_TS_POINT': 0,
          'ALL_JYOKYU_TS_POINT': 0,
          'SHOKYU_WIN_SU': 0,
          'SHOKYU_LOSE_SU': 0,
          'SHOKYU_MATCH_SU': 0,
          'SHOKYU_WIN_RATE': 0,
          'CHUKYU_WIN_SU': 0,
          'CHUKYU_LOSE_SU': 0,
          'CHUKYU_MATCH_SU': 0,
          'CHUKYU_WIN_RATE': 0,
          'JYOKYU_WIN_SU': 0,
          'JYOKYU_LOSE_SU': 0,
          'JYOKYU_MATCH_SU': 0,
          'JYOKYU_WIN_RATE': 0,
          'STROKE_FOREHAND_AVE': 0.0,
          'STROKE_BACKHAND_AVE': 0.0,
          'VOLLEY_FOREHAND_AVE': 0.0,
          'VOLLEY_BACKHAND_AVE': 0.0,
          'SERVE_1ST_AVE': 0.0,
          'SERVE_2ND_AVE': 0.0,
          //ランクNoの結果
          'RANK_TOROKU_RANK': profile.TOROKU_RANK, //ランキング更新時の登録ランキング
          'RANK_NO': 0,
          'TITLE': profile.TITLE,
          'FEEDBACK_COUNT': 0,
          //レビューセッティング
          "REVIEW_ENABLED": true,
          //サーチセッティング
          "SEARCH_ENABLED": true,
          //課金フラグ
          'BILLING_FLG': appData.entitlementIsActive == true ? "1" : "0"
        });
        print("detail登録段階での称号は？" + profile.TITLE.toString());
      }
    } catch (e) {
      print("===makeProfileDetail失敗===");
      throw (e);
      print('ユーザー情報の詳細登録に失敗しました --- $e');
      throw ('ユーザー情報の詳細登録に失敗しました --- $e');
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
   * bkでしか呼ばれてない
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
    String toUserMessage = " ";

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

  static Future<CprofileSetting> getProfile() async {
    late CprofileSetting cprofileSet;
    late String USER_ID;
    late String PROFILE_IMAGE;
    late String NICK_NAME;
    late String TOROKU_RANK;
    late String AGE;
    late String GENDER;
    late String COMENT;
    late String MY_USER_ID;
    late Map<String, dynamic>? TITLE;
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('myProfile')
          .doc(auth.currentUser!.uid)
          .get();

      if(snapShot.data() != null){
        print(auth.currentUser!.uid);
        USER_ID = auth.currentUser!.uid;
        PROFILE_IMAGE = snapShot.data()!['PROFILE_IMAGE'];
        NICK_NAME = snapShot.data()!['NICK_NAME'];
        TOROKU_RANK = snapShot.data()!['TOROKU_RANK'];
        AGE = snapShot.data()!['AGE'];
        GENDER = snapShot.data()!['GENDER'];
        COMENT = snapShot.data()!['COMENT'];
        MY_USER_ID = snapShot.data()!['MY_USER_ID'];
        TITLE = snapShot.data()!['TITLE'];
      }
      else{
        USER_ID = auth.currentUser!.uid;
        PROFILE_IMAGE = '';
        NICK_NAME = '';
        TOROKU_RANK = '';
        AGE = '';
        GENDER = '';
        COMENT = '';
        MY_USER_ID = '';
        TITLE = {};
      }

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

      cprofileSet = await CprofileSetting(
          USER_ID: USER_ID,
          PROFILE_IMAGE: PROFILE_IMAGE,
          NICK_NAME: NICK_NAME,
          TOROKU_RANK: TOROKU_RANK,
          activityList: activityList,
          AGE: AGE,
          GENDER: GENDER,
          COMENT: COMENT,
          MY_USER_ID: MY_USER_ID,
          TITLE: TITLE);
      return cprofileSet;
    } catch (e) {
      throw ("エラー内容は"+ e.toString());
    }
    return cprofileSet;
  }

  static Future<CprofileSetting> getYourProfile(String userId) async {
    List<CativityList> activityList = [];
    final snapShot = await FirebaseFirestore.instance
        .collection('myProfile')
        .doc(userId)
        .get();
    if (snapShot.data()?.length == null) {
      String USER_ID = userId;
      String PROFILE_IMAGE = '';
      String NICK_NAME = "退会済みユーザー";

      CprofileSetting cprofileSet = await CprofileSetting(
          USER_ID: USER_ID,
          PROFILE_IMAGE: PROFILE_IMAGE,
          NICK_NAME: NICK_NAME,
          TOROKU_RANK: '',
          activityList: activityList,
          AGE: '',
          GENDER: '',
          COMENT: '',
          MY_USER_ID: '');

      return cprofileSet;
    } else {
      String USER_ID = userId;
      String PROFILE_IMAGE = snapShot.data()!['PROFILE_IMAGE'];
      String NICK_NAME = snapShot.data()!['NICK_NAME'];
      String TOROKU_RANK = snapShot.data()!['TOROKU_RANK'];
      String AGE = snapShot.data()!['AGE'];
      String GENDER = snapShot.data()!['GENDER'];
      String COMENT = snapShot.data()!['COMENT'];
      String MY_USER_ID = snapShot.data()!['MY_USER_ID'];

      try {
        final snapShotActivity = await FirebaseFirestore.instance
            .collection('myProfile')
            .doc(userId)
            .collection("activityList")
            .get();

        await Future.forEach<dynamic>(snapShotActivity.docs, (doc) async {
          activityList.add(CativityList(
            No: doc.data()!['No'],
            TODOFUKEN: doc.data()!['TODOFUKEN'],
            SHICHOSON: TextEditingController(text: doc.data()!['SHICHOSON']),
          ));
        });
      } catch (e) {
        throw (e);
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
  }

  static Future<CprofileDetail> getYourDetailProfile(String userId) async {
    late CprofileDetail cprofileDetail;
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('myProfileDetail')
          .doc(userId)
          .get();

      Map<String, dynamic> titleMap = snapShot.data()!['TITLE'];

      //現在の称号一覧表の項目を全件取得
      final String yamlString =
          await rootBundle.loadString('assets/Title.yaml');
      final List<dynamic> yamlList = loadYaml(yamlString);
      String returnTitle = '';
      String homeViewTitle = '';
      titleMap.forEach((key, value) {
        if (value == '2') {
          homeViewTitle = key;
        }
      });
      if (homeViewTitle != '') {
        for (var item in yamlList) {
          if (item['no'].toString() == homeViewTitle) {
            returnTitle = item['name'];
          }
        }
      }

      cprofileDetail = CprofileDetail(
        USER_ID: snapShot.data()!['USER_ID'],
        PROFILE_IMAGE: snapShot.data()!['PROFILE_IMAGE'],
        NICK_NAME: snapShot.data()!['NICK_NAME'],
        TOROKU_RANK: snapShot.data()!['TOROKU_RANK'],
        AGE: snapShot.data()!['AGE'],
        GENDER: snapShot.data()!['GENDER'],
        COMENT: snapShot.data()!['COMENT'],
        TODOFUKEN_LIST: snapShot.data()!['TODOFUKEN_LIST'],
        SHICHOSON_LIST: snapShot.data()!['SHICHOSON_LIST'],
        TODOFUKEN_SHICHOSON_LIST: snapShot.data()!['TODOFUKEN_SHICHOSON_LIST'],
        TS_POINT: snapShot.data()!['TS_POINT'],
        SHOKYU_WIN_SU: snapShot.data()!['SHOKYU_WIN_SU'],
        SHOKYU_LOSE_SU: snapShot.data()!['SHOKYU_LOSE_SU'],
        SHOKYU_MATCH_SU: snapShot.data()!['SHOKYU_MATCH_SU'],
        SHOKYU_WIN_RATE: snapShot.data()!['SHOKYU_WIN_RATE'],
        CHUKYU_WIN_SU: snapShot.data()!['CHUKYU_WIN_SU'],
        CHUKYU_LOSE_SU: snapShot.data()!['CHUKYU_LOSE_SU'],
        CHUKYU_MATCH_SU: snapShot.data()!['CHUKYU_MATCH_SU'],
        CHUKYU_WIN_RATE: snapShot.data()!['CHUKYU_WIN_RATE'],
        JYOKYU_WIN_SU: snapShot.data()!['JYOKYU_WIN_SU'],
        JYOKYU_LOSE_SU: snapShot.data()!['JYOKYU_LOSE_SU'],
        JYOKYU_MATCH_SU: snapShot.data()!['JYOKYU_MATCH_SU'],
        JYOKYU_WIN_RATE: snapShot.data()!['JYOKYU_WIN_RATE'],
        STROKE_FOREHAND_AVE: snapShot.data()!['STROKE_FOREHAND_AVE'],
        STROKE_BACKHAND_AVE: snapShot.data()!['STROKE_BACKHAND_AVE'],
        VOLLEY_FOREHAND_AVE: snapShot.data()!['VOLLEY_FOREHAND_AVE'],
        VOLLEY_BACKHAND_AVE: snapShot.data()!['VOLLEY_BACKHAND_AVE'],
        SERVE_1ST_AVE: snapShot.data()!['SERVE_1ST_AVE'],
        SERVE_2ND_AVE: snapShot.data()!['SERVE_2ND_AVE'],
        FIRST_TODOFUKEN_SICHOSON: snapShot.data()!['FIRST_TODOFUKEN_SICHOSON'],
        KOUSHIN_TIME: snapShot.data()!['KOUSHIN_TIME'],
        RANK_NO: snapShot.data()!['RANK_NO'],
        RANK_TOROKU_RANK: snapShot.data()!['RANK_TOROKU_RANK'],
        TITLE: returnTitle,
        REVIEW_ENABLED: snapShot.data()?['REVIEW_ENABLED'] ?? true,
        SEARCH_ENABLE: snapShot.data()?['SEARCH_ENABLED'] ?? true,
      );
    } catch (e) {
      throw (e);
      print("getYourDetailProfileエラー");
    }
    return cprofileDetail;
  }

  static Future<CprofileDetail> getMyDetailProfile(String userId) async {
    late CprofileDetail cprofileDetail;
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('myProfileDetail')
          .doc(userId)
          .get();
      final snapShotMyProfile = await FirebaseFirestore.instance
          .collection('myProfile')
          .doc(auth.currentUser!.uid)
          .get();

      Map<String, dynamic> titleMap = snapShot.data()!['TITLE'];

      //現在の称号一覧表の項目を全件取得
      final String yamlString =
          await rootBundle.loadString('assets/Title.yaml');
      final List<dynamic> yamlList = loadYaml(yamlString);
      String returnTitle = '';

      String homeViewTitleKeyNo = '';
      titleMap.forEach((key, value) {
        if (value == '2') {
          homeViewTitleKeyNo = key;
        }
      });
      if (homeViewTitleKeyNo != '') {
        for (var item in yamlList) {
          if (item['no'].toString() == homeViewTitleKeyNo) {
            returnTitle = item['name'];
          }
        }
      }

      cprofileDetail = CprofileDetail(
        USER_ID: snapShot.data()!['USER_ID'],
        PROFILE_IMAGE: snapShot.data()!['PROFILE_IMAGE'],
        NICK_NAME: snapShot.data()!['NICK_NAME'],
        TOROKU_RANK: snapShot.data()!['TOROKU_RANK'],
        AGE: snapShot.data()!['AGE'],
        GENDER: snapShot.data()!['GENDER'],
        COMENT: snapShot.data()!['COMENT'],
        MY_USER_ID: snapShotMyProfile.data()!['MY_USER_ID'],
        TODOFUKEN_LIST: snapShot.data()!['TODOFUKEN_LIST'],
        SHICHOSON_LIST: snapShot.data()!['SHICHOSON_LIST'],
        TODOFUKEN_SHICHOSON_LIST: snapShot.data()!['TODOFUKEN_SHICHOSON_LIST'],
        TS_POINT: snapShot.data()!['TS_POINT'],
        SHOKYU_WIN_SU: snapShot.data()!['SHOKYU_WIN_SU'],
        SHOKYU_LOSE_SU: snapShot.data()!['SHOKYU_LOSE_SU'],
        SHOKYU_MATCH_SU: snapShot.data()!['SHOKYU_MATCH_SU'],
        SHOKYU_WIN_RATE: snapShot.data()!['SHOKYU_WIN_RATE'],
        CHUKYU_WIN_SU: snapShot.data()!['CHUKYU_WIN_SU'],
        CHUKYU_LOSE_SU: snapShot.data()!['CHUKYU_LOSE_SU'],
        CHUKYU_MATCH_SU: snapShot.data()!['CHUKYU_MATCH_SU'],
        CHUKYU_WIN_RATE: snapShot.data()!['CHUKYU_WIN_RATE'],
        JYOKYU_WIN_SU: snapShot.data()!['JYOKYU_WIN_SU'],
        JYOKYU_LOSE_SU: snapShot.data()!['JYOKYU_LOSE_SU'],
        JYOKYU_MATCH_SU: snapShot.data()!['JYOKYU_MATCH_SU'],
        JYOKYU_WIN_RATE: snapShot.data()!['JYOKYU_WIN_RATE'],
        STROKE_FOREHAND_AVE: snapShot.data()!['STROKE_FOREHAND_AVE'],
        STROKE_BACKHAND_AVE: snapShot.data()!['STROKE_BACKHAND_AVE'],
        VOLLEY_FOREHAND_AVE: snapShot.data()!['VOLLEY_FOREHAND_AVE'],
        VOLLEY_BACKHAND_AVE: snapShot.data()!['VOLLEY_BACKHAND_AVE'],
        SERVE_1ST_AVE: snapShot.data()!['SERVE_1ST_AVE'],
        SERVE_2ND_AVE: snapShot.data()!['SERVE_2ND_AVE'],
        FIRST_TODOFUKEN_SICHOSON: snapShot.data()!['FIRST_TODOFUKEN_SICHOSON'],
        KOUSHIN_TIME: snapShot.data()!['KOUSHIN_TIME'],
        RANK_NO: snapShot.data()!['RANK_NO'],
        RANK_TOROKU_RANK: snapShot.data()!['RANK_TOROKU_RANK'],
        TITLE: returnTitle,
        REVIEW_ENABLED: snapShot.data()?['REVIEW_ENABLED'] ?? true,
      );
    } catch (e) {
      print("getMyDetailProfileエラー");
    }
    return cprofileDetail;
  }

  static Future<String> upload(dynamic image) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    String imageURL = '';
    try {
      if (image != null) {
        final ref = storage
            .ref()
            .child('myProfileImage/${auth.currentUser!.uid}/photos')
            .child("myProfile.jpg");

        if (kIsWeb) {
          await ref.putData(image as Uint8List);
        } else {
          await ref.putFile(image as File);
        }
      }
      imageURL = await storage
          .ref()
          .child('myProfileImage/${auth.currentUser!.uid}/photos')
          .child("myProfile.jpg")
          .getDownloadURL();
    } catch (e) {
      throw (e);
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
    print("roomCheck" + roomCheck.toString());
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
        throw (e);
        throw (e);
        print('トークルーム作成に失敗しました --- $e');
      }
      return room;
    }
  }

  //トークルーム削除
  static Future<void> delTalkRoom(String delId) async {
    try {
      await roomRef.doc(delId).delete();
    } catch (e) {
      throw (e);
    }
  }

  /**
   * 相手とのトークルームが既に存在するかどうかチェックするメソッドです
   */
  static Future<bool> checkRoom(
      String myUserId, String yourUserID, bool roomCheck) async {
    final snapshot =
        await roomRef.where('joined_user_ids', arrayContains: myUserId).get();
    bool roomCheck = false;

    for (var doc in snapshot.docs) {
      var joinedUserIds = doc.data()['joined_user_ids'] as List<dynamic>;
      if (joinedUserIds.contains(yourUserID)) {
        roomCheck = true;
        break; // マッチした場合はループを抜ける
      }
    }
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
    final snapshot =
        await roomRef.where('joined_user_ids', arrayContains: myUserId).get();

    late TalkRoomModel room;
    late int count;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      if (doc.data()['joined_user_ids'].contains(yourUserId)) {
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
    final snapshot =
    await roomRef.where('joined_user_ids', arrayContains: myUserId).get();

    List<Future<TalkRoomModel?>> futures = [];

    for (var doc in snapshot.docs) {
      futures.add(_buildTalkRoomModel(doc, myUserId));
    }

    // null を除外して結果を返す
    List<TalkRoomModel> roomList = (await Future.wait(futures))
        .whereType<TalkRoomModel>()
        .toList();

    roomList.sort((a, b) => b.updated_time.compareTo(a.updated_time));
    return roomList;
  }

  static Future<TalkRoomModel?> _buildTalkRoomModel(
      DocumentSnapshot doc, String myUserId) async {
    late String yourUserId;

    for (var id in doc['joined_user_ids']) {
      if (id != myUserId) {
        yourUserId = id;
        break;
      }
    }

    try {
      String blockUserChk = await getBlockListChk(yourUserId);
      if (blockUserChk != "0") return null;

      final countFuture = NotificationMethod.unreadCountGet(yourUserId);
      final profileFuture = getYourProfile(yourUserId);

      final results = await Future.wait([countFuture, profileFuture]);

      return TalkRoomModel(
        roomId: doc.id,
        user: results[1] as CprofileSetting,
        lastMessage: doc['last_message'] ?? '',
        unReadCnt: results[0] as int,
        updated_time: doc['updated_time'] ?? '',
      );
    } catch (e) {
      print("トークルームの取得に失敗: $e");
      return null;
    }
  }

  //性能改善前
  // static Future<List<TalkRoomModel>> getRooms(String myUserId) async {
  //   final snapshot =
  //       await roomRef.where('joined_user_ids', arrayContains: myUserId).get();
  //   List<TalkRoomModel> roomList = [];
  //   late int count;
  //   await Future.forEach<dynamic>(snapshot.docs, (doc) async {
  //     late String yourUserId;
  //     doc.data()['joined_user_ids'].forEach((id) {
  //       if (id != myUserId) {
  //         yourUserId = id;
  //         return;
  //       }
  //     });
  //     try {
  //       count = await NotificationMethod.unreadCountGet(yourUserId);
  //     } catch (e) {
  //       print("未読メッセージ数を正しく取得できませんでした");
  //       throw (e);
  //     }
  //     //ブロックリストに存在しない場合に表示する
  //     String blockUserChk = await getBlockListChk(yourUserId);
  //     if (blockUserChk == "0") {
  //       try {
  //         CprofileSetting yourProfile = await getYourProfile(yourUserId);
  //         TalkRoomModel room = await TalkRoomModel(
  //             roomId: doc.id,
  //             user: yourProfile,
  //             lastMessage: doc.data()['last_message'] ?? '',
  //             unReadCnt: count,
  //             updated_time: doc.data()['updated_time'] ?? '');
  //         roomList.add(room);
  //       } catch (e) {
  //         print("トークルームの取得に失敗しました");
  //         throw (e);
  //       }
  //     }
  //   });
  //   roomList.sort((a, b) => b.updated_time.compareTo(a.updated_time));
  //   return roomList;
  // }

  static Future<TalkRoomModel> getRoom(String RECIPIENT_ID, String SENDER_ID,
      CprofileSetting yourProfile) async {
    final snapshot = await roomRef
        .where('joined_user_ids', arrayContains: RECIPIENT_ID)
        .get();
    late TalkRoomModel room;
    late int count;
    await Future.forEach<dynamic>(snapshot.docs, (doc) async {
      late String yourUserId;
      if (doc.data()['joined_user_ids'].contains(SENDER_ID)) {
        try {
          count = await NotificationMethod.unreadCountGet(yourProfile.USER_ID);
        } catch (e) {
          throw (e);
          throw (e);
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
    try {
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
      print("ROOMTEST" + room.user.USER_ID + " & " + myUid);
      if (tokenId == "") {
        //トークンIDが登録されていない場合
      } else {
        //トークンIDが登録されている場合
        await NotificationMethod.sendMessage(
            tokenId!, message, myProfile.NICK_NAME, myUid, room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      throw (e);
      throw (e);
      print("sendMessageエラー");
      throw (e);
    }
  }

  //試合申請メッセージ
  static Future<void> sendMatchMessage(TalkRoomModel room) async {
    try {
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
      roomRef.doc(room.roomId).update(
          {'last_message': "対戦お願いします！", 'updated_time': Timestamp.now()});
      CprofileSetting myProfile = await FirestoreMethod.getProfile();
      String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
      if (tokenId == "") {
        //トークンIDが登録されていない場合
      } else {
        //トークンIDが登録されている場合
        await NotificationMethod.sendMessage(tokenId!, "対戦お願いします！",
            myProfile.NICK_NAME, myUid, room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      throw (e);
      throw (e);
      print("sendMatchMessageエラー");
    }
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
      await NotificationMethod.sendMessage(tokenId!, "対戦結果が入力されました！",
          myProfile.NICK_NAME, myUid, room.user.USER_ID);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //対戦結果入力メッセージ(フィードバック入力希望の場合)
  static Future<void> sendMatchResultFeedMessage(
      String myUserId, String yourUserId, String dayKey) async {
    try {
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
        await NotificationMethod.sendMessage(
            tokenId!,
            "対戦結果が入力されました！\n評価の入力、感想・フィードバックの記入お願いします！",
            myProfile.NICK_NAME,
            myUid,
            room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      print("sendMatchResultFeedMessageエラー");
    }
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
      await NotificationMethod.sendMessage(tokenId!, "友達登録お願いします！",
          myProfile.NICK_NAME, myUid, room.user.USER_ID);
    }
    //未読メッセージ数の更新
    await NotificationMethod.unreadCount(room.user.USER_ID);
  }

  //対戦結果入力メッセージ(フィードバック入力希望の場合)
  static Future<void> sendMatchResultFeedMessageReturn(
      String myUserId, String yourUserId, String dayKey) async {
    try {
      TalkRoomModel room = await getRoomBySearchResult(myUserId, yourUserId);
      final messageRef = roomRef.doc(room.roomId).collection('message');
      final DocumentReference newMessageRef =
          messageRef.doc(); // ランダムなドキュメントIDが自動生成されます

      String? myUid = auth.currentUser!.uid;
      await newMessageRef.set({
        'messageId': newMessageRef.id,
        'message': "評価・フィードバックが入力されました！",
        'sender_id': myUid,
        'send_time': Timestamp.now(),
        'matchStatusFlg': "3",
        'friendStatusFlg': "0",
        'dayKey': dayKey
      });
      roomRef.doc(room.roomId).update({
        'last_message': "評価・フィードバックが入力されました！",
        'updated_time': Timestamp.now()
      });
      CprofileSetting myProfile = await FirestoreMethod.getProfile();
      String? tokenId = await NotificationMethod.getTokenId(room.user.USER_ID);
      if (tokenId == "") {
        //トークンIDが登録されていない場合
      } else {
        //トークンIDが登録されている場合
        await NotificationMethod.sendMessage(tokenId!, "評価・フィードバックが入力されました！",
            myProfile.NICK_NAME, myUid, room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      print("sendMatchResultFeedMessageReturnエラー");
    }
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
    try {
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

      // コレクション「myProfile」から該当データを絞る
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('myProfile');

      if (gender != '') {
        query = query.where('GENDER', isEqualTo: gender);
      }

      if (rank != '') {
        query = query.where('TOROKU_RANK', isEqualTo: rank);
      }

      if (age != '') {
        query = query.where('AGE', isEqualTo: age);
      }

      final snapShot = await query.get();

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
          if (todofuken == '' && count == 0) {
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
            } else if (doc.data()['SHICHOSON'] == shichoson) {
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
          } else if (doc.data()['TODOFUKEN'] == todofuken && count == 0) {
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
    } catch (e) {
      print("getFindMultiResultエラー");
    }
    return resultList;
  }

  /**
   * MyUserIDを使ってユーザー情報を取得
   */
  static Future<List<String>> getUserByMyUserId(String myUserID) async {
    List<String> resultList = [];
    late final snapShot;
    late String id;
    try {
      if (!auth.currentUser!.isAnonymous) {
        final snapShot_self = await profileRef
            .where('USER_ID', isEqualTo: auth.currentUser!.uid)
            .get();
        if (myUserID == snapShot_self.docs.first.get('MY_USER_ID')) {
          return resultList;
        }
      }
      //コレクション「myProfile」から該当データを絞る
      snapShot =
          await profileRef.where('MY_USER_ID', isEqualTo: myUserID).get();

      if (snapShot.docs.first == null) {
        return resultList;
      }

      id = snapShot.docs.first.id;
      final snapShot_block = await blockRef
          .doc(auth.currentUser!.uid)
          .collection('blockUserList')
          .where('BLOCK_USER', isEqualTo: id)
          .get();

      if (snapShot_block.size != 0) {
        return resultList;
      }
      String name = snapShot.docs.first!['NICK_NAME'];
      String profile = snapShot.docs.first!['PROFILE_IMAGE'];
      String coment = snapShot.docs.first!['COMENT'];
      resultList.add(name);
      resultList.add(profile);
      resultList.add(id);
      resultList.add(coment);
      return resultList;
    } catch (e) {
      print("getUserByMyUserIdエラー");
    }
    return resultList;
  }

  //試合申請受け入れ
  static Future<void> matchAccept(TalkRoomModel room, String messageId) async {
    try {
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
            tokenId!,
            "対戦を受け入れました。\n対戦相手の方と場所や日時を決めましょう！",
            myProfile.NICK_NAME,
            myUid,
            room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      print("matchAcceptエラー");
    }
  }

  static Future<void> matchAcceptTicketError(
      TalkRoomModel room, String messageId) async {
    try {
      final messageRef = roomRef.doc(room.roomId).collection('message');
      final DocumentReference newMessageRef =
          messageRef.doc(); // ランダムなドキュメントIDが自動生成されます

      String? myUid = auth.currentUser!.uid;

      await newMessageRef.set({
        'messageId': newMessageRef.id, // ドキュメントのフィールドにIDを保存します
        'message': "チケットが不足しています\nチケット購入お願いします！",
        'sender_id': myUid,
        'send_time': Timestamp.now(),
        'matchStatusFlg': "0",
        'friendStatusFlg': "0"
      });
      roomRef.doc(room.roomId).update({
        'last_message': "チケットが不足しています\nチケット購入お願いします！",
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
            tokenId!,
            "チケットが不足しています\nチケット購入お願いします！",
            myProfile.NICK_NAME,
            myUid,
            room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      print("matchAcceptエラー");
    }
  }

  //マッチフィードバック受け入れ
  static Future<void> matchFeedAccept(
      TalkRoomModel room, String messageId) async {
    try {
      final messageRef = roomRef.doc(room.roomId).collection('message');

      await messageRef.doc(messageId).update({'matchStatusFlg': "3"});
    } catch (e) {
      print("matchFeedAcceptエラー");
    }
  }

  //友人申請受け入れ
  static Future<void> friendAccept(TalkRoomModel room, String messageId) async {
    try {
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
            tokenId!,
            "友人申請を受け入れました。\n友人一覧を確認してみよう！",
            myProfile.NICK_NAME,
            myUid,
            room.user.USER_ID);
      }
      //未読メッセージ数の更新
      await NotificationMethod.unreadCount(room.user.USER_ID);
    } catch (e) {
      print("friendAcceptエラー");
    }
  }

  static Future<void> addMatchList(String roomId) async {
    try {
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
      await roomRef.add({
        'joined_user_ids': [myUserId, yourUserID],
        'updated_time': Timestamp.now()
      });
    } catch (e) {
      throw (e);
      print('マッチング一覧の作成に失敗しました --- $e');
    }
  }

  //対戦マッチ一覧に追加
  static final userTicketMgmtRef =
      _firestoreInstance.collection('userTicketMgmt');

  static Future<String> makeMatch(TalkRoomModel talkRoom) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);
    DateFormat outputFormatKoushinYmd = DateFormat('yyyy-MM-dd');
    String koushinYmd = outputFormatKoushinYmd.format(now);

    String myUserId = auth.currentUser!.uid;
    String yourUserId = talkRoom.user.USER_ID;

    late String ticketFlg; //0:チケットあり 1:自分のチケットなし(相手もない可能性もある) 2:相手のチケットなし
    // トランザクション内で上限数を減算してから更新
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //自分と相手の残チケット数を取得する
      DocumentReference myTicketRef = await userTicketMgmtRef.doc(myUserId);
      final myTicketRefSna = await transaction.get(myTicketRef);

      DocumentReference yourTicketRef = await userTicketMgmtRef.doc(yourUserId);
      final yourTicketRefSna = await transaction.get(yourTicketRef);

      if (myTicketRefSna.exists && yourTicketRefSna.exists) {
        //自分の残チケット数を取得する
        final myTicketSu = myTicketRefSna.get("ticketSu");
        final myTogetsuTicketSu = myTicketRefSna.get("togetsuTicketSu");
        final myZengetsuTicketSu = myTicketRefSna.get("zengetsuTicketSu");

        //対戦相手の残チケット数を取得する
        final yourTicketSu = yourTicketRefSna.get("ticketSu");
        final yourTogetsuTicketSu = yourTicketRefSna.get("togetsuTicketSu");
        final yourZengetsuTicketSu = yourTicketRefSna.get("zengetsuTicketSu");

        if (myTicketSu >= 1 && yourTicketSu >= 1) {
          if (myZengetsuTicketSu >= 1) {
            transaction.update(
              myTicketRef,
              {
                'ticketSu': myTicketSu - 1,
                'zengetsuTicketSu': myZengetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          } else {
            transaction.update(
              myTicketRef,
              {
                'ticketSu': myTicketSu - 1,
                'togetsuTicketSu': myTogetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          }
          if (yourZengetsuTicketSu >= 1) {
            transaction.update(
              yourTicketRef,
              {
                'ticketSu': yourTicketSu - 1,
                'zengetsuTicketSu': yourZengetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          } else {
            transaction.update(
              yourTicketRef,
              {
                'ticketSu': yourTicketSu - 1,
                'togetsuTicketSu': yourTogetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          }
          //マッチング処理を実施
          try {
            // マッチング処理をトランザクション内で実行
            // 新しいドキュメントを追加し、そのIDを取得
            DocumentReference newDocMatchRef = matchRef.doc();
            String newDocId = newDocMatchRef.id;

            transaction.set(
              newDocMatchRef,
              {
                'RECIPIENT_ID': auth.currentUser!.uid,
                'SENDER_ID': talkRoom.user.USER_ID,
                'MATCH_USER_LIST': [
                  auth.currentUser!.uid,
                  talkRoom.user.USER_ID
                ],
                'SAKUSEI_TIME': today,
                'MATCH_FLG': '1',
                'MATCH_ID': newDocId
              },
            );
            // throw("マッチングに失敗しました");//エラーテスト用
          } catch (e) {
            throw (e);
            print('マッチングに失敗しました --- $e');
          }
          ticketFlg = "0";
        } else {
          if (myTicketSu < 1) {
            ticketFlg = "1";
          } else {
            ticketFlg = "2";
          }
        }
      } else {
        throw ("チケット数の更新に失敗しました");
      }
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => throw (e),
    );
    return ticketFlg;
  }

  //対戦マッチ一覧に追加
  static Future<String> makeMatchByQrScan(String yourUserId) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);
    DateFormat outputFormatKoushinYmd = DateFormat('yyyy-MM-dd');
    String koushinYmd = outputFormatKoushinYmd.format(now);

    String myUserId = auth.currentUser!.uid;

    late String ticketFlg; //0:チケットあり 1:自分のチケットなし(相手もない可能性もある) 2:相手のチケットなし
    // トランザクション内で上限数を減算してから更新
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      //自分と相手の残チケット数を取得する
      DocumentReference myTicketRef = await userTicketMgmtRef.doc(myUserId);
      final myTicketRefSna = await transaction.get(myTicketRef);

      DocumentReference yourTicketRef = await userTicketMgmtRef.doc(yourUserId);
      final yourTicketRefSna = await transaction.get(yourTicketRef);

      if (myTicketRefSna.exists && yourTicketRefSna.exists) {
        //自分の残チケット数を取得する
        final myTicketSu = myTicketRefSna.get("ticketSu");
        final myTogetsuTicketSu = myTicketRefSna.get("togetsuTicketSu");
        final myZengetsuTicketSu = myTicketRefSna.get("zengetsuTicketSu");

        //対戦相手の残チケット数を取得する
        final yourTicketSu = yourTicketRefSna.get("ticketSu");
        final yourTogetsuTicketSu = yourTicketRefSna.get("togetsuTicketSu");
        final yourZengetsuTicketSu = yourTicketRefSna.get("zengetsuTicketSu");

        if (myTicketSu >= 1 && yourTicketSu >= 1) {
          if (myZengetsuTicketSu >= 1) {
            transaction.update(
              myTicketRef,
              {
                'ticketSu': myTicketSu - 1,
                'zengetsuTicketSu': myZengetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          } else {
            transaction.update(
              myTicketRef,
              {
                'ticketSu': myTicketSu - 1,
                'togetsuTicketSu': myTogetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          }
          if (yourZengetsuTicketSu >= 1) {
            transaction.update(
              yourTicketRef,
              {
                'ticketSu': yourTicketSu - 1,
                'zengetsuTicketSu': yourZengetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          } else {
            transaction.update(
              yourTicketRef,
              {
                'ticketSu': yourTicketSu - 1,
                'togetsuTicketSu': yourTogetsuTicketSu - 1,
                'ticketKoushinYmd': koushinYmd
              },
            );
          }
          //マッチング処理を実施
          // マッチング処理をトランザクション内で実行
          // 新しいドキュメントを追加し、そのIDを取得
          DocumentReference newDocMatchRef = matchRef.doc();
          String newDocId = newDocMatchRef.id;

          transaction.set(
            newDocMatchRef,
            {
              'RECIPIENT_ID': auth.currentUser!.uid,
              'SENDER_ID': yourUserId,
              'MATCH_USER_LIST': [auth.currentUser!.uid, yourUserId],
              'SAKUSEI_TIME': today,
              'MATCH_FLG': '1',
              'MATCH_ID': newDocId
            },
          );
          ticketFlg = "0";
        } else {
          if (myTicketSu < 1) {
            ticketFlg = "1";
          } else {
            ticketFlg = "2";
          }
        }
      } else {
        throw ("QRコードの読み取りに失敗しました");
      }
    }).then(
      (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => throw ("QRコードの読み取りに失敗しました"),
    );
    return ticketFlg;
  }

  //マッチング一覧削除
  static Future<void> delMatchList(String delId) async {
    try {
      await matchRef.doc(delId).delete();
    } catch (e) {
      throw (e);
    }
  }

  //マッチング一覧削除(対戦結果入力時削除)
  static void delMatchListAuto(String delId) async {
    try {
      await matchRef.doc(delId).delete();
    } catch (e) {
      print("delMatchListAutoエラー");
    }
  }

  //対戦結果_新規フラグ取得
  static Future<String> newFlgMatchResult(String UserId) async {
    late String NEW_FLG;
    try {
      final snapshot = await matchResultRef.doc(UserId).get();

      if (snapshot.exists) {
        NEW_FLG = "0";
      } else {
        NEW_FLG = "1";
      }
    } catch (e) {
      print("newFlgMatchResultエラー");
    }
    return NEW_FLG;
  }

  //個人対戦結果_新規フラグ取得
  static Future<String> individualNewFlgMatch(
      String myUserId, String yourUserId) async {
    late String NEW_FLG;

    try {
      final snapshot = await matchResultRef
          .doc(myUserId)
          .collection('opponentList')
          .doc(yourUserId)
          .get();
      if (snapshot.exists) {
        NEW_FLG = "0";
      } else {
        NEW_FLG = "1";
      }
    } catch (e) {
      print("individualNewFlgMatchエラー");
    }
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
    late String NEW_FLG;
    try {
      final rankSnap = await FirebaseFirestore.instance
          .collection('manSinglesRank')
          .doc(manSingleRank)
          .collection('RankList')
          .doc(myUserId)
          .get();
      if (rankSnap.exists) {
        NEW_FLG = "0";
      } else {
        NEW_FLG = "1";
      }
    } catch (e) {
      print("rankNewFlgMatchエラー");
    }
    return NEW_FLG;
  }

  //ランキング取得
  static Future<int> rankingGet(String UserId) async {
    late String manSingleRank;
    int rank_no = 0;
    try {
      final myProfileSnap = await FirebaseFirestore.instance
          .collection('myProfile')
          .doc(UserId)
          .get();
      String rank = myProfileSnap.data()!['TOROKU_RANK'];
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
    } catch (e) {
      print("rankingGetエラー");
    }
    return rank_no;
  }

  //各レベルの勝率算出メソッド
  // static Future<void> winRateUpdate(
  //     CprofileSetting myProfile, CprofileSetting yourProfile) async {
  //   final snapshotDetail = await matchResultRef
  //       .doc(myProfile.USER_ID)
  //       .collection('opponentList')
  //       .doc(yourProfile.USER_ID)
  //       .collection('matchDetail')
  //       .get();
  //   int winSu = 0;
  //   int matchSu = 0;
  //   await Future.forEach<dynamic>(snapshotDetail.docs, (doc) async {
  //     if (doc.data()['TOROKU_RANK'].contains(yourProfile.TOROKU_RANK)) {
  //       winSu = doc.data()['WIN_FLG'] + winSu;
  //       matchSu = matchSu + 1;
  //     } else {
  //       matchSu = matchSu + 1;
  //     }
  //   });
  //   final snapshotResult = await matchResultRef.doc(myProfile.USER_ID);
  //
  //   int loseSu = matchSu - winSu;
  //   int winRate = ((winSu / matchSu) * 100).round();
  //
  //   switch (yourProfile.TOROKU_RANK) {
  //     case '初級':
  //       try {
  //         snapshotResult.update({'SHOKYU_WIN_SU': winSu});
  //         snapshotResult.update({'SHOKYU_LOSE_SU': loseSu});
  //         snapshotResult.update({'SHOKYU_MATCH_SU': matchSu});
  //         snapshotResult.update({'SHOKYU_WIN_RATE': winRate});
  //       } catch (e) { throw(e); throw(e);
  //         print('初級TSPポイントの付与に失敗しました --- $e');
  //       }
  //       break;
  //     case '中級':
  //       try {
  //         snapshotResult.update({'CHUKYU_WIN_SU': winSu});
  //         snapshotResult.update({'CHUKYU_LOSE_SU': loseSu});
  //         snapshotResult.update({'CHUKYU_MATCH_SU': matchSu});
  //         snapshotResult.update({'CHUKYU_WIN_RATE': winRate});
  //       } catch (e) { throw(e); throw(e);
  //         print('中級TSPポイントの付与に失敗しました --- $e');
  //       }
  //       break;
  //     case '上級':
  //       try {
  //         snapshotResult.update({'JYOKYU_WIN_SU': winSu});
  //         snapshotResult.update({'JYOKYU_LOSE_SU': loseSu});
  //         snapshotResult.update({'JYOKYU_MATCH_SU': matchSu});
  //         snapshotResult.update({'JYOKYU_WIN_RATE': winRate});
  //       } catch (e) { throw(e); throw(e);
  //         print('上級TSPポイントの付与に失敗しました --- $e');
  //       }
  //       break;
  //   }
  // }

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
    print("MY_NEW_FLG" + MY_NEW_FLG);
    YOUR_NEW_FLG = await newFlgMatchResult(yourProfile.USER_ID);
    print("YOUR_NEW_FLG" + YOUR_NEW_FLG);

    //ランキング取得メソッド
    MY_RANK = await rankingGet(myProfile.USER_ID);
    print('MY_RANK' + MY_RANK.toString());
    YOUR_RANK = await rankingGet(yourProfile.USER_ID);
    print('YOUR_RANK' + YOUR_RANK.toString());

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

    //対戦成績リスト登録
    List<String> MyScorePoint = [];
    List<String> YourScorePoint = [];

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
          MyScorePoint.add(
              a.myGamePoint.toString() + '-' + a.yourGamePoint.toString());
          YourScorePoint.add(
              a.yourGamePoint.toString() + '-' + a.myGamePoint.toString());
        }
      } catch (e) {
        throw (e);
        throw (e);
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
        'dailyId': dayKey,
        'userId': myProfile.USER_ID,
        'opponentId': yourProfile.USER_ID,
        'opponentProfileImage': yourProfile.PROFILE_IMAGE,
        'opponentName': yourProfile.NICK_NAME,
        'scorePoint': MyScorePoint,
        'koushinTime': today,
        'FEEDBACK_FLG': false
      });
    } catch (e) {
      throw (e);
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
        'dailyId': dayKey,
        'userId': yourProfile.USER_ID,
        'opponentId': myProfile.USER_ID,
        'opponentProfileImage': myProfile.PROFILE_IMAGE,
        'opponentName': myProfile.NICK_NAME,
        'scorePoint': YourScorePoint,
        'koushinTime': today,
        'FEEDBACK_FLG': false
      });
    } catch (e) {
      throw (e);
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
    print("MY_NEW_MATCH_FLG" + MY_NEW_MATCH_FLG);
    print("YOUR_NEW_MATCH_FLG" + YOUR_NEW_MATCH_FLG);

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
        throw (e);
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
        throw (e);
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
        throw (e);
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
        throw (e);
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
      await profileDetailRef.doc(myProfile.USER_ID).update({
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
        throw (e);
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
      await profileDetailRef.doc(yourProfile.USER_ID).update({
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
        throw (e);
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
        profileDetailRef
            .doc(myProfile.USER_ID)
            .update({'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});
      } catch (e) {
        throw (e);
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
            profileDetailRef.doc(myProfile.USER_ID).update({
              'SHOKYU_TS_POINT': MY_TS_POINT,
              'ALL_SHOKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            matchResultRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });
            profileDetailRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            matchResultRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });
            profileDetailRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
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
            profileDetailRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});

            matchResultRef.doc(myProfile.USER_ID).update({
              'SHOKYU_TS_POINT': MY_TS_POINT,
              'ALL_SHOKYU_TS_POINT': MY_ALL_TS_POINT
            });
            profileDetailRef.doc(myProfile.USER_ID).update({
              'SHOKYU_TS_POINT': MY_TS_POINT,
              'ALL_SHOKYU_TS_POINT': MY_ALL_TS_POINT
            });

            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});

            profileDetailRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            MY_TS_POINT = MY_CHUKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            MY_ALL_TS_POINT = MY_ALL_CHUKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            matchResultRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});

            profileDetailRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});

            matchResultRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });

            profileDetailRef.doc(myProfile.USER_ID).update({
              'CHUKYU_TS_POINT': MY_TS_POINT,
              'ALL_CHUKYU_TS_POINT': MY_ALL_TS_POINT
            });

            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});

            profileDetailRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            MY_TS_POINT = MY_JYOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            MY_ALL_TS_POINT = MY_ALL_JYOKYU_TS_POINT_CUR + MY_TS_POINT_FUYO_SUM;
            matchResultRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});

            profileDetailRef.doc(myProfile.USER_ID).update(
                {'TS_POINT': MY_TS_POINT, 'ALL_TS_POINT': MY_ALL_TS_POINT});

            matchResultRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });

            profileDetailRef.doc(myProfile.USER_ID).update({
              'JYOKYU_TS_POINT': MY_TS_POINT,
              'ALL_JYOKYU_TS_POINT': MY_ALL_TS_POINT
            });

            matchResultRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});

            profileDetailRef
                .doc(myProfile.USER_ID)
                .update({'TOROKU_RANK': myProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
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

        profileDetailRef.doc(yourProfile.USER_ID).update(
            {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});
      } catch (e) {
        throw (e);
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

            profileDetailRef.doc(yourProfile.USER_ID).update({
              'SHOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_SHOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
            print('初級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '中級':
          try {
            matchResultRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            profileDetailRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
            print('中級TSPポイントの付与に失敗しました --- $e');
          }
          break;
        case '上級':
          try {
            matchResultRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
            profileDetailRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
          } catch (e) {
            throw (e);
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

            profileDetailRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});

            matchResultRef.doc(yourProfile.USER_ID).update({
              'SHOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_SHOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            profileDetailRef.doc(yourProfile.USER_ID).update({
              'SHOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_SHOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});

            profileDetailRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
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

            profileDetailRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});

            matchResultRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            profileDetailRef.doc(yourProfile.USER_ID).update({
              'CHUKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_CHUKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});

            profileDetailRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
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

            profileDetailRef.doc(yourProfile.USER_ID).update(
                {'TS_POINT': YOUR_TS_POINT, 'ALL_TS_POINT': YOUR_ALL_TS_POINT});

            matchResultRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });

            profileDetailRef.doc(yourProfile.USER_ID).update({
              'JYOKYU_TS_POINT': YOUR_TS_POINT,
              'ALL_JYOKYU_TS_POINT': YOUR_ALL_TS_POINT
            });
            matchResultRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
            profileDetailRef
                .doc(yourProfile.USER_ID)
                .update({'TOROKU_RANK': yourProfile.TOROKU_RANK});
          } catch (e) {
            throw (e);
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

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_WIN_SU': MY_SHOKYU_WIN_SU});

          MY_SHOKYU_LOSE_SU = MY_SHOKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': MY_SHOKYU_LOSE_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': MY_SHOKYU_LOSE_SU});

          MY_SHOKYU_MATCH_SU = MY_SHOKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': MY_SHOKYU_MATCH_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': MY_SHOKYU_MATCH_SU});

          MY_SHOKYU_WIN_RATE =
              ((MY_SHOKYU_WIN_SU / MY_SHOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': MY_SHOKYU_WIN_RATE});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': MY_SHOKYU_WIN_RATE});
        } catch (e) {
          throw (e);
          print('初級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '中級':
        try {
          MY_CHUKYU_WIN_SU = MY_CHUKYU_WIN_SU_CUR + MY_WIN_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': MY_CHUKYU_WIN_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': MY_CHUKYU_WIN_SU});

          MY_CHUKYU_LOSE_SU = MY_CHUKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': MY_CHUKYU_LOSE_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': MY_CHUKYU_LOSE_SU});

          MY_CHUKYU_MATCH_SU = MY_CHUKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': MY_CHUKYU_MATCH_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': MY_CHUKYU_MATCH_SU});

          MY_CHUKYU_WIN_RATE =
              ((MY_CHUKYU_WIN_SU / MY_CHUKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': MY_CHUKYU_WIN_RATE});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': MY_CHUKYU_WIN_RATE});
        } catch (e) {
          throw (e);
          print('中級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '上級':
        try {
          MY_JYOKYU_WIN_SU = MY_JYOKYU_WIN_SU_CUR + MY_WIN_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': MY_JYOKYU_WIN_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': MY_JYOKYU_WIN_SU});

          MY_JYOKYU_LOSE_SU = MY_JYOKYU_LOSE_SU_CUR + MY_LOSE_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': MY_JYOKYU_LOSE_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': MY_JYOKYU_LOSE_SU});

          MY_JYOKYU_MATCH_SU = MY_JYOKYU_MATCH_SU_CUR + MY_MATCH_SU;
          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': MY_JYOKYU_MATCH_SU});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': MY_JYOKYU_MATCH_SU});

          MY_JYOKYU_WIN_RATE =
              ((MY_JYOKYU_WIN_SU / MY_JYOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': MY_JYOKYU_WIN_RATE});

          profileDetailRef
              .doc(myProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': MY_JYOKYU_WIN_RATE});
        } catch (e) {
          throw (e);
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

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_WIN_SU': YOUR_SHOKYU_WIN_SU});

          YOUR_SHOKYU_LOSE_SU = YOUR_SHOKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': YOUR_SHOKYU_LOSE_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_LOSE_SU': YOUR_SHOKYU_LOSE_SU});

          YOUR_SHOKYU_MATCH_SU = YOUR_SHOKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': YOUR_SHOKYU_MATCH_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_MATCH_SU': YOUR_SHOKYU_MATCH_SU});

          YOUR_SHOKYU_WIN_RATE =
              ((YOUR_SHOKYU_WIN_SU / YOUR_SHOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': YOUR_SHOKYU_WIN_RATE});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'SHOKYU_WIN_RATE': YOUR_SHOKYU_WIN_RATE});
        } catch (e) {
          throw (e);
          print('初級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '中級':
        try {
          YOUR_CHUKYU_WIN_SU = YOUR_CHUKYU_WIN_SU_CUR + YOUR_WIN_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': YOUR_CHUKYU_WIN_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_SU': YOUR_CHUKYU_WIN_SU});

          YOUR_CHUKYU_LOSE_SU = YOUR_CHUKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': YOUR_CHUKYU_LOSE_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_LOSE_SU': YOUR_CHUKYU_LOSE_SU});

          YOUR_CHUKYU_MATCH_SU = YOUR_CHUKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': YOUR_CHUKYU_MATCH_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_MATCH_SU': YOUR_CHUKYU_MATCH_SU});

          YOUR_CHUKYU_WIN_RATE =
              ((YOUR_CHUKYU_WIN_SU / YOUR_CHUKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': YOUR_CHUKYU_WIN_RATE});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'CHUKYU_WIN_RATE': YOUR_CHUKYU_WIN_RATE});
        } catch (e) {
          throw (e);
          print('中級の勝率の付与に失敗しました --- $e');
        }
        break;
      case '上級':
        try {
          YOUR_JYOKYU_WIN_SU = YOUR_JYOKYU_WIN_SU_CUR + YOUR_WIN_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': YOUR_JYOKYU_WIN_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_SU': YOUR_JYOKYU_WIN_SU});

          YOUR_JYOKYU_LOSE_SU = YOUR_JYOKYU_LOSE_SU_CUR + YOUR_LOSE_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': YOUR_JYOKYU_LOSE_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_LOSE_SU': YOUR_JYOKYU_LOSE_SU});

          YOUR_JYOKYU_MATCH_SU = YOUR_JYOKYU_MATCH_SU_CUR + YOUR_MATCH_SU;
          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': YOUR_JYOKYU_MATCH_SU});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_MATCH_SU': YOUR_JYOKYU_MATCH_SU});

          YOUR_JYOKYU_WIN_RATE =
              ((YOUR_JYOKYU_WIN_SU / YOUR_JYOKYU_MATCH_SU) * 100).round();

          matchResultRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': YOUR_JYOKYU_WIN_RATE});

          profileDetailRef
              .doc(yourProfile.USER_ID)
              .update({'JYOKYU_WIN_RATE': YOUR_JYOKYU_WIN_RATE});
        } catch (e) {
          throw (e);
          print('上級の勝率の付与に失敗しました --- $e');
        }
        break;
    }

    //更新日時を登録
    profileDetailRef.doc(myProfile.USER_ID).update({'KOUSHIN_TIME': today});

    profileDetailRef.doc(yourProfile.USER_ID).update({'KOUSHIN_TIME': today});
  }

  //友達一覧に追加
  static Future<void> makeFriends(TalkRoomModel talkRoom) async {
    DateTime now = DateTime.now();
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(now);

    bool friendFlg = await FirestoreMethod.checkFriends(talkRoom.roomId);

    if (friendFlg == false) {
      try {
        await friendsListRef.add({
          'RECIPIENT_ID': auth.currentUser!.uid,
          'SENDER_ID': talkRoom.user.USER_ID,
          'FRIEND_USER_LIST': [auth.currentUser!.uid, talkRoom.user.USER_ID],
          'SAKUSEI_TIME': today,
          'FRIENDS_FLG': '1',
        }).then((value) {
          friendsListRef.doc(value.id).update({'FRIENDS_ID': value.id});
        });
      } catch (e) {
        throw (e);
        print('友達登録に失敗しました --- $e');
      }
    } else {
      print("既に友人登録済です");
    }
  }

  /**
   * 友人済みか確認する
   */
  static Future<bool> checkFriends(String roomID) async {
    final doc = await roomRef.doc(roomID).get();
    late bool alreadyFriendflg;
    List<String> checkList = [];
    checkList.add(doc.data()!['joined_user_ids'][0]);
    checkList.add(doc.data()!['joined_user_ids'][1]);
    try {
      final snapshotRECIP = await friendsListRef
          .where('RECIPIENT_ID', isEqualTo: doc.data()!['joined_user_ids'][0])
          .where('SENDER_ID', isEqualTo: doc.data()!['joined_user_ids'][1])
          .get();

      final snapshotSENDER = await friendsListRef
          .where('RECIPIENT_ID', isEqualTo: doc.data()!['joined_user_ids'][1])
          .where('SENDER_ID', isEqualTo: doc.data()!['joined_user_ids'][0])
          .get();

      if (snapshotRECIP.docs.isNotEmpty || snapshotSENDER.docs.isNotEmpty) {
        alreadyFriendflg = true;
        print("alreadyFriendflg" + alreadyFriendflg.toString());
      } else {
        alreadyFriendflg = false;
      }
    } catch (e) {
      print("checkFriendsエラー");
    }
    return alreadyFriendflg;
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
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightGreenAccent),
                child: Text('はい'),
                onPressed: () {
                  try {
                    friendsListRef.doc(delId).delete();
                    Navigator.pop(context);
                  } catch (e) {
                    print("delFriendsListエラー");
                  }
                },
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.lightGreenAccent),
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
  // static Future<List<RankModel>> getManSinglesRank(String RankLevel) async {
  //   final snapshot =
  //       await manSinglesRankRef.doc(RankLevel).collection('RankList').orderBy('RANK_NO').limit(10).get();
  //   List<RankModel> rankList = [];
  //   await Future.forEach<dynamic>(snapshot.docs, (doc) async {
  //     String userId = doc.data()['USER_ID'];
  //     CprofileSetting yourProfile = await getYourProfile(userId);
  //
  //     try {
  //       RankModel rankListWork = RankModel(
  //         rankNo: doc.data()['RANK_NO'],
  //         user: yourProfile,
  //         tpPoint: doc.data()['TS_POINT'],
  //       );
  //       rankList.add(rankListWork);
  //       rankList.sort((a, b) => b.rankNo.compareTo(a.rankNo));
  //     } catch (e) { throw(e);
  //       print(e.toString());
  //     }
  //   });
  //   return rankList;
  // }

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
//     } catch (e) { throw(e);
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
//       } catch (e) { throw(e);
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
//     } catch (e) { throw(e);
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
//     } catch (e) { throw(e);
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
//     } catch (e) { throw(e);
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
          .set({
        'STROKE_FOREHAND': skill.STROKE_FOREHAND,
        'STROKE_BACKHAND': skill.STROKE_BACKHAND,
        'VOLLEY_FOREHAND': skill.VOLLEY_FOREHAND,
        'VOLLEY_BACKHAND': skill.VOLLEY_BACKHAND,
        'SERVE_1ST': skill.SERVE_1ST,
        'SERVE_2ND': skill.SERVE_2ND,
      }, SetOptions(merge: true));
      matchResultRef
          .doc(skill.OPPONENT_ID)
          .collection('opponentList')
          .doc(auth.currentUser!.uid)
          .collection('daily')
          .doc(dayKey)
          .set({
        'STROKE_FOREHAND': skill.STROKE_FOREHAND,
        'STROKE_BACKHAND': skill.STROKE_BACKHAND,
        'VOLLEY_FOREHAND': skill.VOLLEY_FOREHAND,
        'VOLLEY_BACKHAND': skill.VOLLEY_BACKHAND,
        'SERVE_1ST': skill.SERVE_1ST,
        'SERVE_2ND': skill.SERVE_2ND,
      }, SetOptions(merge: true));
    } catch (e) {
      throw (e);
      print('スキルレベル登録に失敗しました --- $e');
    }
  }

  /**
   * スキル評価の合計を算出入力するメソッドです
   * skill.OPPONENT_ID 評価される側のユーザ
   * auth.currentUser!.uid 評価している(入力中ユーザ)
   */
  static Future<void> registSkillSum(String OPPONENT_ID) async {
    try {
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
      final opponentListsnapShot = await matchResultRef
          .doc(OPPONENT_ID)
          .collection('opponentList')
          .get();
      await Future.forEach<dynamic>(opponentListsnapShot.docs, (doc) async {
        //0~5以外は入り得ない
        double fore = await doc.data()?['STROKE_FOREHAND'] ?? 10;
        if (fore == 10) {
          return;
        } else {
          count++;
          stroke_fore_total =
              stroke_fore_total + doc.data()!['STROKE_FOREHAND'];
          stroke_back_total =
              stroke_back_total + doc.data()!['STROKE_BACKHAND'];
          volley_fore_total =
              volley_fore_total + doc.data()!['VOLLEY_FOREHAND'];
          volley_back_total =
              volley_back_total + doc.data()!['VOLLEY_BACKHAND'];
          serve_1st_total = serve_1st_total + doc.data()!['SERVE_1ST'];
          serve_2nd_total = serve_2nd_total + doc.data()!['SERVE_2ND'];
        }
      });
      stroke_fore_avg =
          FirestoreMethod.roundToDecimal(stroke_fore_total / count, 1);
      stroke_back_avg =
          FirestoreMethod.roundToDecimal(stroke_back_total / count, 1);
      volley_fore_avg =
          FirestoreMethod.roundToDecimal(volley_fore_total / count, 1);
      volley_back_avg =
          FirestoreMethod.roundToDecimal(volley_back_total / count, 1);
      serve_1st_avg =
          FirestoreMethod.roundToDecimal(serve_1st_total / count, 1);
      serve_2nd_avg =
          FirestoreMethod.roundToDecimal(serve_2nd_total / count, 1);

      await profileDetailRef.doc(OPPONENT_ID).update({
        'STROKE_FOREHAND_AVE': stroke_fore_avg,
        'STROKE_BACKHAND_AVE': stroke_back_avg,
        'VOLLEY_FOREHAND_AVE': volley_fore_avg,
        'VOLLEY_BACKHAND_AVE': volley_back_avg,
        'SERVE_1ST_AVE': serve_1st_avg,
        'SERVE_2ND_AVE': serve_2nd_avg,
      });
    } catch (e) {
      throw (e);
      print('スキルレベルの平均値算出に失敗しました --- $e');
    }
  }

  //小数点計算
  static double roundToDecimal(double value, int decimalPlaces) {
    double shift = 10.0 * decimalPlaces;
    return (value * shift).round() / shift;
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
      throw (e);
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
    try {
      await matchResultRef
          .doc(yourProfile.USER_ID)
          .collection('opponentList')
          .doc(myProfile.USER_ID)
          .collection('daily')
          .doc(dayKey)
          .set({
        'FEEDBACK_COMMENT': feedBack.FEED_BACK,
        'FEEDBACK_FLG': true,
      }, SetOptions(merge: true));
      //profileDetail内のフィードバックカウントを加算
      final profileDetailVal =
          await profileDetailRef.doc(yourProfile.USER_ID).get();
      int feedbackCount = profileDetailVal.data()!['FEEDBACK_COUNT'];
      feedbackCount = feedbackCount + 1;
      await profileDetailRef.doc(yourProfile.USER_ID).update({
        'FEEDBACK_COUNT': feedbackCount,
      });
    } catch (e) {
      throw (e);
      print('フィードバックの登録に失敗しました --- $e');
    }
  }

  /**
   * ログインユーザに対してのフィードバックのリストを取得
   */
  // static Future<List<CFeedBackCommentSetting>> getFeedBacks() async {
  //   List<CFeedBackCommentSetting> feedBackList = [];
  //   try {
  //     final matchResultSnap = await matchResultRef
  //         .doc(auth.currentUser!.uid)
  //         .collection('opponentList')
  //         .get();
  //     await Future.forEach<dynamic>(matchResultSnap.docs, (doc) async {
  //       final matchResultSnapWk = await matchResultRef
  //           .doc(auth.currentUser!.uid)
  //           .collection('opponentList')
  //           .doc(doc.id)
  //           .collection('daily')
  //           .get();
  //       await Future.forEach<dynamic>(matchResultSnapWk.docs, (doc2) async {
  //         CHomePageVal home = await getNickNameAndTorokuRank(doc.id);
  //         String feedBackComment = await doc2.data()?['FEEDBACK_COMMENT'] ?? "";
  //         String matchTitle = await doc2.data()?['matchTitle'] ?? "";
  //         if (feedBackComment != "") {
  //           feedBackList.add(CFeedBackCommentSetting(
  //               OPPONENT_ID: doc.id,
  //               FEED_BACK: feedBackComment,
  //               DATE_TIME: doc2.id,
  //               MATCH_TITLE: matchTitle,
  //               HOME: home));
  //         }
  //       });
  //     });
  //   } catch (e) { throw(e);
  //     print('フィードバックリスト取得に失敗しました --- $e');
  //   }
  //   return feedBackList;
  // }

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
        throw (e);
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
            SERVE_1ST: snapShot.data()?['SERVE_1ST'] ?? 0,
            SERVE_2ND: snapShot.data()?['SERVE_2ND'] ?? 0,
            STROKE_BACKHAND: snapShot.data()?['STROKE_BACKHAND'] ?? 0,
            STROKE_FOREHAND: snapShot.data()?['STROKE_FOREHAND'] ?? 0,
            VOLLEY_BACKHAND: snapShot.data()?['VOLLEY_BACKHAND'] ?? 0,
            VOLLEY_FOREHAND: snapShot.data()?['VOLLEY_FOREHAND'] ?? 0);
      } catch (e) {
        throw (e);
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
        throw (e);
        print('対戦結果取得に失敗しました --- $e');
      }
    }
    return matchResultList;
  }

  /// 個人用の対戦結果登録（相手は任意の名前のみ）
  static Future<void> makePersonalMatchResult(
      CprofileSetting myProfile,
      String opponentName,
      List<CmatchResult> matchResultList,
      String dayKey,
      String matchTitle) async {
    DateFormat outputFormat = DateFormat('yyyy/MM/dd HH:mm');
    String today = outputFormat.format(DateTime.now());
    final opponentId = 'personal-$dayKey';
    final scorePoints =
        matchResultList.map((mr) => "${mr.myGamePoint}-${mr.yourGamePoint}").toList();

    await matchResultRef
        .doc(myProfile.USER_ID)
        .collection('opponentList')
        .doc(opponentId)
        .collection('daily')
        .doc(dayKey)
        .set({
      'matchTitle': matchTitle,
      'dailyId': dayKey,
      'userId': myProfile.USER_ID,
      'opponentId': opponentId,
      'opponentProfileImage': '',
      'opponentName': opponentName,
      'scorePoint': scorePoints,
      'koushinTime': today,
      'FEEDBACK_FLG': false,
      'personalFlg': true,
    });

    await Future.forEach<CmatchResult>(matchResultList, (matchResult) async {
      await matchResultRef
          .doc(myProfile.USER_ID)
          .collection('opponentList')
          .doc(opponentId)
          .collection('daily')
          .doc(dayKey)
          .collection('matchDetail')
          .doc(matchResult.No)
          .set({
        'No': matchResult.No,
        'MY_POINT': matchResult.myGamePoint,
        'YOUR_POINT': matchResult.yourGamePoint,
      });
    });
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
  //   } catch (e) { throw(e);
  //     print('対戦結果LIST取得に失敗しました --- $e');
  //   }
  //   matchResultList.sort((a, b) => b.dayKey.compareTo(a.dayKey));
  //   return matchResultList;
  // }

  static Future<String> getMatchTitle(String? dayKey, String yourUserId) async {
    //タイトル取得
    String matchTitle = "";
    try {
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
    } catch (e) {
      print("getMatchTitleエラー");
    }
    return matchTitle;
  }

  /**
   * MyUserIdの重複チェックを行うメソッドです
   */
  static Future<bool> checkDoubleMyUserID(
      String inputText, bool isDoubleMyUserId) async {
    print("bbb");
    try {
      final snapShot =
          await profileRef.where('MY_USER_ID', isEqualTo: inputText).get();

      final snapShot_self = await profileRef
          .where('USER_ID', isEqualTo: auth.currentUser!.uid)
          .get();

      if (snapShot.docs.isNotEmpty) {
        //既存のMyUserIdが存在する場合
        String inputID = snapShot.docs.first.get('MY_USER_ID');
        if (snapShot_self.docs.isNotEmpty) {
          //既存のMyUserIdが存在する場合、自分自身のMyUserIdと同じ場合のみ重複を認める
          String selfID = snapShot_self.docs.first.get('MY_USER_ID');
          if (inputID == selfID) {
            isDoubleMyUserId = false;
          } else {
            isDoubleMyUserId = true;
          }
        } else {
          isDoubleMyUserId = true;
        }
      } else {
        //既存のMyUserIdが存在しない場合
        isDoubleMyUserId = false;
      }
    } catch (e) {
      print("checkDoubleMyUserIDエラー");
    }
    print("ccc");
    return isDoubleMyUserId;
  }

//ブロックリスト追加処理
  static Future<void> addBlockList(String userId) async {
//ブロックリストチェック
    String newFlg =
        await FirestoreMethod.newFlgBlockList(auth.currentUser!.uid);
    print("newFlg" + newFlg.toString());

    if (newFlg == "0") {
      try {
        final snapshot = await blockListRef
            .doc(auth.currentUser!.uid)
            .collection('blockUserList')
            .where('BLOCK_USER', isEqualTo: userId)
            .get();
        if (snapshot.docs.isNotEmpty) {
          print("既にブロック済みです");
        } else {
          await blockListRef
              .doc(auth.currentUser!.uid)
              .collection('blockUserList')
              .add({'BLOCK_USER': userId});
        }
      } catch (e) {
        print("addBlockListエラー");
      }
    } else {
      try {
        await blockListRef
            .doc(auth.currentUser!.uid)
            .collection('blockUserList')
            .add({'BLOCK_USER': userId});
      } catch (e) {
        print("addBlockListブロックエラー");
      }
    }
  }

//ブロックリスト解除
  static Future<void> delBlockList(String userId) async {
    try {
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
    } catch (e) {
      print("delBlockListエラー");
    }
  }

//ブロックリスト_新規フラグ取得
  static Future<String> newFlgBlockList(String userId) async {
    late String newFlg;
    try {
      final snapshot =
          await blockListRef.doc(userId).collection('blockUserList').get();
      if (snapshot.docs.isNotEmpty) {
        newFlg = "0";
      } else {
        newFlg = "1";
      }
    } catch (e) {
      print("newFlgBlockListエラー");
    }
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
    final snapshot = await blockListRef
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
        throw (e);
        print('ブロックリスト追加に失敗しました --- $e');
      }
    });
    return blockList;
  }

  //ブロックリスト取得
  static Future<List<String>> getBlockUserList(String myUserId) async {
    List<String> blockList = [];
    try {
      final snapshot = await blockListRef
          .doc(auth.currentUser!.uid)
          .collection('blockUserList')
          .get();
      await Future.forEach<dynamic>(snapshot.docs, (doc) async {
        blockList.add(doc.data()['BLOCK_USER']);
      });
    } catch (e) {
      throw (e);
      print('ブロックリスト取得に失敗しました --- $e');
    }
    return blockList;
  }

  /**
   * 自分のユーザIDをキーに指定対戦相手との対戦結果を取得するメソッド
   *  userId 自身のユーザーID
   */
  static Future<CScoreRef> getMatchResultScore(String oponent_UserId) async {
    late List<CScoreRefHistory> historyList = [];
    late CScoreRef result;
    late CScoreRefHistory history;

    try {
      //対戦結果を取得
      final doc = await matchResultRef
          .doc(auth.currentUser!.uid)
          .collection('opponentList')
          .doc(oponent_UserId)
          .get();

      final snapShot_daily = await matchResultRef
          .doc(auth.currentUser!.uid)
          .collection('opponentList')
          .doc(oponent_UserId)
          .collection('daily')
          .orderBy('dailyId', descending: true)
          .limit(5)
          .get();
      if (snapShot_daily.docs.isNotEmpty) {
        await Future.forEach<dynamic>(snapShot_daily.docs, (docHis) async {
          history = CScoreRefHistory(
              TITLE: docHis.data()["matchTitle"],
              KOUSHIN_TIME: docHis.data()["koushinTime"],
              SCORE_POINT: docHis.data()["scorePoint"],
              FEEDBACK_COMMENT: docHis.data()?["FEEDBACK_COMMENT"] ?? "");
          historyList.add(history);
        });
      } else {
        history = CScoreRefHistory(
            TITLE: "", KOUSHIN_TIME: "", SCORE_POINT: [], FEEDBACK_COMMENT: "");
      }
      if (doc.exists) {
        result = new CScoreRef(
          MATCH_COUNT: doc!['MATCH_SU'],
          WIN_COUNT: doc!['WIN_SU'],
          LOSE_COUNT: doc!['LOSE_SU'],
          WIN_LATE: doc!['WIN_RATE'],
          HISTORYLIST: historyList,
        );
      } else {
        result = new CScoreRef(
          MATCH_COUNT: 0,
          WIN_COUNT: 0,
          LOSE_COUNT: 0,
          WIN_LATE: 0,
          HISTORYLIST: historyList,
        );
      }
    } catch (e) {
      print("getMatchResultScoreエラー");
    }
    return result;
  }

  static bool reviewFeatureEnabled = true;

  static Future<bool> getReviewFeatureEnabled() async {
    try {
      final settingSnapshot = await settingRef.doc(auth.currentUser!.uid).get();

      if (settingSnapshot == null || !settingSnapshot.exists) {
        reviewFeatureEnabled = true;
        // データが存在しない場合、初期値を使用する
        return true;
      }

      reviewFeatureEnabled = settingSnapshot.data()?["REVIEW_ENABLED"] ?? true;
    } catch (e) {
      print("getReviewFeatureEnabledエラー");
    }
    return reviewFeatureEnabled; // Firestoreのデータがnullの場合は初期値を使用する
  }

  static Future<void> putReviewFeatureEnabled(bool reviewFeatureEnabled) async {
    try {
      final settingSnapshot = await settingRef.doc(auth.currentUser!.uid);
      await settingSnapshot.set({"REVIEW_ENABLED": reviewFeatureEnabled});
      await profileDetailRef.doc(auth.currentUser!.uid).set(
          {"REVIEW_ENABLED": reviewFeatureEnabled}, SetOptions(merge: true));
    } catch (e) {
      print("putReviewFeatureEnabledエラー");
      throw ("putReviewFeatureEnabledエラー");
    }
  }

  static Future<bool> getYourReviewFeatureEnabled(String userId) async {
    bool yourReviewFeatureEnabled = true;
    try {
      final settingSnapshot = await settingRef.doc(userId).get();

      if (settingSnapshot == null || !settingSnapshot.exists) {
        // データが存在しない場合、初期値を使用する
        return true;
      }
      yourReviewFeatureEnabled =
          settingSnapshot.data()?["REVIEW_ENABLED"] ?? true;
    } catch (e) {
      print("getYourReviewFeatureEnabledエラー");
    }
    return yourReviewFeatureEnabled; // Firestoreのデータがnullの場合は初期値を使用する
  }

  static bool searchFeatureEnabled = true;

  static Future<void> putSearchFeatureEnabled(bool searchFeatureEnabled) async {
    try {
      final settingSnapshot = await settingRef.doc(auth.currentUser!.uid);
      await settingSnapshot.set(
          {"SEARCH_ENABLED": searchFeatureEnabled}, SetOptions(merge: true));
      await profileDetailRef.doc(auth.currentUser!.uid).set(
          {"SEARCH_ENABLED": searchFeatureEnabled}, SetOptions(merge: true));
    } catch (e) {
      print("putSearchFeatureEnabledエラー");
    }
  }

  static Future<bool> getSearchFeatureEnabled() async {
    try {
      final settingSnapshot = await settingRef.doc(auth.currentUser!.uid).get();

      if (settingSnapshot == null || !settingSnapshot.exists) {
        searchFeatureEnabled = true;
        // データが存在しない場合、初期値を使用する
        return true;
      }
      searchFeatureEnabled = settingSnapshot.data()?["SEARCH_ENABLED"] ?? true;
    } catch (e) {
      print("getSearchFeatureEnabledエラー");
    }
    return searchFeatureEnabled; // Firestoreのデータがnullの場合は初期値を使用する
  }

  //ログインするユーザーがプロフィール登録を完了しているか確認
  static bool isprofile = false;

  static Future<void> isProfile() async {
    try {
      if (auth.currentUser != null) {
        DocumentReference docRef = await profileRef.doc(auth.currentUser!.uid);
        print(docRef.toString());
        DocumentSnapshot docSnapshot = await docRef.get();
        isprofile = docSnapshot.exists;
      }
    } catch (e) {
      print("isProfileエラー");
    }
  }

  /**
   * 称号管理Mapの取得
   */
  static Future<Map<String, dynamic>> getMyTitle() async {
    Map<String, dynamic> title = {};
    try {
      final snapShot = await FirebaseFirestore.instance
          .collection('myProfileDetail')
          .doc(auth.currentUser!.uid)
          .get();

      final data = snapShot.data();
      if (data != null && data['TITLE'] != null) {
        title = Map<String, dynamic>.from(data['TITLE']);
      }
      final defaultTitleStatus = title['0']?.toString();
      if (defaultTitleStatus != '1' && defaultTitleStatus != '2') {
        title['0'] = '1'; // 初期称号を所持中に設定
        await profileDetailRef
            .doc(auth.currentUser!.uid)
            .set({'TITLE': title}, SetOptions(merge: true));
      }
    } catch (e) {
      print("getMyTitleエラー");
    }
    return title;
  }

  /**
   * ホーム画面に表示している称号を変更する
   */
  static Future<void> changeTitle(int no) async {
    try {
      Map<String, dynamic> map = await getMyTitle();
      String changedKey = '';
      for (dynamic entry in map.entries) {
        if (entry.value.toString() == "2") {
          changedKey = entry.key;
        }
      }
      if (changedKey != '') {
        map[changedKey] = '1';
      }
      map[no.toString()] = '2';
      await profileDetailRef.doc(auth.currentUser!.uid).update({'TITLE': map});
    } catch (e) {
      print("changeTitleエラー");
    }
  }

  /**
   * 装着中の称号を解除する
   */
  static Future<void> resetTitleSelection() async {
    try {
      Map<String, dynamic> map = await getMyTitle();
      bool updated = false;
      for (dynamic entry in map.entries) {
        if (entry.value.toString() == "2") {
          map[entry.key] = '1';
          updated = true;
        }
      }
      if (updated) {
        await profileDetailRef
            .doc(auth.currentUser!.uid)
            .update({'TITLE': map});
      }
    } catch (e) {
      print("resetTitleSelectionエラー");
    }
  }

  /**
   * 承認が終わっていないメアドの承認を行う
   */
  // 実行中かどうかを示すフラグを静的変数として定義
  static bool _isSending = false; // (※プライベート変数に修正することを推奨)

  static Future<void> sendUserAuthMail() async {
    // 実行中であれば、ここで処理を終了し二重実行を防ぐ
    if (_isSending) {
      print("承認メール送信処理は実行中です。二重実行をスキップします。");
      return;
    }

    // 処理開始時にフラグを立てる
    _isSending = true;

    try {
      await Future.delayed(Duration(seconds: 1)); // 1秒待機
      User? currentUser = await FirebaseAuth.instance.authStateChanges().first;
      print(currentUser);

      if (currentUser != null) {
        print("承認メール送信");
        // ここでエラーが発生する可能性があるので、tryブロック内に置く
        await currentUser.sendEmailVerification();
      } else {
        print("ユーザーが取得できませんでした");
      }

    } catch (e) {
      // エラー処理（必要に応じて）
      print("承認メール送信中にエラーが発生しました: $e");
      // throw e; // 呼び出し元にエラーを伝える場合は再スロー

    } finally {
      // 処理終了時（エラーが発生しても）に必ずフラグを解除
      _isSending = false;
      print("承認メール送信処理が完了しました。");
    }
  }

  //main.dartの判定で使用
  static bool isAuth = false;

  /**
   * 承認が終わっていないメアドの承認を行う
   */
  static Future<bool> checkUserAuth() async {
    User? currentUser = auth.currentUser;
    print(currentUser);
    if (currentUser!.emailVerified) {
      print("承認されました");
      isAuth = true;
      return true;
    } else {
      print("承認されていません");
      isAuth = false;
      return false;
    }
  }

  /**
   * 自分のブロックリストを確認して相手がブロック対象か否か
   */
  static Future<bool> isBlock(String myUid, String yourUid) async {
    final blockUserListRef =
        blockListRef.doc(myUid).collection('blockUserList');

    // クエリを実行し、結果をリストに格納
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await blockUserListRef.where('BLOCK_USER', isEqualTo: yourUid).get();

    //スナップショットが空でないということは対象をブロックしている
    if (querySnapshot.docs.isNotEmpty) {
      return false;
    }
    return true;
  }

  /**
   * 相手のブロックリストを確認して自分がブロック対象か否か
   */
  static Future<bool> isBlock_yours(String myUid, String yourUid) async {
    final blockUserListRef =
        blockListRef.doc(yourUid).collection('blockUserList');

    // クエリを実行し、結果をリストに格納
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await blockUserListRef.where('BLOCK_USER', isEqualTo: myUid).get();

    //スナップショットが空でないということは対象をブロックしている
    if (querySnapshot.docs.isNotEmpty) {
      return false;
    }
    return true;
  }

  static Future<void> addTodo(String title, String detail, String uid, String categori) async {
    if (uid != null) {
      final todosRef = _firestoreInstance.collection('todos');
      final docRef = todosRef.doc(uid);
    final DocumentSnapshot<dynamic> snapshot = await docRef.get();

      if (!snapshot.exists) {
        // ドキュメントが存在しない場合、新規作成
        await docRef.set({
          'todoList': [
            {
              'title': title,
              'detail': detail,
              'categori': categori,
              'updateTime' :FirestoreMethod.maekDateFormat(DateTime.now())
            },
          ],
        });
      } else {
        List<dynamic> todoList = snapshot.data()?['todoList'] ?? [];
        // 重複チェック
        bool isDuplicate = todoList.any((todo) => todo['title'] == title);
        if(isDuplicate){
          throw Exception("エラー");
        }

        await docRef.update({
          'todoList': FieldValue.arrayUnion([
            {
              'title': title,
              'detail': detail,
              'categori':categori,
              'updateTime' :FirestoreMethod.maekDateFormat(DateTime.now())
              // その他のフィールドを追加
            },
          ]),
        });
      }
    }
  }

  /**
   * todo削除処理
   */
  static Future<void> deleteTodo(String uid, int selectedTodoIds) async {
    final todosRef = _firestoreInstance.collection('todos');
    final docRef = todosRef.doc(uid);
    DocumentSnapshot<dynamic> snapshot = await docRef.get();
    List<dynamic> nowTodoList = snapshot.data()?['todoList'];

    // 削除したい要素を除外した新しい配列を作成
    print("削除対象ListIndex " +
        snapshot.data()!['todoList'][selectedTodoIds].toString());
    nowTodoList = nowTodoList
        .where((todo) =>
    todo['title'] !=
        snapshot.data()?['todoList'][selectedTodoIds]['title'])
        .toList();
    await docRef.update({'todoList': nowTodoList});
  }

  /**
   * TODO更新処理
   */
  static Future<void> updateTodo(
      String uid, String title, String detail, int id, String categori) async {
// Firestoreのドキュメント参照を取得
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final todosRef = _firestore.collection('todos');
    final docRef = todosRef.doc(uid);
    final DocumentSnapshot<dynamic> snapshot = await docRef.get();

    await FirebaseFirestore.instance
        .runTransaction((Transaction transaction) async {
          //現在登録されているtodo一覧
      List<dynamic> todoList = snapshot.data()?['todoList'] ?? [];

      //重複したタイトルがないか確認
      for (int i = 0; i < todoList.length; i++) {
        int todonumber = i;
        Map<String, dynamic> todo = todoList[i];
        if(todonumber != id && todo['title'] == title){
          throw Exception("重複エラー");
        }
      }

      Map<String, dynamic> oldMap = snapshot.data()?['todoList'][id] ?? [];

      Map<String, dynamic> newMap = {
        'title': title,
        'detail': detail,
        'categori':categori,
        'updateTime' :FirestoreMethod.maekDateFormat(DateTime.now())
      };
      List updateList = [newMap];

      // 削除したい要素を除外した新しい配列を作成
      List newTodoList =
      todoList.where((todo) => todo['title'] != oldMap['title']).toList();

      updateList.addAll(newTodoList);
      // ドキュメントを更新
      await transaction.update(docRef, {'todoList': updateList});
    });
  }

  static String maekDateFormat(DateTime date){
    DateFormat outputFormat = DateFormat('yyyy-MM-dd HH:mm');
    String formattedDate = outputFormat.format(date);
    return formattedDate;
  }

}
