//
//  RestartView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

struct RestartView: View {
    var isVictory: Bool
    let onRestart: () -> Void
    
    var body: some View {
        // 背景を半透明の黒にして裏側を暗くする
        Color.black.opacity(0.85)
            .ignoresSafeArea()
        
        VStack(spacing: 30) {
            Text(isVictory ? GameSettings.messages.missionClear : GameSettings.messages.gameOver)
                .font(.system(size: 44, weight: .black))
                .foregroundColor(isVictory ? .yellow : .red)
                .shadow(color: isVictory ? .yellow.opacity(0.5) : .red.opacity(0.5), radius: 10, x: 0, y: 0)
            
            Button(action: {
                onRestart()
            }) {
                Text(GameSettings.messages.goNext)
                    .font(.title2).bold()
                    .padding()
                    .frame(width: 220)
                    .background(Color.cyan)
                    .foregroundColor(.black)
                    .cornerRadius(15)
            }
        }
    }
}

// MARK: - プレビュー用（勝利時と敗北時の両方を確認できるようにします）
#Preview("勝利パターン") {
    RestartView(isVictory: true, onRestart: { print("リスタート！") })
}

#Preview("敗北パターン") {
    RestartView(isVictory: false, onRestart: { print("リスタート！") })
}
