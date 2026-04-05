import Testing

@testable import AstroTactics

@Suite("EnemyDatabase のテスト")
@MainActor
struct EnemyDatabaseTests {

  @Test("EnemyData.json が読み込めること")
  func testLoadEnemyData() throws {
    let catalog: EnemyCatalog = try JSONLoader.load("EnemyData", as: EnemyCatalog.self)
    #expect(catalog.enemies.count > 0, "enemies が1件以上あること")
  }

  @Test("EnemyDatabase.loadFromJSON が allEnemiesData をセットすること")
  func testLoadFromJSON() {
    EnemyDatabase.loadFromJSON()
    #expect(EnemyDatabase.allEnemiesData.count > 0, "allEnemiesData に敵データが読み込まれていること")
  }

  @Test("randomEnemy と bossFlagship が Enemy を返すこと")
  func testCreateEnemies() {
    EnemyDatabase.loadFromJSON()
    let random = EnemyDatabase.randomEnemy()
    let boss = EnemyDatabase.bossFlagship()
    #expect(!random.name.isEmpty, "ランダム敵の name が空でないこと")
    #expect(!boss.name.isEmpty, "ボスの name が空でないこと")
  }
}
