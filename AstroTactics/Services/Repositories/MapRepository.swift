import Foundation

struct MapRepository {
  static func load() throws -> MapData {
    return try JSONLoader.load("MapData", as: MapData.self)
  }
}
