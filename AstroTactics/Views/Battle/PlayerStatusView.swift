//
//  PlayerStatusView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

struct PlayerStatusView: View {
    var player: PlayerShip
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(player.name)
                    .font(.headline)
                    .foregroundColor(.cyan)
                Spacer()
                Text("EN: \(player.currentEnergy) / \(player.maxEnergy)")
                    .font(.headline)
                    .foregroundColor(.yellow)
            }
            .padding(.horizontal, 40)
            
            ProgressView(value: Double(player.currentHP), total: Double(player.maxHP))
                .tint(.cyan)
                .padding(.horizontal, 40)
            
            HStack {
                Text("HP: \(player.currentHP) / \(player.maxHP)")
                    .foregroundColor(.white)
                Spacer()
                if player.shield > 0 {
                    Text("シールド: \(player.shield)")
                        .foregroundColor(.blue)
                        .bold()
                }
            }
            .font(.caption)
            .padding(.horizontal, 40)
        }
        
    }
}
