import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Common/CSinglesRankModel.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:intl/intl.dart';
import '../FireBase/NotificationMethod.dart';
import 'ProfileReference.dart';
import 'TalkRoom.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

class manSinglesRankList extends StatefulWidget {
  final String rank;

  manSinglesRankList(this.rank);

  @override
  _manSinglesRankListState createState() => _manSinglesRankListState();
}

class _manSinglesRankListState extends State<manSinglesRankList> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  List<RankModel> RankModelList = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  Future<void> createRankList() async {
    print("ccc");
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('manSinglesRank')
          .doc(widget.rank)
          .collection('RankList')
          .orderBy('RANK_NO')
          .limit(8)
          .get();

      final rankList = <RankModel>[];

      for (final doc in querySnapshot.docs) {
        final userId = doc.data()['USER_ID'];
        final yourProfile = await FirestoreMethod.getYourProfile(userId);
        final yourProfileDetail = await FirestoreMethod.getYourDetailProfile(userId);

        final rankListWork = RankModel(
          rankNo: doc.data()['RANK_NO'],
          user: yourProfile,
          tpPoint: doc.data()['TS_POINT'],
          searchEnableFlg: yourProfileDetail.SEARCH_ENABLE ?? true
        );

        rankList.add(rankListWork);
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
        print("eee");
      }
      if (mounted) {
        setState(() {
          RankModelList.addAll(rankList);
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    createRankList();
    _scrollController = ScrollController();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore) {
          print("bbb");
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
          .collection('manSinglesRank')
          .doc(widget.rank)
          .collection('RankList')
          .orderBy('RANK_NO')
          .startAfterDocument(lastDocument!)
          .limit(8)
          .get();

      final rankList = <RankModel>[];

      for (final doc in querySnapshot.docs) {
        final userId = doc.data()['USER_ID'];
        final yourProfile = await FirestoreMethod.getYourProfile(userId);
        final yourProfileDetail = await FirestoreMethod.getYourDetailProfile(userId);
        print("ぎゃあああ" + yourProfileDetail.SEARCH_ENABLE.toString());

        final rankListWork = RankModel(
          rankNo: doc.data()['RANK_NO'],
          user: yourProfile,
          tpPoint: doc.data()['TS_POINT'],
          searchEnableFlg: yourProfileDetail.SEARCH_ENABLE ?? true,
        );

        rankList.add(rankListWork);
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last;
      }
      if (mounted) {
        setState(() {
          RankModelList.addAll(rankList);
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

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        // appBar: AppBar(
        //   backgroundColor: const Color(0xFF3CB371),
        //   title: Text('ランキング'),
        // ),
        body: Stack(
      children: [
        Column(
          children: [
            Container(
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 1))),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(padding: EdgeInsets.all(10)),
                  Container(
                    width: deviceWidth * 0.17,
                    alignment: Alignment.center,
                    child: const Text("ランク",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(50, 0, 0, 0)),
                  Container(
                    alignment: Alignment.center,
                    width: deviceWidth * 0.25,
                    child: const Text("選手名", style: TextStyle(fontSize: 20)),
                  ),
                  Container(
                    alignment: Alignment.center,
                    width: deviceWidth * 0.38,
                    child: const Text("ポイント",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40),
          child: ListView.builder(
              controller: _scrollController,
              physics: const RangeMaintainingScrollPhysics(),
              shrinkWrap: true,
              reverse: false,
              itemCount: RankModelList.length + 1,
              itemBuilder: (context, index) {
                if (index == RankModelList.length) {
                  // ページネーションアイテムの場合
                  if (_isLoadingMore) {
                    print("abcdef");
                    print(_isLoadingMore);
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    print("ss");
                    return const SizedBox();
                  }
                } else {
                  return Card(
                    color: Colors.white,
                    child: Container(
                      height: 70,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: deviceWidth * 0.17,
                            alignment: Alignment.center,
                            child: FittedBox(
                              alignment: Alignment.bottomCenter,
                              fit: BoxFit.scaleDown,
                              child: Text(
                                  RankModelList[index].rankNo.toString(),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(right: 3),
                            alignment: Alignment.center,
                            width: deviceWidth * 0.46,
                            child: Row(
                              children: [
                                InkWell(
                                  child: Container(
                                    alignment: Alignment.center,
                                    width: deviceWidth * 0.15,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: RankModelList[index]
                                                .user
                                                .PROFILE_IMAGE ==
                                            ''
                                        ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                                "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Fupper_body-2.png?alt=media&token=5dc475b2-5b5e-4d3a-a6e2-3844a5ebeab7"),
                                            radius: 20,
                                          )
                                        : CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                                RankModelList[index]
                                                    .user
                                                    .PROFILE_IMAGE),
                                            radius: 20,
                                          ),
                                  ),
                                  onTap: () {
                                    if(RankModelList[index].searchEnableFlg){
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProfileReference(
                                                      RankModelList[index]
                                                          .user
                                                          .USER_ID)));
                                    }
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: deviceWidth * 0.3,
                                    child: FittedBox(
                                      alignment: Alignment.bottomLeft,
                                      fit: BoxFit.scaleDown,
                                      // 子ウィジェットを親ウィジェットにフィットさせる
                                      child: Text(
                                          RankModelList[index].user.NICK_NAME,
                                          style: const TextStyle(
                                              fontSize: 15,
                                              color: Colors.green)),
                                    ),
                                  ),
                                  onTap: () {
                                    if (RankModelList[index].user.USER_ID !=
                                        auth.currentUser!.uid && RankModelList[index].searchEnableFlg) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text(RankModelList[index]
                                                      .user
                                                      .NICK_NAME +
                                                  'さんとトークしてみますか'),
                                              actions: <Widget>[
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.black,
                                                      backgroundColor: Colors
                                                          .lightGreenAccent),
                                                  child: const Text('はい'),
                                                  onPressed: () async {
                                                    TalkRoomModel room =
                                                        await FirestoreMethod
                                                            .makeRoom(
                                                                auth.currentUser!
                                                                    .uid,
                                                                RankModelList[
                                                                        index]
                                                                    .user
                                                                    .USER_ID);
                                                    Navigator.pop(context);
                                                    await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    TalkRoom(
                                                                        room)));
                                                    await NotificationMethod
                                                        .unreadCountRest(
                                                            RankModelList[index]
                                                                .user
                                                                .USER_ID);
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
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 3),
                            width: deviceWidth * 0.3,
                            child: FittedBox(
                              alignment: Alignment.bottomRight,
                              fit: BoxFit.scaleDown,
                              // 子ウィジェットを親ウィジェットにフィットさせる
                              child: Text(
                                  NumberFormat('#,###')
                                      .format(RankModelList[index].tpPoint)
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: 20, color: Colors.black),
                                  overflow: TextOverflow.ellipsis),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              }),
        ),
      ],
    ));
  }
}
