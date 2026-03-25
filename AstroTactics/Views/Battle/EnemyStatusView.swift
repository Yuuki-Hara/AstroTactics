//
//  EnemyStatusView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/23.
//
//
//  EnemyStatusView.swift
//  AstroTactics
//

import SwiftUI

struct EnemyStatusView: View {
    var enemy: Enemy
    
    var body: some View {
        // 🌟 変更点1：全体のVStackに「親が許す限り横幅いっぱいを使っていいよ」と指示
        VStack(spacing: 8) {
            
            // MARK: - 1. 次の行動予定
            if let intent = enemy.intent {
                Text(intentString(for: intent))
                    .font(.caption).bold() // 少し小さめにベースを設定
                    .lineLimit(1) // 🌟 1行に収める
                    .minimumScaleFactor(0.5) // 🌟 狭ければ50%まで文字を小さくしてOK！
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
            
            // MARK: - 2. 敵の画像
            Image(enemy.imageName)
                .resizable()
                .scaledToFit()
                // 🌟 変更点2：固定サイズを廃止。「最大120まで、狭ければ勝手に縮む」
                .frame(maxWidth: 120, maxHeight: 120)
                .foregroundColor(.red)
                .padding(.bottom, 4)
            
            // MARK: - 3. 敵の名前
            Text(enemy.name)
                .font(.headline).bold()
                .foregroundColor(.red)
                .lineLimit(1) // 🌟 1行に収める
                .minimumScaleFactor(0.5) // 🌟 狭ければ自動で文字サイズを縮小
            
            // MARK: - 4. 状態異常とシールド
            if enemy.statuses[.target, default: 0] > 0 {
                Text("🎯 ターゲット残り \(enemy.statuses[.target]!)")
                    .font(.caption2).bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.orange)
            }

            if enemy.shield > 0 {
                Text("🛡️ シールド: \(enemy.shield)")
                    .font(.caption).bold()
                    .foregroundColor(.blue)
            }
            
            // MARK: - 5. 敵のHPバー
            ProgressView(value: Double(enemy.currentHP), total: Double(enemy.maxHP))
                .tint(.red)
                // 🌟 変更点3：余白が大きすぎると潰れるので、小さな余白に変更
                .padding(.horizontal, 10)
            
            Text("HP: \(enemy.currentHP) / \(enemy.maxHP)")
                .font(.caption)
                .foregroundColor(.white)
        }
        // 🌟 これがレスポンシブの要！HStackの中で均等に幅を分け合うようになります
        .frame(maxWidth: .infinity)
        .padding(.top, 20)
    }
    
    private func intentString(for intent: EnemyIntent) -> String {
        switch intent {
        case .attack(let damage): return "⚔️ 攻撃: \(damage)"
        case .defend(let amount): return "🛡️ 防御: \(amount)"
        case .charge: return "⚠️ エネルギー充填"
        default: return "待機"
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        // プレビューで「もし3体並んだらどうなるか」をシミュレーション！
        HStack {
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
            EnemyStatusView(enemy: EnemyDatabase.randomEnemy())
        }
    }
}
