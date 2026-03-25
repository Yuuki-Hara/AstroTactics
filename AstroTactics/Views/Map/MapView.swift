//
//  MapView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import SwiftUI

struct MapView: View {
    var runManager: RunManager
    
    // 🌟 マスを選んだ時に親（ContentView）に「ここに行くよ！」と伝えるケーブル
    var onNodeSelected: (MapNode) -> Void
    
    var body: some View {
        ZStack {
            // 宇宙空間っぽい背景
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                // 🌟 Slay the Spire風に「下から上へ」進むように見せるため、階層を逆順(.reversed())で並べます！
                VStack(spacing: 50) {
                    Text("星域マップ")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    // 各階層（横の並び）を描画
                    ForEach(Array(runManager.mapFloors.enumerated().reversed()), id: \.offset) { floorIndex, floorNodes in
                        HStack(spacing: 20) {
                            // その階層にあるマスを描画
                            ForEach(floorNodes) { node in
                                MapNodeView(
                                    node: node,
                                    isCurrent: runManager.currentNodeId == node.id,
                                    canEnter: runManager.canEnter(node: node) // 👈 JSONの繋がりを見て、入れるか判定！
                                )
                                .onTapGesture {
                                    // 入れるマスなら、タップした時に移動処理を発動！
                                    if runManager.canEnter(node: node) {
                                        onNodeSelected(node)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
            }
        }
    }
}

// 🌟 1つのマス目の見た目を定義する専用の部品
struct MapNodeView: View {
    let node: MapNode
    let isCurrent: Bool
    let canEnter: Bool
    
    var body: some View {
        // 🌟 修正2：マスの横幅を制限し、重ならないようにする！
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60) // 少しだけ円を小さくして余裕を持たせる
                    .overlay(
                        Circle().stroke(borderColor, lineWidth: isCurrent ? 4 : 2)
                    )
                    // 🌟 修正1：暴走しないように、点滅ではなく「光の強さ（radius）」だけで表現！
                    .shadow(color: borderColor, radius: isCurrent ? 15 : (canEnter ? 8 : 0))
                
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .bold)) // Imageでもfontでサイズ調整できます
                    .foregroundColor(textColor)
            }
            
            Text(node.type.title)
                .font(.caption).bold()
                .foregroundColor(textColor)
                .lineLimit(1) // 🌟 1行に収める
                .minimumScaleFactor(0.4) // 🌟 狭ければ限界まで文字を小さくして重なりを防ぐ！
                .frame(maxWidth: 80) // 🌟 横幅の最大値を決めて、隣のマスに侵入させない
        }
        // クリア済みや遠い場所は暗くする
        .opacity(canEnter || isCurrent || node.isCompleted ? 1.0 : 0.4)
        // 🌟 修正1：点滅（repeatCount）を完全に削除し、スッと大きくなるだけの安全なアニメーションに！
        .scaleEffect(isCurrent ? 1.2 : (canEnter ? 1.1 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCurrent)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: canEnter)
    }
    
    // MARK: - 見た目の出し分けロジック
    private var iconName: String {
            if node.isCompleted { return "checkmark" } // クリアマーク
            switch node.type {
            case .battle: return "bolt.fill"           // 雷マーク（戦闘）
            case .rest: return "cup.and.saucer.fill"   // コーヒーカップ（休憩）
            case .boss: return "crown.fill"            // 王冠（ボス）
            }
        }
    
    private var backgroundColor: Color {
        if isCurrent { return .yellow.opacity(0.3) }
        if node.isCompleted { return .green.opacity(0.3) }
        if canEnter { return .cyan.opacity(0.3) }
        return .gray.opacity(0.3)
    }
    
    private var borderColor: Color {
        if isCurrent { return .yellow }
        if node.isCompleted { return .green }
        if canEnter { return .cyan }
        return .gray
    }
    
    private var textColor: Color {
        if isCurrent { return .yellow }
        if canEnter { return .cyan }
        return .gray
    }
}
