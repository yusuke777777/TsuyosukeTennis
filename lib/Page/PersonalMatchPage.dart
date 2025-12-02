import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../PropSetCofig.dart';
import 'PersonalMatchRecordPage.dart';
import 'QrScanView.dart';

class PersonalMatchPage extends StatelessWidget {
  const PersonalMatchPage({Key? key}) : super(key: key);

  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "個人対戦");
    DrawerConfig().init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: HeaderConfig.backIcon,
      ),
      drawer: DrawerConfig.drawer,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'QRコードをスキャンし予定一覧に追加してください',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                  const SizedBox(height: 16),
                  QrImageView(
                    data: auth.currentUser!.uid,
                    version: QrVersions.auto,
                    foregroundColor: Colors.green,
                    embeddedImage: Image.network('https://illustimage.com/photo/463.png').image,
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(20, 20),
                    ),
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                    size: 120.0,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrScanView(),
                          ));
                    },
                  ),
                  const SizedBox(height: 24),
                  const FittedBox(
                    alignment: Alignment.center,
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '自分だけで記録をつけたい場合はこちら(ポイントはつきません)',
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PersonalMatchRecordPage(),
                            ));
                      },
                      child: const Text(
                        '個人で記録',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
