//
//  Enemy.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//
import Foundation
import Observation

// 敵（クラス）
@Observable
class Enemy: CombatEntity, Identifiable {
    let id = UUID()
    let category: String
    var name: String
    
    var imageName: String
    
    var maxHP: Int
    var currentHP: Int
    var shield: Int = 0
    var statuses: [StatusType: Int] = [:]
    
    var intent: EnemyIntent?
    var turnCount: Int = 0 // 🌟 追加：自分が何ターン行動したかを記憶する
    
    init(category: String, name: String, imageName: String, maxHP: Int) {
        self.category = category
        self.name = name
        self.imageName = imageName
        self.maxHP = maxHP
        self.currentHP = maxHP
    }
    
    // 🌟 AIの心臓部：敵の種類（id）によって行動を変える！
    func determineNextIntent() {
        turnCount += 1
        
        switch category {
        case "flagship":
            // 💀 ボス専用：恐怖の3ターンローテーションAI
            let phase = turnCount % 3
            if phase == 1 {
                self.intent = .charge            // 1ターン目：充填
            } else if phase == 2 {
                self.intent = .attack(damage: 25) // 2ターン目：極大攻撃
            } else {
                self.intent = .defend(amount: 20) // 3ターン目(0になります)：絶対防壁
            }
        case "scout": // 偵察機：攻撃と防御を交互に繰り返す
            if turnCount % 2 == 1 {
                intent = .attack(damage: 8)
            } else {
                intent = .defend(amount: 5)
            }
            
        case "cruiser": // 巡洋艦：ひたすら重い一撃を放つ
            intent = .attack(damage: 15)
            
        case "interceptor": // 迎撃ドローン：3ターンに1回、強力な攻撃！
            if turnCount % 3 == 0 {
                intent = .attack(damage: 20)
            } else {
                intent = .attack(damage: 5)
            }
            
        default:
            intent = .attack(damage: 10)
        }
    }
}
