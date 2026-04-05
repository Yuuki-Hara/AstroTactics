//
//  HandView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//
import SwiftUI

struct HandView: View {
  var manager: BattleManager
  @Binding var targetId: UUID?

  @State private var selectedCardId: UUID?

  // 扇形の中心座標（画面下部）
  private let fanCenterX: CGFloat = 0  // 親のHStack基準で0
  private let fanCenterY: CGFloat = 450  // カードの下に仮想的な中心点
  private let fanRadius: CGFloat = 400  // 扇形の半径

  // カードのサイズ（既存の130x190を少しコンパクトに）
  private let cardWidth: CGFloat = 120
  private let cardHeight: CGFloat = 175

  var body: some View {
    HStack(spacing: calculateSpacing(for: manager.deckManager.hand.count)) {
      ForEach(manager.deckManager.hand.indices, id: \.self) { index in
        let card = manager.deckManager.hand[index]
        let isUsable = (manager.player.currentEnergy >= card.cost) && !manager.isProcessing

        // --- 🌟ここから扇形配置のための計算---
        let totalCards = manager.deckManager.hand.count

        // カードごとの回転角度（扇形）
        // 1枚なら0度、2枚なら±7度、3枚なら±14度...枚数が増えても重ならないように調整
        let maxAngle: Double = Double(min(max(0, totalCards - 1), 3)) * 6  // 最大21度まで
        let angleStep = totalCards > 1 ? (maxAngle * 2) / Double(totalCards - 1) : 0
        let angle = (Double(index) * angleStep - maxAngle)

        // カードごとの上下位置（アーチ状）
        let arcOffset = calculateArcOffset(for: angle, totalCards: totalCards)

        BattleInteractiveCardView(
          card: card,
          isSelected: selectedCardId == card.id,
          isUsable: isUsable,
          onSelect: {
            selectedCardId = card.id
          },
          onUse: {
            useSelectedCard(card)
          }
        )
        // 🌟カードのサイズを設定
        .frame(width: cardWidth, height: cardHeight)

        // 🌟回転と位置ずらしで扇形を表現
        .rotationEffect(.degrees(angle), anchor: .bottom)  // カードの下を起点に回転
        .offset(y: arcOffset)  // アーチ状に下げる

        .zIndex(selectedCardId == card.id ? 100 : Double(index))  // 重なり順（左が下、右が上、選択中が一番上）
      }
    }
    .padding(.horizontal, 10)
    .padding(.top, 40)
    .frame(height: 250)
    .frame(maxWidth: .infinity)
    .background(
      Color.clear.onTapGesture {
        selectedCardId = nil  // 背景タップでキャンセル
      }
    )
    .allowsHitTesting(!manager.isProcessing)
  }

  // MARK: - 🌟枚数に応じた余白計算ロジック（扇形用に調整）
  private func calculateSpacing(for count: Int) -> CGFloat {
    if count <= 3 {
      return -15  // 3枚以下なら少しだけ重ねる
    } else if count == 4 {
      return -45  // 4枚なら深く（これでも重なりが足りないならもっと小さく）
    } else {
      return -75  // 5枚以上ならガッツリ重ねて1画面に収める！
    }
  }

  // MARK: - 🌟回転角度に応じたアーチ状のオフセット計算
  private func calculateArcOffset(for angle: Double, totalCards: Int) -> CGFloat {
    // カードが1枚ならオフセットなし
    if totalCards <= 1 { return 0 }

    // 回転角度の絶対値（中央が0、外側ほど大きくなる）
    let absoluteAngle = abs(angle)

    // 中央のカードほど少し上に表示するロジック
    // absoluteAngleが大きいほど（外側ほど）yオフセットが大きくなる（下に下がる）
    // arcDepth：中央と外側の高低差（枚数が多いほどアーチを深くする）
    let arcDepth: CGFloat = CGFloat(min(totalCards, 5)) * 3.5  // 最大20
    let offset = CGFloat(absoluteAngle / 21) * arcDepth  // 最大角度21度基準

    return offset
  }

  // MARK: - カード使用のロジック
  private func useSelectedCard(_ card: Card) {
    guard !manager.isProcessing, manager.currentState == .playerAction else { return }

    let targetEnemy: Enemy?
    if card.target == .singleEnemy {
      targetEnemy =
        manager.enemies.first(where: { $0.id == targetId && $0.currentHP > 0 })
        ?? manager.enemies.first(where: { $0.currentHP > 0 })
    } else {
      targetEnemy = nil
    }

    Task {
      await manager.useCard(card, target: targetEnemy)
      selectedCardId = nil
    }
  }
}
