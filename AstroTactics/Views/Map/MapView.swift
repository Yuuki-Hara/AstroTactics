//
//  MapView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import SwiftUI

struct MapView: View {
    var runManager: RunManager
    
    // 🌟 マスが選ばれた時に、親（ContentView）に「このマスに入ります！」と伝える通信ケーブル
    var onEnterNode: (MapNode) -> Void
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.1).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("星域マップ")
                    .font(.largeTitle).bold()
                    .foregroundColor(.cyan)
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(spacing: 40) {
                        // マップのマスを上から順番に表示する
                        ForEach(Array(runManager.mapNodes.enumerated()), id: \.element.id) { index, node in
                            
                            let isCurrent = index == runManager.currentNodeIndex
                            let isPast = index < runManager.currentNodeIndex
                            
                            // 🌟 1マス分のUI部品
                            Button(action: {
                                if isCurrent { onEnterNode(node) }
                            }) {
                                HStack {
                                    Text(node.type.title)
                                        .font(.title2).bold()
                                    
                                    Spacer()
                                    
                                    // 状態によって表示を変える
                                    if isPast {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                    } else if isCurrent {
                                        Text("現在地")
                                            .font(.caption).bold()
                                            .padding(6)
                                            .background(Color.yellow)
                                            .foregroundColor(.black)
                                            .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: 300)
                                // 状態によって色を変える
                                .background(isCurrent ? Color.cyan.opacity(0.3) : (isPast ? Color.gray.opacity(0.3) : Color.white.opacity(0.1)))
                                .foregroundColor(isCurrent ? .cyan : (isPast ? .gray : .white))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(isCurrent ? Color.cyan : Color.clear, lineWidth: 2)
                                )
                            }
                            .disabled(!isCurrent) // 現在地以外は押せないようにする
                        }
                    }
                    .padding()
                }
            }
        }
    }
}
