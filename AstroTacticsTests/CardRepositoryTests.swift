import Testing

@testable import AstroTactics

@Suite("CardRepository のテスト")
@MainActor
struct CardRepositoryTests {

  @Test("loadAll がカードを返すこと")
  func testLoadAll() throws {
    let cards = try CardRepository.loadAll()
    #expect(cards.count > 0, "少なくとも1枚のカードが読み込まれること")
  }

  @Test("getCard(by:) が存在するカードを返すこと")
  func testGetCardExisting() throws {
    let cards = try CardRepository.loadAll()
    let sample = cards[0]
    let fetched = CardRepository.getCard(by: sample.baseId)
    #expect(fetched != nil, "既存の baseId でカードが返ること")
    if let f = fetched {
      #expect(f.baseId == sample.baseId, "返されたカードの baseId が一致すること")
    }
  }

  @Test("getCard(by:) が存在しないカードで nil を返すこと")
  func testGetCardMissing() {
    let fetched = CardRepository.getCard(by: "__not_exist__")
    #expect(fetched == nil, "存在しない baseId では nil になること")
  }
}
