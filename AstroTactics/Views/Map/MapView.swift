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
    
    @State private var nodePositions: [String: CGPoint] = [:]
    
    // 🌟 追加：現在地が含まれるフロア（floorIndex）を計算するヘルパー
    private var currentFloorIndex: Int? {
        // 全階層（runManager.mapFloors）をループして、現在地のIDが含まれる配列を探す
        return runManager.mapFloors.firstIndex { floorNodes in
            floorNodes.contains { node in
                node.id == runManager.currentNodeId
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.2).ignoresSafeArea()
            
            // 🌟 修正1：全体を VStack で囲んで、一番上にステータスバーを置く（画像_14_30114.png のレイアウト）
            VStack(spacing: 0) {
                
                TopStatusBarView(runManager: runManager)
                
                // 🌟 修正2：ScrollViewReader でScrollViewを囲む
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        ZStack {
                            drawPaths()
                            
                            VStack(spacing: 50) {
                                Text(GameSettings.messages.mapTitle)
                                    .font(.largeTitle).bold()
                                    .foregroundColor(.white)
                                    .padding(.top, 40)
                                    .padding(.bottom, 20)
                                
                                // 階層の並び順はそのまま（ボスが上）
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
                                    // 🌟 修正3：各階層（HStack）に .id(floorIndex) を付与して、スクロールの目印にする！
                                    .id(floorIndex)
                                }
                            }
                            .padding(.bottom, 80)
                        }
                        .coordinateSpace(name: "MapSpace")
                    }
                    // 🌟 修正4：マップ画面が開いた瞬間（.onAppear）に、現在地のフロアまで自動スクロールする！
                    .onAppear {
                        // 以前のエラー（Thread 1: Fatal error...）を回避するため、
                        let targetFloorIndex = currentFloorIndex ?? 0
                        // ゲームの設定が読み込まれているか確認してからスクロール
                        if let _ = GameSettings.config {
                            // 少しだけ遅らせる（wait）と、スクロールアニメーションがより綺麗に見えます
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.8)) {
                                    // 指定した floorIndex の場所までスクロール！ anchor: .center で画面中央に配置
                                    proxy.scrollTo(targetFloorIndex, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
        }
        .onPreferenceChange(NodePositionKey.self) { positions in
            self.nodePositions = positions
        }
    }
    
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
        case .treasure: return "gift.fill"
        case .shop: return "cart.fill"
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
