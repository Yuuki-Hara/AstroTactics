//
//  EnemyStatusView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//

import SwiftUI

struct EnemyStatusView: View {
    var enemy: Enemy
    
    // 🌟 ダメージ時の「ブルブル揺れる」演出用
    @State private var shakeOffset: CGFloat = 0
    @State private var isHit: Bool = false
    
    // 🌟 ダメージの「ポップアップ文字」演出用
    @State private var popupText: String = ""
    @State private var popupOffset: CGFloat = 0
    @State private var popupOpacity: Double = 0
    @State private var popupId: UUID = UUID() // 連続で攻撃が当たった時にアニメーションをリセットするため
    
    var body: some View {
        VStack(spacing: 8) {
            
            // MARK: - 1. 次の行動予定
            if let intent = enemy.intent {
                Text(intentString(for: intent))
                    .font(.caption).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 4)
                    .background(Color.black.opacity(0.6))
                    .cornerRadius(8)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.red.opacity(0.5), lineWidth: 1)
                    )
            }
            
            // MARK: - 2. 敵の画像 ＋ ダメージポップアップ
            ZStack {
                // 敵の画像（ブルブル揺れる）
                Image(enemy.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 120, maxHeight: 120)
                    .foregroundColor(isHit ? .white : .red)
                    .brightness(isHit ? 0.4 : 0.0)
                    .scaleEffect(isHit ? 0.85 : 1.0)
                    .offset(x: shakeOffset)
                
                // 🌟 ダメージのポップアップ文字（フワッと浮かんで消える）
                Text(popupText)
                    .font(.title).bold()
                    .foregroundColor(.red)
                    // 文字を見やすくするための黒い縁取り
                    .shadow(color: .black, radius: 1, x: 1, y: 1)
                    .shadow(color: .black, radius: 1, x: -1, y: -1)
                    // アニメーションで動かす部分
                    .offset(y: popupOffset)
                    .opacity(popupOpacity)
                    .id(popupId) // 連続攻撃の時に、新しい文字として出し直すおまじない
            }
            .padding(.bottom, 4)
            .onChange(of: enemy.currentHP) { oldValue, newValue in
                // ダメージを受けた時だけ発動！
                if newValue < oldValue {
                    let damageAmount = oldValue - newValue
                    triggerDamageAnimation()
                    showDamagePopup(amount: damageAmount) // 🌟 ポップアップ処理を追加
                }
            }
            
            // MARK: - 3. 敵の名前
            Text(enemy.name)
                .font(.headline).bold()
                .foregroundColor(.red)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
            
            // MARK: - 4. 状態異常とシールド
            StatusEffectRowView(statuses: enemy.statuses)
            
            // MARK: - 5. 敵のHPバー
            ProgressView(value: Double(enemy.currentHP), total: Double(enemy.maxHP))
                .tint(.red)
                .padding(.horizontal, 10)
            
            Text("HP: \(enemy.currentHP) / \(enemy.maxHP)")
                .font(.caption)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    // MARK: - アニメーション発動処理
    
    // 敵がブルブル揺れる処理（変更なし）
    private func triggerDamageAnimation() {
        withAnimation(.linear(duration: 0.05).repeatCount(5, autoreverses: true)) {
            shakeOffset = 8
            isHit = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            shakeOffset = 0
            isHit = false
        }
    }
    
    // 🌟 ダメージの数字がフワッと浮かぶ処理
    private func showDamagePopup(amount: Int) {
        // 1. まずはアニメーションなしで、パッと最初の場所（真ん中）に文字を準備します
        popupText = "-\(amount)"
        popupOffset = 0     // 位置をリセット
        popupOpacity = 1.0  // 透明度を100%（くっきり）にリセット
        popupId = UUID()
        
        // 2. ほんの少し（0.05秒）だけ待って、画面に文字が出た直後にアニメーションをスタートさせます！
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            // 0.8秒かけて、上（-60）にフワッと移動しながら透明（0.0）にする
            withAnimation(.easeOut(duration: 0.8)) {
                popupOffset = -60 // 👈 ここの数値を大きくすると、さらに高く浮かびます
                popupOpacity = 0.0
            }
        }
    }
    
    private func intentString(for intent: EnemyIntent) -> String {
        switch intent {
        case .attack(let damage): return "攻撃: \(damage)"
        case .defend(let amount): return "防御: \(amount)"
        case .charge: return "エネルギー充填"
        default: return "待機"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack {
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
        }
    }
}
