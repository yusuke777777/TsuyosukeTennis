import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'ProfileSetting.dart';

class Explain extends StatefulWidget {
  @override
  _ExplainState createState() => _ExplainState();
}

class _ExplainState extends State<Explain> {
  final PageController controller = PageController();
  int currentPage = 0; // 現在のページ番号を保持する変数

  final List<String> imageList = [
    'images/ホーム.png',
    'images/結果入力.png',
    'images/ポイント反映.png',
    'images/ランキング.png',
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        currentPage = controller.page!.round(); // ページ番号を更新
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            children: imageList.map((image) {
              return Image.asset(
                image,
                width: deviceWidth,
                height: deviceHeight,
              );
            }).toList(),
          ),
          Positioned(
            top: deviceHeight * 0.1,
            right: deviceWidth * 0.09,
            child: currentPage == 3 // 3枚目（ポイント反映）の時だけ完了ボタンを表示
                ? ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSetting.Make()),
                );
              },
              child: const Text(
                '完了', // ボタンの文字を「完了」にする
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            )
                : ElevatedButton( // それ以外のページでは「スキップ」ボタンを表示
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileSetting.Make()),
                );
              },
              child: const Text(
                'スキップ',
                style: TextStyle(
                  color: Colors.green,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: deviceHeight * 0.1,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.center,
              child: SmoothPageIndicator(
                controller: controller,
                count: imageList.length,
                effect: const ExpandingDotsEffect(
                  activeDotColor: Colors.green,
                  dotColor: Colors.grey,
                  spacing: 5.0,
                  radius: 8.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}