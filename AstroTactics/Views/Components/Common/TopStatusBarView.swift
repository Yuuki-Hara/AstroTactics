//
//  TopStatusBarView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/26.
//


import SwiftUI

struct TopStatusBarView: View {
    var runManager: RunManager
    
    var body: some View {
        HStack(spacing: 16) {
            // ❤️ HPの表示
            HStack(spacing: 4) {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("\(runManager.player.currentHP)/\(runManager.player.maxHP)")
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            
            // 🌟 TopStatusBarView.swift の HStack の中（エナジーの隣など）に追加
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                    .foregroundColor(.yellow)
                Text("\(runManager.player.credits)") // 💰 所持金を表示！
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            // 💎 持っているレリックの一覧（横スクロール）
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(runManager.relics) { relic in
                        Image(systemName: relic.imageName)
                            .font(.title3)
                            .foregroundColor(.cyan)
                            // レリックのアイコンに、うっすら背景と枠をつけてリッチに！
                            .padding(6)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.cyan.opacity(0.5), lineWidth: 1))
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color.black.opacity(0.8)) // バーの背景を黒っぽくする
    }
}
