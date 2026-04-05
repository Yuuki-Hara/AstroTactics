//
//  CardDatabase.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/22.
//
import Foundation

// MARK: - カード図鑑本体 (CardRepository に責務を委譲)
struct CardDatabase {
  static var allCardsData: [Card] = []

  static func loadFromJSON() {
    do {
      allCardsData = try CardRepository.loadAll()
      print("✅ カードデータを \(allCardsData.count) 件読み込みました！")
    } catch {
      print("🚨 CardDatabase: failed to load CardData.json: \(error)")
    }
  }

  // New method that accepts a repository for DI/testing
  static func loadFromJSON(repository: CardRepositoryProtocol) {
    do {
      allCardsData = try repository.loadAll()
      print("✅ カードデータを \(allCardsData.count) 件読み込みました！（DI経由）")
    } catch {
      print("🚨 CardDatabase: failed to load CardData.json via repository: \(error)")
    }
  }

  static func getCard(by baseId: String) -> Card? {
    return CardRepository.getCard(by: baseId)
  }

  static func startingDeck() -> [Card] {
    let strike = allCardsData.first(where: { $0.baseId == "strike" })!
    let defend = allCardsData.first(where: { $0.baseId == "defend" })!

    return [
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits,
        target: defend.target, effects: defend.effects),
      Card(
        baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits,
        target: defend.target, effects: defend.effects),
    ]
  }

  static func allRewardCards() -> [Card] {
    return allCardsData.filter { $0.baseId != "strike" && $0.baseId != "defend" }
  }
}
