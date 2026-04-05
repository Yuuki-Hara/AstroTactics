//
//  CardEffect.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

// 🌟 1. ルールブックに「自分の説明文(description)を持て」という掟を追加
protocol CardEffect {
  var description: String { get }  // 👈 これを追加！

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async
}

// 🌟 2. 各効果が、自分で自分の説明文を名乗るようにする

struct DealDamageEffect: CardEffect {
  let amount: Int
  var description: String { "\(amount) ダメージ" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    if let target = target {
      let result = target.takeDamage(baseAmount: amount, attacker: manager.player)
      let msg = BattleMessageFormatter.damage(
        targetName: target.name, hpDamage: result.damageToHP, blocked: result.blocked)
      await manager.showMessage(msg, duration: 1.2)
    }
  }
}

struct GainShieldEffect: CardEffect {
  let amount: Int
  var description: String { "シールド \(amount)" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.player.addShield(baseAmount: amount)
    await manager.showMessage(BattleMessageFormatter.shieldGained(amount: amount))
  }
}

struct DrawCardEffect: CardEffect {
  let count: Int
  var description: String { "カードを \(count) 枚引く" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.deckManager.drawCard(count: count)
    await manager.showMessage(BattleMessageFormatter.cardDrawn(count: count))
  }
}

struct HealEffect: CardEffect {
  let amount: Int
  var description: String { "HPを \(amount) 回復" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.player.currentHP = min(manager.player.maxHP, manager.player.currentHP + amount)
    await manager.showMessage(BattleMessageFormatter.healed(amount: amount))
  }
}

struct ApplyStatusEffect: CardEffect {
  let status: StatusType
  let amount: Int
  var description: String {
    let name = status == .target ? "ターゲット" : "EMP"
    return "敵に \(name) を \(amount) 付与"
  }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    target?.statuses[status, default: 0] += amount
    await manager.showMessage(BattleMessageFormatter.statusApplied(status: status))
  }
}

struct GainEnergyEffect: CardEffect {
  let amount: Int
  var description: String { "エナジーを\(amount)回復" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.player.currentEnergy = min(
      manager.player.maxEnergy, manager.player.currentEnergy + amount)
    await manager.showMessage(BattleMessageFormatter.energyGained(amount: amount))
  }
}

struct DealDamageToAllEffect: CardEffect {
  let amount: Int
  var description: String { "敵全体に\(amount)のダメージ" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    await manager.showMessage(BattleMessageFormatter.damageToAll())
    for enemy in manager.enemies where enemy.currentHP > 0 {
      let result = enemy.takeDamage(baseAmount: amount, attacker: manager.player)
      let msg = BattleMessageFormatter.damage(
        targetName: enemy.name, hpDamage: result.damageToHP, blocked: result.blocked)
      await manager.showMessage(msg)
    }
  }
}

struct TakeDamageEffect: CardEffect {
  let amount: Int
  var description: String { "自身に\(amount)のダメージ" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.player.takeDamage(baseAmount: amount, attacker: manager.player)
    await manager.showMessage(BattleMessageFormatter.takeDamage(amount: amount))
  }
}

struct DealRandomDamageEffect: CardEffect {
  let amount: Int
  var description: String { "ランダムな敵に \(amount) ダメージ" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    // 1. 生きている敵だけをリストアップする
    let aliveEnemies = manager.enemies.filter { $0.currentHP > 0 }

    // 2. その中からランダムに1体選ぶ
    if let randomTarget = aliveEnemies.randomElement() {
      let result = randomTarget.takeDamage(baseAmount: amount, attacker: manager.player)
      let msg = BattleMessageFormatter.damage(
        targetName: randomTarget.name, hpDamage: result.damageToHP, blocked: result.blocked)
      await manager.showMessage(msg, duration: 1.2)
    }
  }
}

struct GainStrengthEffect: CardEffect {
  let amount: Int
  var description: String { "攻撃力が \(amount) 上昇" }

  @MainActor
  func execute(manager: BattleManager, target: Enemy?) async {
    manager.player.addstrength(baseAmount: amount)
    await manager.showMessage("💪 攻撃力システム・ブースト！(+\(amount))")
  }
}
