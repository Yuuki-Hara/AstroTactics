//
//  PlayerShip.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Foundation
import Observation

// 自艦（クラス）
// HPなど状態が変化していくため、StructではなくClass（参照型）で定義します
@Observable
class PlayerShip: CombatEntity {

  var name: String
  var maxHP: Int
  var currentHP: Int
  var statuses: [StatusType: Int] = [:]
  //    var statuses: [StatusType: Int] = [
  //        .shield: 15,         // シールド
  //        .strength: 3,        // 永続筋力
  //        .tempStrength: 2,    // 一時筋力
  //        .dexterity: 1,       // 装甲
  //        .target: 3,          // ターゲット
  //        .emp: 2              // EMP
  //    ]
  var credits: Int = 500

  var maxEnergy: Int
  var currentEnergy: Int

  init(name: String, maxHP: Int, maxEnergy: Int) {
    self.name = name
    self.maxHP = maxHP
    self.currentHP = maxHP
    self.maxEnergy = maxEnergy
    self.currentEnergy = maxEnergy
  }

  func resetEnergy() {
    currentEnergy = maxEnergy
    print("⚡️ \(name)のENが\(currentEnergy)に回復した。")
  }

  func resetStatuses() {
    statuses = [:]
    print("statusesを初期化した。")
  }
}
