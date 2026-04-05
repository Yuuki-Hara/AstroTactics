import Foundation

struct RelicCatalogDTO: Codable {
  let relics: [RelicDTO]
}

struct RelicDTO: Codable {
  let id: String
  let name: String
  let description: String
  let imageName: String
  let trigger: String
  let effect: RelicEffectDTO
}

struct RelicEffectDTO: Codable {
  let type: String
  let amount: Int
}
