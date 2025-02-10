import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Common/TodoListModel.dart';
import '../FireBase/FireBase.dart';
import '../PropSetCofig.dart';
import 'AddTodoDialog.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  bool _isAnyCheckboxSelected = false;
  Map<int, bool> checkMap = {};

  @override
  void initState() {
    super.initState();
  }

  Future<void> _deleteTodo(String uid, List<dynamic> selectedTodoIds) async {
    // Firestoreのドキュメント参照を取得
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final todosRef = _firestore.collection('todos');
    final docRef = todosRef.doc(uid);
    DocumentSnapshot<dynamic> snapshot = await docRef.get();
    List<dynamic> nowTodoList = snapshot.data()?['todoList'];

    // 削除したい要素を除外した新しい配列を作成
    for (var id in selectedTodoIds) {
      print("削除対象ListIndex " + snapshot.data()!['todoList'][id].toString());
      nowTodoList = nowTodoList
          .where((todo) =>
              todo['title'] != snapshot.data()?['todoList'][id]['title'])
          .toList();
    }
    await docRef.update({'todoList': nowTodoList});
  }

  Future<void> _updateTodo(String uid, String title, String detail, int id) async {
// Firestoreのドキュメント参照を取得
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final todosRef = _firestore.collection('todos');
    final docRef = todosRef.doc(uid);
    final DocumentSnapshot<dynamic> snapshot = await docRef.get();

      await FirebaseFirestore.instance.runTransaction((
          Transaction transaction) async {
        List<dynamic> todoList = snapshot.data()?['todoList'] ?? [];
        // 重複チェック
        bool isDuplicate = todoList.any((todo) => todo['title'] == title);

         if(isDuplicate){
           throw Exception("エラー");
         }

        Map<String, dynamic> oldMap = snapshot.data()?['todoList'][id] ?? [];

        Map<String, dynamic> newMap = {
          'title': title,
          'detail': detail
        };
        List updateList = [newMap];

        // 削除したい要素を除外した新しい配列を作成
        List newTodoList = todoList.where((todo) => todo['title'] != oldMap['title'])
            .toList();

        updateList.addAll(newTodoList);
        // ドキュメントを更新
        await transaction.update(docRef, {'todoList': updateList});
        // 削除完了のSnackBarを表示
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todoを更新しました')),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    var uid = auth.currentUser!.uid;
    HeaderConfig().init(context, "ToDoリスト");
    DrawerConfig().init(context);
    late List<Map<String, dynamic>> todos;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: HeaderConfig.backGroundColor,
        title: HeaderConfig.appBarText,
      ),
      body: FutureBuilder(
        future: context.read<TodoListModel>().fetchTodos(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            todos = context.watch<TodoListModel>().todos;
            return ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                todo['index'] = index;
                return Card(
                    child: CheckboxListTile(
                      title: Text(todo["title"]),
                      value: checkMap[index] ?? false,
                      onChanged: (bool? value) {
                        setState(() {
                          checkMap[index] = value!;
                          _isAnyCheckboxSelected =
                              checkMap.values.any((value) => value);
                        });
                      },
                      activeColor: Colors.greenAccent,
                      checkColor: Colors.yellow,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                );
              },
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddTodoDialog(
                onAdd: (title, detail) async {
                  try{
                    await FirestoreMethod.addTodo(title, detail, uid);
                    Navigator.of(context).pop();
                  }
                  catch(e){
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                          title: Text("入力エラー!"),
                          content: Text(
                              "タイトルが重複しています。"),
                        )
                    );
                  }
                  // ここでsetStateを呼び出す
                  setState(() {});
                },
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      persistentFooterButtons: [
        if (_isAnyCheckboxSelected)
          ElevatedButton(
            onPressed: () async {
              // 選択されたTodoのIDを取得
              List<dynamic> selectedTodoIds = todos
                  .where((todo) => checkMap[todo['index']] == true)
                  .map((todo) => todo['index'])
                  .toList();

              await _deleteTodo(uid, selectedTodoIds);

              // ローカルのリストから削除
              setState(() {
                todos.removeWhere(
                    (todo) => selectedTodoIds.contains(todo['index']));
                _isAnyCheckboxSelected = false;
                checkMap.clear();
              });

              // 削除完了のSnackBarを表示
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todoを削除しました')),
              );
            },
            child: Text('削除'),
          ),
        if (_isAnyCheckboxSelected &&
            checkMap.values.where((value) => value).length == 1)
          ElevatedButton(
            onPressed: () async {
              // 選択されたTodoのIDを取得
              int selectedTodoIds = checkMap.entries
                  .where((entry) => entry.value)
                  .map((entry) => entry.key as int)
                  .first;

              showDialog(
                context: context,
                builder: (context) {
                  return AddTodoDialog(
                    initialTitle: todos[selectedTodoIds]['title'],
                    initialDetail: todos[selectedTodoIds]['detail'],
                    onAdd: (title, detail) async {
                      try{
                        await _updateTodo(uid, title, detail,selectedTodoIds);
                        Navigator.of(context).pop();
                      }
                      catch (e){
                        showDialog(
                            context: context,
                            builder: (_) => const AlertDialog(
                              title: Text("入力エラー!"),
                              content: Text(
                                  "タイトルが重複しています。"),
                            )
                        );
                      }
                      // ここでsetStateを呼び出す
                      setState(() {});
                    },
                  );
                },
              );
              _isAnyCheckboxSelected = false;
              checkMap.clear();
            },
            child: Text('更新'),
          ),
      ],
    );
  }
}
