import Testing

@testable import AstroTactics

@Suite("Card DTO の読み込みテスト")
@MainActor
struct CardDTOTests {

  @Test("CardData.json を DTO として読み込めること")
  func testLoadCardDTO() throws {
    let catalog: CardCatalogDTO = try JSONLoader.load("CardData", as: CardCatalogDTO.self)
    #expect(catalog.cards.count > 0, "cards が1件以上あること")

    let first = catalog.cards[0]
    #expect(!first.baseId.isEmpty, "baseId が空でないこと")
    #expect(!first.name.isEmpty, "name が空でないこと")
  }
}
