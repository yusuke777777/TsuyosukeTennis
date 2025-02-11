import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Common/TodoListModel.dart';

class AddTodoDialog extends StatefulWidget {
  final Function(String, String) onAdd;
  final String? initialTitle;
  final String? initialDetail;
  final String? dialogTitle;

  const AddTodoDialog({Key? key,
    required this.onAdd,
    required this.dialogTitle,
    this.initialTitle,
    this.initialDetail,}) : super(key: key);

  @override
  _AddTodoDialogState createState() => _AddTodoDialogState();
}

class _AddTodoDialogState extends State<AddTodoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _detailController = TextEditingController();
  String dialogTitle ='';

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.initialTitle ?? '';
    _detailController.text = widget.initialDetail ?? '';
    dialogTitle = widget.dialogTitle as String;
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Text(dialogTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'タイトル',
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),),
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
              child: const Text('詳細',
                  style: TextStyle(fontSize: 15)),
            ),
            Container(
              width: deviceWidth * 0.8,
              height: 200,
              alignment: Alignment.center,
              child: TextFormField(
                cursorColor: Colors.green,
                controller: _detailController,
                maxLines: 20,
                decoration: const InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.green),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              print(context.toString());
              widget.onAdd(_titleController.text, _detailController.text);
            }
          },
          child: Text('追加'),
        ),
      ],
    );
  }
}