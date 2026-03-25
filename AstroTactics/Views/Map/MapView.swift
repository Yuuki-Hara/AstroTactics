//
//  MapView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

// 🌟 魔法のケーブル：各マスが「自分の座標(X, Y)」を親画面に報告するための専用通信路
struct NodePositionKey: PreferenceKey {
    static var defaultValue: [String: CGPoint] = [:]
    static func reduce(value: inout [String: CGPoint], nextValue: () -> [String: CGPoint]) {
        value.merge(nextValue(), uniquingKeysWith: { $1 })
    }
}

struct MapView: View {
    var runManager: RunManager
    var onNodeSelected: (MapNode) -> Void
    
    // 🌟 全マスの「画面上の座標」を記憶しておく辞書
    @State private var nodePositions: [String: CGPoint] = [:]
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                ZStack {
                    // 🌟 1. マスを描画する前に、マス同士を繋ぐ「線（Path）」を一番奥に描画する！
                    drawPaths()
                    
                    VStack(spacing: 50) {
                        Text(GameSettings.messages.mapTitle)
                            .font(.largeTitle).bold()
                            .foregroundColor(.white)
                            .padding(.top, 40)
                            .padding(.bottom, 20)
                        
                        ForEach(Array(runManager.mapFloors.enumerated().reversed()), id: \.offset) { floorIndex, floorNodes in
                            HStack(spacing: 20) {
                                ForEach(floorNodes) { node in
                                    MapNodeView(
                                        node: node,
                                        isCurrent: runManager.currentNodeId == node.id,
                                        canEnter: runManager.canEnter(node: node)
                                    )
                                    .onTapGesture {
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
                // 🌟 2. スクロール領域全体を "MapSpace" という名前の座標基準にする
                .coordinateSpace(name: "MapSpace")
            }
        }
        // 🌟 3. 子（各マス）から座標データが送られてきたら、nodePositionsに保存する
        .onPreferenceChange(NodePositionKey.self) { positions in
            self.nodePositions = positions
        }
    }
    
    // MARK: - 線を引く処理
    // MARK: - 線を引く処理
    @ViewBuilder
    private func drawPaths() -> some View {
        let allNodes = runManager.mapFloors.flatMap { $0 }
        
        ZStack {
            // 🌟 修正1: MapNodeは Identifiable なので、 id: \.id は省略した方がSwiftが迷いません！
            ForEach(allNodes) { node in
                let nextDestinations: [String] = node.nextNodeIds
                
                ForEach(nextDestinations, id: \.self) { nextId in
                    
                    if let startPos = nodePositions[node.id],
                       let endPos = nodePositions[nextId] {
                        
                        Path { path in
                            path.move(to: startPos)
                            path.addLine(to: endPos)
                        }
                        .stroke(
                            isRouteActive(from: node) ? Color.cyan : Color.gray.opacity(0.3),
                            style: StrokeStyle(
                                lineWidth: isRouteActive(from: node) ? 4 : 2,
                                dash: isRouteActive(from: node) ? [] : [5, 5]
                            )
                        )
                    }
                }
            }
        }
    }
    // そのマスが「アクティブなルート」かどうかを判定
    private func isRouteActive(from node: MapNode) -> Bool {
        return node.isCompleted || runManager.currentNodeId == node.id
    }
}

// MARK: - 1つのマス目
struct MapNodeView: View {
    let node: MapNode
    let isCurrent: Bool
    let canEnter: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(backgroundColor)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle().stroke(borderColor, lineWidth: isCurrent ? 4 : 2)
                    )
                    .shadow(color: borderColor, radius: isCurrent ? 15 : (canEnter ? 8 : 0))
                
                Image(systemName: iconName)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(textColor)
            }
            // 🌟 4. マスの背景でGPS（GeometryReader）を起動し、自分の中心座標を親に送信する！
            .background(
                GeometryReader { geo in
                    Color.clear.preference(
                        key: NodePositionKey.self,
                        value: [node.id: CGPoint(x: geo.frame(in: .named("MapSpace")).midX,
                                                 y: geo.frame(in: .named("MapSpace")).midY)]
                    )
                }
            )
            
            Text(node.type.title)
                .font(.caption).bold()
                .foregroundColor(textColor)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
                .frame(maxWidth: 80)
        }
        .opacity(canEnter || isCurrent || node.isCompleted ? 1.0 : 0.4)
        .scaleEffect(isCurrent ? 1.2 : (canEnter ? 1.1 : 1.0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isCurrent)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: canEnter)
    }
    
    // MARK: - 見た目の出し分けロジック
    private var iconName: String {
        if node.isCompleted { return "checkmark" }
        switch node.type {
        case .battle: return "bolt.fill"
        case .rest: return "cup.and.saucer.fill"
        case .boss: return "crown.fill"
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
