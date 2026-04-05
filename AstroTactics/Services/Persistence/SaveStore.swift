import Foundation

/// 抽象化された保存ストアのプロトコル
protocol SaveStore {
  func save(data: SaveData)
  func load() -> SaveData?
  func deleteSave()
}
