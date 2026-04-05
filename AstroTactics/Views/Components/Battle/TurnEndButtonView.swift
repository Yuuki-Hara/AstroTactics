//
//  TurnEndButtonView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

// 🌟 ターン終了ボタン「だけ」を担当する専門のView
struct TurnEndButtonView: View {

  // 1. 親から「ボタンが押された時に実行してほしい処理」を丸ごと受け取る箱
  let action: () -> Void

  // 2. ボタンを押せない状態（グレーアウト）にするかどうかの判定を受け取る箱
  let isDisabled: Bool

  var body: some View {
    Button(
      action: {
        // 押されたら、親から渡された処理を実行するだけ！
        action()
      },
      label: {
        Text(GameSettings.messages.turnEnd)
          .font(.headline).bold()
          .padding()
          // 横幅いっぱいに広げる
          .frame(maxWidth: .infinity)
          // 押せない時はグレー、押せる時はオレンジ色にする
          .background(isDisabled ? Color.gray.opacity(0.5) : Color.red)
          .foregroundColor(.white)
          .cornerRadius(12)
      }
    )
    // SwiftUIの標準機能：trueを渡すとボタンが押せなくなる
    .disabled(isDisabled)
    .padding(.horizontal, 40)
    .padding(.top, 10)
  }
}

// MARK: - プレビュー用（押せる状態と押せない状態の両方を確認！）
#Preview {
  ZStack {
    Color.black.ignoresSafeArea()
    VStack(spacing: 20) {
      TurnEndButtonView(action: { print("ターン終了！") }, isDisabled: false)
      TurnEndButtonView(action: { print("今は押せません") }, isDisabled: true)
    }
  }
}
