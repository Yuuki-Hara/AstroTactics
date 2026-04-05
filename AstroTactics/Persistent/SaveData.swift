//
//  SaveData.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Foundation

// 🌟 カードをメモするための軽量データ
struct SavedCard: Codable {
  let baseId: String
  let isUpgraded: Bool
}

// 🌟 セーブデータ本体
struct SaveData: Codable {
  // ① プレイヤー情報
  var playerCurrentHP: Int
  var playerMaxHP: Int
  var playerMaxEnergy: Int

  // ② 所持品（メモ）
  var baseDeck: [SavedCard]
  var relicIds: [String]

  // ③ マップの進行状況
  var mapFloors: [[MapNode]]
  var currentNodeId: String?
}
