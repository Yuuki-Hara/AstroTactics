import Foundation

enum JSONLoaderError: Error, LocalizedError {
  case fileNotFound(String)
  case unreadableData(String)
  case decodingFailed(String, Error)

  var errorDescription: String? {
    switch self {
    case .fileNotFound(let name): return "JSON file not found: \(name).json"
    case .unreadableData(let name): return "Could not read data from: \(name).json"
    case .decodingFailed(let name, let err):
      return "Failed to decode \(name).json: \(err.localizedDescription)"
    }
  }
}

/// Throws-based JSON loader for tests and production. Prefer this over the optional-returning DataLoader.
struct JSONLoader {
  static func load<T: Decodable>(_ filename: String, as type: T.Type) throws -> T {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
      throw JSONLoaderError.fileNotFound(filename)
    }

    do {
      let data = try Data(contentsOf: url)
      do {
        let decoded = try JSONDecoder().decode(T.self, from: data)
        return decoded
      } catch {
        throw JSONLoaderError.decodingFailed(filename, error)
      }
    } catch {
      throw JSONLoaderError.unreadableData(filename)
    }
  }
}
