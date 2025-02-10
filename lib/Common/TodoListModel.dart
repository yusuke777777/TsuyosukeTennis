import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../FireBase/FireBase.dart';

class TodoListModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String,dynamic>> _todos =[];

  List<Map<String,dynamic>> get todos => _todos;

  Future<void> fetchTodos(String uid) async {
    final DocumentSnapshot<dynamic> snapshot = await _firestore
        .collection('todos')
        .doc(uid)
        .get();

    if (snapshot.exists) {
      _todos.clear();
      final List<dynamic> todoList = snapshot.data()?['todoList'] ?? [];
      for (var todo in todoList){
        if (todo is Map<String, dynamic>) {
          _todos.add(todo);
        } else {
          // todoがMap型でない場合の処理（エラーログ出力など）
          print('Error: todo is not a Map');
        }
      }
      notifyListeners();
    }
  }

  Future<void> addTodo(String title, String detail, String uid) async {
    await FirestoreMethod.addTodo(title, detail, uid);
    // 状態変更を通知
    notifyListeners();
  }
}