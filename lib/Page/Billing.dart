import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            onTap: () {
              //利用規約を記入する
            },
          ),
        ],
      ),
    );
  }
}
