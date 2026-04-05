//
//  SaveManager.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//

import Foundation

class SaveManager: SaveStore {
  // どこからでも SaveManager.shared で呼び出せるようにします
  static let shared = SaveManager()

  // 実際の保存先（注入可能）
  private let store: SaveStore

  init(store: SaveStore = UserDefaultsSaveStore()) {
    self.store = store
  }

  // MARK: - SaveStore 実装（委譲）
  func save(data: SaveData) {
    store.save(data: data)
  }

  func load() -> SaveData? {
    return store.load()
  }

  func deleteSave() {
    store.deleteSave()
  }
}
