//
//  RestartView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//
import SwiftUI

struct RestartView: View {
    var isVictory: Bool
    // 💰 追加：BattleManagerから獲得金額を受け取る変数
    var earnedCredits: Int = 0
    let onRestart: () -> Void
    
    var body: some View {
        // 🌟 修正：背景色とテキストを綺麗に重ねるために ZStack で囲みます！
        ZStack {
            // 背景を半透明の黒にして裏側を暗くする
            Color.black.opacity(0.85)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text(isVictory ? GameSettings.messages.missionClear : GameSettings.messages.gameOver)
                    .font(.system(size: 44, weight: .black))
                    .foregroundColor(isVictory ? .yellow : .red)
                    .shadow(color: isVictory ? .yellow.opacity(0.5) : .red.opacity(0.5), radius: 10, x: 0, y: 0)
                
                // 🌟 追加：勝利した時だけ、獲得クレジットをアピール！
                if isVictory {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title2)
                        Text("\(earnedCredits) クレジットを獲得！")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.yellow, lineWidth: 1))
                }
                
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
}

// MARK: - プレビュー用（勝利時と敗北時の両方を確認できるようにします）
#Preview("勝利パターン") {
    // 💰 プレビューでも earnedCredits を渡すようにします
    RestartView(isVictory: true, earnedCredits: 25, onRestart: { print("リスタート！") })
}

#Preview("敗北パターン") {
    RestartView(isVictory: false, earnedCredits: 0, onRestart: { print("リスタート！") })
}
