import 'package:flutter/material.dart';

class AddTodoDialog extends StatefulWidget {
  final Function(String, String,String) onAdd;
  final String? initialTitle;
  final String? initialDetail;
  final String? dialogTitle;
  final String? categori;

  const AddTodoDialog({
    Key? key,
    required this.onAdd,
    required this.dialogTitle,
    this.initialTitle,
    this.initialDetail,
    this.categori,
  }) : super(key: key);

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  String dialogTitle = '';
  String dropdownValue = '';
  final List<String> categories = const [
    '',
    'フォアハンド',
    'バックハンド',
    'フォアボレー',
    'バックボレー',
    '1stサーブ',
    '2ndサーブ',
    'その他',
    '試合メモ',
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _detailController.text = widget.initialDetail ?? '';
    dialogTitle = widget.dialogTitle as String;
    final initValue = widget.categori ?? '';
    dropdownValue = categories.contains(initValue) ? initValue : '';
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      title: Text(dialogTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'タイトル',
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'タイトルを入力してください';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 30,
              ),
              Container(
                //width: deviceWidth * 0.8,
                alignment: Alignment.centerLeft,
                child: const Text('詳細', style: TextStyle(fontSize: 15)),
              ),
              Container(
                width: deviceWidth * 0.8,
                height: 200,
                alignment: Alignment.center,
                child: TextFormField(
                  cursorColor: Colors.green,
                  controller: _detailController,
                  maxLines: 8,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: const Text('カテゴリ', style: TextStyle(fontSize: 15)),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                    child: DropdownButton<String>(
                      value: dropdownValue,
                      icon: const Icon(Icons.arrow_downward),
                      iconSize: 24,
                      elevation: 16,
                      style: const TextStyle(color: Colors.deepPurple),
                      underline: Container(
                        height: 2,
                        color: Colors.green,
                      ),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue ?? '';
                        });
                      },
                      items: categories
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'キャンセル',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onAdd(_titleController.text, _detailController.text, dropdownValue);
            }
          },
          child: Text('追加',
            style: TextStyle(
              color: Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}
