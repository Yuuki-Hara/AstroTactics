//
//  ShopCardItem.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/28.
//

import SwiftUI

// 🌟 ショップに並ぶカードの商品データ
struct ShopCardItem: Identifiable {
    let id = UUID()
    let card: Card
    let price: Int
    var isSold: Bool = false
}

// 💎 追加：ショップに並ぶレリックの商品データ
struct ShopRelicItem: Identifiable {
    let id = UUID()
    let relic: Relic
    let price: Int
    var isSold: Bool = false
}

struct ShopView: View {
    var runManager: RunManager
    var onComplete: () -> Void
    
    @State private var shopCards: [ShopCardItem] = []
    @State private var shopRelics: [ShopRelicItem] = [] // 💎 追加：レリックの棚
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.15, blue: 0.25).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 🏷️ ヘッダー（タイトルと所持金）
                HStack {
                    VStack(alignment: .leading) {
                        Text("宇宙商人")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("「いい品が入ってるぜ。金さえあればな」")
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
                
                // 🛒 お店の中身（縦スクロールできるようにする）
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // 🃏 カードの陳列棚
                        Text("カード")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopCards.count, id: \.self) { index in
                                    if shopCards[index].isSold {
                                        soldOutView(width: 140, height: 200)
                                    } else {
                                        shopCardUI(item: shopCards[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 💎 レリックの陳列棚（追加！）
                        Text("レリック")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopRelics.count, id: \.self) { index in
                                    if shopRelics[index].isSold {
                                        soldOutView(width: 140, height: 160)
                                    } else {
                                        shopRelicUI(item: shopRelics[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 40)
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
        // カードを3枚ランダムに並べる（40〜80クレジット）
        let randomCards = CardDatabase.allCardsData.shuffled().prefix(3)
        shopCards = randomCards.map { ShopCardItem(card: $0, price: Int.random(in: 40...80)) }
        
        // 💎 レリックを2個ランダムに並べる（高額：120〜200クレジット）
        let randomRelics = RelicDatabase.allRelics.shuffled().prefix(2)
        shopRelics = randomRelics.map { ShopRelicItem(relic: $0, price: Int.random(in: 120...200)) }
    }
    
    // MARK: - 🃏 カード販売UI
    private func shopCardUI(item: ShopCardItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            CardView(card: item.card)
                .frame(width: 140, height: 200)
                // 縮小表示して枠に収める
                .scaleEffect(0.8)
                .frame(width: 140, height: 200)
            
            buyButton(price: item.price, canAfford: canAfford) {
                // 購入処理
                runManager.player.credits -= item.price
                runManager.masterDeck.append(item.card)
                shopCards[index].isSold = true
            }
        }
    }
    
    // MARK: - 💎 レリック販売UI
    private func shopRelicUI(item: ShopRelicItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            VStack {
                Image(systemName: item.relic.imageName)
                    .font(.system(size: 40))
                    .foregroundColor(.cyan)
                    .padding()
                Text(item.relic.name)
                    .font(.headline).bold()
                    .foregroundColor(.white)
                Text(item.relic.description)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
            }
            .frame(width: 140, height: 160)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan, lineWidth: 2))
            
            buyButton(price: item.price, canAfford: canAfford) {
                // 購入処理
                runManager.player.credits -= item.price
                runManager.relics.append(item.relic)
                shopRelics[index].isSold = true
            }
        }
    }
    
    // MARK: - 💰 共通購入ボタン
    private func buyButton(price: Int, canAfford: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            if canAfford { action() }
        }) {
            HStack(spacing: 4) {
                Image(systemName: "dollarsign.circle.fill")
                Text("\(price)").bold()
            }
            .foregroundColor(canAfford ? .black : .gray)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(canAfford ? Color.yellow : Color.black)
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow, lineWidth: canAfford ? 0 : 1))
        }
        .disabled(!canAfford)
    }
    
    // MARK: - ❌ 売り切れUI
    private func soldOutView(width: CGFloat, height: CGFloat) -> some View {
        VStack {
            Spacer()
            Text("SOLD OUT")
                .font(.title2).bold()
                .foregroundColor(.red)
                .rotationEffect(.degrees(-15))
            Spacer()
        }
        .frame(width: width, height: height)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 2))
    }
}
