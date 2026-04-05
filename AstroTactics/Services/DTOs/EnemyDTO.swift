import Foundation

// DTOs matching EnemyData.json
struct EnemyCatalog: Codable {
  let enemies: [EnemyJSON]
}

struct EnemyJSON: Codable {
  let category: String
  let name: String
  let imageName: String
  let maxHP: Int
  let behaviorAI: AIJSON
}

struct AIJSON: Codable {
  let type: String
  let moves: [MoveJSON]
}

struct MoveJSON: Codable {
  let intent: String
  let amount: Int?
  let min: Int?
  let max: Int?
}
