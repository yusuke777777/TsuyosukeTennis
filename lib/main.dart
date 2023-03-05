import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/Notification_badge.dart';
import 'Common/CPushNotification.dart';
import 'FireBase/NotificationMethod.dart';
import 'Page/SigninPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      // home: TestHomePage(),
      home: SignInPage(),
    );
  }
}

// class TestHomePage extends StatefulWidget {
//   const TestHomePage({Key? key}) : super(key: key);
//
//   @override
//   State<TestHomePage> createState() => _TestHomePageState();
// }
//
// class _TestHomePageState extends State<TestHomePage> {
//   late int _totalNotifications;
//   late final FirebaseMessaging _messaging;
//   CPushNotification? _notificationInfo;
//
//   void requestAndRegisterNotification() async {
//     await Firebase.initializeApp();
//     _messaging = FirebaseMessaging.instance;
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     NotificationSettings settings = await _messaging.requestPermission(
//       alert: true,
//       badge: true,
//       provisional: false,
//       sound: true,
//     );
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//       String? token = await _messaging.getToken();
//       print("The token is " + token!);
//
//       FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//         CPushNotification notification = CPushNotification(
//           title: message.notification?.title,
//           body: message.notification?.body,
//         );
//         setState(() {
//           _notificationInfo = notification;
//           _totalNotifications++;
//         });
//         if (_notificationInfo != null) {
//           showSimpleNotification(Text(_notificationInfo!.title!),
//               leading:
//                   NotificationBadge(totalNotifications: _totalNotifications),
//               subtitle: Text(_notificationInfo!.body!),
//               background: Colors.cyan.shade700,
//               duration: Duration(seconds: 2));
//         }
//       });
//
//     }
//   }
//
//   @override
//   void initState() {
//     requestAndRegisterNotification();
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       CPushNotification notification = CPushNotification(
//         title: message.notification?.title,
//         body: message.notification?.body,
//       );
//       setState(() {
//         _notificationInfo = notification;
//         _totalNotifications++;
//       });
//     });
//
//     _totalNotifications = 0;
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Notify'),
//         brightness: Brightness.dark,
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'App for capturing Firebase Push Notifications',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: Colors.black,
//               fontSize: 20,
//             ),
//           ),
//           SizedBox(height: 16),
//           NotificationBadge(totalNotifications: _totalNotifications),
//           SizedBox(height: 16),
//           _notificationInfo != null
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'TITLE:${_notificationInfo!.title}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Text(
//                       'BODY:${_notificationInfo!.body}',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                     )
//                   ],
//                 )
//               : Container(),
//         ],
//       ),
//     );
//   }
// }
