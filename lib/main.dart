import 'dart:async';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:purchases_flutter/models/purchases_configuration.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:tsuyosuke_tennis_ap/Page/Explain.dart';
import 'package:tsuyosuke_tennis_ap/Page/HomePage.dart';
import 'package:tsuyosuke_tennis_ap/Page/RankList.dart';
import 'package:uni_links/uni_links.dart';
import 'Common/CPushNotification.dart';
import 'FireBase/FireBase.dart';
import 'FireBase/GoogleAds.dart';
import 'FireBase/NotificationMethod.dart';
import 'FireBase/NotificationProvider.dart';
import 'FireBase/singletons_data.dart';
import 'Page/LoginPage.dart';
import 'Page/ProfileReference.dart';
import 'Page/ProfileSetting.dart';
import 'Page/ReLoginMessagePage.dart';
import 'Page/SigninPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'UnderMenuMove.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'constant.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("ここ");
  await Firebase.initializeApp();
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print('Handling a background message ${message.messageId}');
}

void main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  //クラッシュレポート
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  //Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  FirebaseInAppMessaging.instance; // In-App Messagingを初期化
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  MobileAds.instance.initialize();

  if (FirebaseAuth.instance.currentUser != null &&
      !FirebaseAuth.instance.currentUser!.isAnonymous) {
    await FirestoreMethod.isProfile();
    await FirestoreMethod.checkUserAuth();
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.light,
  ));
  if (FirebaseAuth.instance.currentUser != null &&
      !FirebaseAuth.instance.currentUser!.isAnonymous) {
    final configuration = PurchasesConfiguration(
        Platform.isAndroid ? googleApiKey : appleApiKey)
      ..appUserID = FirebaseAuth.instance.currentUser!.uid;
    await Purchases.configure(configuration);
    appData.appUserID = await Purchases.appUserID;
    print("main Login" + appData.appUserID.toString());
  } else {
    final configuration = PurchasesConfiguration(
      Platform.isAndroid ? googleApiKey : appleApiKey,
    );
    await Purchases.configure(configuration);
    appData.appUserID = await Purchases.appUserID;
    print("main Login" + appData.appUserID.toString());
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late StreamSubscription _sub;

  @override
  void initState() {
    super.initState();

    // initPlatformState();
    initialization();
    NotificationMethod().setting();

    /// Firebase ID取得(テスト用)
    FirebaseInAppMessagingService().getFID();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  // initPlatformState() async {
  //   String appBadgeSupported;
  //   try {
  //     bool res = await FlutterAppBadger.isAppBadgeSupported();
  //     if (res) {
  //       appBadgeSupported = 'Supported';
  //     } else {
  //       appBadgeSupported = 'Not supported';
  //     }
  //   } on PlatformException {
  //     appBadgeSupported = 'Failed to get badge support.';
  //   }
  // }

  // void _addBadge() {
  //   FlutterAppBadger.updateBadgeCount(1);
  // }
  // void _removeBadge() {
  //   FlutterAppBadger.removeBadge();
  // }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

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
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/') {
          return MaterialPageRoute(builder: (context) => HomePage());
        }

        // 動的なプロフィールページへのルート処理
        if (settings.name?.startsWith('/profile/') == true) {
          final userId = settings.name?.split('/')[2]; // URL から userId を取得
          return MaterialPageRoute(
            builder: (context) => ProfileReference(userId!),
          );
        }
        return null;
      },
      home: FirebaseAuth.instance.currentUser == null
          ? LoginPage()
          : FirebaseAuth.instance.currentUser!.isAnonymous
              ? UnderMenuMove.make(4)
              :
              //メール承認を終えていない場合は承認待機画面へ
              !FirestoreMethod.isAuth
                  ? ReLoginMessagePage()
                  : FirestoreMethod.isprofile == true
                      ? UnderMenuMove.make(0)
                      : Explain(),
    );
  }
}

class FirebaseInAppMessagingService {
  void getFID() async {
    String id = await FirebaseInstallations.instance.getId();
    print('id : $id');
  }
}
