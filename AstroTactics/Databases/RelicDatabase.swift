//
//  RelicCatalog.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/26.
//

import Foundation

// RelicRepository に責務を委譲
struct RelicDatabase {
  static var allRelics: [Relic] = []

  static func loadFromJSON() {
    do {
      allRelics = try RelicRepository.loadAll()
      print("✅ レリックデータを \(allRelics.count) 件読み込みました！")
    } catch {
      print("🚨 RelicDatabase: failed to load RelicData.json: \(error)")
    }
  }

  static func getRelic(by id: String) -> Relic? {
    return allRelics.first(where: { $0.id == id })
  }
}
