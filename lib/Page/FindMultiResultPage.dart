import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CFindMultiResultPage.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../FireBase/GoogleAds.dart';
import '../FireBase/NotificationMethod.dart';
import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class FindMultiResultPage extends StatefulWidget {
  FindMultiResultPage(
      this.todoufuken, this.shichoson, this.gender, this.rank, this.age,this.blockList);

  // 検索画面
  String todoufuken;
  String shichoson;
  String gender;
  String rank;
  String age;
  List<String> blockList;

  @override
  State<FindMultiResultPage> createState() => _FindMultiResultPageState(
      todoufuken, shichoson, gender, rank, age, blockList);
}

class _FindMultiResultPageState extends State<FindMultiResultPage> {
  _FindMultiResultPageState(this.todoufuken, this.shichoson, this.gender,
      this.rank, this.age, this.blockList);

  List<CFindMultiResultPage> searchResultListAll = [];
  DocumentSnapshot? lastDocument; // 最後のドキュメントを保持する変数
  bool _isLoadingMore = false;
  late ScrollController _scrollController;

  // 検索画面　アカウントIDの入力値
  String todoufuken;
  String shichoson;
  String gender;
  String rank;
  String age;
  List<String> blockList = [];

  //ログイン中のユーザーのIDを取得
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  String myUserID = auth.currentUser!.uid;

