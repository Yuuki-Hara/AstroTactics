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
            print("🚨 致命的エラー: \(filename).json が見つかりません！(Target Membershipやファイル名を確認してください)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: url) else {
            print("🚨 エラー: \(filename).json のデータが読み込めません！")
            return nil
        }
        
        do {
            let decoded = try JSONDecoder().decode(T.self, from: data)
            return decoded
            
        // 🔍 ここから下がアップグレード部分！エラーの犯人を絶対に逃がさない仕組み
        } catch let DecodingError.keyNotFound(key, context) {
            print("🚨 デコードエラー (\(filename).json): '\(key.stringValue)' という項目がJSON内に見つかりません！")
            print("   👉 場所: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            return nil
            
        } catch let DecodingError.typeMismatch(type, context) {
            print("🚨 デコードエラー (\(filename).json): 型が一致しません！ \(type) 型である必要があります。")
            print("   👉 場所: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            return nil
            
        } catch let DecodingError.valueNotFound(type, context) {
            print("🚨 デコードエラー (\(filename).json): 値が空(null)です！ \(type) 型の値が必要です。")
            print("   👉 場所: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
            return nil
            
        } catch let DecodingError.dataCorrupted(context) {
            print("🚨 デコードエラー (\(filename).json): データが破損しているか、JSONの文法(カンマの忘れなど)が間違っています！")
            print("   👉 詳細: \(context.debugDescription)")
            return nil
            
        } catch {
            print("🚨 その他のエラー (\(filename).json): \(error.localizedDescription)")
            return nil
        }
    }
}
