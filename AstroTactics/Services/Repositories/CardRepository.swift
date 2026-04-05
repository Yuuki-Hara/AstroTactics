import Foundation

/// CardRepository は DTO の読み込み、Domain への変換、キャッシュを担当します。
struct CardRepository {
  private static var cachedCards: [Card]?

  static func loadAll() throws -> [Card] {
    if let cached = cachedCards {
      return cached
    }

    // JSON を DTO として読み込む
    let catalog: CardCatalogDTO = try JSONLoader.load("CardData", as: CardCatalogDTO.self)

    // DTO -> Domain 変換
    let cards = catalog.cards.map { dto -> Card in
      // trait, target, effect の変換は既存の CardDatabase ロジックを再利用
      let traits = dto.traits.compactMap { traitString -> CardTrait? in
        switch traitString {
        case "beam": return .beam
        case "missile": return .missile
        case "mech": return .mech
        case "defense": return .defense
        case "command": return .command
        default: return nil
        }
      }

      let target: TargetType = {
        switch dto.target {
        case "allEnemies": return .allEnemies
        case "selfTarget": return .selfTarget
        default: return .singleEnemy
        }
      }()

      let effects: [CardEffect] = dto.effects.compactMap { efct -> CardEffect? in
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

      return Card(
        baseId: dto.baseId, name: dto.name, cost: dto.cost, traits: traits, target: target,
        effects: effects)
    }

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
