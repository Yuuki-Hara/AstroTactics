//
//  RestView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//


import SwiftUI

struct RestView: View {
    var runManager: RunManager
    var onComplete: () -> Void
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("☕️ 宇宙ステーション")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                
                Text("安全な宙域に到達した。\n船体を修理し、次の戦いに備えよう。")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                // HPを30%回復するボタン
                Button(action: {
                    let healAmount = Int(Double(runManager.player.maxHP) * 0.3)
                    runManager.player.currentHP = min(runManager.player.currentHP + healAmount, runManager.player.maxHP)
                    
                    // 回復したらクリア扱いにしてマップへ戻る
                    runManager.advanceToNextNode()
                    onComplete()
                }) {
                    VStack {
                        Text("🛠️ 修理する")
                            .font(.title2).bold()
                        Text("HPを30%回復")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 200)
                    .background(Color.green)
                    .cornerRadius(12)
                }
                
                // （後でここに「カード強化」のボタンなどを足せます！）
            }
        }
    }
}
