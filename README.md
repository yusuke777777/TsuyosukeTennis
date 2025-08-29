C# テニスポイ - テニススコア管理アプリ

## 概要

このプロジェクトは、FlutterとFirebaseを使用して開発された、テニスのスコア管理・共有アプリケーション「テニスポイ」です。
プレイヤーは試合結果の記録、ランキングの閲覧、フレンドとの交流などができます。

## 主な機能

*   **試合結果の記録・管理:** シングルス、ダブルスの試合結果を記録し、戦績を管理できます。
*   **ランキング機能:** アプリ内でのシングルスランキングを閲覧できます。
*   **フレンド機能:** 他のプレイヤーをフレンドとして登録し、交流することができます。
*   **プロフィール機能:** プレイヤーのプロフィールや戦績を閲覧できます。
*   **プッシュ通知:** 試合結果の更新など、重要なお知らせをプッシュ通知で受け取れます。
*   **アプリ内課金:** アプリ内アイテムの購入が可能です。(RevenueCat利用)
*   **広告表示:** アプリ内に広告を表示します。(AdMob利用)

## 技術スタック

### フロントエンド (モバイルアプリ)

*   **フレームワーク:** [Flutter](https://flutter.dev/)
*   **言語:** [Dart](https://dart.dev/)

### バックエンド

*   **プラットフォーム:** [Firebase](https://firebase.google.com/)
    *   **データベース:** Cloud Firestore
    *   **サーバーレス関数:** Cloud Functions for Firebase (TypeScript)
    *   **認証:** Firebase Authentication
    *   **ストレージ:** Cloud Storage for Firebase
    *   **プッシュ通知:** Firebase Cloud Messaging
*   **言語 (Cloud Functions):** [TypeScript](https://www.typescriptlang.org/)

### その他

*   **アプリ内課金:** [RevenueCat](https://www.revenuecat.com/)
*   **広告:** [Google AdMob](https://admob.google.com/)

## プロジェクト構成

```
/
├── android/ # Androidプロジェクト
├── ios/ # iOSプロジェクト
├── lib/ # Flutterアプリケーションのソースコード
│   ├── Common/ # データモデルクラス
│   ├── Component/ # 共通UIコンポーネント
│   ├── FireBase/ # Firebase関連の処理
│   └── Page/ # 各画面のUI
├── functions/ # Firebase Cloud Functionsのソースコード (TypeScript)
├── assets/ # アプリアイコンなどの静的ファイル
└── pubspec.yaml # Flutterプロジェクトの依存関係定義ファイル
```

## セットアップと実行

(ここにローカル環境でのセットアップや実行方法を記述します)

