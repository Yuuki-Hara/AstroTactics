//
//  Enums.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

enum StatusType {
    case emp, target, strength
}

enum EnemyIntent {
    case attack(damage: Int)
    case defend(amount: Int)
    case charge
    case buff
    case debuff(status: StatusType)
}

enum BattleState {
    case battleStart
    case playerTurnStart
    case playerAction
    case playerTurnEnd
    case enemyTurnStart
    case enemyAction
    case enemyTurnEnd
    case victory
    case defeat
}
