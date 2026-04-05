//
//  MessageBoardView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

struct MessageBoardView: View {
  var message: String
  var body: some View {
    Text(message)
      .font(.title2).bold()
      .foregroundColor(.yellow)
      .padding()
  }
}
