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
    let count: Int?
}

// MARK: - カード図鑑本体
struct CardDatabase {
    
    // アプリに読み込まれた全カードの設計図を保管する場所
    static var allCardsData: [Card] = []
    
    // 🌟 アプリ起動時にJSONを読み込む関数
    static func loadFromJSON() {
        // DataLoaderに「CardData.jsonを、CardCatalog型で読み込んで！」と頼むだけ！
        if let catalog = DataLoader.load("CardData", as: CardCatalog.self) {
            allCardsData = catalog.cards.map { convert(json: $0) }
            print("✅ カードデータを \(allCardsData.count) 件読み込みました！")
        }
    }
    // 🌟 翻訳機：JSONの文字を、Swiftのプログラムに変換する
    static private func convert(json: CardJSON) -> Card {
        // 1. 属性（traits）の翻訳
        let traits = json.traits.compactMap { traitString -> CardTrait? in
            switch traitString {
            case "beam": return .beam
            case "missile": return .missile
            case "mech": return .mech
            case "defense": return .defense
            case "command": return .command
            default: return nil
            }
        }
        
        // 2. ターゲットの翻訳
        let target: TargetType
        switch json.target {
        case "allEnemies": target = .allEnemies
        case "selfTarget": target = .selfTarget
        default: target = .singleEnemy
        }
        
        // 3. 効果（effects）の翻訳！ここが重要！
        let effects = json.effects.compactMap { effectJson -> CardEffect? in
            switch effectJson.type {
            case "damage": return DealDamageEffect(amount: effectJson.amount ?? 0)
            case "shield": return GainShieldEffect(amount: effectJson.amount ?? 0)
            case "draw": return DrawCardEffect(count: effectJson.count ?? 1)
            case "damageAll": return DealDamageToAllEffect(amount: effectJson.amount ?? 0)
            case "energy": return GainEnergyEffect(amount: effectJson.amount ?? 0)
            case "takeDamage": return TakeDamageEffect(amount: effectJson.amount ?? 0)
            default: return nil
            }
        }
        
        // 翻訳完了！新しいカードとして返す
        return Card(baseId: json.baseId, name: json.name, cost: json.cost, traits: traits, target: target, effects: effects)
    }
    
    // MARK: - カードの取得
    
    // JSONから読み込んだ初期デッキを返す
    static func startingDeck() -> [Card] {
        // baseId を指定して、JSONから読み込んだカードをコピーして渡す
        let strike = allCardsData.first(where: { $0.baseId == "strike" })!
        let defend = allCardsData.first(where: { $0.baseId == "defend" })!
        
        // 通常射撃3枚、基本装甲2枚のデッキ
        return [
            Card(baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits, target: strike.target, effects: strike.effects),
            Card(baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits, target: strike.target, effects: strike.effects),
            Card(baseId: strike.baseId, name: strike.name, cost: strike.cost, traits: strike.traits, target: strike.target, effects: strike.effects),
            Card(baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits, target: defend.target, effects: defend.effects),
            Card(baseId: defend.baseId, name: defend.name, cost: defend.cost, traits: defend.traits, target: defend.target, effects: defend.effects)
        ]
    }
    
    // 報酬用のカードリスト（初期デッキ以外のカードをランダムに出す）
    static func allRewardCards() -> [Card] {
        return allCardsData.filter { $0.baseId != "strike" && $0.baseId != "defend" }
    }
}
