import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'FindMultiResultPage.dart';
import 'FindResultPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;

class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;
  //都道府県
  late String todofuken = '';

  //登録ランク
  late String torokuRank = '';

  //性別
  late String gender = '';

  //年齢
  late String torokuAge = '';

  //アカウントIDで検索BOXに入力された値
  final inputId = TextEditingController();

  //入力された市町村
  final inputShichouson = TextEditingController();

  MaterialColor colorstate = Colors.green;

  @override
  Widget build(BuildContext context) {
    //必要コンフィグの初期化
    HeaderConfig().init(context, "検索");
    DrawerConfig().init(context);
    return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
          ),
          //ドロアーの定義
          drawer: DrawerConfig.drawer,

          //メイン画面実装
          body: Scrollbar(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    //アカウントID入力欄
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          width: 200,
                          height: 40,
                          child: TextFormField(
                            controller: inputId,
                            decoration: InputDecoration(
                              labelText: 'IDで検索',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide:
                                      const BorderSide(color: Colors.grey)),
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 16),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ),

                        //検索アイコン実装
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            inputId.text == ""
                                ? showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text("入力エラー!"),
                                          content: Text("アカウントIDを入力してください"),
                                        ))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FindResultPage(inputId.text),
                                    ));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    BorderedText(
                      child: Text('条件検索はこちら',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.green,
                          )),
                      strokeWidth: 0.5, //縁の太さ
                      strokeColor: Colors.black, //縁の色,
                    ),
                    const SizedBox(height: 5),

                    //都道府県選択BOX
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 200,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: todofuken == ''
                              ? Text(
                                  "都道府県",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey),
                                )
                              : Text(
                                  todofuken,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
                                ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_drop_down_circle_rounded),
                          onPressed: () {
                            _showModalLocationPicker(context);
                          },
                        ),
                      ],
                    ),

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    //市町村入力
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          alignment: Alignment.bottomRight,
                          width: 200,
                          height: 40,
                          child: TextFormField(
                            controller: inputShichouson,
                            decoration: InputDecoration(
                                labelText: '市町村',
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 16),
                                fillColor: Colors.white,
                                filled: true),
                          ),
                        ),
                      ],
                    ),

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    //性別
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                          padding: const EdgeInsets.all(5.0),
                          width: 200,
                          height: 40,
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20)),
                          child: gender == ''
                              ? Text(
                                  "性別",
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.grey),
                                )
                              : Text(
                                  gender,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black),
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

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    //登録ランク選択BOX
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                            padding: const EdgeInsets.all(5.0),
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: torokuRank == ''
                                ? Text("登録ランク",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey))
                                : Text(torokuRank,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black))),
                        IconButton(
                          icon: Icon(Icons.arrow_drop_down_circle_rounded),
                          onPressed: () {
                            _showModalRankPicker(context);
                          },
                        ),
                      ],
                    ),

                    //行間の幅調整
                    SizedBox(
                      height: 5,
                    ),

                    SizedBox(
                      height: 5,
                    ),

                    //登録ランク選択BOX
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 50,
                        ),
                        Container(
                            padding: const EdgeInsets.all(5.0),
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20)),
                            child: torokuAge == ''
                                ? Text(
                                    "年齢",
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.grey),
                                  )
                                : Text(
                                    torokuAge,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.black),
                                  )),
                        IconButton(
                          icon: Icon(Icons.arrow_drop_down_circle_rounded),
                          onPressed: () {
                            _showModalAgePicker(context);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () async{
                            // List<String> blockList = await FirestoreMethod.getBlockUserList(auth.currentUser!.uid);
                            todofuken == "" &&
                                    gender == "" &&
                                    torokuRank == "" &&
                                    torokuAge == "" &&
                                    inputShichouson.text == ""
                                ? showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                          title: Text("入力エラー!"),
                                          content: Text(
                                              "都道府県、性別、登録ランク、年齢、市町村のいずれかは入力してください"),
                                        ))
                                : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FindMultiResultPage(
                                          todofuken,
                                          inputShichouson.text,
                                          gender,
                                          torokuRank,
                                          torokuAge),
                                    ));
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
    // TODO: implement build
  }

  void _showModalLocationPicker(BuildContext context) {
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
    "",
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

  final List<String> _Rank = [
    "",
    "初級",
    "中級",
    "上級",
  ];

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
              children: _gender.map(_pickerItem).toList(),
              onSelectedItemChanged: _onSelectedGenderChanged,
            ),
          ),
        );
      },
    );
  }

  final List<String> _gender = [
    "",
    "男性",
    "女性",
    "その他",
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

  final List<String> _Age = [
    "",
    "10代",
    "20代",
    "30代",
    "40代",
    "50代",
    "60代",
    "70代",
    "80代",
    "90代",
  ];

  void _onSelectedLocationChanged(int index) {
    setState(() {
      todofuken = _Location[index];
    });
  }

  void _onSelectedRankChanged(int index) {
    setState(() {
      torokuRank = _Rank[index];
    });
  }

  void _onSelectedAgeChanged(int index) {
    setState(() {
      torokuAge = _Age[index];
    });
  }

  void _onSelectedGenderChanged(int index) {
    setState(() {
      gender = _gender[index];
    });
  }

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

// static String getRecord(){
//   return null;
// }
}
