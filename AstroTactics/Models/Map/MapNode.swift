//
//  NodeType.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import Foundation

// 🌟 マップのマス（部屋）の種類
enum NodeType: String, Codable {
    case battle  // 雑魚戦
    case rest    // 休憩所（回復）
    case boss    // ボス戦
    
    // 画面に表示する時のアイコンと名前
    var title: String {
        switch self {
        case .battle: return "⚔️ 敵艦隊"
        case .rest: return "☕️ 宇宙ステーション"
        case .boss: return "💀 ボス旗艦"
        }
    }
}

struct MapData: Codable {
    let floors: [[MapNode]]
}

// 🌟 マップ上の1つのマスを表すデータ
struct MapNode: Identifiable, Codable {
    let id: String
    let type: NodeType
    let nextNodeIds: [String]
    
    var isCompleted: Bool = false // すでにクリアした場所かどうか
    enum CodingKeys: String, CodingKey {
        case id, type, nextNodeIds
    }
}
