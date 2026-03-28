//
//  HandView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//
import SwiftUI

struct HandView: View {
    var manager: BattleManager
    
    // 🌟 変更：親から「ロックオン中の敵」を受け取る
    @Binding var targetId: UUID?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                ForEach(manager.deckManager.hand) { card in
                    Button(action: {
                        // 🔒 鉄壁の守り1：処理中、または自分のターンでないなら、連打されても完全に無視する！
                        guard !manager.isProcessing, manager.currentState == .playerAction else { return }
                        
                        if card.target == .singleEnemy {
                            // 🌟 単体攻撃なら、ロックオンしている敵に向かって即使う！
                            let targetEnemy = manager.enemies.first(where: { $0.id == targetId && $0.currentHP > 0 })
                                              ?? manager.enemies.first(where: { $0.currentHP > 0 })
                            
                            Task {
                                await manager.useCard(card, target: targetEnemy)
                            }
                        } else {
                            // 全体攻撃や回復などは、そのまま発動
                            Task {
                                await manager.useCard(card, target: nil)
                            }
                        }
                    }) {
                        CardView(card: card)
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 🔒 鉄壁の守り2：「エナジー不足」だけでなく「処理中」の時もボタンを無効化（タップ不可）にする！
                    .disabled(manager.player.currentEnergy < card.cost || manager.isProcessing)
                    
                    // 見た目はエナジー不足の時だけ暗くする（処理中は明るいまま待機させる）
                    .opacity(manager.player.currentEnergy < card.cost ? 0.5 : 1.0)
                }
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 190)
        }
        .frame(height: 230)
        // 🔒 鉄壁の守り3：手札エリア全体のタップ判定をオフにする（ダメ押し）
        .allowsHitTesting(!manager.isProcessing)
    }
}
