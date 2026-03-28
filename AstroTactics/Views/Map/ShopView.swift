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

// 💎 ショップに並ぶレリックの商品データ
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
    @State private var shopRelics: [ShopRelicItem] = []
    
    // 🗑️ 追加：カード廃棄サービス用の変数
    @State private var isRemovalSoldOut: Bool = false
    @State private var showRemovalSheet: Bool = false
    let removalPrice: Int = 75 // 廃棄サービスの値段（Slay the Spireリスペクト！）
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.15, blue: 0.25).ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 🏷️ ヘッダー
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
                
                // 🛒 お店の中身
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
                        
                        // 💎 レリックの陳列棚
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
                        
                        // 🗑️ サービスの陳列棚（追加！）
                        Text("サービス")
                            .font(.title2).bold()
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                        
                        HStack {
                            if isRemovalSoldOut {
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
        // 🌟 追加：カードを選択して消すための専用画面（シート）
        .sheet(isPresented: $showRemovalSheet) {
            removalSheetView
        }
    }
    
    // MARK: - 🛍️ お店の準備
    private func setupShop() {
        let randomCards = CardDatabase.allCardsData.shuffled().prefix(3)
        shopCards = randomCards.map { ShopCardItem(card: $0, price: Int.random(in: 40...80)) }
        
        let randomRelics = RelicDatabase.allRelics.shuffled().prefix(2)
        shopRelics = randomRelics.map { ShopRelicItem(relic: $0, price: Int.random(in: 120...200)) }
    }
    
    // MARK: - 🃏 カード販売UI
    private func shopCardUI(item: ShopCardItem, index: Int) -> some View {
        let canAfford = runManager.player.credits >= item.price
        return VStack(spacing: 12) {
            CardView(card: item.card)
                .scaleEffect(0.8)
                .frame(width: 140, height: 200)
            
            buyButton(price: item.price, canAfford: canAfford) {
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
                runManager.player.credits -= item.price
                runManager.relics.append(item.relic)
                shopRelics[index].isSold = true
            }
        }
    }
    
    // MARK: - 🗑️ カード廃棄サービスUI
    private func removalServiceUI() -> some View {
        let canAfford = runManager.player.credits >= removalPrice
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
            
            buyButton(price: removalPrice, canAfford: canAfford) {
                // お金はまだ減らさず、選択画面（シート）を開く！
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
                Text("廃棄するカードを1枚選んでください")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .padding()
                
                ScrollView {
                    // グリッド状に現在のデッキを並べる
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 20) {
                        ForEach(runManager.masterDeck) { card in
                            Button(action: {
                                // 🗑️ 選んだカードをデッキから削除し、お金を払う！
                                if let index = runManager.masterDeck.firstIndex(where: { $0.id == card.id }) {
                                    runManager.masterDeck.remove(at: index)
                                    runManager.player.credits -= removalPrice
                                    isRemovalSoldOut = true
                                    showRemovalSheet = false // シートを閉じる
                                }
                            }) {
                                CardView(card: card)
                                    .scaleEffect(0.8)
                                    .frame(width: 140, height: 200)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                
                Button("キャンセル") {
                    showRemovalSheet = false
                }
                .foregroundColor(.red)
                .padding()
            }
        }
    }
}
