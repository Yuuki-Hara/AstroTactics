import XCTest
@testable import AstroTactics

final class JSONLoaderTests: XCTestCase {
    func test_loadCardData_returnsCatalog() {
        // このテストは現状の DataLoader を使って JSON が読み込めることを確認します
        let catalog: CardCatalog? = DataLoader.load("CardData", as: CardCatalog.self)
        XCTAssertNotNil(catalog)
        if let c = catalog {
            XCTAssertGreaterThan(c.cards.count, 0)
        }
    }

    func test_loadEnemyData_returnsCatalog() {
        let catalog: EnemyCatalog? = DataLoader.load("EnemyData", as: EnemyCatalog.self)
        XCTAssertNotNil(catalog)
        if let c = catalog {
            XCTAssertGreaterThan(c.enemies.count, 0)
        }
    }

    func test_loadRelicData_returnsCatalog() {
        let catalog: RelicCatalog? = DataLoader.load("RelicData", as: RelicCatalog.self)
        XCTAssertNotNil(catalog)
        if let c = catalog {
            XCTAssertGreaterThan(c.relics.count, 0)
        }
    }

    func test_loadGameSettings_returnsSettings() {
        let settings: GameSettingsData? = DataLoader.load("GameSettings", as: GameSettingsData.self)
        XCTAssertNotNil(settings)
    }

    func test_loadMapData_returnsMap() {
        let map: MapData? = DataLoader.load("MapData", as: MapData.self)
        XCTAssertNotNil(map)
    }
}
