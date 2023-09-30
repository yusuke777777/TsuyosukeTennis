import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';

import '../Common/CTitle.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'package:yaml/yaml.dart';

class MyTitlePage extends StatelessWidget {
  // Title.yamlに記載されている全ての称号を取得
  late List<CTitle> titles = [];
  late CTitle title;

  /**
   * Title.yamlに記載されている称号を全て取得
   */
  Future<List<CTitle>> loadTitles() async {
    final String yamlString = await rootBundle.loadString('assets/Title.yaml');
    final List<dynamic> yamlList = loadYaml(yamlString);
    Map<String, dynamic> map = await FirestoreMethod.getMyTitle();
    for (var item in yamlList) {
      int no = item['no'];
      String name = item['name'];
      String description = item['description'];
      title = CTitle(
          no:no,
          name: name,
          description: description,
          status: map[item['no'].toString()].toString());
      titles.add(title);
    }
    return titles;
  }

  @override
  Widget build(BuildContext context) {
    Future<List<CTitle>> futureList = loadTitles();
    HeaderConfig().init(context, "取得称号一覧");
    DrawerConfig().init(context);
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: FutureBuilder(
          future: futureList,
          builder:
              (BuildContext context, AsyncSnapshot<List<CTitle>> snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return new Align(
                  child: Center(
                child: new CircularProgressIndicator(),
              ));
            } else if (snapshot.hasError) {
              return new Text('Error!!: ${snapshot.error!}');
            } else if (snapshot.hasData) {
              List<CTitle>? titleList = snapshot.data;
              return ListView.builder(
                itemCount: titleList?.length,
                itemBuilder: (context, index) {
                  final title = titles[index];
                  return ListTile(
                      title: Text(title.name),
                      subtitle: Text(title.description),
                      tileColor:
                          title.status == "1" || title.status == "2"? Colors.white : Colors.grey,
                      trailing: title.status == "1" || title.status == "2"
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.green,
                              ),
                              onPressed: () {
                                // ボタンが押されたときの処理
                                FirestoreMethod.changeTitle(title.no);
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      content: Text(
                                          "称号を設定しました"),
                                      actions: <Widget>[
                                        // OKボタン
                                        TextButton(
                                          child: Text('OK'),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => HomePage(),
                                                ));// ダイアログを閉じる
                                          },
                                        ),
                                      ],
                                    )
                                );
                              },
                              child: Text('設定'),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.grey,
                              ),
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: Text("エラー"),
                                      content: Text(
                                          "取得していない称号は設定できません"),
                                    ));
                              },
                              child: Text('設定'),
                            ));
                },
              );
            } else {
              return Text("データが存在しません");
            }
          }),
    );
  }
}
