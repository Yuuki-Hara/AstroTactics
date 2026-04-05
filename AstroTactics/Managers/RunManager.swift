//
//  RunManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import Foundation
import Observation

@Observable
class RunManager {
  var relics: [Relic] = []
  var baseDeck: [Card] = []
  var mapFloors: [[MapNode]] = []
  var currentNodeId: String?

  var player: PlayerShip

  init() {
    GameSettings.loadAll()
    CardDatabase.loadFromJSON()
    EnemyDatabase.loadFromJSON()
    RelicDatabase.loadFromJSON()

    // 🌟 セーブデータがあるかチェック！
    if let savedData = SaveManager.shared.load() {
      // ==========================================
      // 【再開】セーブデータからの復元処理
      // ==========================================

      // 1. プレイヤーの復元
      let loadedPlayer = PlayerShip(
        name: GameSettings.config.playerShipName,
        maxHP: savedData.playerMaxHP,
        maxEnergy: savedData.playerMaxEnergy
      )
      // 🌟 一時的な変数のHPを書き換えます（これなら怒られません）
      loadedPlayer.currentHP = savedData.playerCurrentHP
      self.player = loadedPlayer

      // 2. マップ情報の復元
      self.mapFloors = savedData.mapFloors
      self.currentNodeId = savedData.currentNodeId

      // 3. デッキの復元（IDから本物のカードを生成）
      self.baseDeck = savedData.baseDeck.compactMap { savedCard in
        // ⚠️ 注意: ここはあなたの CardDatabase の仕様に合わせて調整してください
        // 例: idで検索してカードのコピーを取得するメソッドがあると仮定しています
        if var realCard = CardDatabase.getCard(by: savedCard.baseId) {
          if savedCard.isUpgraded {
            realCard.upgrade()
          }
          return realCard
        }
        return nil
      }

      // 4. レリックの復元（IDから本物のレリックを生成）
      self.relics = savedData.relicIds.compactMap { relicId in
        return RelicDatabase.getRelic(by: relicId)
      }

      print("💾 セーブデータを復元して再開します！")

    } else {
      // ==========================================
      // 【新規】今までの初期化処理
      // ==========================================
      self.player = PlayerShip(
        name: GameSettings.config.playerShipName,
        maxHP: GameSettings.config.playerStartingHP,
        maxEnergy: GameSettings.config.playerStartingEnergy
      )
      self.baseDeck = CardDatabase.startingDeck()
      self.relics = []
      loadMapData()
      print("✨ 新規ゲームとしてデータを準備しました！")
    }
  }

  // 今いるマスの情報を取得する便利機能
  var currentNode: MapNode? {
    guard let id = currentNodeId else { return nil }
    return mapFloors.flatMap { $0 }.first(where: { $0.id == id })
  }

  func canEnter(node: MapNode) -> Bool {
    if currentNodeId == nil {
      return mapFloors.first?.contains(where: { $0.id == node.id }) ?? false
    }
    if let current = currentNode {
      return current.nextNodeIds.contains(node.id)
    }
    return false
  }

  func advanceToNextNode() {
    if let current = currentNode {
      for floorIndex in 0..<mapFloors.count {
        if let nodeIndex = mapFloors[floorIndex].firstIndex(where: { $0.id == current.id }) {
          mapFloors[floorIndex][nodeIndex].isCompleted = true
        }
      }
    }

    // 🌟 マスを進んだら自動的にセーブする！
    saveCurrentState()
  }

  // MARK: - 🌟 セーブ機能の追加
  func saveCurrentState() {
    // デッキを軽量な SavedCard に変換
    let deckToSave = self.baseDeck.map { card in
      SavedCard(baseId: card.baseId, isUpgraded: card.isUpgraded)
    }

    // レリックをIDの文字列配列に変換（relic.id や relic.baseId など、あなたの設定に合わせてください）
    let relicsToSave = self.relics.map { relic in
      relic.id  // もしRelicのプロパティ名が違えば修正してください
    }

    // 保存用データの作成
    let data = SaveData(
      playerCurrentHP: self.player.currentHP,
      playerMaxHP: self.player.maxHP,
      playerMaxEnergy: self.player.maxEnergy,
      baseDeck: deckToSave,
      relicIds: relicsToSave,
      mapFloors: self.mapFloors,
      currentNodeId: self.currentNodeId
    )

    // Managerを使って保存
    SaveManager.shared.save(data: data)
    print("💾 現在の進行状況をセーブしました")
  }

  // MARK: - JSONファイルの読み込み処理
  private func loadMapData() {
    do {
      let decodedData = try JSONLoader.load("MapData", as: MapData.self)
      self.mapFloors = decodedData.floors
      print("✅ マップデータを読み込みました！")
    } catch {
      print("🚨 RunManager: failed to load MapData.json: \(error)")
    }
  }
}
