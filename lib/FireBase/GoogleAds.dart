import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constant.dart';

class AdInterstitial {
  InterstitialAd? _interstitialAd;
  int num_of_attempt_load = 0;
  bool? ready;

  // create interstitial ads
  void createAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        // 広告が正常にロードされたときに呼ばれます。
        onAdLoaded: (InterstitialAd ad) {
          print('add loaded');
          _interstitialAd = ad;
          num_of_attempt_load = 0;
          ready = true;
        },
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (LoadAdError error) {
          num_of_attempt_load++;
          _interstitialAd = null;
          if (num_of_attempt_load <= 2) {
            createAd();
          }
        },
      ),
    );
  }

  // show interstitial ads to user
  Future<void> showAd() async {
    ready = false;
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        print("ad onAdshowedFullscreen");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("ad Disposed");
        ad.dispose();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError aderror) {
        print('$ad OnAdFailed $aderror');
        ad.dispose();
        createAd();
      },
    );

    // 広告の表示には.show()を使う
    await _interstitialAd!.show();
    _interstitialAd = null;
  }

  // 広告IDをプラットフォームに合わせて取得
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910';
    } else {
      //どちらでもない場合は、テスト用を返す
      return 'ca-app-pub-3940256099942544/4411468910';
    }
  }
}


class AdBanner extends StatelessWidget {
  const AdBanner({
    required this.size,
    Key? key,
  }) : super(key: key);

  final AdSize size;

  @override
  Widget build(BuildContext context) {
    final banner = BannerAd(
        size: size,
        adUnitId: bannerAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => debugPrint('Ad loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            debugPrint('Ad failed to load: $error');
          },
          onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
          onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
        ),
        request: const AdRequest())
      ..load();

    return SizedBox(
        width: banner.size.width.toDouble(),
        height: banner.size.height.toDouble(),
        child: AdWidget(ad: banner));
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return googleAdsAndroid;
    } else if (Platform.isIOS) {
      return googleAdsIos;
    } else {
      //どちらでもない場合は、テスト用を返す
      return googleAdsIos;
    }
  }
}