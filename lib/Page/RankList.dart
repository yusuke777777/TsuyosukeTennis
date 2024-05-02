import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../FireBase/GoogleAds.dart';
import '../PropSetCofig.dart';
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
    //必要コンフィグの初期化
    HeaderConfig().init(context, "TSPランキング");
    DrawerConfig().init(context);
    return DefaultTabController(
      initialIndex: _screen,
      length: _tab.length,
      child: Scaffold(
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(80.0),
            child: PreferredSize(
              preferredSize: Size.fromHeight(40.0),
              child: AppBar(
                backgroundColor: HeaderConfig.backGroundColor,
                title: HeaderConfig.appBarText,
                iconTheme: IconThemeData(color: Colors.black),
                bottom: TabBar(
                  tabs: _tab,
                  labelColor: Colors.black,
                  unselectedLabelColor: Colors.black,
                  indicatorColor: Colors.black,
                ),
              ),
            )),
        body: Stack(
          children: [
            Container(alignment:Alignment.center,height: 40, child: AdBanner(size: AdSize.banner)),
            Padding(
              padding: EdgeInsets.only(top: 40),
              child: TabBarView(
                children: <Widget>[
                  manSinglesRankList("ShokyuRank"),
                  manSinglesRankList("ChukyuRank"),
                  manSinglesRankList("JyokyuRank")
                ],
              ),
            ),
          ],
        ),
        drawer: DrawerConfig.drawer,
      ),
    );
  }
}