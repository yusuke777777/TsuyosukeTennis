import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Common/CactivityList.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

import '../Common/CprofileSetting.dart';
import '../FireBase/FireBase.dart';

class ProfileSetting extends StatefulWidget {
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  //プロフィール画像  画像を登録できるようにする
  late String profileImage = 'images/ans_032.jpg';

  //ニックネーム
  late TextEditingController nickName = TextEditingController();

  //登録ランク
  String torokuRank = "中級";

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

  //現在登録中の市町村
  TextEditingController curShichoson = TextEditingController();

  //年齢
  String age = "20代";

  //コメント
  TextEditingController coment = TextEditingController();

  // List<Widget> contentWidgets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Scrollbar(
        isAlwaysShown: false,
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Column(children: [
                    ClipOval(
                      child: Image.asset(
                        profileImage,
                        height: 200,
                        width: 200,
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.all(5.0),
                      width: 300,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: TextField(
                        controller: nickName,
                        decoration: InputDecoration.collapsed(
                            border: InputBorder.none, hintText: '名前を入力してください'),
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                          style: TextStyle(fontSize: 25, color: Colors.black),
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
                        ),
                        child: Text(
                          torokuRank,
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_drop_down_circle_rounded),
                        onPressed: () {
                          _showModalRankPicker(context);
                        },
                      ),
                    ],
                  ),
                ]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                            '●主な活動場所',
                            style: TextStyle(fontSize: 25, color: Colors.black),
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
                            print(todofukenTourokuNo);
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
                            style: TextStyle(fontSize: 25, color: Colors.black),
                          ),
                        ),
                      ],
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
                        '●コメント',
                        style: TextStyle(fontSize: 25, color: Colors.black),
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
                      ),
                      child: TextField(
                        decoration: InputDecoration.collapsed(
                            border: InputBorder.none, hintText: ''),
                        controller: coment,
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                FloatingActionButton(
                  child: Text("登録"),
                  onPressed: () async{
                    CprofileSetting cprofileSet =
                    CprofileSetting(
                      USER_ID: auth.currentUser!.uid,
                      PROFILE_IMAGE: 'images/ans_032.jpg',
                      NICK_NAME: nickName.text,
                      TOROKU_RANK: torokuRank,
                      activityList: activityList,
                      AGE: age,
                      COMENT: coment.text,
                    );
                    await FirestoreMethod.makeProfile(cprofileSet);
                  },
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

  activityListAdd(String No) {
    print("No" + No);
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
