//
//  BattleDeckManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Foundation
import Observation // SwiftUIと連動させるための機能

// @Observable をつけることで、このクラスのデータ（手札など）が変わった時に、
// SwiftUIの画面が自動的に再描画されるようになります！
@Observable
class BattleDeckManager {
    // デッキの4つの状態を配列で管理します
    var drawPile: [Card] = []       // 山札
    var hand: [Card] = []           // 手札
    var discardPile: [Card] = []    // 捨て札
    var exhaustPile: [Card] = []    // 除外（使い切り）
    
    // 戦闘開始時に、初期デッキを読み込むための初期化処理（イニシャライザ）
    init(startingDeck: [Card]) {
        // 受け取ったデッキをシャッフルして、山札（drawPile）にセットします
        self.drawPile = startingDeck.shuffled()
    }
    
    // 1. 山札からカードを引く処理
    func drawCard(count: Int) {
        for _ in 0..<count {
            // もし山札が空なら、捨て札をシャッフルして山札に戻す
            if drawPile.isEmpty {
                shuffleDiscardIntoDraw()
            }
            
            // 捨て札を戻してもまだ空なら、これ以上引けないのでループを抜ける
            if drawPile.isEmpty {
                print("⚠️ デッキにカードがありません！")
                break
            }
            
            // 山札の「一番上（配列の最後）」から1枚取り出して、手札に加える
            let drawnCard = drawPile.removeLast()
            hand.append(drawnCard)
            print("🃏 「\(drawnCard.name)」を引きました。(残り山札: \(drawPile.count)枚)")
        }
    }
    
    // 2. 捨て札をシャッフルして山札に戻す処理
    func shuffleDiscardIntoDraw() {
        if discardPile.isEmpty { return } // 捨て札もなければ何もしない
        
        print("🔄 捨て札をシャッフルして新しい山札にします。")
        drawPile = discardPile.shuffled()
        discardPile.removeAll() // 捨て札を空にする
    }
    
    // 3. 手札のカードを使用（プレイ）する処理
    func playCard(card: Card) {
        // 手札の中から、使ったカードと同じIDのものを探す
        if let index = hand.firstIndex(where: { $0.id == card.id }) {
            // 手札から抜き出す
            let playedCard = hand.remove(at: index)
            // 抜き出したカードを捨て札に送る
            discardPile.append(playedCard)
            print("💥 「\(playedCard.name)」を使用し、捨て札に送りました。")
        }
    }
    
    // 4. ターン終了時、手札をすべて捨てる処理
    func discardHand() {
        print("🗑️ ターン終了。残った手札(\(hand.count)枚)を捨て札に送ります。")
        // 手札のカードをすべて捨て札の配列に追加する
        discardPile.append(contentsOf: hand)
        // 手札を空にする
        hand.removeAll()
    }
    
    // 5. カードを除外（使い切り）にする処理
    func exhaustCard(card: Card) {
        if let index = hand.firstIndex(where: { $0.id == card.id }) {
            let exhaustedCard = hand.remove(at: index)
            exhaustPile.append(exhaustedCard)
            print("🚫 「\(exhaustedCard.name)」は除外されました。(この戦闘ではもう使えません)")
        }
    }
}
