import Testing

@testable import AstroTactics

@Suite("RunManager の保存統合テスト")
@MainActor
struct RunManagerSaveTests {

  @Test("saveCurrentState が SaveManager にデータを保存すること")
  func testRunManagerSave() {
    // 初期化して、セーブを行う
    let manager = RunManager()

    // 簡単に状態を変更してからセーブ
    manager.player.currentHP = 5
    manager.baseDeck = CardDatabase.startingDeck()

    // delete first
    SaveManager.shared.deleteSave()
    manager.saveCurrentState()

    let loaded = SaveManager.shared.load()
    #expect(loaded != nil, "RunManager が保存したデータが読み込めること")
    if let l = loaded {
      #expect(l.playerCurrentHP == manager.player.currentHP, "saved playerCurrentHP が一致すること")
      #expect(l.baseDeck.count == manager.baseDeck.count, "saved baseDeck のサイズが一致すること")
    }
  }
}
