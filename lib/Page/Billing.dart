import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../FireBase/singletons_data.dart';
import '../PropSetCofig.dart';
import '../constant.dart';

class Billing extends StatefulWidget {
  final Offering offering;
  const Billing({Key? key, required this.offering}) : super(key: key);

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
        body:SingleChildScrollView(
      child: SafeArea(
        child: Wrap(
          children: <Widget>[
            ListView.builder(
              itemCount: widget.offering.availablePackages.length,
              itemBuilder: (BuildContext context, int index) {
                var myProductList = widget.offering.availablePackages;
                return Card(
                  color: Colors.black,
                  child: ListTile(
                      onTap: () async {
                        try {
                          CustomerInfo customerInfo =
                          await Purchases.purchasePackage(
                              myProductList[index]);
                          EntitlementInfo? entitlement =
                          customerInfo.entitlements.all[entitlementID];
                          appData.entitlementIsActive =
                              entitlement?.isActive ?? false;
                        } catch (e) {
                          print(e);
                        }
                        setState(() {});
                        Navigator.pop(context);
                      },
                      title: Text(
                        myProductList[index].storeProduct.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        myProductList[index].storeProduct.description,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ).copyWith(
                            fontSize: 10),
                      ),
                      trailing: Text(
                          myProductList[index].storeProduct.priceString,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ))),
                );
              },
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
            ),
            const Padding(
              padding:
              EdgeInsets.only(top: 32, bottom: 16, left: 16.0, right: 16.0),
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
}
