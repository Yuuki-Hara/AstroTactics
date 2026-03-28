//
//  RestView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//
import SwiftUI

// 🌟 追加：休憩所で「今何をしているか」の状態
enum RestState {
    case choosing   // 選択中（初期画面）
    case upgrading  // 強化カードを選んでいる
    case removing   // 廃棄カードを選んでいる
}

struct RestView: View {
    var runManager: RunManager
    var onComplete: () -> Void
    
    // 🌟 状態管理を enum に変更！
    @State private var restState: RestState = .choosing
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.2, blue: 0.1).ignoresSafeArea()
            
            // 状態に合わせて画面を切り替える
            switch restState {
            case .choosing:
                restChoiceView
            case .upgrading:
                upgradeSelectionView
            case .removing:
                removeSelectionView // 🌟 追加：廃棄画面
            }
        }
    }
    
    // MARK: - ☕️ 休憩所の選択画面（3択）
    private var restChoiceView: some View {
        VStack(spacing: 40) {
            Text(GameSettings.messages.restTitle)
                .font(.largeTitle).bold()
                .foregroundColor(.white)
            
            Text(GameSettings.messages.restDescription)
                .font(.headline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            // 🌟 変更：選択肢が3つ以上になっても画面に収まるように、横スクロールにする！
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
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
                        withAnimation { restState = .upgrading }
                    }) {
                        choiceButtonUI(
                            icon: "hammer.fill",
                            title: "改造する",
                            subText: "カードを1枚強化",
                            color: .orange
                        )
                    }
                    
                    // 🗑️ 選択肢3：廃棄（デッキ圧縮）
                    Button(action: {
                        withAnimation { restState = .removing }
                    }) {
                        choiceButtonUI(
                            icon: "trash.fill",
                            title: "廃棄する",
                            subText: "不要なカードを1枚削除",
                            color: .red
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // ボタンの見た目（変更なし）
    private func choiceButtonUI(icon: String, title: String, subText: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 40))
            Text(title).font(.title3).bold()
            Text(subText).font(.caption)
        }
        .foregroundColor(.white)
        .frame(width: 140, height: 160)
        .background(color.opacity(0.8))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 2))
    }
    
    // MARK: - 🃏 カード強化画面（既存）
    private var upgradeSelectionView: some View {
        VStack(spacing: 20) {
            Text("強化するカードを選択")
                .font(.title).bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0..<runManager.masterDeck.count, id: \.self) { index in
                        let card = runManager.masterDeck[index]
                        
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
                        .opacity(card.isUpgraded ? 0.5 : 1.0)
                        .onTapGesture {
                            if !card.isUpgraded {
                                runManager.masterDeck[index].upgrade()
                                runManager.advanceToNextNode()
                                onComplete()
                            }
                        }
                    }
                }
                .padding()
            }
            
            Button("やめる（回復を選ぶ）") {
                withAnimation { restState = .choosing }
            }
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
    }
    
    // MARK: - 🗑️ 追加：カード廃棄画面
    private var removeSelectionView: some View {
        VStack(spacing: 20) {
            Text("廃棄するカードを選択")
                .font(.title).bold()
                .foregroundColor(.white)
                .padding(.top, 40)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0..<runManager.masterDeck.count, id: \.self) { index in
                        let card = runManager.masterDeck[index]
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text(card.name)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("コスト: \(card.cost)")
                                    .font(.caption)
                                    .foregroundColor(.cyan)
                            }
                            Spacer()
                            
                            // 赤い「廃棄」ボタン！
                            Text("廃棄する")
                                .font(.caption).bold()
                                .padding(8)
                                .background(Color.red)
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 1))
                        
                        // 🌟 タップした時の処理（デッキから削除！）
                        .onTapGesture {
                            // 指定したインデックスのカードを配列から削除する
                            runManager.masterDeck.remove(at: index)
                            
                            // マップに戻る
                            runManager.advanceToNextNode()
                            onComplete()
                        }
                    }
                }
                .padding()
            }
            
            Button("やめる（回復を選ぶ）") {
                withAnimation { restState = .choosing }
            }
            .foregroundColor(.gray)
            .padding(.bottom, 20)
        }
    }
}
