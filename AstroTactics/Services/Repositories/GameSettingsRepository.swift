import Foundation

struct GameSettingsRepository {
  static func load() throws -> GameSettingsData {
    return try JSONLoader.load("GameSettings", as: GameSettingsData.self)
  }
}

protocol GameSettingsRepositoryProtocol {
  func load() throws -> GameSettingsData
}

struct GameSettingsRepositoryAdapter: GameSettingsRepositoryProtocol {
  func load() throws -> GameSettingsData { try GameSettingsRepository.load() }
}
