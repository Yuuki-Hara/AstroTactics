import Testing

@testable import AstroTactics

@Suite("RelicDatabase のテスト")
@MainActor
struct RelicDatabaseTests {

  @Test("RelicData.json が読み込めること")
  func testLoadRelicData() throws {
    let catalog: RelicCatalogDTO = try JSONLoader.load("RelicData", as: RelicCatalogDTO.self)
    #expect(catalog.relics.count > 0, "relics が1件以上あること")
  }

  @Test("RelicDatabase.loadFromJSON が allRelics をセットすること")
  func testLoadFromJSON() {
    RelicDatabase.loadFromJSON()
    #expect(RelicDatabase.allRelics.count > 0, "allRelics にレリックが読み込まれていること")
  }

  @Test("getRelic(by:) が 正しくRelicを取得すること")
  func testGetRelic() {
    RelicDatabase.loadFromJSON()
    let first = RelicDatabase.allRelics.first
    #expect(first != nil, "少なくとも1個のレリックがあること")
    if let f = first {
      let fetched = RelicDatabase.getRelic(by: f.id)
      #expect(fetched != nil, "getRelic で同一 ID のレリックが返ること")
    }
  }
}
