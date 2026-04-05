//
//  TitleView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

struct TitleView: View {
  // 🌟 親（ContentView）に知らせるための通信ケーブル
  var onStart: () -> Void

  // 🌟 セーブデータがあるかどうかを判定するための変数
  @State private var hasSaveData = false

  var body: some View {
    ZStack {
      // 背景：宇宙空間をイメージした暗い色
      Color(red: 0.05, green: 0.05, blue: 0.1)
        .ignoresSafeArea()

      VStack(spacing: 50) {

        // MARK: - タイトルロゴ
        VStack(spacing: 10) {
          Text("ASTRO")
            .font(.system(size: 60, weight: .black, design: .monospaced))
            .foregroundColor(.cyan)
          Text("TACTICS")
            .font(.system(size: 60, weight: .black, design: .monospaced))
            .foregroundColor(.yellow)
        }
        .shadow(color: .cyan.opacity(0.6), radius: 10, x: 0, y: 0)

        // MARK: - ボタンエリア
        VStack(spacing: 20) {
          // ① NEW GAME (新規) ボタン
          Button(
            action: {
              startNewGame()
            },
            label: {
              Text("NEW GAME")
                .font(.title2).bold()
                .padding()
                .frame(width: 250)
                .background(Color.blue.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(15)
                .overlay(
                  RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.cyan, lineWidth: 2)
                )
            }
          )
          .shadow(color: .cyan.opacity(0.5), radius: 8, x: 0, y: 0)

          // ② RESUME (再開) ボタン
          Button(
            action: {
              resumeGame()
            },
            label: {
              Text("RESUME")
                .font(.title2).bold()
                .padding()
                .frame(width: 250)
                // データがない場合は灰色にして、押せないように見せます
                .background(hasSaveData ? Color.blue.opacity(0.3) : Color.gray.opacity(0.3))
                .foregroundColor(hasSaveData ? .white : .gray)
                .cornerRadius(15)
                .overlay(
                  RoundedRectangle(cornerRadius: 15)
                    .stroke(hasSaveData ? Color.cyan : Color.gray, lineWidth: 2)
                )
            }
          )
          .shadow(color: hasSaveData ? .cyan.opacity(0.5) : .clear, radius: 8, x: 0, y: 0)
          .disabled(!hasSaveData)  // データがない時はボタンの機能を無効化します
        }
        // 🌟 ここにデバッグ用のデータ削除ボタンを追記します
        Button(
          action: {
            deleteSaveDataForDebug()
          },
          label: {
            Text("🗑 セーブデータを削除 (Debug)")
              .font(.footnote)
              .foregroundColor(.red)
              .padding()
          }
        )
        .padding(.top, 30)  // 少し隙間を空けます
      }

    }
    .onAppear {
      // 🌟 画面が表示された時に、セーブデータがあるかチェックします
      checkSaveData()
    }
  }

  // MARK: - メソッド（ボタンを押したときの処理など）

  // セーブデータがあるか確認する処理
  private func checkSaveData() {
    if SaveManager.shared.load() != nil {
      hasSaveData = true  // データあり！
    } else {
      hasSaveData = false  // データなし
    }
  }

  // 新規ゲームを開始する処理
  private func startNewGame() {
    // 1. 古いセーブデータを消去する
    SaveManager.shared.deleteSave()
    onStart()
  }

  // ゲームを再開する処理
  private func resumeGame() {
    // セーブデータはそのままに、ContentViewにゲーム再開を知らせる！
    onStart()
  }

  private func deleteSaveDataForDebug() {
    // 1. データを完全に消去する
    SaveManager.shared.deleteSave()

    // 2. セーブデータがあるかどうかのチェックをやり直す
    // （これによって、RESUMEボタンが即座に灰色に変わります！）
    checkSaveData()

    print("🛠 デバッグ: セーブデータを手動で削除しました")
  }
}

// MARK: - プレビュー
#Preview {
  TitleView(onStart: {})
}
