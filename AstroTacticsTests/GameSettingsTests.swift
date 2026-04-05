import Testing

@testable import AstroTactics

@Suite("GameSettings のテスト")
@MainActor
struct GameSettingsTests {

  @Test("GameSettings.loadAll が config と messages をセットすること")
  func testLoadAll() {
    GameSettings.loadAll()
    #expect(GameSettings.config.playerStartingHP > 0, "playerStartingHP が正の値であること")
    #expect(!GameSettings.messages.mapTitle.isEmpty, "mapTitle が空でないこと")
  }
}
