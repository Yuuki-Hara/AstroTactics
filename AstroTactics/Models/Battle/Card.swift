//
//  Card.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Foundation

struct Card: Identifiable {
    let id: UUID = UUID() // 生成時に自動で割り振り
    let baseId: String
    let name: String
    let cost: Int
    let traits: [CardTrait]
    let target: TargetType
    let effects: [CardEffect]
    var isUpgraded: Bool = false
}
