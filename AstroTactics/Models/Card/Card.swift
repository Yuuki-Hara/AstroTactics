//
//  Card.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Foundation

enum CardTrait {
    case beam, missile, mech, defense, command
}

enum TargetType {
    case singleEnemy, allEnemies, randomEnemy, selfTarget
}

struct Card: Identifiable {
    let id: UUID = UUID() // 生成時に自動で割り振り
    let baseId: String
    var name: String
    var cost: Int
    let traits: [CardTrait]
    let target: TargetType
    let effects: [CardEffect]
    var isUpgraded: Bool = false
    
    mutating func upgrade() {
        guard !isUpgraded else { return }
        
        self.isUpgraded = true
        self.name = self.name + "+"
        
        if self.cost > 0 {
            self.cost -= 1
        }
    }
}
