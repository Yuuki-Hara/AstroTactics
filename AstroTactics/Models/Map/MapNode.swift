//
//  NodeType.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import Foundation

// 🌟 マップのマス（部屋）の種類
enum NodeType {
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

// 🌟 マップ上の1つのマスを表すデータ
struct MapNode: Identifiable {
    let id = UUID()
    let type: NodeType
    var isCompleted: Bool = false // すでにクリアした場所かどうか
}
