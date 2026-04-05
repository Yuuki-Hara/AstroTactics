import Testing

@testable import AstroTactics

@Suite("MapData のテスト")
@MainActor
struct MapDataTests {

  @Test("MapData.json が読み込めること")
  func testLoadMapData() throws {
    let map: MapData = try JSONLoader.load("MapData", as: MapData.self)
    #expect(map.floors.count > 0, "floors が1階層以上あること")
  }

  @Test("RunManager が map を読み込めること（簡易チェック）")
  func testRunManagerLoad() {
    let manager = RunManager()
    // loadMapData は init 内で呼ばれるはず
    #expect(manager.mapFloors.count > 0, "RunManager.mapFloors が読み込まれていること")
  }
}
