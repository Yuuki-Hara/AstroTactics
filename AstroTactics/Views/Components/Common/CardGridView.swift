//
//  CardGridView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//


import SwiftUI

// 🌟 閲覧・削除・強化、すべてで使い回せる最強のカード一覧ビュー！
struct CardGridView: View {
    let title: String
    let cards: [Card]
    
    // 💡 ここがミソ！タップした時の処理を「外から」渡せるようにします。
    // nil（何も渡さない）の場合は「ただ見るだけ（ボタンにならない）」になります。
    let onSelect: ((Card) -> Void)?
    let onCancel: () -> Void
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea()
            
            VStack {
                Text(title)
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding()
                
                ScrollView {
                    // 🌟 画面サイズに合わせて自動で折り返すグリッド！
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                        ForEach(cards) { card in
                            if let action = onSelect {
                                // 👆 処理が渡されている場合（削除や強化）はボタンにする！
                                Button(action: {
                                    action(card)
                                }) {
                                    CardView(card: card)
                                        .scaleEffect(0.8)
                                        .frame(width: 140, height: 200)
                                }
                                .buttonStyle(PlainButtonStyle())
                            } else {
                                // 👀 何も渡されていない場合（デッキ確認）はただ表示するだけ！
                                CardView(card: card)
                                    .scaleEffect(0.8)
                                    .frame(width: 140, height: 200)
                            }
                        }
                    }
                    .padding()
                }
                
                Button("閉じる") {
                    onCancel()
                }
                .font(.headline)
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}