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
    var player: PlayerShip
    var masterDeck: [Card]
    
    var mapFloors: [[MapNode]] = []
    var currentNodeId: String? = nil
    
    init() {
        GameSettings.loadAll()
        CardDatabase.loadFromJSON()
        EnemyDatabase.loadFromJSON()
        self.player = PlayerShip(name: GameSettings.config.playerShipName, maxHP: GameSettings.config.playerStartingHP, maxEnergy: GameSettings.config.playerStartingEnergy)
        self.masterDeck = CardDatabase.startingDeck()
        
        loadMapData()
    }
    
    // 今いるマスの情報を取得する便利機能
    var currentNode: MapNode? {
        guard let id = currentNodeId else { return nil }
        return mapFloors.flatMap { $0 }.first(where: { $0.id == id })
    }
    
    func canEnter(node: MapNode) -> Bool {
        // まだ一度もマスに入っていない（スタート地点）なら、1階層目ならどこでも入れる！
        if currentNodeId == nil {
            return mapFloors.first?.contains(where: { $0.id == node.id }) ?? false
        }
        
        // すでにどこかのマスにいるなら、そのマスの「次に行けるリスト」に入っていればOK！
        if let current = currentNode {
            return current.nextNodeIds.contains(node.id)
        }
        
        return false
    }
    
    func advanceToNextNode() {
        if let current = currentNode {
            // 現在のマスをクリア済みにする（少し複雑ですが、該当するマスを探して更新しています）
            for floorIndex in 0..<mapFloors.count {
                if let nodeIndex = mapFloors[floorIndex].firstIndex(where: { $0.id == current.id }) {
                    mapFloors[floorIndex][nodeIndex].isCompleted = true
                }
            }
        }
    }
    
    // MARK: - JSONファイルの読み込み処理
    private func loadMapData() {
        if let decodedData = DataLoader.load("MapData", as: MapData.self) {
            self.mapFloors = decodedData.floors
            print("✅ マップデータを読み込みました！")
        }
    }
}
