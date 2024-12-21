//TO DO: add the entitlement ID from the RevenueCat dashboard that is activated upon successful in-app purchase for the duration of the purchase.
const entitlementID = 'TSPプレミアムプラン';

//TO DO: add your subscription terms and conditions
const footerText =
"""Don't forget to add your subscription terms and conditions. 

Read more about this here: https://www.revenuecat.com/blog/schedule-2-section-3-8-b""";

//TO DO: add the Apple API key for your app from the RevenueCat dashboard: https://app.revenuecat.com

//課金機能(Revenucat)
const appleApiKey = 'appl_FqFukGrTjwGVYwYkalAgeTGGkog'; // 本番
//const appleApiKey = 'appl_zpRHoKSWQoxVqMeERkTqKTnykfP'; //開発
//TO DO: add the Google API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const googleApiKey = 'googl_api_key'; //使用なし
//TO DO: add the Amazon API key for your app from the RevenueCat dashboard: https://app.revenuecat.com
const amazonApiKey = 'amazon_api_key';//使用なし

//メッセージ送信(cloudMessage)
//const String functionUrl = 'https://asia-northeast1-tsuyosuketest.cloudfunctions.net/sendMessage'; //開発
const String functionUrl = 'https://asia-northeast1-tsuyosuketeniss.cloudfunctions.net/sendMessage'; //本番

//広告(googleAdsInterstitial)
//Android
//const googleInterstitialAdsAndroid = 'ca-app-pub-3940256099942544/1033173712'; //開発
const googleInterstitialAdsAndroid = 'ca-app-pub-3940256099942544/1033173712'; //本番
//IOS
//const googleInterstitialAdsIos = 'ca-app-pub-3940256099942544/4411468910'; //開発
const googleInterstitialAdsIos = 'ca-app-pub-2361922346375583/4315688562'; //本番

//広告(googleAdsBanner)
//Android
//const googleAdsBannerAndroid = 'ca-app-pub-3940256099942544/9214589741'; //開発
const googleAdsBannerAndroid = 'ca-app-pub-3940256099942544/9214589741'; //本番
//IOS
//const googleAdsBannerIos = 'ca-app-pub-3940256099942544/2435281174'; //開発
const googleAdsBannerIos = 'ca-app-pub-2361922346375583/4110034380'; //本番


