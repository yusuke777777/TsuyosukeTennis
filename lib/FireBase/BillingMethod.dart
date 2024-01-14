// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:flutter/services.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
//
// class BillingMethod {
// // 3で利用するフラグです
//   bool isExecuting = false;
//
// // 課金ユーザーになったらtrueを返す
// //   Future<bool> subscribe(String productID) async {
// //     try {
// //       isExecuting = true;
// //       final info = await Purchases.purchaseProduct(productID);
// //       final bool isSubscribed = await syncSubscription(info);
// //       isExecuting = false;
// //     } on PlatformException catch (e) {
// //       final code = PurchasesErrorHelper.getErrorCode(e);
// //       final error = _convertPurchasesError(code, additionalCode: e.code);
// //       throw error;
// //     }
// //   }
//
// // 課金ユーザーになったらtrueを返す
//   Future<bool> syncSubscription(CustomerInfo info, {String? productID}) async {
//     isExecuting = true;
//     final func = FirebaseFunctions.instanceFor(region: 'asia-northeast1')
//         .httpsCallable('syncInAppPurchase');
//     final result = await func.call();
//     var isSubscribed = false;
//     if (productID != null) {
//       isSubscribed = result.data[productID];
//     } else {
//       // 1つでもtrueになったらOKにしておく
//       isSubscribed = (result.data as Map<String, bool>)
//           .values
//           .firstWhere((element) => element, orElse: () => false);
//     }
//     isExecuting = false;
//     return isSubscribed;
//   }
//
// }
//
//
// enum SubscribeErrorCode {
//   canceled,
//   notAllowed,
//   alreadyPurchased,
//   receiptAlreadyInUse,
//   invalidPurchase,
//   noReceipt,
//   appStoreError,
//   paymentPendingError,
//   unexpectedRCError,
//   syncFailedToMyBackend,
// }
//
//
//
// class SubscribeError implements Exception {
//   SubscribeError(this.code, {String? message, this.additionalErrorCode})
//       : _message = message;
//   final SubscribeErrorCode code;
//   final String? _message;
//   final String? additionalErrorCode;
//
//   String get message {
//     if (_message != null) return _message;
//
//     switch (code) {
//       case SubscribeErrorCode.canceled:
//         return 'キャンセルされました。';
//       case SubscribeErrorCode.appStoreError:
//         return '${Platform.isIOS ? 'AppStore' : 'GooglePlayStore'}でエラーが発生しました。時間を置いて再度お試しください。';
//       case SubscribeErrorCode.notAllowed:
//         return 'お使いのAppleIDは購入が許可されていません。';
//       case SubscribeErrorCode.alreadyPurchased:
//         return 'この商品はすでに購入済みです。復元をお試しください。';
//       case SubscribeErrorCode.receiptAlreadyInUse:
//         return '購入情報は別のユーザーで使用されています。別のアカウントにログインしてください。';
//       case SubscribeErrorCode.invalidPurchase:
//         return '購入情報が不正です。';
//       case SubscribeErrorCode.noReceipt:
//         return '購入情報が存在していません。';
//       case SubscribeErrorCode.unexpectedRCError:
//         return '予期せぬエラーが発生しました。スクショを撮影いただきお問い合わせください。[${additionalErrorCode ?? 'none'}]';
//       case SubscribeErrorCode.paymentPendingError:
//         return '購入には承認が必要です。この端末を管理している方に確認してください。';
//       case SubscribeErrorCode.syncFailedToMyBackend:
//         return '購入情報の同期に失敗しました。お手数ですがお問合せフォームからお問い合わせをお願いいたします。';
//     }
//
//     return '予期せぬエラーが発生しました。';
//   }
// }
//
// SubscribeError _convertPurchasesError(PurchasesErrorCode code,
//     {String? additionalCode}) {
//   switch (code) {
//     case PurchasesErrorCode.purchaseCancelledError:
//       return SubscribeError(SubscribeErrorCode.canceled);
//     case PurchasesErrorCode.storeProblemError:
//       return SubscribeError(SubscribeErrorCode.appStoreError);
//     case PurchasesErrorCode.purchaseNotAllowedError:
//       return SubscribeError(SubscribeErrorCode.notAllowed);
//     case PurchasesErrorCode.productAlreadyPurchasedError:
//       return SubscribeError(SubscribeErrorCode.alreadyPurchased);
//     case PurchasesErrorCode.receiptAlreadyInUseError:
//     case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
//       return SubscribeError(SubscribeErrorCode.receiptAlreadyInUse);
//     case PurchasesErrorCode.missingReceiptFileError:
//       return SubscribeError(SubscribeErrorCode.noReceipt);
//     case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
//     case PurchasesErrorCode.invalidAppUserIdError:
//     case PurchasesErrorCode.invalidCredentialsError:
//     case PurchasesErrorCode.invalidReceiptError:
//       return SubscribeError(SubscribeErrorCode.invalidPurchase);
//     case PurchasesErrorCode.paymentPendingError:
//       return SubscribeError(SubscribeErrorCode.paymentPendingError);
//     default:
//       return SubscribeError(SubscribeErrorCode.unexpectedRCError,
//           additionalErrorCode: 'RC$additionalCode');
//   }
// }
