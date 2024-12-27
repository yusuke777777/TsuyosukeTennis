import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import '../Common/CSkilLevelSetting.dart';
import '../Common/CmatchResult.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'MatchResultSansho.dart';

class MatchResultList extends StatefulWidget {
  const MatchResultList({Key? key}) : super(key: key);

  @override
  _MatchResultListState createState() => _MatchResultListState();
}

class _MatchResultListState extends State<MatchResultList> {
  late ScrollController _scrollController;
  late Stream<List<QueryDocumentSnapshot>> _matchResultListStream;
  bool _isLoadingMore = false;
  List<QueryDocumentSnapshot> _matchResultDocList = [];

  Stream<List<QueryDocumentSnapshot>> _getMatchResultsListStream() {
    return FirebaseFirestore.instance
        .collectionGroup('daily')
        .where('userId', isEqualTo: FirestoreMethod.auth.currentUser!.uid)
        .orderBy('dailyId', descending: true)
        .limit(10)
        .snapshots()
        .map((QuerySnapshot snapshot) => snapshot.docs);
  }

  Future<void> _loadMoreMatchList() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    final snapShotWkMore = await FirebaseFirestore.instance
        .collectionGroup('daily')
        .where('userId', isEqualTo: FirestoreMethod.auth.currentUser!.uid)
        .orderBy('dailyId', descending: true)
        .startAfterDocument(_matchResultDocList.last)
        .limit(10)
        .get();
    setState(() {
      _isLoadingMore = false;
      _matchResultDocList.addAll(snapShotWkMore.docs);
    });
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _matchResultListStream = _getMatchResultsListStream();
    // スクロール位置を監視してページネーションを実行
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreMatchList();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose(); // スクロールコントローラーを解放
    super.dispose(); // 親クラスのdisposeを呼び出す
  }

  Future<bool> isUserExist(String uid) async {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('myProfileDetail') // コレクション名を変更してください
        .doc(uid)
        .get();

    return docSnapshot.exists;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    //必要コンフィグの初期化
    HeaderConfig().init(context, "対戦履歴");
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: StreamBuilder<List<QueryDocumentSnapshot>>(
            stream: _matchResultListStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              _matchResultDocList = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.active) {
                return ListView.builder(
                    controller: _scrollController,
                    reverse: false,
                    physics: const RangeMaintainingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _matchResultDocList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _matchResultDocList.length) {
                        if (_isLoadingMore) {
                          return const Center(child: CircularProgressIndicator());
                        } else {
                          return const SizedBox();
                        }
                      }
                      return Card(
                        color: Colors.white,
                        child: Container(
                          height: 70,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: deviceWidth * 0.2,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                  child: InkWell(
                                    child: (_matchResultDocList[index].data()
                                                        as Map<String,
                                                            dynamic>)[
                                                    'opponentProfileImage']
                                                as String ==
                                            ''
                                        ? const CircleAvatar(
                                            backgroundColor: Colors.white,
                                            backgroundImage: NetworkImage(
                                                "https://firebasestorage.googleapis.com/v0/b/tsuyosuketeniss.appspot.com/o/myProfileImage%2Fdefault%2Ftenipoikun.png?alt=media&token=46474a8b-ca79-4232-92ee-431042c19d10"),
                                            radius: 30,
                                          )
                                        : ClipOval(
                                            child: Image.network(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentProfileImage'],
                                              width: 60,
                                              height: 60,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  backgroundImage: AssetImage(
                                                      'images/tenipoikun.png'),
                                                  radius: 30,
                                                );
                                              },
                                            ),
                                          ),
                                    onTap: () async {
                                      print(_matchResultDocList[index].data()
                                          as Map<String, dynamic>);

                                      //対戦相手もしくは入力者が退会済みの場合エラーメッセ
                                      print(await isUserExist(
                                          (_matchResultDocList[index].data()
                                                  as Map<String, dynamic>)[
                                              'userId'] as String));
                                      if (await isUserExist(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String) &&
                                          await isUserExist(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'userId'] as String)) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileReference(
                                                        (_matchResultDocList[
                                                                            index]
                                                                        .data()
                                                                    as Map<String,
                                                                        dynamic>)[
                                                                'opponentId']
                                                            as String)));
                                      } else {
                                        showDialog(
                                            context: context,
                                            builder: (_) => const AlertDialog(
                                                  title: Text("エラー"),
                                                  content: Text("退会済みユーザーです"),
                                                ));
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Container(
                                width: deviceWidth * 0.7,
                                child: InkWell(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: deviceWidth * 0.7,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            (_matchResultDocList[index].data()
                                                    as Map<String, dynamic>)[
                                                'matchTitle'] as String,
                                            overflow: TextOverflow.ellipsis,
                                            // テキストが指定領域を超えた場合の挙動を設定CO
                                            style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Container(
                                        width: deviceWidth * 0.7,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                            "対戦相手：" +
                                                (_matchResultDocList[index]
                                                            .data()
                                                        as Map<String, dynamic>)[
                                                    'opponentName'] +
                                                "\n対戦日時：" +
                                                ((_matchResultDocList[index]
                                                                .data()
                                                            as Map<String,
                                                                dynamic>)[
                                                        'dailyId'] as String)
                                                    .substring(0, 16),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey)),
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                      //対戦結果入力画面へ遷移
                                      //フィードバック結果を取得する
                                      String feedBackComment =
                                          await FirestoreMethod.getFeedBack(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'dailyId'] as String,
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String);
                                      //対戦結果を取得する
                                      List<CmatchResult> matchResult =
                                          await FirestoreMethod.getMatchResult(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'dailyId'] as String,
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String);
                                      //レビュー結果を取得する
                                      CSkilLevelSetting skillLevel =
                                          await FirestoreMethod.getSkillLevel(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'dailyId'] as String,
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String);
                                      CprofileSetting myProfile =
                                          await FirestoreMethod.getProfile();

                                      CprofileSetting yourProfile =
                                          await FirestoreMethod.getYourProfile(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String);
                                      String matchTitle =
                                          await FirestoreMethod.getMatchTitle(
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'dailyId'] as String,
                                              (_matchResultDocList[index].data()
                                                      as Map<String, dynamic>)[
                                                  'opponentId'] as String);

                                      await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MatchResultSansho(
                                                      myProfile,
                                                      yourProfile,
                                                      matchResult,
                                                      feedBackComment,
                                                      skillLevel,
                                                      matchTitle)));
                                    }
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            }));
  }
}
