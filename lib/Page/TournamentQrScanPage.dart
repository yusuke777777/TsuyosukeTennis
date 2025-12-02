import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../Common/CprofileSetting.dart';
import '../Common/TournamentQrPayload.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

class TournamentQrScanPage extends StatefulWidget {
  const TournamentQrScanPage({super.key});

  @override
  State<TournamentQrScanPage> createState() => _TournamentQrScanPageState();
}

class _TournamentQrScanPageState extends State<TournamentQrScanPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "大会参加QR読み取り");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        leading: HeaderConfig.backIcon,
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _handleCapture,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              color: Colors.black54,
              child: Text(
                _isProcessing
                    ? '登録中です...'
                    : '大会のQRコードを読み取って参加登録します',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;
    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    final payload = TournamentQrPayload.parse(raw);
    if (payload == null) {
      _showSnack('大会用のQRコードではありません');
      return;
    }
    final currentUser = FirestoreMethod.auth.currentUser;
    if (currentUser == null) {
      _showSnack('ログインが必要です');
      return;
    }
    setState(() => _isProcessing = true);
    try {
      await _controller.stop();
      final CprofileSetting profile =
          await FirestoreMethod.getYourProfile(currentUser.uid);
      await FirestoreMethod.addTournamentParticipant(
        tournamentId: payload.tournamentId,
        hostUserId: payload.hostUserId,
        profile: profile,
      );
      _showSnack('参加登録しました');
      if (mounted) Navigator.of(context).pop(payload);
    } catch (e) {
      _showSnack('参加登録に失敗しました。通信状況を確認してください。');
      try {
        await _controller.start();
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
