//
//  CardDatabase.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/22.
//
import Foundation

// MARK: - JSONを読み込むための仮の型
struct CardCatalog: Codable {
  let cards: [CardJSON]
}
struct CardJSON: Codable {
  let baseId: String
  let name: String
  let cost: Int
  let traits: [String]
  let target: String
  let effects: [EffectJSON]
}
struct EffectJSON: Codable {
  let type: String
  let amount: Int?
  let status: String?
}

// MARK: - カード図鑑本体
struct CardDatabase {

  // アプリに読み込まれた全カードの設計図を保管する場所
  static var allCardsData: [Card] = []

  // 🌟 アプリ起動時にJSONを読み込む関数
  static func loadFromJSON() {
    do {
      let catalog = try JSONLoader.load("CardData", as: CardCatalog.self)
      allCardsData = catalog.cards.map { convert(json: $0) }
      print("✅ カードデータを \(allCardsData.count) 件読み込みました！")
    } catch {
      print("🚨 CardDatabase: failed to load CardData.json: \(error)")
    }
  }
  // 🌟 翻訳機：JSONの文字を、Swiftのプログラムに変換する
  static private func convert(json: CardJSON) -> Card {
    // 1. 属性（traits）の翻訳
    let traits = parseTraits(from: json.traits)

    // 2. ターゲットの翻訳
    let target = parseTarget(from: json.target)

    // 3. 効果（effects）の翻訳はヘルパーへ委譲して複雑度を下げる
    let effects = parseEffects(from: json.effects)

    // 翻訳完了！新しいカードとして返す
    return Card(
      baseId: json.baseId, name: json.name, cost: json.cost, traits: traits, target: target,
      effects: effects)
  }

  // MARK: - helpers (複雑な分岐を分離)
  static private func parseTraits(from raw: [String]) -> [CardTrait] {
    return raw.compactMap { traitString -> CardTrait? in
      switch traitString {
      case "beam": return .beam
      case "missile": return .missile
      case "mech": return .mech
      case "defense": return .defense
      case "command": return .command
      default: return nil
      }
    }
  }

  static private func parseTarget(from raw: String) -> TargetType {
    switch raw {
    case "allEnemies": return .allEnemies
    case "selfTarget": return .selfTarget
    default: return .singleEnemy
    }
  }

  static private func parseEffects(from raw: [EffectJSON]) -> [CardEffect] {
    return raw.compactMap { parseEffect($0) }
  }

  static private func parseEffect(_ effectJson: EffectJSON) -> CardEffect? {
    let amount = effectJson.amount ?? 0
    switch effectJson.type {
    case "damage": return DealDamageEffect(amount: amount)
    case "shield": return GainShieldEffect(amount: amount)
    case "draw": return DrawCardEffect(count: max(1, effectJson.amount ?? 1))
    case "damageAll": return DealDamageToAllEffect(amount: amount)
    case "energy": return GainEnergyEffect(amount: amount)
    case "takeDamage": return TakeDamageEffect(amount: amount)
    case "randomDamage": return DealRandomDamageEffect(amount: amount)
    case "applyStatus":
      let statusEnum: StatusType = (effectJson.status == "EMP") ? .emp : .target
      return ApplyStatusEffect(status: statusEnum, amount: amount)
    case "gainStrength": return GainStrengthEffect(amount: amount)
    default: return nil
    }
  }

  // MARK: - カードの取得
  static func getCard(by baseId: String) -> Card? {
    // allCardsData から、同じ baseId を持つカードの設計図を探す
    guard let blueprint = allCardsData.first(where: { $0.baseId == baseId }) else {
      return nil  // 見つからなければ nil を返す
    }

    // 設計図から、全く新しいカードのコピーを作って返す（これが超重要！）
    return Card(
      baseId: blueprint.baseId,
      name: blueprint.name,
      cost: blueprint.cost,
      traits: blueprint.traits,
      target: blueprint.target,
      effects: blueprint.effects
        // UUIDはCardの初期化時に自動で新しいものが振られます
    )
  }

  // JSONから読み込んだ初期デッキを返す
  static func startingDeck() -> [Card] {
    // baseId を指定して、JSONから読み込んだカードをコピーして渡す
    let strike = allCardsData.first(where: { $0.baseId == "strike" })!
    let defend = allCardsData.first(where: { $0.baseId == "defend" })!

    // 通常射撃3枚、基本装甲2枚のデッキ
    return [
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits,
        target: strike.target, effects: strike.effects),
      Card(
        baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits,
        target: defend.target, effects: defend.effects),
      Card(
        baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits,
        target: defend.target, effects: defend.effects),
    ]
  }

  // 報酬用のカードリスト（初期デッキ以外のカードをランダムに出す）
  static func allRewardCards() -> [Card] {
    return allCardsData.filter { $0.baseId != "strike" && $0.baseId != "defend" }
  }
}
