import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Common/CtalkRoom.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchResult.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileSetting.dart';
import '../Common/CSkilLevelSetting.dart';
import '../Common/CmatchList.dart';
import '../Common/CmatchResult.dart';
import '../Common/CmatchResultsList.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'MatchResultSansho.dart';
import 'TalkRoom.dart';

class MatchResultList extends StatefulWidget {
  const MatchResultList({Key? key}) : super(key: key);

  @override
  _MatchResultListState createState() => _MatchResultListState();
}

class _MatchResultListState extends State<MatchResultList> {
  List<CmatchResultList> matchResultList = [];

  Future<void> createMatchList() async {
    try {
      matchResultList = await FirestoreMethod.getMatchResults();
    } catch (e) {
      print("マッチ結果一覧の取得に失敗しました");
    }
  }

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "マッチング結果一覧");
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirestoreMethod.matchResultListSnapshot,
            builder: (context, snapshot) {
              return FutureBuilder(
                future: createMatchList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return ListView.builder(
                        itemCount: matchResultList.length,
                        itemBuilder: (context, index) {
                          return Slidable(
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (value) {
                                    FirestoreMethod.delMatchResultList(
                                        matchResultList[index].YOUR_USER.USER_ID,
                                        matchResultList[index].dayKey, context);
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
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      //プロフィール参照画面への遷移　※参照用のプロフィール画面作成する必要あり
                                      child: InkWell(
                                        child: matchResultList[index]
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
                                                    matchResultList[index]
                                                        .YOUR_USER
                                                        .PROFILE_IMAGE),
                                                radius: 30),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ProfileReference(
                                                          matchResultList[index]
                                                              .YOUR_USER
                                                              .USER_ID)));
                                        },
                                      ),
                                    ),
                                    InkWell(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              matchResultList[index].matchTitle,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold)),
                                          Text(
                                              "対戦相手：" +
                                                  matchResultList[index]
                                                      .YOUR_USER
                                                      .NICK_NAME +
                                                  "\n対戦日時：" +
                                                  matchResultList[index]
                                                      .dayKey
                                                      .toString()
                                                      .substring(0, 16),
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                      onTap: () async {
                                        //対戦結果入力画面へ遷移
                                        //フィードバック結果を取得する
                                        String feedBackComment =
                                            await FirestoreMethod.getFeedBack(
                                                matchResultList[index].dayKey,
                                                matchResultList[index]
                                                    .YOUR_USER
                                                    .USER_ID);
                                        //対戦結果を取得する
                                        List<CmatchResult> matchResult =
                                            await FirestoreMethod
                                                .getMatchResult(
                                                    matchResultList[index]
                                                        .dayKey,
                                                    matchResultList[index]
                                                        .YOUR_USER
                                                        .USER_ID);
                                        //レビュー結果を取得する
                                        CSkilLevelSetting skillLevel =
                                            await FirestoreMethod.getSkillLevel(
                                                matchResultList[index].dayKey,
                                                matchResultList[index]
                                                    .YOUR_USER
                                                    .USER_ID);
                                        CprofileSetting myProfile =
                                            await FirestoreMethod.getProfile();
                                        CprofileSetting yourProfile =
                                            await FirestoreMethod
                                                .getYourProfile(
                                                    matchResultList[index]
                                                        .YOUR_USER
                                                        .USER_ID);
                                        String matchTitle =
                                            await FirestoreMethod.getMatchTitle(
                                                matchResultList[index].dayKey,
                                                matchResultList[index]
                                                    .YOUR_USER
                                                    .USER_ID);

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
                                      },
                                    ),
                                    SizedBox(
                                      width: 120,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              );
            }));
  }
}
