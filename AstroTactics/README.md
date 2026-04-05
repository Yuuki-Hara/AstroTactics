# AstroTactics — リファクタリング計画

この README はリポジトリ内コードのリファクタリング方針、段階的タスク、並びにリファクタリング後の推奨フォルダ構成と各ファイル（/コンポーネント）の役割をまとめたものです。

目的:

- 可読性・保守性・テスト容易性を高める。
- UI とドメインロジックを分離し、単体テストを実装しやすくする。
- 将来的な拡張（効果追加・AI ルール追加・ローカライズ）を容易にする。

---

## 要求チェックリスト

- [x] リファクタリングの高レベル方針を提示
- [x] 具体的な改善案（Data 層 / Domain / Managers / UI）を提示
- [x] 優先度付きの段階実施プラン（PR 単位）を提示
- [x] リファクタリング後の推奨フォルダ構成を提示
- [x] 各ファイル／コンポーネントの簡潔な役割を整理

---

## 高レベル方針

1. 単一責任（SRP）を徹底し、ファイル・型ごとに一つの責務に限定する。
2. 層分離（Domain / Services / Persistence / UI(View + ViewModel)）を明確化する。
3. 依存注入（protocol を用いる）でテストを容易にする。
4. 非同期処理は @MainActor とビジネス層で責務を分け、Task のキャンセルと再入を考慮する。
5. JSON 読み込みは `throws` にして呼び出し側でハンドリングする。
6. ロガーと Lint/Format を導入して品質と一貫性を担保する。

---

## 具体的な改善案（抜粋）

- Data 層
  - `DataLoader` を例外（throws）を返す `JSONLoader` に変更。
  - JSON DTO（CardJSON 等）を `Services/DTOs` にまとめ、Domain 変換を `Mappers/Repositories` に移す。

- Domain
  - `Card`, `Enemy`, `PlayerShip`, `Relic` を可能な限り不変（let）で定義。
  - `CardEffect` は軽量な struct とし、副作用は Manager に委譲する。

- Managers / Services
  - `RunManager`, `BattleManager`, `ShopManager`, `BattleDeckManager` を protocol 抽象化。
  - `BattleManager` の UI 露出は `BattleViewModel` 経由に限定する。

- UI (MVVM)
  - 各画面は View + ViewModel。ViewModel は Observable な状態のみ公開し、View はそれを描画。

- テスト
  - `JSONLoader`, `BattleDeckManager`, `BattleManager` のユニットテストを優先的に追加。

---

## 優先度付き段階実施プラン（PR 単位）

1. CI／Lint 導入: SwiftLint, SwiftFormat 設定。テストターゲット追加。
2. JSONLoader: `DataLoader` を throws ベースの `JSONLoader` に置換。`CardDatabase.loadFromJSON` 等の呼び出しを修正。
3. DTO と Mapper 分離: `CardJSON` などを DTO に移し、`CardRepository` を導入して変換とキャッシュを担当させる。
4. SaveStore 抽象化: `SaveStore` protocol と `UserDefaultsSaveStore` 実装を作る。`RunManager` は protocol 経由で保存。
5. Battle → ViewModel 移行: `BattleViewModel` を作成し、`BattleManager` を注入。View は ViewModel を参照するみに。
6. Manager の protocol 化とモックの追加（テスト用）。
7. CardEffect のリファクタ（必要なら効果の純関数化と Manager 実行への委譲）。

各 PR は小さく、ビルド可能な状態を保ちながら段階的に適用してください。

---

## リファクタ後の推奨フォルダ構成

（Xcode プロジェクトでも同様に反映）

- App/
  - AstroTacticsApp.swift
  - ContentView.swift
  - AppCoordinator.swift (任意)
- Sources/
  - Domain/
    - Card/
      - Card.swift
      - CardTrait.swift
    - Battle/
      - Enemy.swift
      - PlayerShip.swift
      - CombatEntity.swift
    - Relic/
      - Relic.swift
    - Map/
      - MapNode.swift
    - Settings/
      - GameSettings.swift
  - Services/
    - JSON/
      - JSONLoader.swift
      - DTOs/ (CardDTO.swift, EnemyDTO.swift, ...)
    - Repositories/
      - CardRepository.swift
      - EnemyRepository.swift
    - Persistence/
      - SaveStore.swift
      - UserDefaultsSaveStore.swift
  - Managers/
    - Run/
      - RunManaging.swift
      - RunManager.swift
    - Battle/
      - BattleManaging.swift
      - BattleManager.swift
    - Deck/
      - BattleDeckManaging.swift
      - BattleDeckManager.swift
    - Shop/
      - ShopManaging.swift
      - ShopManager.swift
  - ViewModels/
    - BattleViewModel.swift
    - MapViewModel.swift
    - ShopViewModel.swift
  - UI/
    - Views/
      - TitleView.swift
      - MapView.swift
      - BattleView.swift
      - ...
    - Components/
      - CardView.swift
      - CardGridView.swift
      - TopStatusBarView.swift
      - Battle/ (HandView, EnemyStatusView...)
  - Utilities/
    - BattleMessageFormatter.swift
    - Logger.swift
- Resources/
  - Assets.xcassets/
  - GameData/
    - CardData.json
    - EnemyData.json
    - RelicData.json
    - MapData.json
    - GameSettings.json
- Tests/
  - DomainTests/
  - ServiceTests/
  - ManagerTests/

---

## 主要ファイル／コンポーネントの役割（短評）

- `JSONLoader.swift` — 汎用 JSON 読み込み。`func load<T: Decodable>(_ name: String) throws -> T`。
- `CardRepository.swift` — DTO → Domain 変換、設計図キャッシュと検索 API。
- `BattleManager.swift` — ターン進行・勝敗判定・レリックトリガーを担当（副作用はここで発生）。
- `BattleViewModel.swift` — `BattleManager` を注入し、View 用の Observable 状態を提供。View からの操作を受ける。
- `BattleDeckManager.swift` — 山札/手札/捨て/除外の基本操作実装と単体テスト対象。
- `SaveStore` — セーブ/ロードの抽象。現行 `SaveManager` を`UserDefaultsSaveStore` として移行。

---

## テスト優先箇所

1. `JSONLoader`（成功・キー欠落・型不一致・壊れた JSON）
2. `BattleDeckManager`（ドロー／シャッフル／捨て／除外）
3. `BattleManager` のコアフロー（簡単なシナリオで勝敗判定、カード効果適用、レリック反応）
4. `RunManager` のセーブ/復元ロジック（SavedCard の復元検証）

---

## 注意点・リスク

- 大規模変更は段階的に。各 PR は必ずビルド通過と主要ユニットテストの追加を伴うこと。
- 非同期・Task の再入とキャンセル管理を怠ると UI の二重処理やクラッシュ原因になる。
- Save 互換性はバージョニングを検討する（fields の追加/削除）。

---

## 次にできること（私が作業可能なもの）

- まずは `JSONLoader` と `CardRepository` を実装する PR の差分を生成します。
- あるいは SwiftLint / SwiftFormat の設定ファイルを追加します。

どちらを先に進めますか？
