import 'package:firebase_auth/firebase_auth.dart' as Firebase_Auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tsuyosuke_tennis_ap/Page/EmailChangePage.dart';
import 'package:tsuyosuke_tennis_ap/Page/TicketListPage.dart';


import 'FireBase/native_dialog.dart';
import 'FireBase/singletons_data.dart';
import 'FireBase/urlMove.dart';
import 'Page/BlockList.dart';
import 'Page/FriendManagerPage.dart';
import 'Page/MatchResultList.dart';
import 'Page/MySetting.dart';
import 'Page/PasswordResetPage.dart';
import 'Page/SignUpPromptPage.dart';
import 'Page/SigninPage.dart';

/**
 * ヘッダ部の共通クラスです
 */
class HeaderConfig {
  //ヘッダー部の背景色
  static late Color backGroundColor;

  //ヘッダー部の中身
  static late Text appBarText;

  //戻るボタンの中身
  static late IconButton backIcon;

  void init(BuildContext context, String inputTitle) {
    backGroundColor = Colors.white;

    appBarText = Text(
      inputTitle,
      style: TextStyle(fontSize: 20, color: Colors.black),
    );
    backIcon = IconButton(
      icon: const Icon(
        Icons.reply,
        color: Colors.black,
        size: 40.0,
      ),
      onPressed: () => {Navigator.pop(context)},
    );
  }
}

/**
 * ヘッダー部左のドロアーの共通クラスです
 */
class DrawerConfig {
  static late Drawer drawer;

  static final Firebase_Auth.FirebaseAuth auth =
      Firebase_Auth.FirebaseAuth.instance;

  void init(BuildContext context) {
    drawer = Drawer(
      child: ListView(
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('管理一覧', style: TextStyle(fontSize: 30)),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              UrlMove().UrlMoving(
                  'https://spectacled-lan-4ae.notion.site/54a20356702e41cca956b9b72b9f9c4c?pvs=4');
            },
            child: Container(
              child: Text('アプリ利用手順'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TicketList(),
                ),
              );
            },
            child: Container(
              child: Text('チケット管理'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendManagerPage(),
                ),
              );
            },
            child: Container(
              child: Text('友人管理'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MatchResultList(),
                ),
              );
            },
            child: Container(
              child: Text('対戦履歴'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailChangePage(),
                ),
              );
            },
            child: Container(
              child: Text('メールアドレス変更'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PasswordResetPage(),
                ),
              );
            },
            child: Container(
              child: Text('パスワード変更'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlockList(),
                ),
              );
            },
            child: Container(
              child: Text('ブロックリスト確認'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          GestureDetector(
            onTap: () {
              if (auth.currentUser == null) {
                // ユーザーがログインしていない場合
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPromptPage()),
                );
                return; // ここで処理を終了。これより下のコードは実行されない
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MySetting(),
                ),
              );
            },
            child: Container(
              child: Text('設定'),
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(
            height: 20,
          ),

          Container(
            child: Visibility(
              visible: auth.currentUser != null,
              child:          GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  //課金機能ログアウト
                  try {
                    await Purchases.logOut();
                    // appUserID を取得
                    String? newAppUserID = await Purchases.appUserID;
                    appData.appUserID = newAppUserID ?? "未設定"; // nullの処理
                    // ログアウト情報の確認
                    print("ログアウト: " + (appData.appUserID.isNotEmpty ? appData.appUserID : "未設定"));

                  } on PlatformException catch (e) {
                    await showDialog(
                        context: context,
                        builder: (BuildContext context) => ShowDialogToDismiss(
                            title: "Error",
                            content: e.message ?? "Unknown error",
                            buttonText: 'OK'));
                  } catch (e) {
                    // その他のエラー処理
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) => ShowDialogToDismiss(
                        title: "エラー",
                        content: e.toString(),
                        buttonText: 'OK',
                      ),
                    );
                  }
                  // ログアウト後の画面に遷移
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignInPage()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  child: Text('ログアウト'),
                  alignment: Alignment.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/**
 * 検索結果リストの共通化クラスです
 */
// class ListTileConfig {
//   static late ListTile listTile;
//
//   void init(BuildContext context, String name, String profile, String docId,String coment,
//       String loginUserId) {
//     listTile = ListTile(
//       tileColor: Colors.white24,
//       leading: ClipOval(
//         child: GestureDetector(
//           //アイコン押下時の挙動
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ProfileReference(docId),
//                 ));
//           },
//           child: profile == ""
//               ? Image.asset('images/tenipoikun.png', fit: BoxFit.cover)
//               : Image.network(
//                   profile,
//                   width: 70,
//                   height: 70,
//                   fit: BoxFit.fill,
//                 ),
//         ),
//       ),
//       title: Text(name, style: TextStyle(fontSize: 20)),
//       //リスト押下時の挙動
//       onTap: () async {
//         TalkRoomModel room = await FirestoreMethod.makeRoom(loginUserId, docId);
//         Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => TalkRoom(room),
//             ));
//       },
//     );
//   }
// }
