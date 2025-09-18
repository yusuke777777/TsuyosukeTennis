import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:tsuyosuke_tennis_ap/Page/MatchList.dart';

import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/singletons_data.dart';
import '../PropSetCofig.dart';
import '../UnderMenuMove.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({Key? key}) : super(key: key);

  @override
  _QrScanViewState createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  bool isProcessing = false; // 処理が進行中かどうかを管理するフラグ
  final MobileScannerController controller = MobileScannerController();
  List<String> matchdList = [];


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "QR読み取り");
    return Scaffold(
      appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return MobileScanner(
      controller: controller,
      onDetect: (capture) async {
        final List<Barcode> barcodes = capture.barcodes;
        if (isProcessing) return;

        if (barcodes.isNotEmpty) {
          final barcode = barcodes.first;
          if (barcode.rawValue == null) {
            return;
          }
          String yourId = barcode.rawValue!;

          if (!matchdList.contains(yourId)) {
            setState(() {
              isProcessing = true;
            });
            try {
              String ticketFlg = await FirestoreMethod.makeMatchByQrScan(yourId);
              if (ticketFlg == "0") {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('マッチング完了.\n試合終了後に対戦結果を入力しよう！'),duration: const Duration(seconds: 10),) // 表示時間を10秒に設定),
                );
                matchdList.add(yourId);

                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UnderMenuMove.make(2)
                      ));
                }
              } else if (ticketFlg == "1") {
                if (appData.entitlementIsActive == true || Platform.isAndroid) {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => const ShowDialogToDismiss(
                      content: "チケットが不足しています。",
                      buttonText: "はい",
                    ),
                  );
                } else {
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => const BillingShowDialogToDismiss(
                      content: "チケットが不足しています。有料プランを確認しますか",
                    ),
                  );
                }
              } else {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) => const ShowDialogToDismiss(
                    content: "対戦相手のチケットが不足しています。",
                    buttonText: "はい",
                  ),
                );
              }
            } catch (e) {
              await showDialog(
                context: context,
                builder: (BuildContext context) => const ShowDialogToDismiss(
                  content: "QRコードの読み取りに失敗しました",
                  buttonText: "はい",
                ),
              );
            } finally {
              // 少し待ってからスキャンを再開
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  setState(() {
                    isProcessing = false;
                  });
                }
              });
            }
          }
        }
      },
    );
  }
}