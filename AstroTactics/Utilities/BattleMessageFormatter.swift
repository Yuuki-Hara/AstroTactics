//
//  BattleMessageFormatter.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import Foundation

// 🌟 画面に出す「日本語のメッセージ」を作るためだけの専門家
struct BattleMessageFormatter {

  static func cardPlayed(cardName: String) -> String {
    return "「\(cardName)」を発動！"
  }

  static func damage(targetName: String, hpDamage: Int, blocked: Int) -> String {
    if blocked > 0 {
      return "\(targetName)に \(hpDamage) ダメージ！\n(\(blocked) ブロック)"
    } else {
      return "\(targetName)に \(hpDamage) のダメージ！"
    }
  }

  static func shieldGained(amount: Int) -> String {
    return "シールドを \(amount) 展開！"
  }

  static func cardDrawn(count: Int) -> String {
    return "カードを \(count) 枚引いた！"
  }

  static func healed(amount: Int) -> String {
    return "HPが \(amount) 回復した！"
  }

  static func statusApplied(status: StatusType) -> String {
    let statusName = status == .target ? "ターゲット(被ダメ増)" : "EMP"
    return "敵に \(statusName) を付与！"
  }

  static func enemyAttack(enemyName: String) -> String {
    return "\(enemyName)の攻撃！"
  }

  static func enemyDefend(enemyName: String, amount: Int) -> String {
    return "\(enemyName)が\nシールドを \(amount) 展開！"
  }

  static func energyGained(amount: Int) -> String {
    return "エナジーを \(amount) 回復！"
  }

  static func damageToAll() -> String {
    return "敵全体への範囲攻撃！"
  }

  static func takeDamage(amount: Int) -> String {
    return "自身に \(amount) の反動ダメージ！"
  }

  static func enemyCharge(enemyName: String) -> String {
    return "\(enemyName) はエネルギーを充填している…！"
  }

  static func gainEnergyByRelic(name: String, amount: Int) -> String {
    return "[\(name)] エナジー+\(amount)"
  }

  static func gainShieldByRelic(name: String, amount: Int) -> String {
    return "[\(name)] シールド+\(amount)"
  }

}
