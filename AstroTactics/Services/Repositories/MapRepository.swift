import Foundation

struct MapRepository {
  static func load() throws -> MapData {
    return try JSONLoader.load("MapData", as: MapData.self)
  }
}

protocol MapRepositoryProtocol {
  func load() throws -> MapData
}

struct MapRepositoryAdapter: MapRepositoryProtocol {
  func load() throws -> MapData { try MapRepository.load() }
}
