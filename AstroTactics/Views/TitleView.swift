//
//  TitleView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import SwiftUI

struct TitleView: View {
    // 🌟 「START GAME」ボタンが押された時に、親（ContentView）に知らせるための通信ケーブル
    var onStart: () -> Void
    
    var body: some View {
        ZStack {
            // 背景：宇宙空間をイメージした暗い色
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 50) {
                
                // MARK: - タイトルロゴ
                VStack(spacing: 10) {
                    Text("ASTRO")
                        .font(.system(size: 60, weight: .black, design: .monospaced))
                        .foregroundColor(.cyan)
                    Text("TACTICS")
                        .font(.system(size: 60, weight: .black, design: .monospaced))
                        .foregroundColor(.yellow)
                }
                .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 0)
                
                // MARK: - スタートボタン
                Button(action: {
                    onStart() // 押されたら ContentView に知らせる！
                }) {
                    Text("START GAME")
                        .font(.title2).bold()
                        .padding()
                        .frame(width: 250)
                        .background(Color.blue.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.cyan, lineWidth: 2)
                        )
                }
                .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)
            }
        }
    }
}

// MARK: - プレビュー
#Preview {
    TitleView(onStart: {})
}
