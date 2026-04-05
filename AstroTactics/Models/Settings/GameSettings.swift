//
//  GameConfigJSON.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//

import Foundation

struct GameSettingsData: Codable {
  let config: GameConfigJSON
  let messages: MessageDataJSON
}

// MARK: - JSONの受け皿（型）
struct GameConfigJSON: Codable {
  let playerShipName: String
  let playerStartingHP: Int
  let playerStartingEnergy: Int
  let restHealPercentage: Double
  let battleFieldName: String
  let restFieldName: String
  let bossFieldName: String
  let treasureFieldName: String
  let shopFieldName: String

  let battleRewardMin: Int
  let battleRewardMax: Int
  let shopCardPriceMin: Int
  let shopCardPriceMax: Int
  let shopRelicPriceMin: Int
  let shopRelicPriceMax: Int
  let shopRemovalPrice: Int
}

struct MessageDataJSON: Codable {
  let mapTitle: String
  let restTitle: String
  let restDescription: String
  let restHealButton: String
  let restHealSubText: String
  let gameClearTitle: String
  let gameClearSubText1: String
  let gameClearSubText2: String
  let returnToTitle: String
  let playerCannotAct: String
  let enemyCannotAct: String
  let playerTurnStart: String
  let enemyAction: String
  let turnEnd: String
  let goNext: String
  let missionClear: String
  let gameOver: String
}

// MARK: - アプリ全体で共有する設定の保管庫
struct GameSettings {
  // どこからでも GameSettings.config.playerStartingHP のようにアクセスできる！
  static var config: GameConfigJSON!
  static var messages: MessageDataJSON!

  // 🌟 アプリ起動時に一括で読み込む
  static func loadAll() {
    do {
      let loadData = try JSONLoader.load("GameSettings", as: GameSettingsData.self)
      config = loadData.config
      messages = loadData.messages
      print("✅ ゲーム設定（GameSettings.json）を統合して読み込みました！")
    } catch {
      print("❌ GameSettingsの読み込みに失敗しました！ \(error)")
    }
  }
}
