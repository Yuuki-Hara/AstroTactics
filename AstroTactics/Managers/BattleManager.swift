//
//  BattleManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import Foundation
import Observation
import Combine

@Observable
class BattleManager {
    var currentState: BattleState = .battleStart
    var displayMessage: String = ""
    var player: PlayerShip
    var enemies: [Enemy]
    var relics: [Relic] = []
    var deckManager: BattleDeckManager
    var turnCount: Int = 0
    var animationSpeed: Double = 1.0
    
    var earnedCredits: Int = 0
    
    var isProcessing: Bool = false
    
    init(player: PlayerShip, enemies: [Enemy], relics: [Relic], deckManager: BattleDeckManager) {
        self.player = player
        self.enemies = enemies
        self.deckManager = deckManager
        self.relics = relics
    }
    
    private func wait(seconds: Double) async {
        let actualSeconds = seconds * animationSpeed
        if actualSeconds > 0 {
            try? await Task.sleep(nanoseconds: UInt64(actualSeconds * 1_000_000_000))
        }
    }
    
    @MainActor
    func showMessage(_ text: String, duration: Double = 1.0) async {
        displayMessage = text
        await wait(seconds: duration)
    }
    
    // MARK: - ゲームの進行コントロール (目次)
    
    @MainActor
    func startBattle() async {
        print("🚀 戦闘開始！エイリアン艦隊と遭遇！")
        await changeState(to: .battleStart)
    }
    
    @MainActor
    func changeState(to newState: BattleState) async {
        currentState = newState
        
        switch newState {
        case .battleStart:      await handleBattleStart()
        case .playerTurnStart:  await handlePlayerTurnStart()
        case .playerAction:     print("⏳ プレイヤーのコマンド入力待ち...")
        case .playerTurnEnd:    await handlePlayerTurnEnd()
        case .enemyTurnStart:   await handleEnemyTurnStart()
        case .enemyAction:      await handleEnemyAction()
        case .enemyTurnEnd:     await handleEnemyTurnEnd()
        case .victory, .defeat: break
        }
    }
    
    // 🌟 追加：指定したタイミングでレリックの効果を発動する機能
    private func triggerRelics(on trigger: RelicTrigger) async {
        for relic in relics where relic.trigger == trigger {
            switch relic.effectType {
            case .gainEnergy:
                player.currentEnergy += relic.amount
                print("💎 レリック発動！[\(relic.name)] エナジーを\(relic.amount)回復！")
                await showMessage(BattleMessageFormatter.gainEnergyByRelic(name: relic.name, amount: relic.amount), duration: 1.2)
            case .gainShield:
                player.shield += relic.amount
                print("💎 レリック発動！[\(relic.name)] シールドを\(relic.amount)獲得！")
                await showMessage(BattleMessageFormatter.gainShieldByRelic(name: relic.name, amount: relic.amount), duration: 1.2)
            // 💖 追加：HP回復
            case .heal:
                player.currentHP = min(player.maxHP, player.currentHP + relic.amount)
                await showMessage("🔧 レリック発動！[\(relic.name)] HPを\(relic.amount)回復！", duration: 1.2)
                
            // 💪 追加：筋力アップ
            case .gainStrength:
                player.statuses[.strength, default: 0] += relic.amount
                await showMessage("🔥 レリック発動！[\(relic.name)] 筋力+\(relic.amount)！", duration: 1.2)
            }
        }
    }
    
    @MainActor private func handleBattleStart() async {
        deckManager.drawCard(count: 5)
        player.resetEnergy()
        player.statuses = [:]
        for enemy in enemies { enemy.determineNextIntent() }
        await triggerRelics(on: .onBattleStart)
        await wait(seconds: 1.0)
        await changeState(to: .playerTurnStart)
    }
    
