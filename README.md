# AstroTactics

この README は `AstroTactics` フォルダ内のフォルダ構成と各 Swift ファイルの役割・実装概要をまとめたドキュメントです。

## 概要

AstroTactics は Swift/SwiftUI によるカードバトル風の小規模ゲームプロジェクトです。主要な責務は以下の通りです。

- JSON からゲームデータを読み込みデータベース化する（カード、敵、レリック、マップ、設定）
- ラン管理（RunManager）による進行管理とセーブ/ロード
- 戦闘ロジック（BattleManager）と手札/山札管理（BattleDeckManager）
- UI は SwiftUI で画面（Title/Map/Battle/Shop/Rest/Reward/Treasure/etc.）を構成

## 目次

- フォルダ構成
- 各ファイルの説明（フォルダごとにまとめています）
- 実行・開発メモ

---

## フォルダ構成

ルート: `AstroTactics/`

- `App/` - アプリ起動とルートの View
- `Databases/` - JSON を読み込み、ゲーム内の設計図（カード・敵・レリック）を保持・生成する
- `Managers/` - ゲーム進行やセーブ、ショップ、デッキなどのビジネスロジック
- `Models/` - ドメインモデル。カード／効果／敵／プレイヤー／レリック／マップ等
  - `Card/`, `Battle/`, `Map/`, `Relic/`, `Settings/` に分割
- `Persistent/` - 永続化向けの軽量モデル（SaveData など）
- `Resources/` - アセット・ゲームデータ JSON
- `Utilities/` - 汎用ユーティリティ（JSON ローダー、メッセージフォーマッタ等）
- `Views/` - SwiftUI 画面群（Components と Screens）

---

## 各ファイルの説明

以下は主要ファイルをフォルダ別に列挙し、実装内容を要約したものです。

### App

- `AstroTacticsApp.swift`
  - `@main`。アプリの起点。SwiftData の `ModelContainer` を作成し、`ContentView` をルートに設定。
  - `Item` モデル（SwiftData）をスキーマに含める初期化処理を持つ。

- `ContentView.swift`
  - アプリ全体の画面遷移を制御するトップレベルの View。
  - 内部で `AppState` を持ち、`TitleView`, `MapView`, `BattleView` などへ遷移。
  - `RunManager` を保持し、新規開始やノード選択→バトル開始のハンドリングを行う。

### Utilities

- `DataLoader.swift`
  - 汎用 JSON ローダー。デコードエラー時に詳細な情報を出力するよう丁寧に実装。
  - 型パラメータ `T: Decodable` で任意の JSON を読み込める。

- `BattleMessageFormatter.swift`
  - 戦闘中に画面表示する日本語メッセージを生成するユーティリティ（例：ダメージ文、カード発動文など）。

### Databases

- `CardDatabase.swift`
  - `CardData.json` を読み込み、`Card` の設計図リスト（allCardsData）を構築する。
  - JSON の表現（traits, effects, target）を `Card`, `CardEffect` 実装に変換する `convert(json:)` を持つ。
  - 初期デッキ生成（`startingDeck()`）や報酬用カード取得（`allRewardCards()`）、個別カード複製（`getCard(by:)`）を提供。

- `EnemyDatabase.swift`
  - `EnemyData.json` を読み込み、敵テンプレートを保持。
  - ランダムな雑魚生成（`randomEnemy()`）とボス生成（`bossFlagship()`）を提供。
  - AI の定義（`AIJSON`、`MoveJSON`）を読み込み、`Enemy` の初期化に使う。

- `RelicDatabase.swift`
  - `RelicData.json` を読み込み、`Relic` 型へ変換して保持。
  - トリガー（onBattleStart / onTurnStart）や効果種別の翻訳を行い、ID で検索できる `getRelic(by:)` を提供。

### Managers

- `SaveManager.swift`
  - シングルトン `SaveManager.shared`。
  - `SaveData` を JSON エンコードして `UserDefaults` に保存/読み込み/削除する機能を提供。

- `BattleManager.swift`
  - 戦闘の状態機械（BattleState）を持ち、非同期でゲーム進行を管理する中心的クラス。
  - プレイヤーターン・敵ターンのハンドリング、カード適用（`useCard` / `applyCardEffect`）、勝敗判定（`checkWinCondition`）等を実装。
  - レリック発動のトリガーや、ターン内メッセージ表示（`showMessage`）などの演出補助も含む。

- `BattleDeckManager.swift`
  - 山札/手札/捨て札/除外のデッキ運用を担当。ドロー、シャッフル、プレイ（捨てる）、除外、手札破棄等の基本操作を実装。

- `RunManager.swift`
  - 冒険（ラン）の進行を保持するクラス。所持レリック、マスターデッキ、マップ、現在ノード、プレイヤー等を持つ。
  - 起動時に `GameSettings` / 各 Database を読み込み、セーブがあれば復元する処理を持つ。
  - マップ読み込み、ノード移動（`advanceToNextNode()`）、セーブ（`saveCurrentState()`）を実装。

- `ShopManager.swift`
  - ショップの在庫生成（カード・レリック）、購入処理、カード廃棄サービスの管理を行う。
  - `ShopCardItem` / `ShopRelicItem` を用いて UI 用データを保持。

### Models

フォルダは細分化されています。代表的なファイルを抜粋します。

- `Models/Card/Card.swift`
  - `Card` 構造体。ID・baseId・name・cost・traits・target・effects・isUpgraded を持ち、`upgrade()` を実装。

