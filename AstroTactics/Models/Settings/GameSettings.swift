//
//  GameConfigJSON.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//

import Foundation

// MARK: - アプリ全体で共有する設定の保管庫
struct GameSettings {
  // どこからでも GameSettings.config.playerStartingHP のようにアクセスできる！
  static var config: GameConfigJSON!
  static var messages: MessageDataJSON!

  // 🌟 アプリ起動時に一括で読み込む
  static func loadAll() {
    do {
      let loadData = try GameSettingsRepository.load()
      config = loadData.config
      messages = loadData.messages
      print("✅ ゲーム設定（GameSettings.json）を統合して読み込みました！")
    } catch {
      print("❌ GameSettingsの読み込みに失敗しました！ \(error)")
    }
  }
}
