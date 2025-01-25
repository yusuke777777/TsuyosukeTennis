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
          child: Column(
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
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(10.0)),
                              width: deviceWidth * 0.9,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              child: Text(widget.tspPlan.storeProduct.title,
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white))),
                        )
                      : Card(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.greenAccent,
                                  borderRadius: BorderRadius.circular(10.0)),
                              width: deviceWidth * 0.9,
                              height: 50,
                              alignment: Alignment.centerLeft,
                              child: const Text("ベーシック(無料)",
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.white))),
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
                          child: Row(
                            children: [
                              const Text("TSPプレミアム",
                                  style: TextStyle(fontSize: 18)),
                              TextButton(
                                  onPressed: () {
                                    //TSPプレミアムプランの説明へ
                                  },
                                  child: Text(
                                    "（機能の詳細はこちら）",
                                    style: TextStyle(fontSize: 18),
                                  ))
                            ],
                          ),
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
                                  child: const Text("初月無料キャンペーン実施中！！\nチケット増量に加え、友人対戦管理機能も利用可能に！",
                                      style: TextStyle(fontSize: 18)),
                                ),
                                Column(
                                  children: [
                                    Card(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          width: deviceWidth * 0.5,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "加入済み",
                                            style: TextStyle(
                                                fontSize: 18, color: Colors.white),
                                          ),
                                        ),
                                    ),
                                    Card(
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                              BorderRadius.circular(10.0)),
                                          width: deviceWidth * 0.5,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "復元する",
                                            style: TextStyle(
                                                fontSize: 18, color: Colors.white),
                                          ),
                                        ),
                                        onTap: () async {
                                          try {
                                            //復元する
                                            CustomerInfo customerInfo = await Purchases.restorePurchases();
                                            EntitlementInfo? entitlement =
                                            customerInfo.entitlements
                                                .all[entitlementID];
                                            appData.entitlementIsActive =
                                                entitlement?.isActive ?? false;
                                            setState(() {});
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
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
                          child: Row(
                            children: [
                              const Text("TSPプレミアム",
                                  style: TextStyle(fontSize: 18)),
                              TextButton(
                                  onPressed: () {
                                    //TSPプレミアムプランの説明へ
                                    UrlMove().UrlMoving(
                                        'https://spectacled-lan-4ae.notion.site/TSP-17204101f8a580479b20d62abb95f15a?pvs=4');
                                  },
                                  child: Text(
                                    "（機能の詳細はこちら）",
                                    style: TextStyle(fontSize: 18),
                                  ))
                            ],
                          ),
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
                                  child: const Text("初月無料キャンペーン実施中！！\nチケット増量に加え、友人対戦管理機能も利用可能に！",
                                      style: TextStyle(fontSize: 18)),
                                ),
                                Column(
                                  children: [
                                    Card(
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          width: deviceWidth * 0.5,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "加入する",
                                            style: TextStyle(
                                                fontSize: 18, color: Colors.white),
                                          ),
                                        ),
                                        onTap: () async {
                                          try {
                                            //処理
                                            CustomerInfo customerInfo =
                                                await Purchases.purchasePackage(
                                                    widget.tspPlan);
                                            EntitlementInfo? entitlement =
                                                customerInfo.entitlements
                                                    .all[entitlementID];
                                            appData.entitlementIsActive =
                                                entitlement?.isActive ?? false;
                                            // //DBの課金フラグを更新する
                                            // await FirestoreMethod
                                            //     .updateBillingFlg();
                                            setState(() {});
                                          } catch (e) {
                                            // エラーの種類を確認
                                            String errorMessage =
                                                parsePurchaseError(e);
                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext context) =>
                                                    ShowDialogToDismiss(
                                                      content: errorMessage,
                                                      buttonText: "はい",
                                                    ));
                                          }
                                        },
                                      ),
                                    ),
                                    Card(
                                      child: InkWell(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Colors.greenAccent,
                                              borderRadius:
                                              BorderRadius.circular(10.0)),
                                          width: deviceWidth * 0.5,
                                          height: 50,
                                          alignment: Alignment.center,
                                          child: const Text(
                                            "復元する",
                                            style: TextStyle(
                                                fontSize: 18, color: Colors.white),
                                          ),
                                        ),
                                        onTap: () async {
                                          try {
                                            //復元する
                                            CustomerInfo customerInfo = await Purchases.restorePurchases();
                                            EntitlementInfo? entitlement =
                                            customerInfo.entitlements
                                                .all[entitlementID];
                                            appData.entitlementIsActive =
                                                entitlement?.isActive ?? false;
                                            setState(() {});
                                          } catch (e) {
                                            // エラーの種類を確認
                                            String errorMessage =
                                            parsePurchaseError(e);
                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext context) =>
                                                    ShowDialogToDismiss(
                                                      content: errorMessage,
                                                      buttonText: "はい",
                                                    ));
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
              SizedBox(
                height: 40,
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "●自動継続課金について",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "有料プランは毎月自動更新されます。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "自動更新の課金は契約期間が終了する前の24時間以内に行われます。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "期間終了の24時間前までに自動更新の解除をされない場合、契約期間が自動更新されます。",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "●確認と解約",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "1.設定アプリ＞「ユーザー名」＞「サブスクリプション」の順にタップします。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "2.変更したいサブスクリプションをタップします。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "3.この画面から次回の自動更新のタイミングの確認や自動更新の解除ができます。",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "●機種変更時の復元",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "機種変更時には、以前購入したプランを復元できます。購入時と同じApple IDで端末にログインの上、「復元する」ボタンを押してください。",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "●注意点",
                      style: TextStyle(fontSize: 14),
                    ),
                    Text(
                      "当月分のキャンセルについては受け付けておりません。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "Apple IDを経由して課金されます。",
                      style: TextStyle(fontSize: 12),
                    ),
                    Text(
                      "無料トライアル期間が終了するまでに解約しない場合、自動的に有料プランが開始されます。",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    TextButton(
                      onPressed: () {
                        //利用規約へ
                        UrlMove().UrlMoving(
                            'https://spectacled-lan-4ae.notion.site/a20f927123de4185bf444025d095e525?pvs=4');
                      },
                      child: const Text(
                        "利用規約",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        //プライバシーポリシーへ
                        UrlMove().UrlMoving(
                            'https://spectacled-lan-4ae.notion.site/09dca252ef2e4ba7bd692f1e0228acc1?pvs=4');
                      },
                      child: const Text(
                        "プライバシーポリシー",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
              ),
            ],
          ),
        ));
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
