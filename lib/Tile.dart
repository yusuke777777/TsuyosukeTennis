import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

//!!!!!ListViewをスライドさせる実装イメージ!!!!!
//!!!!!このクラスは使用しないでください!!!!!
class Tile extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Slidable(
    endActionPane: ActionPane(
    motion: DrawerMotion(),
    children: [
    SlidableAction(
    onPressed: (value) {},
    backgroundColor: Colors.blue,
    icon: Icons.share,
    label: 'シェア',
    ),
    SlidableAction(
    onPressed: (value) {},
    backgroundColor: Colors.red,
    icon: Icons.delete,
    label: '削除',
    ),
    ],
    ),
    child:                               ListView(
      // padding: const EdgeInsets.all(8),
        children: <Widget>[
          //TODO このListTileを押せるようにしたい＋アイコン付ける方法調べる
          ListTile(
              leading:
              ClipOval(
                child: Image.asset(
                  'images/ans_032.jpg',
                  width: 70,
                  height: 70,
                  fit: BoxFit.fill,
                ),
              ),
              title: Text('TEST'
                  , style: TextStyle(fontSize: 30))
          ),
        ]
    ),

    );

  }
}