//
//  CardDatabase.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/22.
//

import Foundation

// ゲーム内に登場するカードを定義するカタログ（マスターデータ）
struct CardDatabase {
    
    // ゲーム開始時にプレイヤーが持っている「初期デッキ」を生成して返す
    static func startingDeck() -> [Card] {
        return [
            // 攻撃カード（3枚）
            Card(baseId: "strike", name: "主砲発射", cost: 1, traits: [.beam], target: .singleEnemy, effects: [DealDamageEffect(amount: 10)]),
            Card(baseId: "strike", name: "主砲発射", cost: 1, traits: [.beam], target: .singleEnemy, effects: [DealDamageEffect(amount: 10)]),
            Card(baseId: "strike", name: "主砲発射", cost: 1, traits: [.beam], target: .singleEnemy, effects: [DealDamageEffect(amount: 10)]),
            
            // 防御カード（2枚）
            Card(baseId: "defend", name: "シールド展開", cost: 1, traits: [.defense], target: .selfTarget, effects: [GainShieldEffect(amount: 8)]),
            Card(baseId: "defend", name: "シールド展開", cost: 1, traits: [.defense], target: .selfTarget, effects: [GainShieldEffect(amount: 8)]),
            
            // 回復カード（1枚）：コストは高いがHPが回復する
            Card(baseId: "repair", name: "緊急ナノ修理", cost: 2, traits: [.mech], target: .selfTarget, effects: [HealEffect(amount: 15)]),
            
            // ドローカード（1枚）：コスト0でカードを引ける！
            Card(baseId: "tactics", name: "戦術分析", cost: 0, traits: [.command], target: .selfTarget, effects: [DrawCardEffect(count: 2)]),
            
            // 複合カード（1枚）：ダメージを与えつつ、デバフも与える
            Card(baseId: "missile", name: "徹甲ミサイル", cost: 2, traits: [.missile], target: .singleEnemy, effects: [
                DealDamageEffect(amount: 12),
                ApplyStatusEffect(status: .target, amount: 1)
            ])
        ]
    }
    
    static func allRewardCards() -> [Card] {
            return [
                Card(baseId: "twin_laser", name: "ツインレーザー", cost: 1, traits: [.beam], target: .singleEnemy, effects: [DealDamageEffect(amount: 6), DealDamageEffect(amount: 6)]),
                Card(baseId: "heavy_armor", name: "超合金装甲", cost: 2, traits: [.defense], target: .selfTarget, effects: [GainShieldEffect(amount: 15)]),
                Card(baseId: "emergency_draw", name: "緊急ドロー", cost: 0, traits: [.command], target: .selfTarget, effects: [DrawCardEffect(count: 3)]),
 
                Card(baseId: "missile_pod", name: "拡散ミサイル", cost: 2, traits: [.missile], target: .allEnemies, effects: [DealDamageToAllEffect(amount: 8)]),

                Card(baseId: "reactor_boost", name: "リアクター暴走", cost: 0, traits: [.mech], target: .selfTarget, effects: [GainEnergyEffect(amount: 2), TakeDamageEffect(amount: 3)]),

                Card(baseId: "tactical_guard", name: "戦術防壁", cost: 1, traits: [.command, .defense], target: .selfTarget, effects: [GainShieldEffect(amount: 4), DrawCardEffect(count: 1)]),

                Card(baseId: "hyper_cannon", name: "ハイパーカノン", cost: 3, traits: [.beam], target: .singleEnemy, effects: [DealDamageEffect(amount: 25)])
            ]
        }
}
