# 大会DB構成

## 目的/前提
- 予定一覧タブ「参加大会」「主催大会」で使うメタ情報（タイトル/形式/人数/説明）と、参加者リアルタイム表示を返す。
- QR参加フローは `lib/FireBase/FireBase.dart` の `addTournamentParticipant` が `tournaments/{id}` と `participants` サブコレクションに書き込む構成を前提。

## コレクション構造
### `tournaments`（トップレベル）
| フィールド | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| hostUserId | string | ◯ | 主催者UID（現行実装で書き込み済み） |
| title | string | ◯ | 大会名。予定一覧カード用 |
| format | string | ◯ | リーグ / トーナメント / リーグ→トーナメント |
| description | string | ◯ | ルール・備考。`TournamentConfirmPage` の概要表示用 |
| startAt / endAt | timestamp | ◯ | 開催日時。予定一覧のソートに使用 |
| location | string | - | 会場名・住所 |
| participantLimit | number | - | 募集上限 |
| participantCount | number | - | 参加済み人数サマリ（Cloud Function 等で集計） |
| status | string | ◯ | planned / ongoing / finished / cancelled |
| qrPayload | string | - | 主催画面で使う事前生成QR文字列 |
| createdAt / updatedAt | timestamp | ◯ | 作成・更新時刻（`updatedAt` は現行実装で書き込み済み） |

例:
```json
{
  "hostUserId": "uid_host_001",
  "title": "サマーカップ ダブルス",
  "format": "リーグ/トーナメント",
  "description": "6ゲーム先取・ノーアド",
  "startAt": "2024-08-03T09:00:00Z",
  "endAt": "2024-08-03T17:00:00Z",
  "location": "駒沢公園コート",
  "participantLimit": 16,
  "participantCount": 12,
  "status": "planned",
  "qrPayload": "tournament:abc|host:uid_host_001",
  "createdAt": "...",
  "updatedAt": "..."
}
```

### `tournaments/{tournamentId}/participants`（サブコレクション）
| フィールド | 型 | 必須 | 説明 |
| --- | --- | --- | --- |
| userId（docIdと同じ） | string | ◯ | 参加者UID |
| displayName | string | ◯ | 表示名（プロフィール由来、現行実装で書き込み済み） |
| profileImage | string | - | アイコンURL |
| joinedAt | timestamp | ◯ | 参加時刻（現行実装で書き込み済み、orderBy 用） |
| hostUserId | string | - | 主催者UID（現行実装で書き込み済み） |
| status | string | ◯ | confirmed / cancelled / waiting など |
| joinedBy | string | - | qr / invite / manual。参加経路の監査用 |
| note | string | - | レベル・同伴者などの補足 |

例:
```json
{
  "userId": "uid_player_123",
  "displayName": "山本 健太",
  "profileImage": "https://.../avatar.jpg",
  "joinedAt": "2024-07-01T12:00:00Z",
  "hostUserId": "uid_host_001",
  "status": "confirmed",
  "joinedBy": "qr"
}
```

### `userTournaments`（任意の補助コレクション）
- パス: `userTournaments/{userId}/entries/{tournamentId}`
- フィールド例: `role: host|participant`, `tournamentRef`, `joinedAt`, `status`
- 参加大会一覧を1クエリで返したい場合に利用。代わりに collectionGroup(`participants`) でも取得可。

## 主なクエリとインデックス
- 主催一覧: `tournaments.where('hostUserId', isEqualTo: me).orderBy('startAt')`（`hostUserId + startAt` の複合インデックス）
- 参加一覧: collectionGroup(`participants`).where(`userId` == me) で取得し、parent の `tournamentId` から本体を参照。もしくは `userTournaments/{uid}/entries` を直接読む。
- 参加者リアルタイム表示: `tournaments/{id}/participants.orderBy('joinedAt')`（既存実装と一致）
- 参加数サマリ: `participants` onWrite トリガーで `participantCount` を増減。上限チェックに `participantLimit` を使用。

### 必要作業: インデックス作成
- Firestore コンソールで以下のコレクショングループインデックスを作成すること:
  - Collection Group: `participants`
  - Fields: `userId` (Ascending)
  - Order/Splits: なし
- CLIで管理する場合は `firestore.indexes.json` に下記を追加し、`firebase deploy --only firestore:indexes` を実行:
```json
{
  "indexes": [
    {
      "collectionGroup": "participants",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## セキュリティルールの考え方
- 主催者のみ大会メタ（`tournaments/{id}`）を編集・削除可。
- 参加者は自分の `participants/{uid}` の作成/削除のみ許可。
- collectionGroup クエリで `participants` を読むことを許可するルールを追加。

## 補足
- まだ大会メタを登録していない場合、QR参加時に `tournaments/{id}` は `hostUserId` と `updatedAt` のみで初期化される（現行実装）。作成画面で `title/startAt/format` などを保存する処理を追加すると一覧表示が成立。
- 一覧カードで必要なフィールドは `title`, `format`, `description`, `participantCount/participantLimit`。重いリストは避け、サマリ値は `tournaments` 本体に保持する。