- `Models/Card/CardEffect.swift`
  - `CardEffect` プロトコル（description と execute を定義）と各効果の実装（DealDamageEffect, GainShieldEffect, DrawCardEffect, HealEffect, ApplyStatusEffect, GainEnergyEffect, DealDamageToAllEffect, TakeDamageEffect, DealRandomDamageEffect, GainStrengthEffect）。
  - 各効果は `@MainActor func execute(manager: BattleManager, target: Enemy?) async` を持ち、戦闘ロジックへ作用する。

- `Models/Battle/CombatEntityProtocol.swift` (プロトコルファイル)
  - `StatusType` 列挙と `CombatEntity` (敵/プレイヤーに共通の API) を定義。
  - 拡張で `takeDamage` と `decrementStatuses` の共通実装を提供。

- `Models/Battle/Enemy.swift`
  - `Enemy` クラス（Observable）。HP/シールド/ステータス/意図(intent) を持ち、AI 定義（AIJSON）に基づき `determineNextIntent()` を決定する。

- `Models/Battle/PlayerShip.swift`
  - `PlayerShip` クラス（Observable, CombatEntity 実装）。エネルギー管理や所持金(credits) を持つ。

- `Models/Relic/Relic.swift`
  - `Relic` 構造。`RelicTrigger`, `RelicEffectType` と合わせて、トリガー／効果定義を持つ。

- `Models/Map/MapNode.swift`
  - `MapNode`, `NodeType`, `MapData`。マップのノード定義とシリアライズ用実装。

- `Models/Settings/GameSettings.swift`
  - `GameSettings`（JSON から読み込む設定データ構造体群）。ゲーム内で参照される定数やメッセージを保持し、`loadAll()` で `GameSettings.json` を読み込む。

### Persistent

- `Persistent/Item.swift`
  - SwiftData の `@Model` を使用した簡易エンティティ（例: timestamp のみ）。

- `Persistent/SaveData.swift`
  - セーブ用の軽量データ構造（`SavedCard`, `SaveData`）。`SaveData` はプレイヤーHP、エネルギー、masterDeck（SavedCard）、relicIds、mapFloors、currentNodeId を持つ。

### Views

Views 以下は `Components` と `Screens` に分かれています。主なファイルと役割を示します。

- Components/Battle/
  - `EnemyStatusView.swift`：敵ステータス（HPバー・シールド・次の意図など）表示。
  - `HandView.swift`：手札の表示とカードタップでの発動処理（ターゲットロックを受け取る）。
  - `PlayerStatusView.swift`：プレイヤー HP/EN/シールド/ステータス表示。
  - `MessageBoardView.swift`：戦闘中のメッセージ表示。
  - `StatusEffectRowView.swift`：ステータス（ターゲット/EMP/Strength など）のバッジ表示。
  - `TurnEndButtonView.swift`：ターン終了ボタン。

- Components/Common/
  - `CardView.swift`：カードの見た目（コスト・名前・効果説明等）を描画する汎用コンポーネント。
  - `CardGridView.swift`：カード一覧をグリッドで表示する汎用ビュー（選択/キャンセル用ハンドラあり）。
  - `TopStatusBarView.swift`：画面上部のステータスバー（HP/所持金/デッキ/レリック確認）

- Components/Rest/
  - `ChoiceButtonView.swift`：休憩オプション（回復/強化/廃棄）を表すボタンコンポーネント。

- Components/Shop/
  - `BuyButtonView.swift`：価格表示付き購入ボタン。
  - `RelicView.swift`：レリックの見た目。
  - `RemovalView.swift`：カード廃棄サービスのカードUI。
  - `SoldOutView.swift`：売り切れ表示。

- Screens/
  - `TitleView.swift`：タイトル画面（NEW / RESUME）とデバッグ用セーブ削除。
  - `MapView.swift`：マップ描画、ノード選択、経路表示（PreferenceKey を使ってノード位置を計算）。
  - `BattleView.swift`：戦闘メイン画面（敵列、メッセージ、手札、ターン終了など）。
  - `RewardView.swift`：戦闘勝利後の報酬カード選択画面。
  - `TreasureView.swift`：宝箱（レリック取得）画面。
  - `RestView.swift`：休憩画面（回復/強化/廃棄選択）。
  - `ShopView.swift`：ショップ画面（カード/レリック購入、廃棄サービス）
  - `RestartView.swift`：勝利/敗北後の再開画面。
  - `GameClearView.swift`：ゲームクリア画面。

---

## 実行・開発メモ

- 必要なリソースは `Resources/GameData/` 内の JSON（`CardData.json`, `EnemyData.json`, `RelicData.json`, `GameSettings.json`, `MapData.json`）と `Resources/Assets.xcassets`。
- 初回起動時に `RunManager` が `GameSettings.loadAll()` と各 Database のロードを行う設計。
- セーブは `UserDefaults`（`SaveManager`）にバイナリ化した JSON を格納する仕様。

## 仕様メモ／注意点

- `CardDatabase.getCard(by:)` は `allCardsData` の設計図から新しい Card を生成して返す。保存は `SavedCard(baseId:isUpgraded:)` を使うため、復元時は `getCard(by:)` で実体を作る必要がある。
- `BattleManager` は非同期処理（async/await）を多用しているため UI スレッドでの呼び出しや Task の使い方に注意。
