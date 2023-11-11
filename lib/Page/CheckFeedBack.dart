import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Common/CFeedBackCommentSetting.dart';
import '../PropSetCofig.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'ProfileReference.dart';

class CheckFeedBack extends StatefulWidget {
  const CheckFeedBack({Key? key}) : super(key: key);

  @override
  State<CheckFeedBack> createState() => _CheckFeedBackState();
}

class _CheckFeedBackState extends State<CheckFeedBack> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  List<CFeedBackCommentSetting> feedBackList = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  Future<void> createfeedBackList() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('daily')
          .where('userId', isEqualTo: FirestoreMethod.auth.currentUser!.uid)
          .where('FEEDBACK_FLG', isEqualTo: true)
          .orderBy('dailyId', descending: true)
          .limit(10)
          .get();

      List<CFeedBackCommentSetting> feedBackListWk = [];

      for (final doc in querySnapshot.docs) {
        final feedBackWk = CFeedBackCommentSetting(
          OPPONENT_ID: doc.id,
          OPPONENT_NAME: doc.data()['opponentName'],
          OPPONENT_IMAGE: doc.data()['opponentProfileImage'],
          FEED_BACK: doc.data()['FEEDBACK_COMMENT'],
          DATE_TIME: doc.data()['dailyId'],
          MATCH_TITLE: doc.data()['matchTitle'],
        );
        feedBackListWk.add(feedBackWk);
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }

      setState(() {
        feedBackList.addAll(feedBackListWk);
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    createfeedBackList();
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

  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collectionGroup('daily')
          .where('userId', isEqualTo: FirestoreMethod.auth.currentUser!.uid)
          .where('FEEDBACK_FLG', isEqualTo: true)
          .orderBy('dailyId', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();

      List<CFeedBackCommentSetting> feedBackListWk = [];

      for (final doc in querySnapshot.docs) {
        final feedBackWk = CFeedBackCommentSetting(
          OPPONENT_ID: doc.id,
          OPPONENT_NAME: doc.data()['opponentName'],
          OPPONENT_IMAGE: doc.data()['opponentProfileImage'],
          FEED_BACK: doc.data()['FEEDBACK_COMMENT'],
          DATE_TIME: doc.data()['dailyId'],
          MATCH_TITLE: doc.data()['matchTitle'],
        );
        feedBackListWk.add(feedBackWk);
      }

      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }

      setState(() {
        feedBackList.addAll(feedBackListWk);
        _isLoadingMore = false;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Future<List<CFeedBackCommentSetting>> feedBackList =
  //     FirestoreMethod.getFeedBacks();

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "フィードバック一覧");
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            physics: RangeMaintainingScrollPhysics(),
            itemCount: feedBackList.length + 1,
            // padding: const EdgeInsets.all(8),
            itemBuilder: (BuildContext context, int index) {
              if (index == feedBackList.length) {
                // ページネーションアイテムの場合
                if (_isLoadingMore) {
                  print(_isLoadingMore);
                  return Center(child: CircularProgressIndicator());
                } else {
                  return SizedBox();
                }
              } else {
                //共通リストタイルの呼出
                return Card(
                    elevation: 0,
                    child: ListTile(
                        tileColor: Colors.white24,
                        leading: ClipOval(
                          child: GestureDetector(
                            //アイコン押下時の挙動
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => ProfileReference(pro),
                              //     ));
                            },
                            child: feedBackList[index].OPPONENT_IMAGE == ""
                                ? Image.asset('images/upper_body-2.png',
                                    fit: BoxFit.cover)
                                : Image.network(
                                    feedBackList[index]
                                        .OPPONENT_IMAGE
                                        .toString(),
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.fill,
                                  ),
                          ),
                        ),
                        title: Text(
                          feedBackList[index].FEED_BACK.toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                        subtitle: Text(
                          "タイトル：" +
                              feedBackList[index].MATCH_TITLE.toString() +
                              "\n入力者：" +
                              feedBackList[index].OPPONENT_NAME.toString() +
                              "\n入力日時：" +
                              feedBackList[index]
                                  .DATE_TIME
                                  .toString()
                                  .substring(0, 16),
                          style: TextStyle(fontSize: 12),
                        )));
              }
            }));
  }
}
