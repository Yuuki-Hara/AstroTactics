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
    
    // 🌟 強化画面を開いているかどうかの状態
    @State private var isUpgrading: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.1).ignoresSafeArea()
            
            if isUpgrading {
                // 🃏 カード選択画面（デッキ一覧）
                upgradeSelectionView
            } else {
                // ☕️ いつもの休憩所画面（2択）
                restChoiceView
            }
        }
    }
    
    // MARK: - ☕️ 休憩所の2択画面
    private var restChoiceView: some View {
        VStack(spacing: 40) {
            Text(GameSettings.messages.restTitle)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            Text(GameSettings.messages.restDescription)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 30) {
                // 🛠️ 選択肢1：修理（回復）
                Button(action: {
                    let healAmount = Int(Double(runManager.player.maxHP) * GameSettings.config.restHealPercentage)
                    runManager.player.currentHP = min(runManager.player.currentHP + healAmount, runManager.player.maxHP)
                    runManager.advanceToNextNode()
                    onComplete()
                }) {
                    choiceButtonUI(
                        icon: "wrench.and.screwdriver.fill",
                        title: GameSettings.messages.restHealButton,
                        subText: String(format: GameSettings.messages.restHealSubText, Int(GameSettings.config.restHealPercentage * 100)),
                        color: .green
                    )
                }
                
                // ⚡️ 選択肢2：改造（カード強化）
                Button(action: {
                    // 強化画面に切り替える！
                    withAnimation { isUpgrading = true }
                }) {
                    choiceButtonUI(
                        icon: "hammer.fill", title: "改造する",
                        subText: "カードを1枚強化",
                        color: .orange
                    )
                }
            }
        }
    }
    
    // ボタンの見た目を共通化する便利パーツ
    private func choiceButtonUI(icon: String, title: String, subText: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 40))
            Text(title).font(.title3).bold()
            Text(subText).font(.caption)
        }
        .foregroundColor(.white)
        .frame(width: 140, height: 160)
        .background(color.opacity(0.8))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 2))
    }
    
    // MARK: - 🃏 カード強化画面
    private var upgradeSelectionView: some View {
        VStack(spacing: 20) {
            Text("強化するカードを選択")
                .font(.title).bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            ScrollView {
                // デッキのカードを縦に並べる
                VStack(spacing: 15) {
                    // 🌟 修正ポイント：デッキの「番号(index)」を使ってループを回す！
                    ForEach(0..<runManager.masterDeck.count, id: \.self) { index in
                        let card = runManager.masterDeck[index]
                        
                        // 1枚のカードの見た目（簡易版）
                        HStack {
                            VStack(alignment: .leading) {
                                Text(card.name)
                                    .font(.headline)
                                    .foregroundColor(card.isUpgraded ? .orange : .white)
                                Text("コスト: \(card.cost)")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                            }
                            Spacer()
                            
                            if card.isUpgraded {
                                Text("強化済")
                                    .font(.caption).bold()
                                    .foregroundColor(.gray)
                            } else {
                                Text("強化する")
                                    .font(.caption).bold()
                                    .padding(8)
                                    .background(Color.orange)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(card.isUpgraded ? Color.orange : Color.gray, lineWidth: 1))
                        .opacity(card.isUpgraded ? 0.5 : 1.0) // 強化済みは暗くする
                        
                        // 🌟 タップした時の処理
                        .onTapGesture {
                            if !card.isUpgraded {
                                // 該当のカードを強化！
                                runManager.masterDeck[index].upgrade()
                                
                                // マップに戻る
                                runManager.advanceToNextNode()
                                onComplete()
                            }
                        }
                    }
                }
                .padding()
            }
            
            // キャンセルして戻るボタン
            Button("やめる（回復を選ぶ）") {
                withAnimation { isUpgrading = false }
            }
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
    }
}
