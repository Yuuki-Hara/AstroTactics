import Foundation

struct EnemyRepository {
  private static var cachedEnemies: [EnemyJSON]?

  static func loadAll() throws -> [EnemyJSON] {
    if let cached = cachedEnemies { return cached }
    // load DTO-style EnemyCatalog from JSON
    let catalog: EnemyCatalog = try JSONLoader.load("EnemyData", as: EnemyCatalog.self)
    cachedEnemies = catalog.enemies
    return catalog.enemies
  }

  static func firstBoss() -> EnemyJSON? {
    return (try? loadAll())?.first(where: { $0.category == "boss" })
  }

  static func randomNormal() -> EnemyJSON? {
    return (try? loadAll())?.filter({ $0.category != "boss" }).randomElement()
  }
}
