//
//  TreasureView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/26.
//

import SwiftUI

struct TreasureView: View {
  var runManager: RunManager
  var onComplete: () -> Void

  @State private var obtainedRelic: Relic?
  @State private var isOpened: Bool = false

  var body: some View {
    ZStack {
      Color(red: 0.2, green: 0.1, blue: 0.3).ignoresSafeArea()  // ちょっと特別感のある紫背景

      VStack(spacing: 30) {
        Text("未知の宝箱")
          .font(.largeTitle).bold()
          .foregroundColor(.white)

        if !isOpened {
          // 🎁 開ける前の宝箱
          Button(action: openChest) {
            VStack {
              Image(systemName: "gift.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
              Text("開ける")
                .font(.title2).bold()
                .foregroundColor(.white)
                .padding(.top, 10)
            }
          }
        } else if let relic = obtainedRelic {
          // 💎 開けた後（レリック獲得！）
          VStack(spacing: 20) {
            Text("レリックを獲得した！")
              .font(.headline)
              .foregroundColor(.yellow)

            Image(systemName: relic.imageName)
              .font(.system(size: 60))
              .foregroundColor(.cyan)
              .padding()
              .background(Color.black.opacity(0.5))
              .cornerRadius(15)

            Text(relic.name)
              .font(.title).bold()
              .foregroundColor(.white)

            Text(relic.description)
              .font(.body)
              .foregroundColor(.gray)
              .multilineTextAlignment(.center)
              .padding(.horizontal, 40)

            Button("進む") {
              runManager.advanceToNextNode()
              onComplete()
            }
            .font(.title3).bold()
            .foregroundColor(.white)
            .padding()
            .frame(width: 200)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.top, 20)
          }
        } else {
          // すべてのレリックを持っている場合
          Text("宝箱は空だった…")
            .foregroundColor(.gray)

          Button("進む") {
            runManager.advanceToNextNode()
            onComplete()
          }
          .padding()
        }
      }
    }
  }

  private func openChest() {
    // まだ持っていないレリックをリストアップ
    let unownedRelics = RelicDatabase.allRelics.filter { dbRelic in
      !runManager.relics.contains(where: { $0.id == dbRelic.id })
    }
    // ランダムに1つ選んで獲得！
    if let newRelic = unownedRelics.randomElement() {
      runManager.relics.append(newRelic)
      obtainedRelic = newRelic
    }

    withAnimation { isOpened = true }
  }
}
