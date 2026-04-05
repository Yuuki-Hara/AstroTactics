import Foundation

struct RelicRepository {
  private static var cachedRelics: [Relic]?

  static func loadAll() throws -> [Relic] {
    if let cached = cachedRelics { return cached }
    let catalog: RelicCatalogDTO = try JSONLoader.load("RelicData", as: RelicCatalogDTO.self)
    let relics = catalog.relics.compactMap { dto -> Relic? in
      let trigger: RelicTrigger
      switch dto.trigger {
      case "onBattleStart": trigger = .onBattleStart
      case "onTurnStart": trigger = .onTurnStart
      default: return nil
      }

      let effectType: RelicEffectType
      switch dto.effect.type {
      case "gainEnergy": effectType = .gainEnergy
      case "gainShield": effectType = .gainShield
      case "heal": effectType = .heal
      case "gainStrength": effectType = .gainStrength
      default: return nil
      }

      return Relic(
        id: dto.id, name: dto.name, description: dto.description, imageName: dto.imageName,
        trigger: trigger, effectType: effectType, amount: dto.effect.amount)
    }

    cachedRelics = relics
    return relics
  }

  static func getRelic(by id: String) -> Relic? {
    return (try? loadAll())?.first(where: { $0.id == id })
  }
}

protocol RelicRepositoryProtocol {
  func loadAll() throws -> [Relic]
  func getRelic(by id: String) -> Relic?
}

struct RelicRepositoryAdapter: RelicRepositoryProtocol {
  func loadAll() throws -> [Relic] { try RelicRepository.loadAll() }
  func getRelic(by id: String) -> Relic? { RelicRepository.getRelic(by: id) }
}
