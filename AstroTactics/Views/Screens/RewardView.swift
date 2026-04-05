//
//  RewardView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/24.
//

import SwiftUI

struct RewardView: View {
  var runManager: RunManager
  // 🌟 カードを選び終わった（またはスキップした）時に親に知らせるケーブル
  var onComplete: () -> Void

  // 画面に表示する3枚のランダムなカード候補
  @State private var offeredCards: [Card] = []

  var body: some View {
    ZStack {
      Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()

      VStack(spacing: 40) {
        VStack(spacing: 10) {
          Text("BATTLE CLEAR!")
            .font(.system(size: 40, weight: .black))
            .foregroundColor(.yellow)
            .shadow(color: .yellow.opacity(0.5), radius: 10, x: 0, y: 0)

          Text("デッキに追加するカードを1枚選んでください")
            .font(.headline)
            .foregroundColor(.white)
        }

        ScrollView(.horizontal, showsIndicators: false) {
          HStack(spacing: 20) {
            ForEach(offeredCards) { card in
              Button(
                action: {
                  runManager.baseDeck.append(card)
                  onComplete()
                },
                label: {
                  CardView(card: card)
                }
              )
              .buttonStyle(PlainButtonStyle())
              // 画面外にはみ出しにくくするため、フワフワの拡大率を少し控えめ(1.02)に調整
              .scaleEffect(1.02)
              .animation(
                .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                value: offeredCards.count)
            }
          }
          // スクロールした時に両端が切れないように、しっかり余白を持たせる
          .padding(.horizontal, 30)
          .padding(.vertical, 20)
        }
        // 欲しいカードがない場合のスキップボタン
        Button(
          action: {
            onComplete()
          },
          label: {
            Text("スキップ (追加しない)")
              .font(.headline)
              .foregroundColor(.gray)
              .padding()
              .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
          })
      }
    }
    .onAppear {
      generateRewardCards()
    }
  }

  // MARK: - 報酬カードの生成
  private func generateRewardCards() {
    var allCards = CardDatabase.allRewardCards()
    allCards.shuffle()

    offeredCards = Array(allCards.prefix(3))
  }
}
