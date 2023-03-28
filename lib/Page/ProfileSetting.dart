import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Common/CactivityList.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/ProfileImage.dart';
import '../UnderMenuMove.dart';

class ProfileSetting extends StatefulWidget {
  late CprofileSetting myProfile;
  String koushinFlg = '0';
  late String myUserId;

  ProfileSetting.Edit(CprofileSetting myProfileWork) {
    myProfile = myProfileWork;
    koushinFlg = '1';
  }

  ProfileSetting.Make(String? myUserId) {
    List<CativityList> activityList = [];
    myProfile = CprofileSetting(
      USER_ID: '',
      PROFILE_IMAGE: '',
      NICK_NAME: '',
      TOROKU_RANK: '',
      activityList: activityList,
      AGE: '',
      GENDER: '',
      COMENT: '',
      MY_USER_ID: myUserId!,
    );
  }

  @override
  _ProfileSettingState createState() => _ProfileSettingState(myProfile);
}

class _ProfileSettingState extends State<ProfileSetting> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  //ニックネーム
  late TextEditingController nickName = TextEditingController();

  //プロフィール画像  画像を登録できるようにする
  String profileImage = '';

  //登録ランク
  String torokuRank = "中級";

  //性別
  String gender = "男";

  late String myUserId;

  //市町村
  TextEditingController curShichoson = TextEditingController();

  //アクティビィリスト
  List<CativityList> activityList = [
    CativityList(
      No: "0",
      TODOFUKEN: "東京都",
      SHICHOSON: TextEditingController(),
    ),
  ];

  //都道府県登録数Index
  int todofukenTourokuNo = 0;

  //現在登録中の登録No
  int curTourokuNo = 0;

  //年齢
  String age = "20代";

  //コメント
  TextEditingController coment = TextEditingController();

  CprofileSetting myProfile;

  _ProfileSettingState(this.myProfile);

  // List<Widget> contentWidgets = [];

  @override
  void initState() {
    super.initState();
    String koushinFlg = widget.koushinFlg;

    //ニックネーム
    if (koushinFlg == "1") {
      nickName = TextEditingController(text: widget.myProfile.NICK_NAME);
    }

    //プロフィール画像  画像を登録できるようにする
    if (koushinFlg == "1") {
      profileImage = widget.myProfile.PROFILE_IMAGE;
    }

    //登録ランク
    if (koushinFlg == "1") {
      torokuRank = widget.myProfile.TOROKU_RANK;
    }
    //年齢
    if (koushinFlg == "1") {
      age = widget.myProfile.AGE;
    }
    //性別
    if (koushinFlg == "1") {
      gender = widget.myProfile.GENDER;
    }
    //コメント
    if (koushinFlg == "1") {
      coment = TextEditingController(text: widget.myProfile.COMENT);
    }

    //アクティビティリスト
    if (koushinFlg == "1") {
      activityList = widget.myProfile.activityList;
    }

    //都道府県登録数Index更新
    if (koushinFlg == "1") {
      todofukenTourokuNo = widget.myProfile.activityList.length;
      todofukenTourokuNo = todofukenTourokuNo - 1;
    }

    //アクティビティリスト
    if (koushinFlg == "1") {
      myUserId = widget.myProfile.MY_USER_ID;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            leading: widget.koushinFlg == '1'
                ? IconButton(
              icon: const Icon(
                Icons.reply,
                color: Colors.black,
                size: 40.0,
              ),
              onPressed: () => {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UnderMenuMove.make(0),
                  ),
                )
              },
            )
                : null,
            elevation: 0.0,
            backgroundColor: Colors.white,
            shadowColor: Colors.white,
          ),
          body: Scrollbar(
            isAlwaysShown: false,
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Column(children: [
                        SizedBox(
                          height: 30,
                        ),
                        InkWell(
                            child: ClipOval(
                                child: Container(
                                    child: profileImage == ""
                                        ? Image.asset(
                                      'images/upper_body-2.png',
                                      height: 100,
                                      width: 100,
                                    )
                                        : Image.network(
                                      profileImage,
                                      height: 100,
                                      width: 100,
                                      fit: BoxFit.cover,
                                    ))),
                            onTap: () async {
                              Future result = Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileImage.image(
                                          profileImage, "1")));
                              profileImage = await result;
                              setState(() {});
                            }),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 300,
                          height: 50,

                          child: TextFormField(
                            controller: nickName,
                            decoration: InputDecoration(
                                labelText: '名前',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16),
                                fillColor: Colors.white,
                                filled: true
                            ),
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ]),
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 30,
                              ),
                              Container(
                                child: Text(
                                  '●登録ランク',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 60,
                              ),
                              Container(
                                padding: const EdgeInsets.all(5.0),
                                width: 250,
                                height: 40,
                                decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Text(
                                  torokuRank,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                              ),
                              IconButton(
                                icon:
                                Icon(Icons.arrow_drop_down_circle_rounded),
                                onPressed: () {
                                  _showModalRankPicker(context);
                                },
                              ),
                            ],
                          ),
                        ]),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          child: Text(
                            '●主な活動場所',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        // ②配列のデータ数分カード表示を行う
                        itemCount: activityList.length,
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
                                      '都道府県',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5.0),
                                    width: 250,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Text(
                                      '${activityList[index].TODOFUKEN}',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                        Icons.arrow_drop_down_circle_rounded),
                                    onPressed: () {
                                      _showModalLocationPicker(
                                          context,
                                          int.parse(activityList[index].No),
                                          activityList[index].SHICHOSON);
                                      setState(() {});
                                    },
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
                                      '市町村',
                                      style: TextStyle(
                                          fontSize: 20, color: Colors.black),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Container(
                                      padding: const EdgeInsets.all(5.0),
                                      width: 250,
                                      height: 40,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey),
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration.collapsed(
                                            border: InputBorder.none,
                                            hintText: ''),
                                        controller:
                                        activityList[index].SHICHOSON,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ))
                                ],
                              ),
                            ],
                          );
                        }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            //登録Noを更新
                            todofukenTourokuNo = todofukenTourokuNo + 1;
                            //都道府県ウィジェット追加
                            // _makeWidgets(todofukenTourokuNo);
                            activityListAdd(todofukenTourokuNo.toString());
                            setState(() {});
                          },
                        ),
                        SizedBox(
                          width: 40,
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
                            '●年齢',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 250,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            age,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_drop_down_circle_rounded),
                          onPressed: () {
                            _showModalAgePicker(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          child: Text(
                            '●性別',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 250,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: Text(
                            gender,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_drop_down_circle_rounded),
                          onPressed: () {
                            _showModalGenderPicker(context);
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        SizedBox(
                          width: 30,
                        ),
                        Container(
                          child: Text(
                            '●コメント',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 300,
                          height: 150,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: TextField(
                            maxLines: 6,
                            decoration: InputDecoration.collapsed(
                                border: InputBorder.none, hintText: ''),
                            controller: coment,
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 260,
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.lightGreenAccent,
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(100)),
                            ),
                          ),
                          child: Text(
                            "登録",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            myProfile.USER_ID = auth.currentUser!.uid;
                            myProfile.PROFILE_IMAGE = profileImage;
                            myProfile.NICK_NAME = nickName.text;
                            myProfile.TOROKU_RANK = torokuRank;
                            myProfile.activityList = activityList;
                            myProfile.AGE = age;
                            myProfile.GENDER = gender;
                            myProfile.COMENT = coment.text;
                            //必須入力項目のチェック
                            if (nickName.text.isNotEmpty) {
                              //   CprofileSetting cprofileSet = CprofileSetting(
                              //     USER_ID: auth.currentUser!.uid,
                              //     PROFILE_IMAGE: profileImage,
                              //     NICK_NAME: nickName.text,
                              //     TOROKU_RANK: torokuRank,
                              //     activityList: activityList,
                              //     AGE: age,
                              //     GENDER: gender,
                              //     COMENT: coment.text,
                              //     MY_USER_ID:
                              //   );
                              //   await FirestoreMethod.makeProfile(cprofileSet);
                              await FirestoreMethod.makeProfile(myProfile);

                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UnderMenuMove.make(0),
                                ),
                              );
                            } else {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('必須項目を入力してください'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              primary: Colors.lightGreenAccent,
                                              onPrimary: Colors.black),
                                          child: Text('OK'),
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
                    )
                  ]),
            ),
          )),
    );
  }

  void _showModalRankPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Rank.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedRankChanged,
            ),
          ),
        );
      },
    );
  }

  void _showModalLocationPicker(
      BuildContext context, int No, TextEditingController shichoson) {
    curTourokuNo = No;
    curShichoson = shichoson;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Location.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedLocationChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _Location = [
    "北海道",
    "青森県",
    "岩手県",
    "宮城県",
    "秋田県",
    "山形県",
    "福島県",
    "茨城県",
    "栃木県",
    "群馬県",
    "埼玉県",
    "千葉県",
    "東京都",
    "神奈川県",
    "新潟県",
    "富山県",
    "石川県",
    "福井県",
    "山梨県",
    "長野県",
    "岐阜県",
    "静岡県",
    "愛知県",
    "三重県",
    "滋賀県",
    "京都府",
    "大阪府",
    "兵庫県",
    "奈良県",
    "和歌山県",
    "鳥取県",
    "島根県",
    "岡山県",
    "広島県",
    "山口県",
    "徳島県",
    "香川県",
    "愛媛県",
    "高知県",
    "福岡県",
    "佐賀県",
    "長崎県",
    "熊本県",
    "大分県",
    "宮崎県",
    "鹿児島県",
    "沖縄県",
  ];
  final List<String> _Rank = [
    "初級",
    "中級",
    "上級",
  ];

  final List<String> _Age = [
    "10代",
    "20代",
    "30代",
    "40代",
    "50代",
    "60代",
    "70代",
    "80代",
    "90代"
  ];

  final List<String> _Gender = [
    "男性",
    "女性",
  ];

  void _showModalAgePicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Age.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedAgeChanged,
            ),
          ),
        );
      },
    );
  }

  void _showModalGenderPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          child: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: CupertinoPicker(
              itemExtent: 40,
              children: _Gender.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedGenderChanged,
            ),
          ),
        );
      },
    );
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _onSelectedLocationChanged(int index) {
    activityList[curTourokuNo] = CativityList(
      No: curTourokuNo.toString(),
      TODOFUKEN: _Location[index],
      SHICHOSON: curShichoson,
    );
    setState(() {});
  }

  void _onSelectedRankChanged(int index) {
    setState(() {
      torokuRank = _Rank[index];
    });
  }

  void _onSelectedAgeChanged(int index) {
    setState(() {
      age = _Age[index];
    });
  }

  void _onSelectedGenderChanged(int index) {
    setState(() {
      gender = _Gender[index];
    });
  }

  activityListAdd(String No) {
    activityList.add(
      CativityList(
        No: No,
        TODOFUKEN: "東京都",
        SHICHOSON: TextEditingController(),
      ),
    );
  }

// List<Widget> _makeWidgets(int todofukenTourokuNoWk) {
//   contentWidgets.add(
//     Column(
//       children: [
//         Row(
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               child: Text(
//                 '都道府県',
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               padding: const EdgeInsets.all(5.0),
//               width: 250,
//               height: 40,
//               decoration: BoxDecoration(
//                 border: Border.all(color: Colors.grey),
//               ),
//               child: Text(
//                 ${todofuken + todofukenTourokuNoWk.toString()},
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//             IconButton(
//               icon: Icon(Icons.arrow_drop_down_circle_rounded),
//               onPressed: () {
//                 _showModalLocationPicker(context);
//                 setState(() {});
//               },
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//               child: Text(
//                 '市町村',
//                 style: TextStyle(fontSize: 20, color: Colors.black),
//               ),
//             ),
//           ],
//         ),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: 50,
//             ),
//             Container(
//                 padding: const EdgeInsets.all(5.0),
//                 width: 250,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: TextField(
//                   controller: shichoson,
//                   style: TextStyle(fontSize: 20, color: Colors.black),
//                 ))
//           ],
//         ),
//       ],
//     ),
//   );
//   return contentWidgets;
// }
}

