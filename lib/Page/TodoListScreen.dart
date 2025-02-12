import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  Map<int, bool> checkMap = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String _filterText = '';
    var uid = auth.currentUser!.uid;
    HeaderConfig().init(context, "テニスメモ");
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
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (value) async {
                          await FirestoreMethod.deleteTodo(uid, todo['index']);
                          // ローカルのリストから削除
                          setState(() {});
                          // 削除完了のSnackBarを表示
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('テニスメモを削除しました')),
                          );
                        },
                        backgroundColor: Colors.red,
                        icon: Icons.delete,
                        label: '削除',
                      ),
                    ],
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(todo["title"]),
                      subtitle:Text('更新日: '+ todo['updateTime']),
                      onTap: (){
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AddTodoDialog(
                              dialogTitle: 'テニスメモを更新',
                              initialTitle: todos[index]['title'],
                              initialDetail: todos[index]['detail'],
                              categori: todos[index]['categori'],
                              onAdd: (title, detail, categori) async {
                                try {
                                  await FirestoreMethod.updateTodo(uid, title, detail, index,categori);
                                  // 更新完了のSnackBarを表示
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('テニスメモを更新しました')),
                                  );
                                  Navigator.of(context).pop();
                                } catch (e) {
                                  showDialog(
                                      context: context,
                                      builder: (_) => const AlertDialog(
                                        title: Text("入力エラー!"),
                                        content: Text("タイトルが重複しています。"),
                                      ));
                                }
                                // ここでsetStateを呼び出す
                                setState(() {});
                              },
                            );
                          },
                        );

                      },
                    ),
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
                dialogTitle: '新しいテニスメモを追加',
                onAdd: (title, detail,categori) async {
                  try {
                    await FirestoreMethod.addTodo(title, detail, uid, categori);
                    // 削除完了のSnackBarを表示
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('テニスメモを作成しました')),
                    );
                    Navigator.of(context).pop();
                  } catch (e) {
                    showDialog(
                        context: context,
                        builder: (_) => const AlertDialog(
                              title: Text("入力エラー!"),
                              content: Text("タイトルが重複しています。"),
                            ));
                  }
                  // ここでsetStateを呼び出す
                  setState(() {});
                },
              );
            },
          );
        },
        backgroundColor: Colors.lightGreen,
        child: Icon(Icons.add),
      ),
    );
  }
}
