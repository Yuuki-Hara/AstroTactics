//
//  ShopCardItem.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/28.
//

import SwiftUI

struct ShopView: View {
    var runManager: RunManager
    var onComplete: () -> Void
    
    @State private var shopManager = ShopManager()
    @State private var showRemovalSheet: Bool = false
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.15, blue: 0.25).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    HStack(spacing: 8) {
                        Text("宇宙商人")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("「不要なカードの処分も請け負うぜ」")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // 🃏 カードの陳列棚
                        Text("カード").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopManager.shopCards.count, id: \.self) { index in
                                    if shopManager.shopCards[index].isSold {
                                        SoldOutView()
                                    } else {
                                        shopCardUI(item: shopManager.shopCards[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 💎 レリックの陳列棚
                        Text("レリック").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopManager.shopRelics.count, id: \.self) { index in
                                    if shopManager.shopRelics[index].isSold {
                                        SoldOutView()
                                    } else {
                                        shopRelicUI(item: shopManager.shopRelics[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 🗑️ サービスの陳列棚
                        Text("サービス").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        HStack {
                            if shopManager.isRemovalSoldOut {
                                SoldOutView()
                            } else {
                                removalServiceUI()
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
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
                        .font(.title3).bold().foregroundColor(.white)
                        .padding().frame(width: 200).background(Color.blue).cornerRadius(12)
                }
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            shopManager.setupShop()
        }
        .sheet(isPresented: $showRemovalSheet) {
            // 🗑️ 今作った汎用ビューに、タイトルと「消す処理」を渡すだけ！
            CardGridView(
                title: "廃棄するカードを選んでください",
                cards: runManager.masterDeck,
                onSelect: { selectedCard in
                    // カードがタップされたら、マネージャーに消してもらう！
                    shopManager.removeCardFromDeck(cardId: selectedCard.id, runManager: runManager)
                    showRemovalSheet = false
                },
                onCancel: {
                    showRemovalSheet = false
                }
            )
        }
    }
    
    // MARK: - 🃏 カード販売UI
    private func shopCardUI(item: ShopCardItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            CardView(card: item.card).scaleEffect(0.8).frame(width: 140, height: 200)
            buyButton(price: item.price, canAfford: canAfford) {
                shopManager.buyCard(at: index, runManager: runManager)
            }
        }
    }
    
    // MARK: - 💎 レリック販売UI
    private func shopRelicUI(item: ShopRelicItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            
            RelicView(relic: item.relic)
            buyButton(price: item.price, canAfford: canAfford) {
                // 🌟 修正：購入時に runManager を渡す！
                shopManager.buyRelic(at: index, runManager: runManager)
            }
        }
    }
    
    // MARK: - 🗑️ カード廃棄サービスUI
    private func removalServiceUI() -> some View {
        let canAfford = runManager.player.credits >= shopManager.removalPrice
        return VStack(spacing: 12) {
            RemovalView()
            buyButton(price: shopManager.removalPrice, canAfford: canAfford) {
                showRemovalSheet = true
            }
        }
    }
    
    // MARK: - 💰 共通購入ボタン
    private func buyButton(price: Int, canAfford: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            if canAfford { action() }
        }) {
            BuyButtonView(price: price, canAfford: canAfford)
        }
        .disabled(!canAfford)
    }
}
