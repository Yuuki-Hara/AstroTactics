//
//  GameSettingsData.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/04/06.
//

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
