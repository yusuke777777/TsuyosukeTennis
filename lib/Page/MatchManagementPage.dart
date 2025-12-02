import 'package:flutter/material.dart';

import '../PropSetCofig.dart';
import 'PersonalMatchPage.dart';
import 'TournamentCreatePage.dart';
import 'TournamentQrScanPage.dart';

class MatchManagementPage extends StatelessWidget {
  const MatchManagementPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "対戦管理");
    DrawerConfig().init(context);
    final Color buttonColor = Colors.green.shade100;
    final Color textColor = Colors.green.shade900;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: HeaderConfig.backGroundColor,
          title: HeaderConfig.appBarText,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        drawer: DrawerConfig.drawer,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MatchManageButton(
                    label: '個人対戦',
                    backgroundColor: buttonColor,
                    textColor: textColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalMatchPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  _MatchManageButton(
                    label: '大会を主催',
                    backgroundColor: buttonColor,
                    textColor: textColor,
                    onPressed: () async {
                      final createdId = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentCreatePage(),
                        ),
                      );
                      if (createdId != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('大会を作成しました。予定一覧（主催）に追加しました。')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  _MatchManageButton(
                    label: '大会に参加',
                    backgroundColor: buttonColor,
                    textColor: textColor,
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TournamentQrScanPage(),
                        ),
                      );
                      if (result != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('参加登録しました。予定一覧で確認できます。')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchManageButton extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onPressed;

  const _MatchManageButton({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        onPressed: onPressed ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$label の機能は準備中です')),
              );
            },
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
