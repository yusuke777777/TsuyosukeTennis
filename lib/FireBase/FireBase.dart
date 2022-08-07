import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

import '../Common/CHomePageSetting.dart';
import '../Common/CprofileSetting.dart';
import '../Common/CactivityList.dart';

class FirestoreMethod {
  String Uid = '';
  static FirebaseFirestore _firestoreInstance = FirebaseFirestore.instance;
  static final profileRef = _firestoreInstance.collection('myProfile');

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
        'GENDER':profile.GENDER,
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
    if (snapShot == null) {
      return stringList;
    }

    stringList.add(name);
    stringList.add(rank);
    stringList.add(id);

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
        SHICHOSON: TextEditingController(text:doc.data()['SHICHOSON']),
      ));
    });

    CprofileSetting cprofileSet =  await CprofileSetting(
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
    if(profileImage != null) {
      await storage.ref().child('myProfileImage/${auth.currentUser!.uid}/photos').child("myProfile.jpg").putFile(
          profileImage);
    }
    imageURL =  await storage.ref().child('myProfileImage/${auth.currentUser!.uid}/photos').child("myProfile.jpg").getDownloadURL();
  } catch (e) {
    print(e);
  }
  return imageURL;
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
