//
//  GameClearView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//

import SwiftUI

struct GameClearView: View {
  // ボタンを押した時に親（ContentView）に「タイトルに戻るよ」と伝えるケーブル
  var onReturnToTitle: () -> Void

  // 演出用：文字をフワッと出すための変数
  @State private var isVisible = false

  var body: some View {
    ZStack {
      // 背景は宇宙の深淵をイメージした濃い色
      Color(red: 0.05, green: 0.05, blue: 0.15).ignoresSafeArea()

      VStack(spacing: 40) {
        Text("MISSION COMPLETE")
          .font(.system(size: 45, weight: .black))
          .foregroundColor(.yellow)
          .shadow(color: .yellow.opacity(0.8), radius: 10, x: 0, y: 0)
          .scaleEffect(isVisible ? 1.0 : 0.5)
          .opacity(isVisible ? 1.0 : 0)

        VStack(spacing: 15) {
          Text("帝国軍 殲滅旗艦を撃破し、")
          Text("この星域に平和が訪れた…！")
        }
        .font(.title2).bold()
        .foregroundColor(.white)
        .multilineTextAlignment(.center)
        .opacity(isVisible ? 1.0 : 0)

        // 🌟 ボーナス：プレイヤーを労うメッセージ
        Text("見事な指揮でした、艦長。")
          .font(.headline)
          .foregroundColor(.cyan)
          .padding(.top, 20)
          .opacity(isVisible ? 1.0 : 0)

        Button(
          action: {
            onReturnToTitle()
          },
          label: {
            Text("タイトルへ戻る")
              .font(.title3).bold()
              .foregroundColor(.black)
              .padding(.horizontal, 40)
              .padding(.vertical, 15)
              .background(Color.cyan)
              .cornerRadius(12)
              .shadow(color: .cyan.opacity(0.5), radius: 5)
          }
        )
        .padding(.top, 50)
        .opacity(isVisible ? 1.0 : 0)
      }
    }
    .onAppear {
      // 画面が表示されたら、1秒かけてフワッと要素を表示するアニメーション
      withAnimation(.easeOut(duration: 1.5)) {
        isVisible = true
      }
    }
  }
}

#Preview {
  GameClearView(onReturnToTitle: {})
}
