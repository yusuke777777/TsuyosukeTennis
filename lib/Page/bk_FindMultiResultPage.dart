import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/material/list_tile.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CtalkRoom.dart';
import '../FireBase/FireBase.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../PropSetCofig.dart';
import 'TalkRoom.dart';

class FindMultiResultPage extends StatefulWidget {
  FindMultiResultPage(
      this.todoufuken, this.shichoson, this.gender, this.rank, this.age);

  // 検索画面
  String todoufuken;
  String shichoson;
  String gender;
  String rank;
  String age;
  List<String> blockList = [];

  @override
  State<FindMultiResultPage> createState() => _FindMultiResultPageState(
      todoufuken, shichoson, gender, rank, age, blockList);
}

class _FindMultiResultPageState extends State<FindMultiResultPage> {
  _FindMultiResultPageState(this.todoufuken, this.shichoson, this.gender,
      this.rank, this.age, this.blockList);

  late ScrollController _scrollController;
  late Stream<List<QueryDocumentSnapshot>> _searchResultListStream;
  bool _isLoadingMore = false;
  List<QueryDocumentSnapshot> _searchResultDocList = [];

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

  //入力値から対象レコードリストを取得
  // late Future<List<List<String>>> futureList =
  //     FirestoreMethod.getFindMultiResult(
  //         todoufuken, shichoson, gender, rank, age);

  Stream<List<QueryDocumentSnapshot>> _getSearchResultsListStream() {
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

    if (blockList.isNotEmpty) {
      query = query.where('USER_ID', whereNotIn: blockList);
    }

    return query
        .orderBy('KOUSHIN_TIME', descending: true)
        .limit(10)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  Future<void> _loadMoreSearchList() async {
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

    if (blockList.isNotEmpty) {
      print("aaa");
      query = query.where('USER_ID', whereNotIn: blockList);
    }

    final snapShotWkMore = await query
        .orderBy('KOUSHIN_TIME', descending: true)
        .startAfterDocument(_searchResultDocList.last)
        .limit(10)
        .get();

    setState(() {
      _isLoadingMore = false;
      _searchResultDocList.addAll(snapShotWkMore.docs);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _searchResultListStream = _getSearchResultsListStream();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreSearchList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "検索結果");
    DrawerConfig().init(context);
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _searchResultListStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                print(snapshot.error);
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              _searchResultDocList = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.active) {
                //該当するユーザが存在しない時
                if (_searchResultDocList!.isEmpty) {
                  return ListView(
                      padding: const EdgeInsets.all(8),
                      children: <Widget>[
                        //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
                        ListTile(title: Text("対象ユーザーは存在しません")),
                      ]);
                } else {
                  return ListView.builder(
                      controller: _scrollController,
                      reverse: false,
                      physics: const RangeMaintainingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _searchResultDocList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == _searchResultDocList.length) {
                          if (_isLoadingMore) {
                            return Center(child: CircularProgressIndicator());
                          } else {
                            return SizedBox();
                          }
                        }
                        return InkWell(
                          onTap: () async {
                            //トーク画面へ遷移
                            TalkRoomModel room = await FirestoreMethod.makeRoom(
                                auth.currentUser!.uid,
                                (_searchResultDocList[index].data()
                                        as Map<String, dynamic>)['USER_ID']
                                    as String);
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TalkRoom(room),
                                ));
                          },
                          child: Card(
                            color: Colors.white,
                            child: Container(
                              height: 70,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                    child: InkWell(
                                      child: (_searchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'PROFILE_IMAGE'] as String ==
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
                                                  (_searchResultDocList[index]
                                                              .data()
                                                          as Map<String,
                                                              dynamic>)[
                                                      'PROFILE_IMAGE']),
                                              radius: 30),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileReference(
                                                        (_searchResultDocList[
                                                                        index]
                                                                    .data()
                                                                as Map<String,
                                                                    dynamic>)[
                                                            'USER_ID'] as String)));
                                      },
                                    ),
                                  ),
                                  Container(
                                    child: Text(
                                        (_searchResultDocList[index].data()
                                                as Map<String, dynamic>)[
                                            'NICK_NAME'] as String,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      });
                }
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
