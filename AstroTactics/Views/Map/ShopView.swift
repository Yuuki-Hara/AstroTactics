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
                // ... 🏷️ ヘッダー部分はそのまま ...
                HStack {
                    VStack(alignment: .leading) {
                        Text("宇宙商人")
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                        Text("「不要なカードの処分も請け負うぜ」")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    // 💰 所持金
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
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // 🃏 カードの陳列棚
                        Text("📦 カード").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopManager.shopCards.count, id: \.self) { index in
                                    if shopManager.shopCards[index].isSold {
                                        soldOutView(width: 140, height: 200)
                                    } else {
                                        shopCardUI(item: shopManager.shopCards[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 💎 レリックの陳列棚
                        Text("💎 レリック").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                ForEach(0..<shopManager.shopRelics.count, id: \.self) { index in
                                    if shopManager.shopRelics[index].isSold {
                                        soldOutView(width: 140, height: 160)
                                    } else {
                                        shopRelicUI(item: shopManager.shopRelics[index], index: index)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // 🗑️ サービスの陳列棚
                        Text("🛠️ サービス").font(.title2).bold().foregroundColor(.white).padding(.horizontal, 20)
                        HStack {
                            if shopManager.isRemovalSoldOut {
                                soldOutView(width: 160, height: 100)
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
            removalSheetView
        }
    }
    
    // MARK: - 🃏 カード販売UI
    private func shopCardUI(item: ShopCardItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            CardView(card: item.card).scaleEffect(0.8).frame(width: 140, height: 200)
            buyButton(price: item.price, canAfford: canAfford) {
                // 🌟 修正：購入時に runManager を渡す！
                shopManager.buyCard(at: index, runManager: runManager)
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
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 5)
            }
            .frame(width: 140, height: 160)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan, lineWidth: 2))
            
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
            VStack {
                Image(systemName: "trash.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.red)
                Text("カードを廃棄")
                    .font(.headline).bold()
                    .foregroundColor(.white)
            }
            .frame(width: 160, height: 100)
            .background(Color.black.opacity(0.8))
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
            
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
        
    
    // MARK: - 📝 廃棄カードを選択する画面（シート）
    private var removalSheetView: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea()
            VStack {
                Text("廃棄するカードを1枚選んでください").font(.title2).bold().foregroundColor(.white).padding()
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                        ForEach(runManager.masterDeck) { card in
                            Button(action: {
                                // 🌟 修正：削除時に runManager を渡す！
                                shopManager.removeCardFromDeck(cardId: card.id, runManager: runManager)
                                showRemovalSheet = false
                            }) {
                                CardView(card: card).scaleEffect(0.8).frame(width: 140, height: 200)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                Button("キャンセル") { showRemovalSheet = false }.foregroundColor(.red).padding()
            }
        }
    }
}
