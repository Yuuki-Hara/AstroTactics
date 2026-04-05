import Foundation

struct UserDefaultsSaveStore: SaveStore {
  private let saveKey: String

  init(saveKey: String = "MyGameSaveData") {
    self.saveKey = saveKey
  }

  func save(data: SaveData) {
    if let encoded = try? JSONEncoder().encode(data) {
      UserDefaults.standard.set(encoded, forKey: saveKey)
    }
  }

  func load() -> SaveData? {
    if let savedData = UserDefaults.standard.data(forKey: saveKey),
      let decoded = try? JSONDecoder().decode(SaveData.self, from: savedData)
    {
      return decoded
    }
    return nil
  }

  func deleteSave() {
    UserDefaults.standard.removeObject(forKey: saveKey)
  }
}
