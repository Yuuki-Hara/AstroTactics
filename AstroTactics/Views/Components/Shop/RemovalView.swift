//
//  Removal.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//

import SwiftUI

struct RemovalView: View {

  var body: some View {
    VStack {
      Image(systemName: "trash.fill")
        .font(.system(size: 30))
        .foregroundColor(.red)
      Text("カードを廃棄")
        .font(.headline).bold()
        .foregroundColor(.white)
    }
    .frame(width: 130, height: 190)
    .background(Color.black.opacity(0.8))
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 2))
  }
}
