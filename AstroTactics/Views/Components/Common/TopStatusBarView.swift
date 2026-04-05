//
//  TopStatusBarView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/26.
//

import SwiftUI

struct TopStatusBarView: View {
  var runManager: RunManager

  @State private var showDeckSheet = false
  @State private var showRelicSheet = false

  var body: some View {
    HStack(spacing: 16) {
      // ❤️ HPの表示
      HStack(spacing: 4) {
        Image(systemName: "heart.fill")
          .foregroundColor(.red)
        Text("\(runManager.player.currentHP)/\(runManager.player.maxHP)")
          .font(.headline).bold()
          .foregroundColor(.white)
      }

      // 🌟 TopStatusBarView.swift の HStack の中（エナジーの隣など）に追加
      HStack(spacing: 4) {
        Image(systemName: "dollarsign.circle.fill")
          .foregroundColor(.yellow)
        Text("\(runManager.player.credits)")  // 💰 所持金を表示！
          .font(.headline).bold()
          .foregroundColor(.white)
      }

      Spacer()
      // 🔍 デッキ確認ボタン
      Button(
        action: { showDeckSheet = true },
        label: {
          Image(systemName: "square.stack.3d.up.fill")
            .font(.title2)
            .foregroundColor(.white)
        })

      // 💎 レリック確認ボタン
      Button(
        action: { showRelicSheet = true },
        label: {
          Image(systemName: "sparkles")
            .font(.title2)
            .foregroundColor(.cyan)
        })
    }
    .padding(.horizontal)
    .padding(.vertical, 10)
    .background(Color.black.opacity(0.8))  // バーの背景を黒っぽくする
    // 🌟 デッキ確認シート（onSelect は nil なので、ただ見るだけ！）
    .sheet(isPresented: $showDeckSheet) {
      CardGridView(
        title: "現在のマスターデッキ (\(runManager.baseDeck.count)枚)",
        cards: runManager.baseDeck,
        onSelect: nil,
        onCancel: { showDeckSheet = false }
      )
    }
    // 🌟 レリック確認シート（とりあえず今は簡易的なリストで表示）
    .sheet(isPresented: $showRelicSheet) {
      relicSheetView
    }
  }
  private var relicSheetView: some View {
    ZStack {
      Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea()
      VStack {
        Text("所持しているレリック").font(.title2).bold().foregroundColor(.white).padding()
        if runManager.relics.isEmpty {
          Text("まだレリックを持っていません").foregroundColor(.gray).padding()
        } else {
          List(runManager.relics) { relic in
            HStack(spacing: 15) {
              Image(systemName: relic.imageName).font(.title).foregroundColor(.cyan)
              VStack(alignment: .leading) {
                Text(relic.name).font(.headline).foregroundColor(.white)
                Text(relic.description).font(.caption).foregroundColor(.gray)
              }
            }
            .listRowBackground(Color.clear)
          }
          .listStyle(PlainListStyle())
        }
        Spacer()
        Button("閉じる") { showRelicSheet = false }.foregroundColor(.red).padding()
      }
    }
  }
}
