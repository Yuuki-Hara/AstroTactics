//
//  ShopCardItem.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/28.
//


import SwiftUI

// 🌟 ショップに並ぶ商品のデータ（商品タグのようなもの）
struct ShopCardItem: Identifiable {
    let id = UUID()
    let card: Card
    let price: Int
    var isSold: Bool = false
}

struct ShopView: View {
    var runManager: RunManager
    var onComplete: () -> Void
    
    // お店に並んでいるカードのリスト
    @State private var shopCards: [ShopCardItem] = []
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.15, blue: 0.25).ignoresSafeArea() // ちょっと怪しげな宇宙商人の背景色
            
            VStack(spacing: 30) {
                // 🏷️ ヘッダー（タイトルと所持金）
                HStack {
                    VStack(alignment: .leading) {
                        Text("宇宙商人")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("「金さえあれば、いいモノを売るぜ」")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // 💰 現在の所持金
                    HStack(spacing: 8) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                        Text("\(runManager.player.credits)")
                            .font(.title).bold()
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // 🃏 商品（カード）の陳列棚
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(0..<shopCards.count, id: \.self) { index in
                            let item = shopCards[index]
                            
                            if item.isSold {
                                // ❌ 売り切れ表示
                                soldOutView
                            } else {
                                // 🛒 販売中のカード
                                shopCardUI(item: item, index: index)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // 🚪 お店を出るボタン
                Button(action: {
                    runManager.advanceToNextNode()
                    onComplete()
                }) {
                    Text("店を出る")
                        .font(.title3).bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 200)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            setupShop()
        }
    }
    
    // MARK: - 🛍️ お店の準備
    private func setupShop() {
        // CardDatabase からランダムに3枚選んで、値段をつけて並べる
        // （※ CardDatabase.allCards は艦長の環境に合わせて適宜書き換えてください）
        let randomCards = CardDatabase.allCardsData.shuffled().prefix(3)
        
        shopCards = randomCards.map { card in
            // 値段は 40 〜 80 クレジットの間でランダム
            let randomPrice = Int.random(in: 40...80)
            return ShopCardItem(card: card, price: randomPrice)
        }
    }
    
    // MARK: - 🃏 販売中カードの見た目
    private func shopCardUI(item: ShopCardItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        
        return VStack(spacing: 12) {
            // ここは既存のカード表示ビューがあればそれに差し替えてもOKです！
            CardView(card: item.card)

            // 💰 購入ボタン
            Button(action: {
                if canAfford {
                    buyCard(at: index)
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                    Text("\(item.price)")
                        .bold()
                }
                .foregroundColor(canAfford ? .black : .gray)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(canAfford ? Color.yellow : Color.black)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow, lineWidth: canAfford ? 0 : 1))
            }
            .disabled(!canAfford) // お金が足りない時は押せないようにする
        }
    }
    
    // MARK: - ❌ 売り切れの見た目
    private var soldOutView: some View {
        VStack {
            Spacer()
            Text("SOLD OUT")
                .font(.title2).bold()
                .foregroundColor(.red)
                .rotationEffect(.degrees(-15))
            Spacer()
        }
        .frame(width: 140, height: 200)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 2))
    }
    
    // MARK: - 💸 購入処理
    private func buyCard(at index: Int) {
        let item = shopCards[index]
        
        // 1. お金を減らす
        runManager.player.credits -= item.price
        // 2. デッキにカードを追加
        runManager.masterDeck.append(item.card)
        // 3. 商品を「売り切れ」にする
        shopCards[index].isSold = true
    }
}
