//
//  RelicCatalog.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/26.
//


import Foundation

// MARK: - JSON読み込み用の型
struct RelicCatalog: Codable {
    let relics: [RelicJSON]
}
struct RelicJSON: Codable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    let trigger: String
    let effect: RelicEffectJSON
}
struct RelicEffectJSON: Codable {
    let type: String
    let amount: Int
}

// MARK: - ゲーム内で使うレリックの型
enum RelicTrigger {
    case onBattleStart // 戦闘開始時
    case onTurnStart   // 自分のターン開始時
}
enum RelicEffectType {
    case gainEnergy
    case gainShield
    case heal
    case gainStrength
}

struct Relic: Identifiable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    let trigger: RelicTrigger
    let effectType: RelicEffectType
    let amount: Int
}

// MARK: - データベース本体
struct RelicDatabase {
    static var allRelics: [Relic] = []
    
    static func loadFromJSON() {
        if let catalog = DataLoader.load("RelicData", as: RelicCatalog.self) {
            allRelics = catalog.relics.compactMap { convert(json: $0) }
            print("✅ レリックデータを \(allRelics.count) 件読み込みました！")
        }
    }
    
    private static func convert(json: RelicJSON) -> Relic? {
        // 発動タイミングの翻訳
        let trigger: RelicTrigger
        switch json.trigger {
        case "onBattleStart": trigger = .onBattleStart
        case "onTurnStart": trigger = .onTurnStart
        default: return nil
        }
        
        // 効果の翻訳
        let effectType: RelicEffectType
        switch json.effect.type {
        case "gainEnergy": effectType = .gainEnergy
        case "gainShield": effectType = .gainShield
        default: return nil
        }
        
        return Relic(id: json.id, name: json.name, description: json.description, imageName: json.imageName, trigger: trigger, effectType: effectType, amount: json.effect.amount)
    }
}
