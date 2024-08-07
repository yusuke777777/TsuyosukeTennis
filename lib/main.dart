import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tsuyosuke_tennis_ap/FireBase/Notification_badge.dart';
import 'Common/CPushNotification.dart';
import 'FireBase/FireBase.dart';
import 'FireBase/GoogleAds.dart';
import 'FireBase/NotificationMethod.dart';
import 'FireBase/singletons_data.dart';
import 'Page/ProfileSetting.dart';
import 'Page/ReLoginMessagePage.dart';
import 'Page/SigninPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'UnderMenuMove.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';

import 'constant.dart';

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  await FirestoreMethod.isProfile();
  // await FirestoreMethod.checkUserAuth();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));
  if (FirebaseAuth.instance.currentUser != null) {
    final configuration = PurchasesConfiguration(
      Platform.isAndroid ? 'androidRevenueCatKey' : appleApiKey,
    )..appUserID = FirebaseAuth.instance.currentUser!.uid;
    await Purchases.configure(configuration);
    appData.appUserID = await Purchases.appUserID;
    print("main Login" + appData.appUserID.toString());
  } else {
    final configuration = PurchasesConfiguration(
      Platform.isAndroid ? 'androidRevenueCatKey' : appleApiKey,
    );
    await Purchases.configure(configuration);
    appData.appUserID = await Purchases.appUserID;
    print("main Login" + appData.appUserID.toString());
  }

  // const isDebug = !bool.fromEnvironment('TSP0001');
  // Purchases.setDebugLogsEnabled(isDebug);
  //
  // void _customerInfoUpdated(CustomerInfo info) async{
  //   // if (isExecuting) return;
  //   await BillingMethod().syncSubscription(info);
  // }
  // Purchases.addCustomerInfoUpdateListener(_customerInfoUpdated);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _appBadgeSupported = 'Unknown';

  // This widget is the root of your application.
  @override
  void initState() {
    super.initState();
    initPlatformState();
    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  initPlatformState() async {
    String appBadgeSupported;
    try {
      bool res = await FlutterAppBadger.isAppBadgeSupported();
      if (res) {
        appBadgeSupported = 'Supported';
      } else {
        appBadgeSupported = 'Not supported';
      }
    } on PlatformException {
      appBadgeSupported = 'Failed to get badge support.';
    }
  }

  // void _addBadge() {
  //   FlutterAppBadger.updateBadgeCount(1);
  // }
  // void _removeBadge() {
  //   FlutterAppBadger.removeBadge();
  // }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        textTheme: GoogleFonts.latoTextTheme(),
        // This is the theme of your application.
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
      home: FirebaseAuth.instance.currentUser == null
          ? SignInPage()
          :
          //  !FirestoreMethod.isAuth
          //    ? ReLoginMessagePage()
          // :
          FirestoreMethod.isprofile == true
              ? UnderMenuMove.make(0)
              : ProfileSetting.Make(),
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
