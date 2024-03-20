import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../Component/native_dialog.dart';
import '../FireBase/FireBase.dart';
import '../FireBase/singletons_data.dart';
import '../PropSetCofig.dart';
import 'HomePage.dart';

class QrScanView extends StatefulWidget {
  const QrScanView({Key? key}) : super(key: key);

  @override
  _QrScanViewState createState() => _QrScanViewState();
}

class _QrScanViewState extends State<QrScanView> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
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
          iconTheme: IconThemeData(color: Colors.black),
          leading: HeaderConfig.backIcon),
      body: _buildQrView(context),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
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
    //一度スキャンした相手のQRコードは読み込まない
    //カメラを再起動することで読取可能
    List matchdList = [];
    setState(() {
      this.controller = controller;
    });
    //読み込み時の処理
    controller.scannedDataStream.listen((scanData) async {
      //読み込んだ相手のID
      String yourId = scanData.code!;
      if (!matchdList.contains(yourId)) {
        try {
          String ticketFlg = await FirestoreMethod.makeMatchByQrScan(yourId);
          if (ticketFlg == "0") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('マッチング完了！')),
            );
            matchdList.add(yourId);
          } else if (ticketFlg == "1") {
            if (appData.entitlementIsActive == true) {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) => ShowDialogToDismiss(
                        content: "チケットが不足しています。",
                        buttonText: "はい",
                      ));
            } else {
              await showDialog(
                  context: context,
                  builder: (BuildContext context) => BillingShowDialogToDismiss(
                      content: "チケットが不足しています。有料プランを確認しますか"));
            }
          } else {
            await showDialog(
                context: context,
                builder: (BuildContext context) => ShowDialogToDismiss(
                      content: "対戦相手のチケットが不足しています。",
                      buttonText: "はい",
                    ));
          }
        } catch (e) {
          await showDialog(
              context: context,
              builder: (BuildContext context) => ShowDialogToDismiss(
                    content: e.toString(),
                    buttonText: "はい",
                  ));
        }
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission')),
      );
    }
  }
}
