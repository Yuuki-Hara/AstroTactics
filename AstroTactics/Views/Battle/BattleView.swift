//
//  BattleView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import SwiftUI

struct BattleView: View {
    var manager: BattleManager
    var onRestart: () -> Void
    
    @State private var targetId: UUID? = nil
    
    private var currentTarget: Enemy? {
        if let id = targetId, let enemy = manager.enemies.first(where: { $0.id == id && $0.currentHP > 0 }) {
            return enemy
        }
        return manager.enemies.first(where: {$0.currentHP > 0})
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1)
                .ignoresSafeArea()
            
            VStack {
                HStack(spacing: 15) {
                    ForEach(manager.enemies.filter { $0.currentHP > 0 }) { enemy in
                        Button(action: {
                            targetId = enemy.id
                        }) {
                            EnemyStatusView(enemy: enemy)
                                .overlay(
                                    // 🌟 修正：色が変化するのではなく、
                                    // 「ターゲットなら赤枠を被せる、違うなら何も被せない」と明確に分ける！
                                    Group {
                                        if currentTarget?.id == enemy.id {
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(Color.red, lineWidth: 3)
                                                // 枠の透明度（濃さ）だけをフワフワさせる
                                                .opacity(0.8)
                                        }
                                    }
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)

                Spacer()
                MessageBoardView(message: manager.displayMessage)
                Spacer()
                PlayerStatusView(player: manager.player)
                TurnEndButtonView(action: {
                    Task {
                        await manager.endPlayerTurn()
                    }
                },
                    isDisabled: manager.currentState != .playerAction
                )
                HandView(manager: manager, targetId: $targetId)

            }
            if manager.currentState == .victory || manager.currentState == .defeat {
                RestartView(isVictory: manager.currentState == .victory, onRestart: onRestart)
            }
        }
        // 🌟 ここは .onAppear ではなく .task を使います
        .task {
            if manager.currentState == .battleStart {
                await manager.startBattle()
            }
        }
    }
}

// MARK: - プレビュー
#Preview {
    let player = PlayerShip(name: "アストロ旗艦", maxHP: 50, maxEnergy: 3)
    let enemy = Enemy(category: "alien", name: "エイリアン偵察機",imageName: "alien_scout" , maxHP: 30)
    let deckManager = BattleDeckManager(startingDeck: CardDatabase.startingDeck())
    let battleManager = BattleManager(player: player, enemies: [enemy], deckManager: deckManager)
    return BattleView(manager: battleManager, onRestart: {})
}
