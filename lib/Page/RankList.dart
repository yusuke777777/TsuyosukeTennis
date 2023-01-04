import 'package:flutter/material.dart';

import 'manSinglesRankList.dart';

class RankList extends StatelessWidget {
  final _tab = <Tab>[
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.edit_sharp, size: 16),
          Text('初級',style: TextStyle(fontSize: 16),),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.app_registration, size: 16),
          Text('中級',style:TextStyle(fontSize: 16),),
        ],
      ),
    ),
    Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon(Icons.app_registration, size: 16),
          Text('上級',style:TextStyle(fontSize: 16),),
        ],
      ),
    ),
  ];

  @override
  int _screen = 0;

  TabPage(int curPage) {
    this._screen = curPage;
  }

  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: _screen,
      length: _tab.length,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: PreferredSize(
              preferredSize: Size.fromHeight(40.0),
              child: AppBar(
                title: Text("TSPランキング",
                    style: TextStyle(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 18,
                    )),
                iconTheme: const IconThemeData(
                  color: const Color(0xFFFFFFFF),
                ),
                backgroundColor: Color(0xFF3CB371),
                bottom: TabBar(
                  tabs: _tab,
                  labelColor: const Color(0xFFFFFFFF),
                  unselectedLabelColor: const Color(0xFFFFFFFF),
                  indicatorColor: const Color(0xFFFFFFFF),
                ),
              ),
            )),
        body: TabBarView(
          children: <Widget>[
            manSinglesRankList("ShokyuRank"),
            manSinglesRankList("ChukyuRank"),
            manSinglesRankList("JyokyuRank")
          ],
        ),
        drawer: Drawer(
            child: ListView(
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: 10.0)),
                Container(
                  height: 60.0,
                  child: DrawerHeader(
                    child: Text("メニュー"),
                    decoration: BoxDecoration(),
                  ),
                ),
                ListTile(
                  title: Text('利用規約同意書', style: TextStyle(color: Colors.black54)),
                  // onTap: _manualURL,
                ),
                ListTile(
                  title: Text('アプリ操作手順書', style: TextStyle(color: Colors.black54)),
                  // onTap: _FAQURL,
                )
              ],
            )),
      ),
    );
  }
}