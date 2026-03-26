//
//  GameConfigJSON.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//


import Foundation

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
        if let loadedConfig = DataLoader.load("GameConfig", as: GameConfigJSON.self) {
            config = loadedConfig
            print("✅ ゲーム基本ルール（Config）を読み込みました！")
        }
        
        if let loadedMessages = DataLoader.load("MessageData", as: MessageDataJSON.self) {
            messages = loadedMessages
            print("✅ UIテキスト（Message）を読み込みました！")
        }
    }
}
