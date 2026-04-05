//
//  BuyButtonView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//

import SwiftUI

struct BuyButtonView: View {
  let price: Int
  var canAfford: Bool

  var body: some View {
    HStack(spacing: 4) {
      Image(systemName: "dollarsign.circle.fill")
      Text("\(price)").bold()
    }
    .foregroundColor(canAfford ? .black : .gray)
    .padding(.vertical, 8)
    .padding(.horizontal, 16)
    .background(canAfford ? Color.yellow : Color.black)
    .cornerRadius(8)
    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.yellow, lineWidth: canAfford ? 0 : 1))
  }
}
