//
//  CardDTO.swift
//  AstroTactics
//
//  DTOs for Card JSON data
//

import Foundation

struct CardCatalogDTO: Codable {
  let cards: [CardDTO]
}

struct CardDTO: Codable {
  let baseId: String
  let name: String
  let cost: Int
  let traits: [String]
  let target: String
  let effects: [EffectDTO]
}

struct EffectDTO: Codable {
  let type: String
  let amount: Int?
  let status: String?
}
