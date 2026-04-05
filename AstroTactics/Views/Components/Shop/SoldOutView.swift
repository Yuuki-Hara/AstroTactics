//
//  SoldOutView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//

import SwiftUI

struct SoldOutView: View {
  var body: some View {
    VStack {
      Spacer()
      Text("SOLD OUT")
        .font(.title2).bold()
        .foregroundColor(.red)
        .rotationEffect(.degrees(-15))
      Spacer()
    }
    .frame(width: 130, height: 190)
    .background(Color.black.opacity(0.3))
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3), lineWidth: 2))
  }
}
