import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileSetting extends StatefulWidget {
  @override
  _ProfileSettingState createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  //プロフィール画像  画像を登録できるようにする
  late String profileImage = 'images/ans_032.jpg';

  //ニックネーム
  late String nickName = '名前を入力してください';

  //登録ランク
  late List<String> torokuRank = ['名前を入力してください'];

  //都道府県
  late List<String> todofuken = ['東京都'];

  //市町村
  late TextEditingController shichoson = TextEditingController();

  //都道府県登録数Index
  int todofukenTourokuNo = 0;

  //コメント
  var coment = TextEditingController();

  List<Widget> contentWidgets = [];

  @override
  void initState() {
    super.initState();
    _makeWidgets(todofukenTourokuNo);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Scrollbar(
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
                    child: Text(
                      nickName,
                      style: TextStyle(fontSize: 25, color: Colors.black),
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
                        torokuRank[0],
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
                        '●主な活動場所',
                        style: TextStyle(fontSize: 25, color: Colors.black),
                      ),
                    ),
                  ],
                ),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: contentWidgets),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        //登録Noを更新
                        todofukenTourokuNo = todofukenTourokuNo + 1;
                        //都道府県リスト追加
                        todofuken.add("東京都");
                        //都道府県ウィジェット追加
                        _makeWidgets(todofukenTourokuNo);
                        print(todofuken[todofukenTourokuNo] );
                        setState(() {});
                      },
                    ),
                    SizedBox(
                      width: 40,
                    ),
                  ],
                ),
              ]),
            ],
          ),
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

  Widget _pickerItem(String str) {
    return Text(
      str,
      style: const TextStyle(fontSize: 20),
    );
  }

  void _onSelectedLocationChanged(int index) {
    todofuken[todofukenTourokuNo] = _Location[index];
    print(todofuken[todofukenTourokuNo] );
    print(todofukenTourokuNo);
    setState(() {
    });
  }

  void _onSelectedRankChanged(int index) {
    setState(() {
      torokuRank[0] = _Rank[index];
    });
  }

  List<Widget> _makeWidgets(int todofukenTourokuNoWk) {
    contentWidgets.add(
      Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 50,
              ),
              Container(
                child: Text(
                  '都道府県',
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
                ),
                child: Text(
                  todofuken[todofukenTourokuNoWk],
                  style: TextStyle(fontSize: 20, color: Colors.black),
                ),
              ),
              IconButton(
                icon: Icon(Icons.arrow_drop_down_circle_rounded),
                onPressed: () {
                  _showModalLocationPicker(context);
                  setState(() {
                  });
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
                  ),
                  child: TextField(
                    controller: shichoson,
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ))
            ],
          ),
        ],
      ),
    );
    return contentWidgets;
  }
}
