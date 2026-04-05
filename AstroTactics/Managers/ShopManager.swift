//
//  ShopManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/28.
//

import Foundation
import Observation

struct ShopCardItem: Identifiable {
  let id = UUID()
  let card: Card
  let price: Int
  var isSold: Bool = false
}

struct ShopRelicItem: Identifiable {
  let id = UUID()
  let relic: Relic
  let price: Int
  var isSold: Bool = false
}

@Observable
class ShopManager {
  // 🛒 お店に並ぶ商品
  var shopCards: [ShopCardItem] = []
  var shopRelics: [ShopRelicItem] = []

  // 🗑️ 廃棄サービスの状態
  var isRemovalSoldOut: Bool = false
  var removalPrice: Int { GameSettings.config.shopRemovalPrice }

  // 🌟 init(runManager: ...) は削除しました！とてもスッキリ！

  // MARK: - お店の準備
  func setupShop() {
    let randomCards = CardDatabase.allCardsData.shuffled().prefix(3)
    shopCards = randomCards.map {
      let price = Int.random(
        in: GameSettings.config.shopCardPriceMin...GameSettings.config.shopCardPriceMax)
      return ShopCardItem(card: $0, price: price)
    }

    let randomRelics = RelicDatabase.allRelics.shuffled().prefix(2)
    shopRelics = randomRelics.map {
      let price = Int.random(
        in: GameSettings.config.shopRelicPriceMin...GameSettings.config.shopRelicPriceMax)
      return ShopRelicItem(relic: $0, price: price)
    }
  }

  // MARK: - 購入処理（買う時だけ、RunManagerの財布を操作する！）
  func buyCard(at index: Int, runManager: RunManager) {
    let item = shopCards[index]
    guard runManager.player.credits >= item.price, !item.isSold else { return }

    runManager.player.credits -= item.price
    runManager.baseDeck.append(item.card)
    shopCards[index].isSold = true
  }

  func buyRelic(at index: Int, runManager: RunManager) {
    let item = shopRelics[index]
    guard runManager.player.credits >= item.price, !item.isSold else { return }

    runManager.player.credits -= item.price
    runManager.relics.append(item.relic)
    shopRelics[index].isSold = true
  }

  func removeCardFromDeck(cardId: UUID, runManager: RunManager) {
    guard runManager.player.credits >= removalPrice, !isRemovalSoldOut else { return }

    if let index = runManager.baseDeck.firstIndex(where: { $0.id == cardId }) {
      runManager.baseDeck.remove(at: index)
      runManager.player.credits -= removalPrice
      isRemovalSoldOut = true
    }
  }
}
