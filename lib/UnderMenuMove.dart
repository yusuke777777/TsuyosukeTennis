import 'package:flutter/material.dart';
import 'package:tsuyosuke_tennis_ap/Page/FindPage.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import 'Page/MatchList.dart';
import 'Page/RankList.dart';
import 'Page/TalkList.dart';
import 'Page/manSinglesRankList.dart';

/**
 * 下部メニューの動きを制御するクラス
 */
class UnderMenuMove extends StatefulWidget {
  const UnderMenuMove({Key? key}) : super(key: key);

  @override
  State<UnderMenuMove> createState() => _UnderMenuMoveState();
}

class _UnderMenuMoveState extends State<UnderMenuMove> {
  static final _screens = [
    HomePage(),
    FindPage(),
    MatchList(),
    TalkList(),
    RankList(),

  ];
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'ホーム'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: '検索'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard), label: 'マッチ'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble), label: 'トーク'),
            BottomNavigationBarItem(icon: Icon(Icons.star), label: 'ランク'),
          ],
          type: BottomNavigationBarType.fixed,
        ));
  }
}