    @MainActor private func handlePlayerTurnStart() async {
        turnCount += 1
        if turnCount != 1 {
            player.resetEnergy()
        }
        player.shield = 0
        await triggerRelics(on: .onTurnStart)
        await showMessage(GameSettings.messages.playerTurnStart, duration: 0.8)
        await changeState(to: .playerAction)
    }
    
    @MainActor private func handlePlayerTurnEnd() async {
        deckManager.discardHand()
        player.decrementStatuses()
        await wait(seconds: 0.5)
        await changeState(to: .enemyTurnStart)
    }
    
    @MainActor private func handleEnemyTurnStart() async {
        for enemy in enemies where enemy.currentHP > 0 { enemy.shield = 0 }
        await wait(seconds: 0.5)
        await changeState(to: .enemyAction)
    }
    
    @MainActor private func handleEnemyAction() async {
        await showMessage(GameSettings.messages.enemyAction)
        
        for enemy in enemies where enemy.currentHP > 0 {
            guard let intent = enemy.intent else { continue }
            await executeEnemyIntent(intent, for: enemy)
        }
        
        if await !checkWinCondition() {
            await changeState(to: .enemyTurnEnd)
        }
    }
    
    @MainActor private func handleEnemyTurnEnd() async {
        for enemy in enemies where enemy.currentHP > 0 {
            enemy.determineNextIntent()
            enemy.decrementStatuses()
        }
        deckManager.drawCard(count: 5)
        await wait(seconds: 0.5)
        await changeState(to: .playerTurnStart)
    }
    
    @MainActor private func executeEnemyIntent(_ intent: EnemyIntent, for enemy: Enemy) async {
        switch intent {
        case .attack(let damage):
            await showMessage(BattleMessageFormatter.enemyAttack(enemyName: enemy.name), duration: 0.8)
            let result = player.takeDamage(amount: damage)
            let msg = BattleMessageFormatter.damage(targetName: enemy.name, hpDamage: result.damageToHP, blocked: result.blocked)
            await showMessage(msg, duration: 1.2)
            
        case .defend(let amount):
            enemy.shield += amount
            await showMessage(BattleMessageFormatter.enemyDefend(enemyName: enemy.name, amount: amount), duration: 1.2)
        case .charge:
            await showMessage(BattleMessageFormatter.enemyCharge(enemyName: enemy.name), duration: 1.2)
        case .buff:
            //TODO: 未実装
            break
        case .debuff(let status):
            //TODO: 未実装
            print(status)
            break
        }
        
    }
    
    @MainActor
    func endPlayerTurn() async {
        guard currentState == .playerAction, !isProcessing else { return }
        
        isProcessing = true
        defer { isProcessing = false }
        await changeState(to: .playerTurnEnd)
    }
    
    @MainActor
    func useCard(_ card: Card, target: Enemy?) async {
        guard currentState == .playerAction, !isProcessing else { return }
        guard player.currentEnergy >= card.cost else { return }
        
        player.currentEnergy -= card.cost
        deckManager.playCard(card: card)
        
        await showMessage(BattleMessageFormatter.cardPlayed(cardName: card.name), duration: 0.8)
        
        for effect in card.effects {
            await applyCardEffect(effect, target: target)
        }
        
        if await !checkWinCondition() {
            displayMessage = GameSettings.messages.playerTurnStart
        }
    }
    
    @MainActor private func applyCardEffect(_ effect: any CardEffect, target: Enemy?) async {
        await effect.execute(manager: self, target: target)
    }
    
    @MainActor
    private func checkWinCondition() async -> Bool {
        if currentState == .victory || currentState == .defeat {
            return true
        }
        
        if player.currentHP <= 0 {
            await changeState(to: .defeat)
            return true
        }
        
        let allEnemiesDefeated = enemies.allSatisfy { $0.currentHP <= 0 }
        if allEnemiesDefeated {
            self.earnedCredits = Int.random(in: 10...25)
            player.credits += self.earnedCredits
            await changeState(to: .victory)
            return true
        }
        return false
    }
}
