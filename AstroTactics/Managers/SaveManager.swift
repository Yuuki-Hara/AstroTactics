//
//  SaveManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//


import Foundation

class SaveManager {
    // どこからでも SaveManager.shared で呼び出せるようにします
    static let shared = SaveManager()
    
    // データを保存する時の「合言葉（キー）」です
    private let saveKey = "MyGameSaveData"
    
    // ① データを保存する機能
    func save(data: SaveData) {
        // SaveDataを保存できる形（JSON）に変換します
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
            print("データを保存しました！")
        }
    }
    
    // ② データを読み込む機能
    func load() -> SaveData? {
        if let savedData = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode(SaveData.self, from: savedData) {
            print("データを読み込みました！")
            return decoded
        }
        return nil // データが見つからない場合は nil を返します
    }
    
    // ③ セーブデータを消去する機能（新規ゲーム用）
    func deleteSave() {
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
}
