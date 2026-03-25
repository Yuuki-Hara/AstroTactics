//
//  DataLoader.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//


import Foundation

// 🌟 どんなJSONでも読み込める魔法の工場
struct DataLoader {
    
    // <T: Decodable> は「JSONから変換できる型なら、カードでも敵でも何でもいいよ！」という意味です
    static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ \(filename).json が見つかりません！")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("⚠️ \(filename).json のデータが読み込めません！")
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
        } catch {
            print("⚠️ \(filename).json の変換に失敗しました: \(error)")
            return nil
        }
    }
}
