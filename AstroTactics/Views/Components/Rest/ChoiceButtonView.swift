//
//  ChoiceButtonView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/29.
//

import SwiftUI

struct ChoiceButtonView: View {
    let icon: String
    let title: String
    let subText: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 40))
            Text(title).font(.title3).bold()
            Text(subText).font(.caption)
        }
        .foregroundColor(.white)
        .frame(width: 140, height: 160)
        .background(color.opacity(0.8))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color, lineWidth: 2))
    }
}
