import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Common/CtalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchResult.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CmatchList.dart';
import '../Common/CprofileSetting.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  static final FirebaseFirestore _firestoreInstance =
      FirebaseFirestore.instance;
  List<MatchListModel> matchListAll = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;
  static final blockListRef = _firestoreInstance.collection('blockList');

  Future<void> createMatchList() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matchList')
          .where('MATCH_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: true)
          .limit(10)
          .get();

      List<MatchListModel> matchList = [];
      await Future.forEach<dynamic>(querySnapshot.docs, (doc) async {
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);

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
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
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

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }
      if (mounted) {
        setState(() {
          matchListAll.addAll(matchList);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    createMatchList();
    _scrollController = ScrollController();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore) {
          _loadMoreData();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollControllerの解放
    super.dispose();
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;
    if (mounted) {
      setState(() {
        _isLoadingMore = true;
        print("loadMoreData");
        print(_isLoadingMore);
      });
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('matchList')
          .where('MATCH_USER_LIST',
              arrayContains: FirestoreMethod.auth.currentUser!.uid)
          .orderBy('SAKUSEI_TIME', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();

      List<MatchListModel> matchList = [];
      await Future.forEach<dynamic>(querySnapshot.docs, (doc) async {
        if (doc
            .data()['RECIPIENT_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);

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
        } else if (doc
            .data()['SENDER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          CprofileSetting yourProfile =
              await FirestoreMethod.getYourProfile(doc.data()['RECIPIENT_ID']);
          CprofileSetting myProfile =
              await FirestoreMethod.getYourProfile(doc.data()['SENDER_ID']);
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

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
      if (mounted) {
        setState(() {
          matchListAll.addAll(matchList);
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      print(e.toString());
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

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

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    //必要コンフィグの初期化
    HeaderConfig().init(context, "マッチング一覧");
    DrawerConfig().init(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          drawer: DrawerConfig.drawer,
          body: Stack(
            children: [
              Container(
                  alignment: Alignment.center,
                  height: 40,
                  child: const AdBanner(size: AdSize.banner)),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: ListView.builder(
                    controller: _scrollController,
                    physics: const RangeMaintainingScrollPhysics(),
                    shrinkWrap: true,
                    reverse: false,
                    itemCount: matchListAll.length + 1,
                    itemBuilder: (context, index) {
                      if (index == matchListAll.length) {
                        // ページネーションアイテムの場合
                        if (_isLoadingMore) {
                          print(_isLoadingMore);
                          return const Center(
                              child: CircularProgressIndicator());
                        } else {
                          print("ss");
                          return const SizedBox();
                        }
                      } else {
                        return Slidable(
                            endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (value) async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('本当に削除して宜しいですか'),
                                            actions: <Widget>[
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    backgroundColor: Colors
                                                        .lightGreenAccent),
                                                child: const Text('はい'),
                                                onPressed: () async {
                                                  try {
                                                    await FirestoreMethod
                                                        .delMatchList(
                                                            matchListAll[index]
                                                                .MATCH_ID);
                                                    Navigator.pop(context);
                                                    setState(() {
                                                      matchListAll
                                                          .removeAt(index);
                                                    });
                                                  } catch (e) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            const ShowDialogToDismiss(
                                                              content:
                                                                  "マッチングリストの削除に失敗しました",
                                                              buttonText: "はい",
                                                            ));
                                                  }
                                                },
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    foregroundColor:
                                                        Colors.black,
                                                    backgroundColor: Colors
                                                        .lightGreenAccent),
                                                child: const Text('いいえ'),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  backgroundColor: Colors.red,
                                  icon: Icons.delete,
                                  label: '削除',
                                ),
                              ],
                            ),
                            child: InkWell(
                                onTap: () async {
                                  bool blockFlg = await isBlock(
                                      matchListAll[index].MY_USER.USER_ID,
                                      matchListAll[index].YOUR_USER.USER_ID);
                                  if (!blockFlg) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                              title: Text('ブロック中のユーザーです',
                                                  style: TextStyle(fontSize: 18)),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor: Colors
                                                          .lightGreenAccent),
                                                  child: const Text('OK'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ]);
                                        });
                                  } else {
                                    try {
                                      // ドキュメントのロック状態を取得
                                      final matchSnapshot =
                                          await FirebaseFirestore.instance
                                              .collection('matchList')
                                              .doc(matchListAll[index].MATCH_ID)
                                              .get();

                                      String LOCK_FLG =
                                          matchSnapshot.data()?['LOCK_FLG'] ??
                                              "0";
                                      String LOCK_USER =
                                          matchSnapshot.data()?['LOCK_USER'] ??
                                              '';

                                      if (matchSnapshot.exists) {
                                        // 自分がロックしている、もしくはロックされていない場合
                                        if (LOCK_FLG == '0' ||
                                            LOCK_USER ==
                                                FirestoreMethod
                                                    .auth.currentUser!.uid ||
                                            LOCK_USER == '') {
                                          // 自分のUIDでロック設定
                                          await FirebaseFirestore.instance
                                              .collection('matchList')
                                              .doc(matchListAll[index].MATCH_ID)
                                              .set({
                                            'LOCK_FLG': '1',
                                            'LOCK_USER': FirestoreMethod
                                                .auth.currentUser!.uid,
                                          }, SetOptions(merge: true));
                                          //対戦結果入力画面へ遷移
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MatchResult(
                                                          matchListAll[index]
                                                              .MY_USER,
                                                          matchListAll[index]
                                                              .YOUR_USER,
                                                          matchListAll[index]
                                                              .MATCH_ID)));
                                          // 画面から戻ってきたときに対象のドキュメントが存在するか確認
                                          final matchDoc =
                                              await FirebaseFirestore.instance
                                                  .collection('matchList')
                                                  .doc(matchListAll[index]
                                                      .MATCH_ID)
                                                  .get();

                                          if (matchDoc.exists) {
                                            // ドキュメントが存在する場合にのみロックを解除
                                            await FirebaseFirestore.instance
                                                .collection('matchList')
                                                .doc(matchListAll[index]
                                                    .MATCH_ID)
                                                .set({
                                              'LOCK_FLG': '0',
                                              'LOCK_USER': '',
                                            }, SetOptions(merge: true));
                                          }
                                        } else {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  const ShowDialogToDismiss(
                                                    content: '現在、他のユーザーが登録中です',
                                                    buttonText: "はい",
                                                  ));
                                        }
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) =>
                                                const ShowDialogToDismiss(
                                                  content:
                                                      'この対戦は既に他ユーザーが登録済。又は削除されています',
                                                  buttonText: "はい",
                                                ));
                                      }
                                    } catch (e) {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              const ShowDialogToDismiss(
                                                content: 'エラーが発生しました',
                                                buttonText: "はい",
                                              ));
                                    }
                                  }
                                },
                                child: Card(
                                  color: Colors.white,
                                  child: Container(
                                    height: 70,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: deviceWidth * 0.8,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                                child: InkWell(
                                                  child: matchListAll[index]
                                                              .YOUR_USER
                                                              .PROFILE_IMAGE ==
                                                          ''
                                                      ? const CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                                          radius: 30,
                                                        )
                                                      : CircleAvatar(
                                                          backgroundColor:
                                                              Colors.white,
                                                          backgroundImage:
                                                              NetworkImage(
                                                                  matchListAll[
                                                                          index]
                                                                      .YOUR_USER
                                                                      .PROFILE_IMAGE),
                                                          radius: 30),
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                ProfileReference(
                                                                    matchListAll[
                                                                            index]
                                                                        .YOUR_USER
                                                                        .USER_ID)));
                                                  },
                                                ),
                                              ),
                                              InkWell(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                        matchListAll[index]
                                                            .YOUR_USER
                                                            .NICK_NAME,
                                                        style: const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                    Text(
                                                        matchListAll[index]
                                                            .SAKUSEI_TIME,
                                                        style: const TextStyle(
                                                            color: Colors.grey),
                                                        overflow: TextOverflow
                                                            .ellipsis)
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        //トーク画面へ遷移
                                        Container(
                                          width: deviceWidth * 0.1,
                                          alignment: Alignment.centerRight,
                                          child: IconButton(
                                              icon: const Icon(
                                                Icons.message,
                                                color: Colors.black,
                                                size: 30.0,
                                              ),
                                              onPressed: () async {
                                                bool BlockFlg = await isBlock(
                                                    matchListAll[index]
                                                        .MY_USER
                                                        .USER_ID,
                                                    matchListAll[index]
                                                        .YOUR_USER
                                                        .USER_ID);
                                                if (!BlockFlg) {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                            title: Text(
                                                                'ブロック中のユーザーです',
                                                                style: TextStyle(fontSize: 18)),
                                                            actions: <Widget>[
                                                              ElevatedButton(
                                                                style: ElevatedButton.styleFrom(
                                                                    foregroundColor:
                                                                        Colors
                                                                            .black,
                                                                    backgroundColor:
                                                                        Colors
                                                                            .lightGreenAccent),
                                                                child:
                                                                    const Text(
                                                                        'OK'),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                              ),
                                                            ]);
                                                      });
                                                } else {
                                                  TalkRoomModel room =
                                                      await FirestoreMethod
                                                          .makeRoom(
                                                              matchListAll[
                                                                      index]
                                                                  .MY_USER
                                                                  .USER_ID,
                                                              matchListAll[
                                                                      index]
                                                                  .YOUR_USER
                                                                  .USER_ID);

                                                  // TalkRoomModel room =
                                                  //     await FirestoreMethod.getRoom(
                                                  //         matchList[index]
                                                  //             .RECIPIENT_ID,
                                                  //         matchList[index].SENDER_ID,
                                                  //         matchList[index].YOUR_USER);
                                                  await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              TalkRoom(room)));
                                                  await NotificationMethod
                                                      .unreadCountRest(
                                                          matchListAll[index]
                                                              .YOUR_USER
                                                              .USER_ID);
                                                }
                                              }),
                                        )
                                      ],
                                    ),
                                  ),
                                )));
                      }
                    }),
              ),
            ],
          )),
    );
  }
}
