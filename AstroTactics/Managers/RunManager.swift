//
//  RunManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//


import Foundation
import Observation

@Observable
class RunManager {
    // 🌟 バトルを跨いでも引き継がれるプレイヤーのデータ
    var player: PlayerShip
    var masterDeck: [Card]
    
    // 🌟 マップのデータ
    var mapNodes: [MapNode] = []
    var currentNodeIndex: Int = 0 // 今マップの何階層目にいるか
    
    init() {
        // ゲーム開始時の初期ステータス
        self.player = PlayerShip(name: "アストロ旗艦", maxHP: 50, maxEnergy: 3)
        self.masterDeck = CardDatabase.startingDeck()
        
        // とりあえず最初は「一直線に3つの部屋が並んでいる」シンプルなマップを生成！
        self.mapNodes = [
            MapNode(type: .battle), // 1階層目：雑魚戦
            MapNode(type: .rest),   // 2階層目：休憩所
            MapNode(type: .boss)    // 3階層目：ボス
        ]
    }
    
    // 現在いる部屋（ノード）を取得する便利関数
    var currentNode: MapNode? {
        guard currentNodeIndex < mapNodes.count else { return nil }
        return mapNodes[currentNodeIndex]
    }
    
    // 部屋をクリアして次に進む処理
    func advanceToNextNode() {
        if currentNodeIndex < mapNodes.count {
            mapNodes[currentNodeIndex].isCompleted = true
            currentNodeIndex += 1
        }
    }
}
