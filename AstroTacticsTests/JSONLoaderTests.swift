//
//  JSONLoaderTests.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Testing

@testable import AstroTactics

@Suite("JSON ローダーのデータ読み込みテスト")
@MainActor
struct JSONLoaderTests {

  @Test("敵データが読み込めること")
  func testLoadEnemyData() {
    let catalog: EnemyCatalog? = DataLoader.load("EnemyData", as: EnemyCatalog.self)
    #expect(catalog != nil, "EnemyData が読み込まれること")
    if let c = catalog {
      #expect(c.enemies.count > 0, "enemies が空でないこと")
    }
  }

  @Test("レリックデータが読み込めること")
  func testLoadRelicData() {
    let catalog: RelicCatalogDTO? = DataLoader.load("RelicData", as: RelicCatalogDTO.self)
    #expect(catalog != nil, "RelicData が読み込まれること")
    if let c = catalog {
      #expect(c.relics.count > 0, "relics が空でないこと")
    }
  }

  @Test("ゲーム設定が読み込めること")
  func testLoadGameSettings() {
    let settings: GameSettingsData? = DataLoader.load("GameSettings", as: GameSettingsData.self)
    #expect(settings != nil, "GameSettings が読み込まれること")
  }

  @Test("マップデータが読み込めること")
  func testLoadMapData() {
    let map: MapData? = DataLoader.load("MapData", as: MapData.self)
    #expect(map != nil, "MapData が読み込まれること")
  }
}
