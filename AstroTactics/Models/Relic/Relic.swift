//
//  RelicTrigger.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/28.
//


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
