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

// MARK: - データベース本体
struct RelicDatabase {
  static var allRelics: [Relic] = []

  static func loadFromJSON() {
    do {
      let catalog = try JSONLoader.load("RelicData", as: RelicCatalog.self)
      allRelics = catalog.relics.compactMap { convert(json: $0) }
      print("✅ レリックデータを \(allRelics.count) 件読み込みました！")
    } catch {
      print("🚨 RelicDatabase: failed to load RelicData.json: \(error)")
    }
  }

  // 🌟 セーブデータからレリックを復元するための機能
  static func getRelic(by id: String) -> Relic? {
    // IDが一致するものを探して返す（レリックがクラスか構造体かによってコピーの必要性は変わりますが、基本はこれでOKです）
    return allRelics.first(where: { $0.id == id })
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

    return Relic(
      id: json.id, name: json.name, description: json.description, imageName: json.imageName,
      trigger: trigger, effectType: effectType, amount: json.effect.amount)
  }
}
