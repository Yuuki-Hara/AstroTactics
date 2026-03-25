import Testing
@testable import AstroTactics

@Suite("バトル進行(BattleManager)の結合テスト")
@MainActor
struct BattleManagerTests {

    private func setupBattle() -> BattleManager {
        let player = PlayerShip(name: "テスト旗艦", maxHP: 50, maxEnergy: 3)
        let enemy = Enemy(id: "test_alien", name: "テストエイリアン", maxHP: 20)
        
        var deck: [Card] = []
        for i in 1...10 {
            deck.append(Card(baseId: "laser", name: "小レーザー\(i)", cost: 1, traits: [.beam], target: .singleEnemy, effects: [.dealDamage(amount: 10)]))
        }
        let deckManager = BattleDeckManager(startingDeck: deck)
        let manager = BattleManager(player: player, enemies: [enemy], deckManager: deckManager)
        
        // 🌟 追加：テスト時はアニメーションをオフにして一瞬で完了させる！
        manager.animationSpeed = 0.0
        return manager
    }

    // 🌟 全てのテスト関数に async と await を追加
    @Test("戦闘開始")
    func testBattleStart() async {
        let manager = setupBattle()
        await manager.startBattle()
        
        #expect(manager.currentState == .playerAction)
        #expect(manager.turnCount == 1)
    }

    @Test("カード使用と勝利")
    func testUseCardAndVictory() async {
        let manager = setupBattle()
        await manager.startBattle()
        
        let enemy = manager.enemies[0]
        let card1 = manager.deckManager.hand[0]
        await manager.useCard(card1, target: enemy)
        
        let card2 = manager.deckManager.hand[1]
        await manager.useCard(card2, target: enemy)
        
        #expect(enemy.currentHP == 0)
        #expect(manager.currentState == .victory)
    }

    @Test("ターン進行")
    func testTurnProgressionAndEnemyAttack() async {
        let manager = setupBattle()
        await manager.startBattle()
        
        await manager.endPlayerTurn()
        
        #expect(manager.player.currentHP == 40)
        #expect(manager.turnCount == 2)
    }

    @Test("敗北判定")
    func testPlayerDefeat() async {
        let manager = setupBattle()
        await manager.startBattle()
        manager.player.currentHP = 10
        
        await manager.endPlayerTurn()
        
        #expect(manager.player.currentHP == 0)
        #expect(manager.currentState == .defeat)
    }
}
