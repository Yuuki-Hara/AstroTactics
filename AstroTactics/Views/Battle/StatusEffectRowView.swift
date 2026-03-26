//
//  StatusEffectRowView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/27.
//


import SwiftUI

struct StatusEffectRowView: View {
    // 敵でも味方でも、statuses辞書を渡すだけでOK！
    let statuses: [StatusType: Int]
    
    private var activeStatuses: [StatusType] {
            var activeKeys: [StatusType] = []
            
            // 1. 辞書を一つずつ確認して、値が1以上のものだけを配列に入れる
            for (key, value) in statuses {
                if value > 0 {
                    activeKeys.append(key)
                }
            }
            
            // 2. 「by:」をハッキリ書き、さらに型（StatusType）を明記することで、
            // SortComparatorの勘違いを完全に封じ込める！
            activeKeys.sort(by: { (a: StatusType, b: StatusType) -> Bool in
                return a.hashValue < b.hashValue
            })
            
            return activeKeys
        }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(activeStatuses, id: \.self) { status in
                if let amount = statuses[status], amount > 0 {
                    // 値が1以上の時だけバッジを表示！
                    HStack(spacing: 4) {
                        Image(systemName: iconName(for: status))
                            .font(.caption)
                        Text("\(amount)")
                            .font(.caption).bold()
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(color(for: status).opacity(0.3))
                    .cornerRadius(6)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(color(for: status), lineWidth: 1))
                    .foregroundColor(color(for: status))
                }
            }
        }
    }
    
    // 🌟 ステータスごとの「アイコン（SF Symbols）」を決める
    private func iconName(for status: StatusType) -> String {
        switch status {
        case .target: return "scope"             // 🎯 ロックオンのマーク
        case .emp: return "bolt.slash.fill"      // ⚡️ 雷に斜線のマーク
        case .strength: return "flame.fill"      // 🔥 炎のマーク（筋力）
        // ※他にも追加したらここに足してください！
        }
    }
    
    // 🌟 ステータスごとの「色」を決める
    private func color(for status: StatusType) -> Color {
        switch status {
        case .target: return .red
        case .emp: return .cyan
        case .strength: return .orange
        }
    }
}
