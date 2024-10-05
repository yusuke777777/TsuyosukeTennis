import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:tsuyosuke_tennis_ap/Page/ProfileReference.dart';

import '../Common/CblockList.dart';
import '../Common/CfriendsList.dart';
import '../Common/CtalkRoom.dart';
import '../Common/CticketList.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/userTicketMgmt.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';
import 'ProfileSetting.dart';
import 'TalkRoom.dart';

/**
 * チケット管理画面です
 */
class TicketList extends StatefulWidget {
  const TicketList({Key? key}) : super(key: key);

  @override
  State<TicketList> createState() => _TicketListState();
}

class _TicketListState extends State<TicketList> {
  late CTicketModel myTicketSuList;

  Future<void> createTicketList() async {
    myTicketSuList = await getTicketSu(FirestoreMethod.auth.currentUser!.uid);
  }

  @override
  void dispose() {
    // 必要なリソースがあればここで解放する
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    HeaderConfig().init(context, "チケット管理");

    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: FutureBuilder(
          future: createTicketList(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(5),
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.greenAccent,
                          style: BorderStyle.solid,
                          width: 3),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 5),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                              "総チケット数： " + myTicketSuList.TICKET_SU.toString(),
                              style: TextStyle(fontSize: 20)),
                        ),
                        Container(
                            padding: EdgeInsets.only(left: 20),
                            alignment: Alignment.bottomLeft,
                            child: Text(
                                "当月発行チケット数： " +
                                    myTicketSuList.TOGETSU_TICKET_SU.toString(),
                                style: TextStyle(fontSize: 15))),
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          alignment: Alignment.bottomLeft,
                          child: Text(
                              "前月発行チケット数： " +
                                  myTicketSuList.ZENGETSU_TICKET_SU.toString(),
                              style: TextStyle(fontSize: 15)),
                        )
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(left: 5),
                        child: Text('・チケット管理ルール',style: TextStyle(fontSize: 20),),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '・毎月1日に入会しているプランに応じてチケット発行されます',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '・毎月1日に前月発行チケットは失効されます',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        alignment: Alignment.bottomLeft,
                        child: Text(
                          '・1試合のマッチングに付き、両者から1枚チケットが使用されます',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  )
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
