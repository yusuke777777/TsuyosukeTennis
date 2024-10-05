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
          print('Ad loaded');
          _interstitialAd = ad;
          num_of_attempt_load = 0;
          ready = true;
        },
        // 広告のロードが失敗した際に呼ばれます。
        onAdFailedToLoad: (LoadAdError error) {
          print('Ad failed to load: $error');
          num_of_attempt_load++;
          _interstitialAd = null;
          if (num_of_attempt_load <= 2) {
            createAd(); // 再試行
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
        print("Ad showed fullscreen");
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print("Ad dismissed, disposing");
        ad.dispose(); // 広告が閉じられたら破棄
        _interstitialAd = null; // 新たな広告をロードする準備
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError adError) {
        print('Ad failed to show: $adError');
        ad.dispose(); // 広告表示失敗時も破棄
        _interstitialAd = null;
        createAd(); // 再ロード
      },
    );

    await _interstitialAd!.show();
    _interstitialAd = null; // 広告を表示したら破棄
  }

  // 広告オブジェクトの解放
  void dispose() {
    _interstitialAd?.dispose(); // 広告がまだ残っていたら破棄
    _interstitialAd = null; // メモリリーク防止
  }

  // 広告IDをプラットフォームに合わせて取得
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return googleInterstitialAdsAndroid;
    } else if (Platform.isIOS) {
      return googleInterstitialAdsIos;
    } else {
      //どちらでもない場合は、テスト用IDを返す
      return googleInterstitialAdsIos;
    }
  }
}


class AdBanner extends StatefulWidget {
  const AdBanner({
    required this.size,
    Key? key,
  }) : super(key: key);

  final AdSize size;

  @override
  _AdBannerState createState() => _AdBannerState();

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return googleAdsBannerAndroid;
    } else if (Platform.isIOS) {
      return googleAdsBannerIos;
    } else {
      return googleAdsBannerIos; // テスト用IDを返す
    }
  }
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  int _numOfAttempts = 0; // 失敗した回数をカウント

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      size: widget.size,
      adUnitId: AdBanner.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          debugPrint('Ad loaded.');
          _numOfAttempts = 0; // 成功したらリセット
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          debugPrint('Ad failed to load: $error');
          ad.dispose();
          _numOfAttempts++; // 失敗した回数をインクリメント

          // 失敗回数が3を超えないように制限
          if (_numOfAttempts <= 3) {
            _loadAd(); // 再ロードを試みる
          } else {
            debugPrint('Max attempts reached. No more retries.');
          }
        },
        onAdOpened: (Ad ad) => debugPrint('Ad opened.'),
        onAdClosed: (Ad ad) => debugPrint('Ad closed.'),
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // 広告オブジェクトを破棄
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      return SizedBox.shrink(); // 広告がまだない場合は何も表示しない
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}

