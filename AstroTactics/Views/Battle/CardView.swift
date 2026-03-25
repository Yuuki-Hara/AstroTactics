import SwiftUI

struct CardView: View {
    let card: Card
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.black.opacity(0.8)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.8), lineWidth: 2)
                )
            
            VStack(spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Text("\(card.cost)")
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(.black)
                        )
                    
                    Spacer()
                    
                    Text(traitString(for: card.traits.first))
                        .font(.caption2).bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(4)
                        .foregroundColor(.white)
                }
                .padding([.top, .leading, .trailing], 8)
                
                Spacer()
                
                Text(card.name)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 4)
                
                Spacer()
                
                // 🌟 変更点：カード全体を渡してテキストを生成する
                Text(effectString(for: card))
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.cyan)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 12)
                    .padding(.horizontal, 8)
            }
        }
        .frame(width: 130, height: 190)
        .shadow(color: .cyan.opacity(0.3), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - 表示用のヘルパー関数
    
    // 1. 属性（CardTrait）の文字列変換
    private func traitString(for trait: CardTrait?) -> String {
        switch trait {
        case .beam: return "光学"
        case .missile: return "実弾"
        case .mech: return "機体"
        case .defense: return "装甲"
        case .command: return "指令"
        case .none: return "無属性"
        }
    }
    
    // 4. すべての情報を組み合わせて説明文（EffectString）を作る
    private func effectString(for card: Card) -> String {
        // 効果が1つもない場合は「効果なし」を返す
        if card.effects.isEmpty { return "効果なし" }
        
        return card.effects.map { $0.description }.joined(separator: "\n")
    }
}

// MARK: - プレビュー
#Preview {
    CardView(card: Card(
        baseId: "laser_cannon",
        name: "レーザーカノン",
        cost: 2,
        traits: [.beam],
        target: .singleEnemy,
        effects: [DealDamageEffect(amount: 15)]
    ))
}
