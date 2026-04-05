import Foundation

struct CardMapper {
  // DTOからCardモデルへの変換（メインの窓口）
  static func map(_ dto: CardDTO) -> Card {
    let traits = dto.traits.compactMap { mapTrait($0) }
    let target = mapTarget(dto.target)
    let effects = dto.effects.compactMap { mapEffect($0) }

    return Card(
      baseId: dto.baseId,
      name: dto.name,
      cost: dto.cost,
      traits: traits,
      target: target,
      effects: effects
    )
  }

  // 各要素ごとの変換メソッド（細かいswitch文を分離）
  private static func mapTrait(_ traitString: String) -> CardTrait? {
    switch traitString {
    case "beam": return .beam
    case "missile": return .missile
    case "mech": return .mech
    case "defense": return .defense
    case "command": return .command
    default: return nil
    }
  }

  private static func mapTarget(_ targetString: String) -> TargetType {
    switch targetString {
    case "allEnemies": return .allEnemies
    case "selfTarget": return .selfTarget
    default: return .singleEnemy
    }
  }

  private static func mapEffect(_ efct: EffectDTO) -> CardEffect? {
    let amount = efct.amount ?? 0
    switch efct.type {
    case "damage": return DealDamageEffect(amount: amount)
    case "shield": return GainShieldEffect(amount: amount)
    case "draw": return DrawCardEffect(count: max(1, efct.amount ?? 1))
    case "damageAll": return DealDamageToAllEffect(amount: amount)
    case "energy": return GainEnergyEffect(amount: amount)
    case "takeDamage": return TakeDamageEffect(amount: amount)
    case "randomDamage": return DealRandomDamageEffect(amount: amount)
    case "applyStatus":
      let statusEnum: StatusType = (efct.status == "EMP") ? .emp : .target
      return ApplyStatusEffect(status: statusEnum, amount: amount)
    case "gainStrength": return GainStrengthEffect(amount: amount)
    default: return nil
    }
  }
}

/// CardRepository は DTO の読み込み、Domain への変換、キャッシュを担当します。
struct CardRepository {
  private static var cachedCards: [Card]?

  static func loadAll() throws -> [Card] {
    // 1. キャッシュがあれば即返す
    if let cached = cachedCards {
      return cached
    }

    // 2. JSONをロード（読み込みに専念）
    let catalog: CardCatalogDTO = try JSONLoader.load("CardData", as: CardCatalogDTO.self)

    // 3. Mapperを使って変換（中身を知らなくてOK）
    let cards = catalog.cards.map { CardMapper.map($0) }

    cachedCards = cards
    return cards
  }

  static func getCard(by baseId: String) -> Card? {
    do {
      let cards = try loadAll()
      guard let blueprint = cards.first(where: { $0.baseId == baseId }) else { return nil }
      return Card(
        baseId: blueprint.baseId, name: blueprint.name, cost: blueprint.cost,
        traits: blueprint.traits, target: blueprint.target, effects: blueprint.effects)
    } catch {
      print("[CardRepository] failed to load cards: \(error)")
      return nil
    }
  }
}

// MARK: - Protocol for DI / testing
protocol CardRepositoryProtocol {
  func loadAll() throws -> [Card]
  func getCard(by baseId: String) -> Card?
}

/// Adapter that forwards to the existing static CardRepository implementation
struct CardRepositoryAdapter: CardRepositoryProtocol {
  func loadAll() throws -> [Card] { try CardRepository.loadAll() }
  func getCard(by baseId: String) -> Card? { CardRepository.getCard(by: baseId) }
}
