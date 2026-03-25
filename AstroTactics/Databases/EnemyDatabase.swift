//
//  EnemyDatabase.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/22.
//
import Foundation

// MARK: - JSONを読み込むための型
struct EnemyCatalog: Codable {
    let enemies: [EnemyJSON]
}

struct EnemyJSON: Codable {
    let category: String
    let name: String
    let imageName: String
    let maxHP: Int
    let ai: AIJSON // 🌟 AI情報を追加
}

// 🌟 AIの設計図
struct AIJSON: Codable {
    let type: String // "random" か "rotation"
    let moves: [MoveJSON]
}

// 🌟 1つ1つの行動の設計図
struct MoveJSON: Codable {
    let intent: String
    let amount: Int? // 固定値（例: 25ダメージ）
    let min: Int?    // ランダムの最小値
    let max: Int?    // ランダムの最大値
}

// MARK: - 敵データベース本体
struct EnemyDatabase {
    
    // JSONから読み込んだ「敵の設計図」を保管する場所
    static var allEnemiesData: [EnemyJSON] = []
    
    // 🌟 アプリ起動時にJSONを読み込む関数
    static func loadFromJSON() {
        if let catalog = DataLoader.load("EnemyData", as: EnemyCatalog.self) {
            allEnemiesData = catalog.enemies
            print("✅ 敵データを \(allEnemiesData.count) 件読み込みました！")
        }
    }
    
    // MARK: - 敵の生成
    
    // 🌟 雑魚敵をランダムに生成して返す（ボス以外から選ぶ）
    static func randomEnemy() -> Enemy {
        let normalEnemies = allEnemiesData.filter { $0.category != "boss" }
        
        guard let template = normalEnemies.randomElement() else {
            // 万が一JSONが空だった場合の保険
            let dummyAI = AIJSON(type: "random", moves: [MoveJSON(intent: "attack", amount: 1, min: nil, max: nil)])
            return Enemy(category: "scout", name: "未知の敵", imageName: "questionmark.diamond", maxHP: 10, ai: dummyAI)
        }
        
        return Enemy(category: template.category, name: template.name, imageName: template.imageName, maxHP: template.maxHP, ai: template.ai)
    }
    
    // 🌟 ボスを生成して返す
    static func bossFlagship() -> Enemy {
        guard let template = allEnemiesData.first(where: { $0.category == "boss" }) else {
            let dummyAI = AIJSON(type: "random", moves: [MoveJSON(intent: "attack", amount: 1, min: nil, max: nil)])
            return Enemy(category: "boss", name: "ボスが見つかりません", imageName: "exclamationmark.triangle", maxHP: 1, ai: dummyAI)
        }
        
        return Enemy(category: template.category, name: template.name, imageName: template.imageName, maxHP: template.maxHP, ai: template.ai)
    }
}
