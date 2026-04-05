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
    
    // 🌟 シールドも受け取るようにします
    var shield: Int = 0
    
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
    
    let columns = [
        GridItem(.adaptive(minimum: 45), spacing: 4)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(activeStatuses, id: \.self) { status in
                if let amount = statuses[status], amount > 0 {
                    // 🌟 StatusType が持っているプロパティを直接使う！
                    StatusBadgeView(
                        iconName: status.iconName,
                        amount: amount,
                        tintColor: status.color
                    )
                }
            }
        }
    }
}

// MARK: - 🌟 共通デザイン部品
struct StatusBadgeView: View {
    let iconName: String
    let amount: Int
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: iconName)
                .font(.caption)
            Text("\(amount)")
                .font(.caption).bold()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(tintColor.opacity(0.3))
        .cornerRadius(6)
        .overlay(RoundedRectangle(cornerRadius: 6).stroke(tintColor, lineWidth: 1))
        .foregroundColor(tintColor)
    }
}
