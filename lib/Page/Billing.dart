import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/userLimitMgmt.dart';
import '../BillingThreshold.dart';
import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/singletons_data.dart';
import '../FireBase/urlMove.dart';
import '../FireBase/userTicketMgmt.dart';
import '../PropSetCofig.dart';
import '../constant.dart';
import 'package:intl/intl.dart';

class Billing extends StatefulWidget {
  final Package tspPlan;

  const Billing({Key? key, required this.tspPlan}) : super(key: key);

  @override
  State<Billing> createState() => _BillingState();
}

class _BillingState extends State<Billing> {
  @override
  void initState() {
    super.initState();
    print(widget.tspPlan);
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "有料プランへ加入");
    final deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
            backgroundColor: HeaderConfig.backGroundColor,
            title: HeaderConfig.appBarText,
            iconTheme: const IconThemeData(color: Colors.black),
            leading: HeaderConfig.backIcon),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Wrap(
              children: <Widget>[
                Column(
                  children: [
                    Column(
                      children: [
                        Container(
                            alignment: Alignment.bottomLeft,
                            width: deviceWidth * 0.95,
                            child:
                                const Text("現在のプラン", style: TextStyle(fontSize: 18))),
                        appData.entitlementIsActive == true
                            ? Card(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    width: deviceWidth * 0.9,
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                        widget.tspPlan.storeProduct.title,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white))),
                              )
                            : Card(
                                child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    width: deviceWidth * 0.9,
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    child: const Text("ベーシック(無料)",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white))),
                              )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    appData.entitlementIsActive == true
                        ? Column(
                            children: [
                              Container(
                                width: deviceWidth * 0.95,
                                alignment: Alignment.centerLeft,
                                child: const Text("TSPプレミアム",
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Card(
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                          width: deviceWidth * 0.9,
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                              widget.tspPlan.storeProduct.title,
                                              style: const TextStyle(fontSize: 20))),
                                      Container(
                                        width: deviceWidth * 0.9,
                                        alignment: Alignment.bottomLeft,
                                        child: const Text("チケット増量に加え、友人対戦管理機能も利用可能に！",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      Card(
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            width: deviceWidth * 0.5,
                                            height: 50,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "解約する",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          onTap: () async {
                                            //退会処理
                                            UrlMove().UrlMoving(
                                                'https://support.apple.com/ja-jp/118428');
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Container(
                                width: deviceWidth * 0.95,
                                alignment: Alignment.centerLeft,
                                child: const Text("TSPプレミアム",
                                    style: TextStyle(fontSize: 18)),
                              ),
                              Card(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Container(
                                          width: deviceWidth * 0.9,
                                          alignment: Alignment.bottomLeft,
                                          child: Text(
                                              widget.tspPlan.storeProduct.title,
                                              style: const TextStyle(fontSize: 20))),
                                      Container(
                                        width: deviceWidth * 0.9,
                                        alignment: Alignment.bottomLeft,
                                        child: const Text("チケット増量に加え、友人対戦管理機能も利用可能に！",
                                            style: TextStyle(fontSize: 18)),
                                      ),
                                      Card(
                                        child: InkWell(
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.greenAccent,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            width: deviceWidth * 0.5,
                                            height: 50,
                                            alignment: Alignment.center,
                                            child: const Text(
                                              "加入する",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          onTap: () async {
                                            try {
                                              //処理
                                              CustomerInfo customerInfo =
                                                  await Purchases
                                                      .purchasePackage(
                                                          widget.tspPlan);
                                              EntitlementInfo? entitlement =
                                                  customerInfo.entitlements
                                                      .all[entitlementID];
                                              appData.entitlementIsActive =
                                                  entitlement?.isActive ??
                                                      false;
                                              // //DBの課金フラグを更新する
                                              // await FirestoreMethod
                                              //     .updateBillingFlg();
                                              setState(() {});
                                            } catch (e) {
                                              // エラーの種類を確認
                                              String errorMessage = parsePurchaseError(e);
                                              await showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) =>
                                                          ShowDialogToDismiss(
                                                            content:
                                                            errorMessage,
                                                            buttonText: "はい",
                                                          ));
                                            }
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(
                      top: 32, bottom: 16, left: 16.0, right: 16.0),
                  child: SizedBox(
                    child: Text(
                      footerText,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                        fontSize: 16.0,
                      ),
                    ),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ),
        )
        );
  }
  @override
  void dispose() {
    // 必要なリソースを解放する処理をここに追加
    super.dispose();
  }

  String parsePurchaseError(dynamic error) {
    if (error is PlatformException) {
      print(error.code);
      print(error.details);
      print(error.message);
      // プラットフォームのエラー
      switch (error.code) {
        case '1': // purchaseCancelledError のコード
          return '購入がキャンセルされました。';
        case '2': // purchaseNotAllowedError のコード
          return 'このデバイスでは購入が許可されていません。';
        case '3': // purchaseInvalidError のコード
          return '無効な購入です。';
        case '4': // productNotAvailableForPurchaseError のコード
          return 'この商品は購入できません。';
        case '5': // networkError のコード
          return 'ネットワーク接続に失敗しました。後ほど再試行してください。';
        case '8':
          return "購入が無効です。レシートに購入された商品が見つかりませんでした。";
        case '15':
          return '購入処理中です';
        case 'purchase_canceled':
          return "購入がキャンセルされました。";
        case 'storekit_invalid_purchase':
          return "購入が無効です。StoreKitのバグによる問題が発生しました。";
        case 'PurchaseAlreadyOwnedError':
          return '既に他のアカウントで購入済みです';
        default:
          return "エラーが発生しました: ${error.message}";
      }
    } else {
      // その他のエラー
      return "予期しないエラーが発生しました。";
    }
  }

}


