//
//  DataLoader.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/25.
//

import Foundation

// Deprecated shim to keep backwards compatibility while we migrate callers to JSONLoader.
// Prefer using `JSONLoader.load(_:as:) throws` in new code.
struct DataLoader {
  static func load<T: Decodable>(_ filename: String, as type: T.Type) -> T? {
    do {
      return try JSONLoader.load(filename, as: type)
    } catch {
      // During migration, keep legacy behavior by printing and returning nil.
      print("[DataLoader shim] Failed to load \(filename).json: \(error)")
      return nil
    }
  }
}
