import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/urlMove.dart';
import '../PropSetCofig.dart';
import 'Billing.dart';
import 'UnsubscribePage.dart';

class MySetting extends StatefulWidget {
  const MySetting({Key? key}) : super(key: key);

  @override
  State<MySetting> createState() => _MySettingState();
}

class _MySettingState extends State<MySetting> {
  @override
  void initState() {
    super.initState();
    FirestoreMethod.getReviewFeatureEnabled().then((enabled) {
      setState(() {
        FirestoreMethod.reviewFeatureEnabled = enabled;
      });
    });
    FirestoreMethod.getSearchFeatureEnabled().then((enabled2) {
      setState(() {
        FirestoreMethod.searchFeatureEnabled = enabled2;
      });
    });
  }

  @override
  void dispose() {
    super.dispose(); // 親クラスのdisposeを呼び出す
  }


  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "設定");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Scrollbar(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text('利用規約',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //利用規約を記入する
                  UrlMove().UrlMoving(
                  'https://spectacled-lan-4ae.notion.site/a20f927123de4185bf444025d095e525?pvs=4');
                },
              ),
              ListTile(
                title: Text('プライバシーポリシー',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //プライバシーポリシーを記入する
                  UrlMove().UrlMoving(
                      'https://spectacled-lan-4ae.notion.site/09dca252ef2e4ba7bd692f1e0228acc1?pvs=4');
                },
              ),
              ListTile(
                title: Text('問い合わせ',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  //問い合わせホームを作成する
                  UrlMove().UrlMoving('https://docs.google.com/forms/d/e/1FAIpQLSfxw77z17RwulR7oXD146E1XaxARDFIjd25nDg7l7dFH9A1bQ/viewform');
                },
              ),
              ListTile(
                title: Text('Follow us!!',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  UrlMove().UrlMoving('https://x.com/tsuyosuke7');
                  //つよすけテニスチャンネルのフォロー？
                },
              ),
              ListTile(
                title: Text('ライセンス',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'テニポイ',
                    applicationVersion: '1.0.0',
                  );
                },
              ),
              ListTile(
                title: Text('有料プランへの加入',
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () async {
                  final offerings = await Purchases.getOfferings();
                  print(offerings.current); // コンソールでcurrentに設定しているやつ
                  print(offerings.all); // Offeringすべて
                  print(offerings.current?.monthly?.storeProduct
                      .priceString); // '¥120' みたいなのが取得できます
                  if (offerings == null || offerings.current == null) {
                    // offerings are empty, show a message to your user
                  } else {
                    Package? tspPlan = offerings!.current?.monthly;
                    print(tspPlan);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Billing(tspPlan: tspPlan!)),
                    );
                  }
                },
              ),
              ListTile(
                title: Text("レビュー機能（OFF/ON）",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                trailing: CupertinoSwitch(
                  value: FirestoreMethod.reviewFeatureEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      FirestoreMethod.reviewFeatureEnabled = value ?? true;
                      FirestoreMethod.putReviewFeatureEnabled(
                          FirestoreMethod.reviewFeatureEnabled);
                    });
                  },
                ),
              ),
              ListTile(
                title: Text("マルチ検索機能（OFF/ON）",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                trailing: CupertinoSwitch(
                  value: FirestoreMethod.searchFeatureEnabled,
                  onChanged: (bool? value) {
                    setState(() {
                      FirestoreMethod.searchFeatureEnabled = value ?? true;
                      FirestoreMethod.putSearchFeatureEnabled(
                          FirestoreMethod.searchFeatureEnabled);
                    });
                  },
                ),
              ),
              ListTile(
                title:
                    Text('退会', style: TextStyle(fontSize: 20, color: Colors.black)),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnsubscribePage(),
                      ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