  Future<double> _calculateTextHeight(String text, TextStyle style) async {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 5,
    );
    textPainter.layout(maxWidth: MediaQuery.of(context).size.width * 0.7);
    return textPainter.height;
  }


  Future<void> _getSearchResultsList() async {
    //検索用のクエリ文を作成
    try {
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('myProfileDetail');

      if (gender != '') {
        query = query.where('GENDER', isEqualTo: gender);
      }

      if (rank != '') {
        query = query.where('TOROKU_RANK', isEqualTo: rank);
      }

      if (age != '') {
        query = query.where('AGE', isEqualTo: age);
      }

      query = query.where('SEARCH_ENABLED', isEqualTo: true);


      if (todoufuken != '') {
        if (shichoson != '') {
          query = query.where('TODOFUKEN_SHICHOSON_LIST',
              arrayContains: todoufuken + "(" + shichoson + ")");
        } else {
          query = query.where('TODOFUKEN_LIST', arrayContains: todoufuken);
        }
      } else if (shichoson != '') {
        query = query.where('SHICHOSON_LIST', arrayContains: shichoson);
      }
      final querySnapshot =
          await query.orderBy('KOUSHIN_TIME', descending: true).limit(10).get();

      List<CFindMultiResultPage> searchResultList = [];

      await Future.forEach<dynamic>(querySnapshot.docs, (doc) async {
        if (doc
            .data()['USER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          print("ユーザーが自分自身");
        } else {
          if (blockList.contains(doc.data()['USER_ID'])) {
            print("ブロックリストに含まれています");
          } else {
            double COMENT_HEIGHT = await _calculateTextHeight(doc.data()['COMENT'], TextStyle(fontSize: 12));
            CFindMultiResultPage FindMultiResult = CFindMultiResultPage(
                USER_ID: doc.data()['USER_ID'],
                NICK_NAME: doc.data()['NICK_NAME'],
                PROFILE_IMAGE: doc.data()['PROFILE_IMAGE'],
                COMENT: doc.data()['COMENT'],
                COMENT_HEIGHT:COMENT_HEIGHT);
            searchResultList.add(FindMultiResult);
          }
        }
      });
      if (querySnapshot.docs.isNotEmpty) {
        lastDocument = querySnapshot.docs.last; // 最後のドキュメントを設定
      }

      setState(() {
        searchResultListAll.addAll(searchResultList);
        if(searchResultList.length < 10) {
          _loadMoreSearchList();
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _loadMoreSearchList() async {
    try {
      if (_isLoadingMore) return;

      setState(() {
        _isLoadingMore = true;
      });

      //検索用のクエリ文を作成
      Query<Map<String, dynamic>> query =
          FirebaseFirestore.instance.collection('myProfileDetail');

      if (gender != '') {
        query = query.where('GENDER', isEqualTo: gender);
      }

      if (rank != '') {
        query = query.where('TOROKU_RANK', isEqualTo: rank);
      }

      if (age != '') {
        query = query.where('AGE', isEqualTo: age);
      }

      query = query.where('SEARCH_ENABLED', isEqualTo: true);


      if (todoufuken != '') {
        if (shichoson != '') {
          query = query.where('TODOFUKEN_SHICHOSON_LIST',
              arrayContains: todoufuken + "(" + shichoson + ")");
        } else {
          query = query.where('TODOFUKEN_LIST', arrayContains: todoufuken);
        }
      } else if (shichoson != '') {
        query = query.where('SHICHOSON_LIST', arrayContains: shichoson);
      }
      List<CFindMultiResultPage> searchResultList = [];

      final snapShotWkMore = await query
          .orderBy('KOUSHIN_TIME', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(10)
          .get();

      await Future.forEach<dynamic>(snapShotWkMore.docs, (doc) async {
        if (doc
            .data()['USER_ID']
            .contains(FirestoreMethod.auth.currentUser!.uid)) {
          print("ユーザーが自分自身");
        } else {
          if (blockList.contains(doc.data()['USER_ID'])) {
            print("ブロックリストに含まれています");
          } else {
            double COMENT_HEIGHT = await _calculateTextHeight(doc.data()['COMENT'], const TextStyle(fontSize: 12));
            CFindMultiResultPage FindMultiResult = CFindMultiResultPage(
                USER_ID: doc.data()['USER_ID'],
                NICK_NAME: doc.data()['NICK_NAME'],
                PROFILE_IMAGE: doc.data()['PROFILE_IMAGE'],
                COMENT: doc.data()['COMENT'],
                COMENT_HEIGHT:COMENT_HEIGHT
            );
            searchResultList.add(FindMultiResult);
          }
        }
      });

      if (snapShotWkMore.docs.isNotEmpty) {
        lastDocument = snapShotWkMore.docs.last;
      }
      setState(() {
        searchResultListAll.addAll(searchResultList);
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
  void initState() {
    super.initState();
    _getSearchResultsList();
    _scrollController = ScrollController();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (!_isLoadingMore) {
          _loadMoreSearchList();
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // ScrollControllerを解放
    super.dispose(); // 親クラスのdisposeも呼び出す
  }

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "検索結果");
    DrawerConfig().init(context);
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: Stack(
          children: [
            Container(alignment:Alignment.center,height: 40, child: AdBanner(size: AdSize.banner)),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: searchResultListAll.length == 0 ? new Text("対象ユーザーは存在しません") : ListView.builder(
                  controller: _scrollController,
                  physics: const RangeMaintainingScrollPhysics(),
                  shrinkWrap: true,
                  reverse: false,
                  itemCount: searchResultListAll.length + 1,
                  itemBuilder: (context, index) {
                    if (index == searchResultListAll.length) {
                      // ページネーションアイテムの場合
                      if (_isLoadingMore) {
                        print(_isLoadingMore);
                        return const Center(child: CircularProgressIndicator());
                      } else {
                        print("aaa");
                        return const SizedBox();
                      }
                    } else {
                      return InkWell(
                        onTap: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text(
                                      searchResultListAll[index].NICK_NAME +
                                          'さんとトークしてみますか'),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                                      child: const Text('はい'),
                                      onPressed: () async{
                                        //トーク画面へ遷移
                                        TalkRoomModel room = await FirestoreMethod.makeRoom(
                                            auth.currentUser!.uid,
                                            searchResultListAll[index].USER_ID);
                                        Navigator.pop(context);
                                        await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => TalkRoom(room),
                                            ));
                                        await NotificationMethod.unreadCountRest(
                                            searchResultListAll[index].USER_ID);
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black, backgroundColor: Colors.lightGreenAccent),
                                      child: const Text('いいえ'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                        },
                        child: Card(
                          color: Colors.white,
                          child:Container(
                            height: searchResultListAll[index].COMENT == '' ? 70 : searchResultListAll[index].COMENT_HEIGHT + 55,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8.0),
                                  //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                  child: InkWell(
                                    child:
                                        searchResultListAll[index].PROFILE_IMAGE == ''
                                            ? const CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Ftenipoikun.png?alt=media&token=46474a8b-ca79-4232-92ee-431042c19d10"),
                                                radius: 30,
                                              )
                                            : CircleAvatar(
                                                backgroundColor: Colors.white,
                                                backgroundImage: NetworkImage(
                                                    searchResultListAll[index]
                                                        .PROFILE_IMAGE),
                                                radius: 30),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProfileReference(
                                                  searchResultListAll[index]
                                                      .USER_ID)));
                                    },
                                  ),
                                ),
                                Column(
                                    crossAxisAlignment:CrossAxisAlignment.start,

                                  children: [
                                    Container(
                                      width: deviceWidth * 0.7,
                                      height: 30,
                                      child: Text(searchResultListAll[index].NICK_NAME,
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis, // テキストが指定領域を超えた場合の挙動を設定CO
                                          maxLines: 1,
                                          style: const TextStyle(
                                              fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                    Container(
                                      width: deviceWidth * 0.7,
                                      child: Text(searchResultListAll[index].COMENT,
                                          textAlign: TextAlign.start,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis, // テキストが指定領域を超えた場合の挙動を設定CO
                                          maxLines: (searchResultListAll[index].COMENT_HEIGHT/12).floor() > 5 ? 5 :(searchResultListAll[index].COMENT_HEIGHT/12).floor()  ,
                                          style: const TextStyle(
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
