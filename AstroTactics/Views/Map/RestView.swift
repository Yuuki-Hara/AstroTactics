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
                Text(GameSettings.messages.restTitle)
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                
                Text(GameSettings.messages.restDescription)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                
                Button(action: {
                    // 🌟 回復量（0.3など）をJSONから取得！
                    let healAmount = Int(Double(runManager.player.maxHP) * GameSettings.config.restHealPercentage)
                    runManager.player.currentHP = min(runManager.player.currentHP + healAmount, runManager.player.maxHP)
                    
                    runManager.advanceToNextNode()
                    onComplete()
                }) {
                    VStack {
                        // 🌟 ボタンのテキストもJSONから！
                        Text(GameSettings.messages.restHealButton)
                            .font(.title2).bold()
                        let percentValue = Int(GameSettings.config.restHealPercentage * 100)
                        Text(String(format: GameSettings.messages.restHealSubText, percentValue))
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
