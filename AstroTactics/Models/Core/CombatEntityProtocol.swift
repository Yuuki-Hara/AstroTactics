//
//  Protocols.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

// 共通仕様（プロトコル）
// AnyObjectを継承することで、これを採用する型がクラス（参照型）であることを保証します
protocol CombatEntity: AnyObject {
    var name: String { get }
    var maxHP: Int { get }
    var currentHP: Int { get set }
    var shield: Int { get set }
    var statuses: [StatusType: Int] { get set }
    
    func takeDamage(amount: Int) -> (damageToHP: Int, blocked: Int)
    func decrementStatuses()
}

// プロトコルの拡張（デフォルト実装）
// 自艦も敵も「ダメージ計算のルール」は同じなので、ここに共通処理を書いてしまいます
extension CombatEntity {
    // 敵がダメージを受ける処理
    @discardableResult
    func takeDamage(amount: Int) -> (damageToHP: Int, blocked: Int) {
        var finalDamage = amount
        
        // 🌟 追加：ターゲット(被ダメ増)の効果を計算！
        if statuses[.target, default: 0] > 0 {
            finalDamage = Int(Double(finalDamage) * 1.5) // ダメージ1.5倍！
            print("🎯 ターゲット効果でダメージ増大！(\(amount) -> \(finalDamage))")
        }
        
        let blockedByShield: Int
        let actualDamageToHP: Int
        
        // シールドでダメージを軽減する処理
        if shield >= finalDamage {
            blockedByShield = finalDamage
            shield -= finalDamage
            actualDamageToHP = 0
        } else {
            blockedByShield = shield
            actualDamageToHP = finalDamage - shield
            shield = 0
            currentHP -= actualDamageToHP
        }
        
        // HPがマイナスにならないようにする
        if currentHP < 0 { currentHP = 0 }
        
        return (damageToHP: actualDamageToHP, blocked: blockedByShield)
    }
    
    // 🌟 追加：ターン終了時に状態異常のカウントを減らす処理
    func decrementStatuses() {
        var nextStatuses: [StatusType: Int] = [:]
        
        for (status, amount) in statuses {
            if amount > 1 {
                // まだ効果が続く場合は、数値を1減らして引き継ぐ
                nextStatuses[status] = amount - 1
            } else {
                // 1以下の場合は引き継がない（＝効果が切れて消滅する）
                print("✨ \(name)の \(status) の効果が切れた！")
            }
        }
        
        // 新しい状態異常リストに上書きする
        statuses = nextStatuses
    }
}
