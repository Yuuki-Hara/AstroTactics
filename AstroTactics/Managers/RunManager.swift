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
    
    // 🌟 1次元の配列から、階層ごとの2次元配列（フロア）に変更！
    var mapFloors: [[MapNode]] = []
    
    // 🌟 現在地を「階層の数字」ではなく「今いるマスのID」で記憶する
    var currentNodeId: String? = nil
    
    init() {
        CardDatabase.loadFromJSON()
        EnemyDatabase.loadFromJSON()
        self.player = PlayerShip(name: "アストロ旗艦", maxHP: 50, maxEnergy: 3)
        self.masterDeck = CardDatabase.startingDeck()
        
        // 🌟 アプリ起動時にJSONファイルを読み込んでマップを作る！
        loadMapData()
    }
    
    // 今いるマスの情報を取得する便利機能
    var currentNode: MapNode? {
        guard let id = currentNodeId else { return nil }
        return mapFloors.flatMap { $0 }.first(where: { $0.id == id })
    }
    
    // 🌟 指定したマスが「今タップして進めるマスか？」を判定する機能
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
    
    // 🌟 マスをクリアした時の処理（現在地を更新するだけ）
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
        // MapData.json というファイルを探す
        guard let url = Bundle.main.url(forResource: "MapData", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("⚠️ MapData.json が見つかりません！")
            return
        }
        
        // JSONデータをSwiftの MapData に変換！
        do {
            let decodedData = try JSONDecoder().decode(MapData.self, from: data)
            self.mapFloors = decodedData.floors
        } catch {
            print("⚠️ マップの読み込みに失敗しました: \(error)")
        }
    }
}
