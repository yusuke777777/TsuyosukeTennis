import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FindResultPage.dart';
class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  State<FindPage> createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  //都道府県
  late String todofuken = '東京都';
  //登録ランク
  late String torokuRank = 'ランクを入力を選択してください';
  //年齢
  late String torokuAge = '年齢を選択してください';

  //アカウントIDで検索BOXに入力された値
  final inputId = TextEditingController();

  MaterialColor colorstate = Colors.green;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //appBarの背景色等設定
          leading: const Icon(Icons.menu,
              color:Colors.black),
          elevation: 0.0,
          backgroundColor: Colors.white,
          shadowColor:Colors.white,

          title: const Text("検索",
          style: TextStyle(
            color:Colors.black,
            fontSize: 30,
          ),
        ),
    ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('アカウントIDで検索',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 5,
            ),
            //アカウントID入力欄
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 60,
                ),
                Container(
                  alignment: Alignment.bottomRight,
                  width: 200,
                  height: 40,
                  child:TextFormField(
                    controller: inputId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.vertical()
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            //検索ボタン
            Align(
              alignment: const Alignment(0.8, 0.1),
              child: TextButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  onPrimary: Colors.white,
                ),
                //検索ボタン押下時の処理
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindResultPage(inputId.text),
                      )
                  );
                },
                child: Text('検索'),
              ),
            ),

            Text('条件で検索',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(
                height: 5
            ),

            //都道府県タイトル
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

            //都道府県選択BOX
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        todofuken,
                        style: TextStyle(fontSize: 20, color: Colors.black),
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

            //市町村タイトル
            Row(
              children: [
                SizedBox(
                  width: 50,
                ),
                Container(
                  child: Text(
                    '市町村(任意)',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
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
                  child:TextFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.vertical()
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),

            //行間の幅調整
            SizedBox(
              height: 5,
            ),

            //登録ランクタイトル
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 50,
                  ),
                  Container(
                    child: Text(
                      '登録ランク',
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ],
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

            //行間の幅調整
            SizedBox(
              height: 5,
            ),

            //年齢
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                ),
                Container(
                  child: Text(
                    '年齢',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ],
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
                  width: 250,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(
                    torokuAge,
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

            const SizedBox(
              height: 16,
            ),

            //検索ボタン
            Align(
              alignment: const Alignment(0.8, 0.1),
              child: TextButton(
                style: ElevatedButton.styleFrom(

                  primary: Colors.orange,
                  onPrimary: Colors.white,
                ),
                //検索ボタン押下時の処理
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FindResultPage(inputId.text),
                      )
                  );
                },
                child: Text('検索'),
              ),
            ),
          ],
        ),
      ),
    );
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
    "初級",
    "中級",
    "上級",
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
    "16",
    "17",
    "18",
    "19",
    "20",
    "21",
    "22",
    "23",
    "24",
    "25",
    "26",
    "27",
    "28",
    "29",
    "30",
    "31",
    "32",
    "33",
    "34",
    "35",
    "36",
    "37",
    "38",
    "39",
    "40",
    "41",
    "42",
    "43",
    "44",
    "45",
    "46",
    "47",
    "48",
    "49",
    "50",
    "51",
    "52",
    "53",
    "54",
    "55",
    "56",
    "57",
    "58",
    "59",
    "60",
    "61",
    "62",
    "63",
    "64",
    "65",
    "66",
    "67",
    "68",
    "69",
    "70",
    "71",
    "72",
    "73",
    "74",
    "75",
    "76",
    "77",
    "78",
    "79",
    "80",
    "81",
    "82",
    "83",
    "84",
    "85",
    "86",
    "87",
    "88",
    "89",
    "90",
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