import Testing

@testable import AstroTactics

@Suite("SaveManager のテスト")
@MainActor
struct SaveManagerTests {

  @Test("save と load が対になること")
  func testSaveAndLoad() {
    // 一時的にテスト用の SaveData を作る
    let card = SavedCard(baseId: "strike", isUpgraded: false)
    let data = SaveData(
      playerCurrentHP: 10, playerMaxHP: 20, playerMaxEnergy: 3, baseDeck: [card], relicIds: [],
      mapFloors: [], currentNodeId: nil)

    // 既存のセーブを削除してから実行
    SaveManager.shared.deleteSave()
    SaveManager.shared.save(data: data)

    let loaded = SaveManager.shared.load()
    #expect(loaded != nil, "保存したデータが読み込めること")
    if let l = loaded {
      #expect(l.playerCurrentHP == data.playerCurrentHP, "playerCurrentHP が一致すること")
      #expect(l.baseDeck.count == data.baseDeck.count, "baseDeck のサイズが一致すること")
    }
  }

  @Test("deleteSave がデータを消すこと")
  func testDeleteSave() {
    SaveManager.shared.deleteSave()
    #expect(SaveManager.shared.load() == nil, "削除後は load が nil を返すこと")
  }
}
