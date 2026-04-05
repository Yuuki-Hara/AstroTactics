import Foundation

struct GameSettingsRepository {
  static func load() throws -> GameSettingsData {
    return try JSONLoader.load("GameSettings", as: GameSettingsData.self)
  }
}
