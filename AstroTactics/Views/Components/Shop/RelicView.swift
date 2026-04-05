//
//  RelicView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//
import SwiftUI

struct RelicView: View {
  let relic: Relic

  var body: some View {
    VStack {
      Image(systemName: relic.imageName)
        .font(.system(size: 40))
        .foregroundColor(.cyan)
        .padding()
      Text(relic.name)
        .font(.headline).bold()
        .foregroundColor(.white)
      Text(relic.description)
        .font(.caption2)
        .foregroundColor(.gray)
        .lineLimit(2)
        .minimumScaleFactor(0.8)
        .multilineTextAlignment(.center)
        .padding(.horizontal, 5)
    }
    .frame(width: 130, height: 190)
    .background(Color.black.opacity(0.8))
    .cornerRadius(12)
    .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.cyan, lineWidth: 2))
  }
}
