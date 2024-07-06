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
            iconTheme: IconThemeData(color: Colors.black),
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
                                Text("現在のプラン", style: TextStyle(fontSize: 18))),
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
                                        style: TextStyle(
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
                                    child: Text("ベーシック(無料)",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.white))),
                              )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    appData.entitlementIsActive == true
                        ? Column(
                            children: [
                              Container(
                                width: deviceWidth * 0.95,
                                alignment: Alignment.centerLeft,
                                child: Text("TSPプレミアム",
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
                                              style: TextStyle(fontSize: 20))),
                                      Container(
                                        width: deviceWidth * 0.9,
                                        alignment: Alignment.bottomLeft,
                                        child: Text("チケット増量に加え、友人対戦管理機能も利用可能に！",
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
                                            child: Text(
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
                                child: Text("TSPプレミアム",
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
                                              style: TextStyle(fontSize: 20))),
                                      Container(
                                        width: deviceWidth * 0.9,
                                        alignment: Alignment.bottomLeft,
                                        child: Text("チケット増量に加え、友人対戦管理機能も利用可能に！",
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
                                            child: Text(
                                              "加入する",
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                            ),
                                          ),
                                          onTap: () async {
                                            try {
                                            //   //トーク上限数のリセット
                                            //   await FirebaseFirestore.instance
                                            //       .runTransaction(
                                            //           (transaction) async {
                                            //     //プレミアム会員登録時に、トークメッセージの上限数でリセット
                                            //     // 現在のタイムスタンプを取得
                                            //     Timestamp currentTimestamp =
                                            //         Timestamp.now();
                                            //
                                            //     // Firestoreのユーザードキュメントを更新してリセット
                                            //     DocumentReference
                                            //         userLimitMgmtDocRef =
                                            //         FirebaseFirestore.instance
                                            //             .collection(
                                            //                 'userLimitMgmt')
                                            //             .doc(FirestoreMethod
                                            //                 .auth
                                            //                 .currentUser!
                                            //                 .uid);
                                            //
                                            //     try {
                                            //       await transaction.set(
                                            //           userLimitMgmtDocRef,
                                            //           {
                                            //             'dailyMessageLimit':
                                            //             messagePremiumLimit,
                                            //             // リセット後のデフォルト上限を設定
                                            //             'lastResetTimestamp':
                                            //                 currentTimestamp,
                                            //           },
                                            //           SetOptions(merge: true));
                                            //     } catch (e) {
                                            //       throw ("メッセージ数のリセットに失敗しました $e");
                                            //     }
                                            //
                                            //     //プレミアム会員登録時に、チケットの上限数でリセット
                                            //     DocumentReference
                                            //         userTicketMgmDocRef =
                                            //         FirebaseFirestore.instance
                                            //             .collection(
                                            //                 'userTicketMgmt')
                                            //             .doc(FirestoreMethod
                                            //                 .auth
                                            //                 .currentUser!
                                            //                 .uid);
                                            //
                                            //     DateTime now = DateTime.now();
                                            //     DateFormat outputFormat =
                                            //         DateFormat('yyyy-MM-dd');
                                            //     String today =
                                            //         outputFormat.format(now);
                                            //     int zengetsuTicketSu = 0;
                                            //     DocumentSnapshot
                                            //         userTicketMgmDoc =
                                            //         await userTicketMgmDocRef
                                            //             .get();
                                            //
                                            //     if (userTicketMgmDoc.exists) {
                                            //       zengetsuTicketSu =
                                            //           userTicketMgmDoc[
                                            //               'zengetsuTicketSu'];
                                            //     }
                                            //     int ticketSuSum =
                                            //         ticketPremiumLimit +
                                            //             zengetsuTicketSu;
                                            //     //当月のプレミアム会員のチケット数だけ更新する
                                            //     try {
                                            //       transaction.set(
                                            //           userTicketMgmDocRef,
                                            //           {
                                            //             'ticketSu': ticketSuSum,
                                            //             'togetsuTicketSu':
                                            //                 ticketPremiumLimit,
                                            //             'zengetsuTicketSu':
                                            //                 zengetsuTicketSu,
                                            //             'ticketKoushinYmd':
                                            //                 today
                                            //           },
                                            //           SetOptions(merge: true));
                                            //       // throw ("エラー");
                                            //     } catch (e) {
                                            //       throw ("TSPプレミアム会員のチケット発行に失敗しました $e");
                                            //     }
                                            //   }).then(
                                            //           (value) => print(
                                            //               "DocumentSnapshot successfully updated!"),
                                            //           onError: (e) =>
                                            //               throw ("課金処理の更新に失敗しました $e"));
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
                // ListView.builder(
                //   itemCount: widget.offering.availablePackages.length,
                //   itemBuilder: (BuildContext context, int index) {
                //     var myProductList = widget.offering.availablePackages;
                //     color:
                //     Colors.black,
                //     child: ListTile(
                //     onTap: () async {
                //     try {
                //     bool beforeentitlementIsActive =
                //     appData.entitlementIsActive;
                //     CustomerInfo customerInfo =
                //     await Purchases.purchasePackage(
                //     myProductList[index]);
                //     EntitlementInfo? entitlement =
                //     customerInfo.entitlements.all[entitlementID];
                //     appData.entitlementIsActive =
                //     entitlement?.isActive ?? false;
                //     //トーク上限数のリセット
                //     print("beforeentitlementIsActive" +
                //     beforeentitlementIsActive.toString());
                //     print("entitlementIsActive" +
                //     appData.entitlementIsActive.toString());
                //
                //     if (beforeentitlementIsActive == false &&
                //     appData.entitlementIsActive == true) {
                //     await FirebaseFirestore.instance.runTransaction(
                //     (transaction) async {
                //     //プレミアム会員登録時に、トークメッセージの上限数でリセット
                //     await resetDailyMessageLimit(
                //     FirestoreMethod.auth.currentUser!.uid);
                //     //プレミアム会員登録時に、チケットの上限数でリセット
                //     await billingUpdateTicket(
                //     FirestoreMethod.auth.currentUser!.uid);
                //     }).then(
                //     (value) => print(
                //     "DocumentSnapshot successfully updated!"),
                //     onError: (e) =>
                //     throw ("課金処理の更新に失敗しました $e"));
                //     }
                //     } catch (e) {
                //     await showDialog(
                //     context: context,
                //     builder: (BuildContext context) =>
                //     ShowDialogToDismiss(
                //     content: e.toString(),
                //     buttonText: "はい",
                //     ));
                //     }
                //     setState(() {});
                //     Navigator.pop(context);
                //     },
                //     title: Text(
                //     myProductList[index].storeProduct.title,
                //     style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 18,
                //     ),
                //     ),
                //     subtitle: Text(
                //     myProductList[index].storeProduct.description,
                //     style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.normal,
                //     fontSize: 16,
                //     ).copyWith(fontSize: 10),
                //     ),
                //     trailing: Text(
                //     myProductList[index].storeProduct.priceString,
                //     style: TextStyle(
                //     color: Colors.white,
                //     fontWeight: FontWeight.bold,
                //     fontSize: 18.0,
                //     ))),
                //     );
                //   },
                //   shrinkWrap: true,
                //   physics: const ClampingScrollPhysics(),
                // ),
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
        // return Scaffold(
        //   appBar: AppBar(
        //       backgroundColor: HeaderConfig.backGroundColor,
        //       title: HeaderConfig.appBarText,
        //       iconTheme: IconThemeData(color: Colors.black),
        //       leading: HeaderConfig.backIcon),
        //   body: Column(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       ListTile(
        //         title: Text('プレミアムプランへ加入',
        //             style: TextStyle(fontSize: 20, color: Colors.black)),
        //         onTap: () async{
        //           final offerings = await Purchases.getOfferings();
        //           final product = offerings.current?.monthly?.storeProduct;
        //           final info = await Purchases.purchaseProduct('TSP0001'); // 1つのサブスクリプションプランしかない場合はproduct.idは固定文字列で指定しても問題ありません
        //
        //           final infoCus = await Purchases.getCustomerInfo();
        //           final isSubscribing = infoCus.entitlements.all['TSPプレミアムプラン']?.isActive == true;
        //
        //         },
        //       ),
        //     ],
        //   ),
        // );
        );
  }
  String parsePurchaseError(dynamic error) {
    if (error is PlatformException) {
      print(error.code);
      print(error.details);
      print(error.message);
      // プラットフォームのエラー
      switch (error.code) {
        case '8':
          return "購入が無効です。レシートに購入された商品が見つかりませんでした。";
        case 'storekit_invalid_purchase':
          return "購入が無効です。StoreKitのバグによる問題が発生しました。";
        case 'purchase_canceled':
          return "購入がキャンセルされました。";
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


