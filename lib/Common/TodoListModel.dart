import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../FireBase/FireBase.dart';

class TodoListModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> _todos =[];

  List<Map<String,dynamic>> get todos => _todos;

  Future<void> fetchTodos(String uid) async {
    final docRef = _firestore.collection('todos').doc(uid);
    final DocumentSnapshot<dynamic> snapshot = await docRef.get();

    if (!snapshot.exists) return;

    _todos.clear();
    final List<dynamic> todoList = snapshot.data()?['todoList'] ?? [];
    bool updated = false;
    for (var todo in todoList) {
      if (todo is Map<String, dynamic>) {
        final originalTitle = todo['title']?.toString() ?? '';
        final normalizedTitle =
            originalTitle.replaceFirst(RegExp(r'_メモ_\\d+\$'), '');
        if (normalizedTitle != originalTitle) {
          updated = true;
        }
        _todos.add({
          ...todo,
          'title': normalizedTitle,
        });
      } else {
        print('Error: todo is not a Map');
      }
    }

    if (updated) {
      await docRef.set({'todoList': _todos}, SetOptions(merge: true));
    }

    _todos.sort((a, b) =>
        DateTime.parse(b["updateTime"]).compareTo(DateTime.parse(a["updateTime"])));
    notifyListeners();
  }

  // Future<void> addTodo(String title, String detail, String uid) async {
  //   await FirestoreMethod.addTodo(title, detail, uid,);
  //   // 状態変更を通知
  //   notifyListeners();
  // }
}
