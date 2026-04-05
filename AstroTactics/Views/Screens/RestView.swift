//
//  RestView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//
import SwiftUI

// 🌟 休憩所で「今何をしているか」の状態
enum RestState {
  case choosing  // 選択中（初期画面）
  case upgrading  // 強化カードを選んでいる
  case removing  // 廃棄カードを選んでいる
}

struct RestView: View {
  var runManager: RunManager
  var onComplete: () -> Void

  @State private var restState: RestState = .choosing

  var body: some View {
    ZStack {
      Color(red: 0.1, green: 0.2, blue: 0.1).ignoresSafeArea()

      // 状態に合わせて画面を切り替える
      switch restState {
      case .choosing:
        restChoiceView

      case .upgrading:
        // 🌟 CardGridViewの魔法で、強化画面がたったこれだけに！
        CardGridView(
          title: "強化するカードを選択",
          cards: runManager.baseDeck,
          onSelect: { selectedCard in
            // すでに強化済みの場合は何もしない
            guard !selectedCard.isUpgraded else { return }

            // 選んだカードを探して強化し、出発する！
            if let index = runManager.baseDeck.firstIndex(where: { $0.id == selectedCard.id }) {
              runManager.baseDeck[index].upgrade()
              runManager.advanceToNextNode()
              onComplete()
            }
          },
          onCancel: {
            withAnimation { restState = .choosing }
          }
        )

      case .removing:
        // 🌟 もちろん廃棄画面もCardGridViewを使い回すだけ！
        CardGridView(
          title: "廃棄するカードを選択",
          cards: runManager.baseDeck,
          onSelect: { selectedCard in
            // 選んだカードを探して削除し、出発する！
            if let index = runManager.baseDeck.firstIndex(where: { $0.id == selectedCard.id }) {
              runManager.baseDeck.remove(at: index)
              runManager.advanceToNextNode()
              onComplete()
            }
          },
          onCancel: {
            withAnimation { restState = .choosing }
          }
        )
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

      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 20) {
          // 🛠️ 選択肢1：修理（回復）
          Button(
            action: {
              let healAmount = Int(
                Double(runManager.player.maxHP) * GameSettings.config.restHealPercentage)
              runManager.player.currentHP = min(
                runManager.player.currentHP + healAmount, runManager.player.maxHP)
              runManager.advanceToNextNode()
              onComplete()
            },
            label: {
              ChoiceButtonView(
                icon: "wrench.and.screwdriver.fill",
                title: GameSettings.messages.restHealButton,
                subText: String(
                  format: GameSettings.messages.restHealSubText,
                  Int(GameSettings.config.restHealPercentage * 100)),
                color: .green
              )
            })

          // ⚡️ 選択肢2：改造（カード強化）
          Button(
            action: {
              withAnimation { restState = .upgrading }
            },
            label: {
              ChoiceButtonView(
                icon: "hammer.fill",
                title: "改造する",
                subText: "カードを1枚強化",
                color: .orange
              )
            })

          // 🗑️ 選択肢3：廃棄（デッキ圧縮）
          Button(
            action: {
              withAnimation { restState = .removing }
            },
            label: {
              ChoiceButtonView(
                icon: "trash.fill",
                title: "廃棄する",
                subText: "不要なカードを1枚削除",
                color: .red
              )
            })
        }
        .padding(.horizontal, 20)
      }
    }
  }
}
