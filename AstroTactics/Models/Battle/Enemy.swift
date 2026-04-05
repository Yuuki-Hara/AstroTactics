//
//  Enemy.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//
import Foundation
import Observation

enum EnemyIntent {
  case attack(damage: Int)
  case defend(amount: Int)
  case charge
  case buff
  case debuff(status: StatusType)
}

@Observable
class Enemy: CombatEntity, Identifiable {
  let id = UUID()
  let category: String
  var name: String

  var imageName: String

  var maxHP: Int
  var currentHP: Int
  var statuses: [StatusType: Int] = [:]
  //    var statuses: [StatusType: Int] = [
  //        .emp: 2,             // ⚡️ 2ターンの間、行動不能になるかテスト
  //        .target: 3,          // 🎯 ターゲット（被ダメージ増加）
  //        .strength: 2,        // ⚔️ 筋力（EMPが切れた後の攻撃力アップ）
  //        .shield: 10          // 🛡 最初からシールドを持っている状態
  //    ]

  var intent: EnemyIntent?
  var turnCount: Int = 0
  let behaviorAI: AIJSON

  init(category: String, name: String, imageName: String, maxHP: Int, behaviorAI: AIJSON) {
    self.category = category
    self.name = name
    self.imageName = imageName
    self.maxHP = maxHP
    self.currentHP = maxHP
    self.behaviorAI = behaviorAI
  }

  func determineNextIntent() {
    turnCount += 1
    // もし万が一 JSON の moves が空っぽなら、安全なダミー行動をとって終了する
    guard !behaviorAI.moves.isEmpty else {
      self.intent = .attack(damage: 1)
      return
    }

    var selectedMove: MoveJSON?

    if behaviorAI.type == "rotation" {
      // 順番に行動する（ターン数に応じて配列をループさせる）
      let moveIndex = (turnCount - 1) % behaviorAI.moves.count
      selectedMove = behaviorAI.moves[moveIndex]
    } else {
      // ランダムに行動する
      selectedMove = behaviorAI.moves.randomElement()
    }

    // 選ばれた行動の指示（MoveJSON）を、実際のEnemyIntentに翻訳してセットする！
    if let move = selectedMove {
      self.intent = parseMove(move)
    }
  }

  private func parseMove(_ move: MoveJSON) -> EnemyIntent {
    switch move.intent {
    case "attack":
      if let exact = move.amount { return .attack(damage: exact) }
      let minVal = move.min ?? 1
      let maxVal = move.max ?? 1
      let actualMin = min(minVal, maxVal)
      let actualMax = max(minVal, maxVal)
      return .attack(damage: Int.random(in: actualMin...actualMax))

    case "defend":
      if let exact = move.amount { return .defend(amount: exact) }
      let minVal = move.min ?? 1
      let maxVal = move.max ?? 1
      let actualMin = min(minVal, maxVal)
      let actualMax = max(minVal, maxVal)
      return .defend(amount: Int.random(in: actualMin...actualMax))

    case "charge":
      return .charge

    default:
      return .attack(damage: 1)  // エラー回避用
    }
  }
}
