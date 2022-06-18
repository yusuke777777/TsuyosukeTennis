import 'package:flutter/material.dart';
class FindPage extends StatefulWidget {
  const FindPage({Key? key}) : super(key: key);

  @override
  State<FindPage> createState() => _FindPageState();

}

class _FindPageState extends State<FindPage> {
  String? isSelectedItem = null;
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
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            TextField(
              decoration: InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: const Alignment(1.0, 0.1),
              child: TextButton(
                style: ElevatedButton.styleFrom(

                  primary: Colors.orange,
                  onPrimary: Colors.white,
                ),
                onPressed: () {},
                child: Text('検索'),
              ),
            ),

            Text('条件で検索',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

        SizedBox(
          width: 300,
            //都道府県ドロップダウン
            child:DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: '都道府県',
              ),
              //ドロップダウンの中身
              items: const [
                DropdownMenuItem(
                  child: Text('北海道'),
                  value: '北海道',
                ),
                DropdownMenuItem(
                  child: Text('東京'),
                  value: '青森',
                ),
                DropdownMenuItem(
                  child: Text('沖縄'),
                  value: '沖縄',
                ),
              ],
              onChanged: (String? value) {
              setState(() {
                isSelectedItem = value;
              });
            },
              //7
              value: isSelectedItem,
              isExpanded: true,
              //6

            ),
        ),
            const SizedBox(
              height: 32,
            ),

            //市町村
            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  labelText: "市町村(任意)"),
            ),

            const SizedBox(height: 16),

            TextField(
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  labelText: "年齢"),
            ),

            // Text('　種別(複数選択可)',
            //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            // const SizedBox(height: 16),
            //
            // TextButton(
            //   child: Text('シングルス'),
            //   onPressed: () {},
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states){
            //   if (states.contains(MaterialState.pressed)) {
            //     if(colorstate ==Colors.green){
            //       colorstate = Colors.pink;
            //     }
            //     else{
            //       colorstate =Colors.green;
            //     }
            //   }
            //   return colorstate; //タップ中の色
            //   },
            //   ),
            //   ),
            // ),
            //
            // TextButton(
            //   child: Text('ダブルス'),
            //   onPressed: () {},
            //   style: ButtonStyle(
            //     backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states){
            //       if (states.contains(MaterialState.pressed)) {
            //         if(colorstate ==Colors.green){
            //           colorstate = Colors.pink;
            //         }
            //         else{
            //           colorstate =Colors.green;
            //         }
            //       }
            //       return colorstate; //タップ中の色
            //     },
            //     ),
            //   ),
            // )
          ],
        ),
      ),
    );

    // TODO: implement build
  }

}