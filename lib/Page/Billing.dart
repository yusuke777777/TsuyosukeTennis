import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../PropSetCofig.dart';

class Billing extends StatefulWidget {
  const Billing({Key? key}) : super(key: key);

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "有料プランへ加入");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('プレミアムプランへ加入',
                style: TextStyle(fontSize: 20, color: Colors.black)),
            onTap: () async{
              final offerings = await Purchases.getOfferings();
              final product = offerings.current?.monthly?.storeProduct;
              final info = await Purchases.purchaseProduct('TSP0001'); // 1つのサブスクリプションプランしかない場合はproduct.idは固定文字列で指定しても問題ありません
            },
          ),
        ],
      ),
    );
  }
}
