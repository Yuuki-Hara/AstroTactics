import Testing

@testable import AstroTactics

@Suite("CardDatabase 統合テスト")
@MainActor
struct CardDatabaseTests {

  @Test("loadFromJSON が allCardsData をセットすること")
  func testLoadFromJSON() {
    CardDatabase.loadFromJSON()
    #expect(CardDatabase.allCardsData.count > 0, "allCardsData にカードが読み込まれていること")
  }

  @Test("startingDeck が正しい枚数を返すこと")
  func testStartingDeck() {
    CardDatabase.loadFromJSON()
    let deck = CardDatabase.startingDeck()
    #expect(deck.count == 5, "初期デッキは5枚であること")
  }

  @Test("allRewardCards が strike/defend を除外すること")
  func testAllRewardCards() {
    CardDatabase.loadFromJSON()
    let rewards = CardDatabase.allRewardCards()
    #expect(!rewards.contains(where: { $0.baseId == "strike" }), "rewards に strike が含まれないこと")
    #expect(!rewards.contains(where: { $0.baseId == "defend" }), "rewards に defend が含まれないこと")
  }
}
