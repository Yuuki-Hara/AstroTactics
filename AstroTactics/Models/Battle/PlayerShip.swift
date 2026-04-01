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
    var shield: Int = 0
    var strength: Int = 0
    var statuses: [StatusType: Int] = [:]
    var credits: Int = 200
    
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
}
