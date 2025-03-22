import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false; // 処理が進行中かどうかを管理するフラグ

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    }
    controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
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
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.green,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  /**
   * QRコードを起動した時の動き
   */
  void _onQRViewCreated(QRViewController controller) {
    List matchdList = [];
    setState(() {
      this.controller = controller;
    });

    // 読み込み時の処理
    controller.scannedDataStream.listen((scanData) async {
      // 既に処理中なら何もしない
      if (isProcessing) return;

      String yourId = scanData.code!;

      // まだ処理していないIDの場合のみ進む
      if (!matchdList.contains(yourId)) {
        // カメラを停止して、処理が複数回呼ばれないようにする
        controller.pauseCamera();
        isProcessing = true;
        try {
          String ticketFlg = await FirestoreMethod.makeMatchByQrScan(yourId);
          if (ticketFlg == "0") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('マッチング完了。\n試合終了後に対戦結果を入力しよう！'),duration: const Duration(seconds: 10),) // 表示時間を10秒に設定),
            );
            matchdList.add(yourId);

            // マッチングが完了したらカメラ画面を閉じる
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
          isProcessing = false;
          if (mounted) {
            controller.resumeCamera();
          }
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('権限がありません')),
      );
    }
  }
}
