import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Common/CtalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchResult.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileSetting.dart';
import '../Common/CmatchList.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class MatchList extends StatefulWidget {
  const MatchList({Key? key}) : super(key: key);

  @override
  _MatchListState createState() => _MatchListState();
}

class _MatchListState extends State<MatchList> {
  List<MatchListModel> matchListAll = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  Future<void> createMatchList() async {
    print("ccc");
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
        print("eee");
      }

      setState(() {
        matchListAll.addAll(matchList);
      });
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

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
      print("loadMoreData");
      print(_isLoadingMore);
    });

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

      setState(() {
        matchListAll.addAll(matchList);
        _isLoadingMore = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    //必要コンフィグの初期化
    HeaderConfig().init(context, "マッチング一覧");
    DrawerConfig().init(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        drawer: DrawerConfig.drawer,
        body: ListView.builder(
            controller: _scrollController,
            physics: RangeMaintainingScrollPhysics(),
            shrinkWrap: true,
            reverse: false,
            itemCount: matchListAll.length + 1,
            itemBuilder: (context, index) {
              if (index == matchListAll.length) {
                // ページネーションアイテムの場合
                if (_isLoadingMore) {
                  print(_isLoadingMore);
                  return Center(child: CircularProgressIndicator());
                } else {
                  print("ss");
                  return SizedBox();
                }
              } else {
                return Slidable(
                    endActionPane: ActionPane(
                      motion: DrawerMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (value) {
                            FirestoreMethod.delMatchList(
                                matchListAll[index].MATCH_ID, context);
                          },
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          label: '削除',
                        ),
                      ],
                    ),
                    child: Card(
                      color: Colors.white,
                      child: Container(
                        height: 70,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: deviceWidth * 0.8,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                    child: InkWell(
                                      child: matchListAll[index]
                                                  .YOUR_USER
                                                  .PROFILE_IMAGE ==
                                              ''
                                          ? CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(
                                                  "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                              radius: 30,
                                            )
                                          : CircleAvatar(
                                              backgroundColor: Colors.white,
                                              backgroundImage: NetworkImage(
                                                  matchListAll[index]
                                                      .YOUR_USER
                                                      .PROFILE_IMAGE),
                                              radius: 30),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileReference(
                                                        matchListAll[index]
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
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        Text(matchListAll[index].SAKUSEI_TIME,
                                            style:
                                                TextStyle(color: Colors.grey),
                                            overflow: TextOverflow.ellipsis)
                                      ],
                                    ),
                                    onTap: () {
                                      //対戦結果入力画面へ遷移
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => MatchResult(
                                                  matchListAll[index].MY_USER,
                                                  matchListAll[index].YOUR_USER,
                                                  matchListAll[index]
                                                      .MATCH_ID)));
                                    },
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
                                    TalkRoomModel room =
                                        await FirestoreMethod.makeRoom(
                                            matchListAll[index].MY_USER.USER_ID,
                                            matchListAll[index]
                                                .YOUR_USER
                                                .USER_ID);

                                    // TalkRoomModel room =
                                    //     await FirestoreMethod.getRoom(
                                    //         matchList[index]
                                    //             .RECIPIENT_ID,
                                    //         matchList[index].SENDER_ID,
                                    //         matchList[index].YOUR_USER);
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                TalkRoom(room)));
                                  }),
                            )
                          ],
                        ),
                      ),
                    ));
              }
            }));
  }
}
