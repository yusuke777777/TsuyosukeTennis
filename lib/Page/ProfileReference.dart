import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';

/**
 * 他人のプロフィールを参照する用画面
 * 編集不可なのでテキストボックスとかもナシ
 */
class ProfileReference extends StatefulWidget {
  String user_id;

  //プロフィールを表示するためのidをもつ
  ProfileReference(this.user_id);

  @override
  _ProfileReferenceState createState() => _ProfileReferenceState(user_id);
}

class _ProfileReferenceState extends State<ProfileReference> {
  String user_id;

  _ProfileReferenceState(this.user_id);

  //対象ユーザのプロフィールをユーザIDをキーに取得
  late Future<CprofileSetting> yourProfile =
      FirestoreMethod.getYourProfile(user_id);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.white,
          shadowColor: Colors.white,
          leading: IconButton(
            icon: const Icon(
              Icons.reply,
              color: Colors.black,
              size: 40.0,
            ),
            onPressed: () => {Navigator.pop(context)},
          ),
        ),
        body: FutureBuilder(
            future: yourProfile,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return new Align(
                    child: Center(
                  child: new CircularProgressIndicator(),
                ));
              } else if (snapshot.hasError) {
                return new Text('Error: ${snapshot.error!}');
              } else if (snapshot.hasData) {
                CprofileSetting? profileList = snapshot.data;
                return Scrollbar(
                    isAlwaysShown: false,
                    child: SingleChildScrollView(
                      //画面の中身
                      //プロフィール画像
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Center(
                            child: ClipOval(
                                //プロフィール画像が設定されていなければデフォ画像
                                child: profileList!.PROFILE_IMAGE == ""
                                    ? Image.asset('images/upper_body-2.png',
                                        fit: BoxFit.cover)
                                    : Image.network(
                                        profileList.PROFILE_IMAGE,
                                        width: 70,
                                        height: 70,
                                        fit: BoxFit.fill,
                                      )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  profileList.NICK_NAME,
                                  style: TextStyle(
                                      fontSize: 50, color: Colors.black),
                                ),
                              ),
                            ],
                          ),

                          //登録ランク
                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                child: Text(
                                  '●登録ランク',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          //登録ランクの値
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  profileList.TOROKU_RANK,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          //主な活動場所
                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                child: Text(
                                  '●主な活動場所',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                              ),
                            ],
                          ),

                          //活動場所の値
                          ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(8),
                              // ②配列のデータ数分カード表示を行う
                              itemCount: profileList.activityList.length,
                              itemBuilder: (BuildContext context, int index) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Container(
                                          child: Text(
                                            '●都道府県',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(5.0),
                                          width: 250,
                                          height: 40,
                                          child: Text(
                                            '${profileList.activityList[index].TODOFUKEN}',
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 50,
                                        ),
                                        Container(
                                          child: Text(
                                            '●市町村',
                                            style: TextStyle(
                                                fontSize: 25,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.all(5.0),
                                            width: 250,
                                            height: 40,
                                            child: TextField(
                                              decoration:
                                                  InputDecoration.collapsed(
                                                      border: InputBorder.none,
                                                      hintText: ''),
                                              controller: profileList
                                                  .activityList[index]
                                                  .SHICHOSON,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black),
                                            ))
                                      ],
                                    ),
                                  ],
                                );
                              }),
                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                child: Text(
                                  '●年齢',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          //登録ランクの値
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  profileList.AGE,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ],
                          ),

                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                child: Text(
                                  '●コメント',
                                  style: TextStyle(
                                      fontSize: 25, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          //登録ランクの値
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Text(
                                  profileList.COMENT,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ));
              } else {
                return Text("データが存在しません");
              }
            }),
      ),
    );
  }
}
