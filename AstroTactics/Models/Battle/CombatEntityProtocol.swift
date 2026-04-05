//
//  Protocols.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//
import SwiftUI

enum StatusValueBehavior {
  case duration  // ⏳ ターン数型：毎ターン -1 される
  case permanent  // ⚔️ 実数値・永続型：ずっと減らない
  case temporary  // 🔥 実数値・使い捨て型：ターン終了時にリセット
}

// MARK: - ステータスの種類と性質の定義
enum StatusType: String, Codable, CaseIterable {

  // ==========================================
  // ⚔️ 攻撃系バフ
  // ==========================================
  case strength  // 永続：攻撃力アップ（スタック型）
  case tempStrength  // 1ターン：一時的な攻撃力アップ（使い捨て型）

  // ==========================================
  // 🛡 防御系バフ
  // ==========================================
  case dexterity  // 永続：装甲アップ（シールド獲得量が増える）
  case shield
  // ※シールド自体は毎ターン0になる特殊な値なので、今まで通り `var shield: Int` で管理します

  // ==========================================
  // ☠️ デバフ（状態異常）
  // ==========================================
  case target  // ターン減少：狙われやすくなる、等
  case emp  // ターン減少：行動不能や弱体化、等

  var behavior: StatusValueBehavior {
    switch self {
    case .target, .emp:
      return .duration  // ターンで減る
    case .strength, .dexterity:
      return .permanent  // 減らない
    case .tempStrength, .shield:
      return .temporary  // ターン終了で消える
    }
  }

  // 🌟 2. アイコンの定義
  var iconName: String {
    switch self {
    case .shield: return "shield.fill"  // 🛡 追加
    case .strength: return "powermeter"
    case .tempStrength: return "flame.fill"
    case .dexterity: return "bolt.shield.fill"
    case .target: return "scope"
    case .emp: return "bolt.slash.fill"
    }
  }

  // 🌟 3. 色の定義
  var color: SwiftUI.Color {
    switch self {
    case .shield, .dexterity: return .blue  // 🛡 追加
    case .strength, .tempStrength: return .orange
    case .target: return .red
    case .emp: return .cyan
    }
  }
}

protocol CombatEntity: AnyObject {
  var name: String { get }
  var maxHP: Int { get }
  var currentHP: Int { get set }
  var statuses: [StatusType: Int] { get set }

  func takeDamage(baseAmount: Int, attacker: CombatEntity?) -> (damageToHP: Int, blocked: Int)
  func applyStartOfTurnLogic()
  func applyEndOfTurnLogic()
}

// プロトコルの拡張（デフォルト実装）
// 自艦も敵も「ダメージ計算のルール」は同じなので、ここに共通処理を書いてしまいます
extension CombatEntity {
  func addShield(baseAmount: Int) {
    // 現在の装甲値（dexterity）を取得（なければ0）
    let dex = statuses[.dexterity, default: 0]

    // 最終的なシールド獲得量を計算（※もしデバフで装甲がマイナスになっても、獲得量がマイナスにならないよう max で0止めします）
    let totalGain = max(0, baseAmount + dex)

    // シールドを加算！
    statuses[.shield, default: 0] += totalGain

    print("🛡 シールド獲得: 基本\(baseAmount) + 装甲\(dex) = 最終獲得量\(totalGain)")
  }

  func addstrength(baseAmount: Int) {
    statuses[.strength, default: 0] += baseAmount
    print("🛡 力強化獲得: 獲得量\(baseAmount)")
  }

  @discardableResult
  func takeDamage(baseAmount: Int, attacker: CombatEntity?) -> (damageToHP: Int, blocked: Int) {

    var finalDamage = baseAmount

    // ==========================================
    // ⚔️ 1. 攻撃側（Attacker）のバフ・デバフを計算
    // ==========================================
    if let attacker = attacker {
      // 攻撃側の筋力を足す
      let str = attacker.statuses[.strength, default: 0]
      let tempStr = attacker.statuses[.tempStrength, default: 0]
      finalDamage += (str + tempStr)

      // ※もし「弱体化（与えるダメージが減る）」などのデバフがあればここで計算します
    }

    // ==========================================
    // 🛡 2. 防御側（Self）のバフ・デバフを計算
    // ==========================================
    // 例: 「ターゲット」状態だと受けるダメージが +2 されるルールの場合はここに書く
    let targetDebuff = self.statuses[.target, default: 0]
    if targetDebuff > 0 {
      finalDamage += 2  // 1スタックにつき+2なのか、固定で+2なのかはゲームのルール次第です
    }

    // ※最終ダメージがマイナスにならないよう、念のため0でストッパーをかけます
    finalDamage = max(0, finalDamage)
    print("💥 ダメージ計算: 元\(baseAmount) -> 最終\(finalDamage)")

    // ==========================================
    // 🛡 3. シールドの処理とHP減少
    // ==========================================
    let currentShield = self.statuses[.shield, default: 0]

    if currentShield >= finalDamage {
      // シールドで全ブロック
      self.statuses[.shield] = currentShield - finalDamage
      return (0, finalDamage)
    } else {
      // シールド貫通
      let remainingDamage = finalDamage - currentShield
      self.statuses.removeValue(forKey: .shield)  // シールド破壊
      self.currentHP = max(0, self.currentHP - remainingDamage)
      return (remainingDamage, currentShield)
    }
  }

  func canAct() -> Bool {
    // EMPのスタックが0以下なら行動可能！
    let empCount = statuses[.emp, default: 0]
    return empCount <= 0

    // ※将来「睡眠」や「凍結」が増えたら、ここに条件を書き足すだけでOKです
  }

  /// 🌟 自分のターンが始まった時の処理
  func applyStartOfTurnLogic() {
    for (status, _) in statuses {
      switch status.behavior {
      case .temporary:
        // 🛡 シールドや一時筋力など「使い捨て」をここで一斉清掃！
        statuses.removeValue(forKey: status)
        print("♻️ [\(status.rawValue)] をリセットしました")

      case .duration, .permanent:
        // ⏳ ターン数型や永続型はここでは何もしない
        break
      }
    }
  }

  /// 🌟 自分のターンが終わった時の処理
  func applyEndOfTurnLogic() {
    for (status, value) in statuses {
      switch status.behavior {
      case .duration:
        // ⏳ ターン制（EMPやターゲット）の残りカウントを1減らす
        let newValue = value - 1
        if newValue > 0 {
          statuses[status] = newValue
        } else {
          statuses.removeValue(forKey: status)
        }

      case .temporary, .permanent:
        // 🔥 ここではリセットせず、次のターンの開始時まで持ち越す
        break
      }
    }
  }
}
