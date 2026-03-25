//
//  DeckManagerTests.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Testing
@testable import AstroTactics

@Suite("デッキ管理システムのテスト")
@MainActor
struct DeckManagerTests {
    
    // 準備：テスト用のダミーカードを必要な枚数だけ作る便利関数
    private func createDummyDeck(count: Int) -> [Card] {
        var deck: [Card] = []
        for i in 1...count {
            let card = Card(
                baseId: "dummy_\(i)",
                name: "テストカード\(i)",
                cost: 1,
                traits: [.beam],
                target: .singleEnemy,
                effects: [.dealDamage(amount: 5)]
            )
            deck.append(card)
        }
        return deck
    }

    @Test("初期化：開始時に山札がセットされるか")
    func testInitialization() {
        let deck = createDummyDeck(count: 10)
        let manager = BattleDeckManager(startingDeck: deck)
        
        #expect(manager.drawPile.count == 10, "山札に10枚セットされていること")
        #expect(manager.hand.isEmpty, "最初の手札は0枚であること")
        #expect(manager.discardPile.isEmpty, "最初の捨て札は0枚であること")
    }

    @Test("ドロー：山札から手札に移動するか")
    func testDrawCard() {
        let manager = BattleDeckManager(startingDeck: createDummyDeck(count: 10))
        
        manager.drawCard(count: 3) // 3枚引く
        
        #expect(manager.hand.count == 3, "手札が3枚に増えていること")
        #expect(manager.drawPile.count == 7, "山札が3枚減っていること")
    }

    @Test("プレイ：使ったカードが捨て札に送られるか")
    func testPlayCard() {
        let manager = BattleDeckManager(startingDeck: createDummyDeck(count: 5))
        manager.drawCard(count: 3)
        
        // 手札の1枚目（0番目）を使用する想定
        let cardToPlay = manager.hand[0]
        manager.playCard(card: cardToPlay)
        
        #expect(manager.hand.count == 2, "手札が1枚減っていること")
        #expect(manager.discardPile.count == 1, "捨て札が1枚増えていること")
        #expect(manager.discardPile[0].id == cardToPlay.id, "使用したまさにそのカードが捨て札にあること")
    }

    @Test("ターン終了：手札がすべて捨て札に送られるか")
    func testDiscardHand() {
        let manager = BattleDeckManager(startingDeck: createDummyDeck(count: 5))
        manager.drawCard(count: 3)
        
        manager.discardHand() // ターン終了！
        
        #expect(manager.hand.isEmpty, "手札が空になっていること")
        #expect(manager.discardPile.count == 3, "手札にあった3枚がすべて捨て札に移動していること")
    }

    @Test("リシャッフル：山札が0の時に引くと、捨て札が復活するか")
    func testReshuffle() {
        let manager = BattleDeckManager(startingDeck: createDummyDeck(count: 3))
        
        // 3枚引いて、すべて捨てる（山札0、捨て札3の状態を作る）
        manager.drawCard(count: 3)
        manager.discardHand()
        
        #expect(manager.drawPile.isEmpty, "山札は空である")
        #expect(manager.discardPile.count == 3, "捨て札に3枚ある")
        
        // 🌟 ここが最大のテストポイント！山札がないのに引こうとする
        manager.drawCard(count: 1)
        
        #expect(manager.discardPile.isEmpty, "捨て札がシャッフルされて空になっていること")
        #expect(manager.hand.count == 1, "手札に新しく1枚引かれていること")
        #expect(manager.drawPile.count == 2, "残りの2枚が新しい山札になっていること")
    }
}
