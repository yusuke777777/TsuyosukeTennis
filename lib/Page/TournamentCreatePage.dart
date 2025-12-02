import 'package:flutter/material.dart';

import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';

class TournamentCreatePage extends StatefulWidget {
  const TournamentCreatePage({Key? key}) : super(key: key);

  @override
  State<TournamentCreatePage> createState() => _TournamentCreatePageState();
}

class _TournamentCreatePageState extends State<TournamentCreatePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _limitController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _formats = const [
    'リーグ戦',
    'トーナメント戦',
    'リーグ/トーナメント戦'
  ];
  String? _selectedFormat;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _limitController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HeaderConfig().init(context, "大会作成");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: HeaderConfig.backIcon,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel('大会名'),
                  TextField(
                    controller: _titleController,
                    maxLength: 30,
                    decoration: const InputDecoration(
                      hintText: '例）サマーカップ2024',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('参加上限人数'),
                  TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: const InputDecoration(
                      hintText: '例）16',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('形式'),
                  DropdownButtonFormField<String>(
                    value: _selectedFormat,
                    decoration: const InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    items: _formats
                        .map((format) => DropdownMenuItem(
                              value: format,
                              child: Text(format),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedFormat = val;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildLabel('大会内容'),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      hintText: '大会のルールや備考を入力してください',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade100,
                        foregroundColor: Colors.green.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _onCreatePressed,
                      child: _isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              '大会作成',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _onCreatePressed() async {
    final title = _titleController.text.trim();
    final limitText = _limitController.text.trim();
    final description = _descriptionController.text.trim();
    final format = _selectedFormat;

    if (title.isEmpty) {
      _showError('大会名を入力してください');
      return;
    }
    final limit = int.tryParse(limitText);
    if (limit == null || limit <= 0) {
      _showError('参加上限人数は1以上の数字で入力してください');
      return;
    }
    if (format == null || format.isEmpty) {
      _showError('形式を選択してください');
      return;
    }
    if (description.isEmpty) {
      _showError('大会内容を入力してください');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final tournamentId = await FirestoreMethod.createTournament(
        title: title,
        participantLimit: limit,
        format: format,
        description: description,
      );
      if (!mounted) return;
      Navigator.of(context).pop(tournamentId);
    } catch (e) {
      _showError('大会作成に失敗しました。通信状況を確認してください。');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('入力エラー'),
            content: Text(message),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'))
            ],
          );
        });
  }
}
