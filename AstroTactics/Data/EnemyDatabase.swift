//
//  EnemyDatabase.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/22.
//

import Foundation

// ゲーム内に登場する敵を定義する図鑑（マスターデータ）
struct EnemyDatabase {
    
    // 図鑑の中からランダムに1体の敵を選んで返す機能
    static func randomEnemy() -> Enemy {
        // 色々な個性を持った敵のリストを作成
        let enemyList = [
            Enemy(category: "scout", name: "エイリアン偵察機",imageName: "alien_scout" ,maxHP: 30),      // 標準的な敵
            Enemy(category: "interceptor", name: "高速迎撃ドローン",imageName: "high_speed_drone" , maxHP: 20), // HPは低いが...？
            Enemy(category: "cruiser", name: "重装甲巡洋艦",imageName: "armored_cruiser" , maxHP: 60),         // HPが高いタフな敵
        ]
        
        // randomElement() は配列の中からランダムに1つを抽出する超便利機能です！
        // （※ 万が一リストが空だった時のために、?? を使って予備の敵を用意しておきます）
        return enemyList.randomElement() ?? Enemy(category: "scout", name: "予備の偵察機",imageName: "alien_scout" , maxHP: 30)
    }
    
    static func bossFlagShip() -> Enemy {
        Enemy(category: "flagship", name: "敵主力艦隊",imageName: "main_fleet" , maxHP: 150)
    }
}
