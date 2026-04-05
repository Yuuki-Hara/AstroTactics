//
//  BattleInteractiveCardView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/04/05.
//


import SwiftUI

// 🌟 バトル画面専用の「操作できるカード」
struct BattleInteractiveCardView: View {
    let card: Card
    let isSelected: Bool
    let isUsable: Bool // エナジー不足や処理中でないか
    
    let onSelect: () -> Void
    let onUse: () -> Void
    
    // ドラッグ（スワイプ）の移動量を記録
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        // 既存の綺麗なCardViewをそのまま中に表示！
        CardView(card: card)
            .opacity(isUsable ? 1.0 : 0.5)
        
            // 🌟 動きの魔法：選択中なら -30 浮き、ドラッグ中なら指についてくる
            .offset(y: isSelected ? -30 : 0)
            .offset(dragOffset)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
            .animation(.interactiveSpring(), value: dragOffset)
        
            // 👆 【操作A】タップの処理
            .onTapGesture {
                guard isUsable else { return } // 使えないカードは無反応
                
                if isSelected {
                    onUse()    // 2回目のタップ：使用！
                } else {
                    onSelect() // 1回目のタップ：選択して浮かせる！
                }
            }
        
            // 👆 【操作B】スワイプ（ドラッグ）の処理
            .gesture(
                DragGesture()
                    .onChanged { value in
                        guard isUsable else { return }
                        
                        dragOffset = value.translation
                        
                        // 触って動かし始めた瞬間に、選択状態（浮いた状態）にする
                        if !isSelected {
                            onSelect()
                        }
                    }
                    .onEnded { value in
                        guard isUsable else {
                            dragOffset = .zero
                            return
                        }
                        
                        // 上に100ポイント以上スワイプして指を離したら使用！
                        if value.translation.height < -100 {
                            onUse()
                        }
                        
                        // どこで指を離しても、スッと元の位置に戻る
                        dragOffset = .zero
                    }
            )
    }
}
