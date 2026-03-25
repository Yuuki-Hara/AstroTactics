//
//  ContentView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import SwiftUI

// 🌟 追加：状態に .map が増えました！
enum AppState {
    case title
    case map
    case battle
    case reward
}

struct ContentView: View {
    @State private var appState: AppState = .title
    
    // 🌟 変更：大元のデータは BattleManager ではなく、RunManager（冒険の記録係）が持つ！
    @State private var runManager: RunManager? = nil
    @State private var battleManager: BattleManager? = nil

    var body: some View {
        switch appState {
            
        // 🚀 タイトル画面
        case .title:
            TitleView(onStart: {
                // スタートボタンが押されたら、新しい冒険（RunManager）を作ってマップへ！
                runManager = RunManager()
                appState = .map
            })
            
        // 🗺️ マップ画面
        case .map:
            if let run = runManager {
                MapView(runManager: run, onEnterNode: { node in
                    // 選んだマスによって処理を変える
                    switch node.type {
                    case .battle, .boss:
                        // ⚔️ バトルマスなら戦闘準備をしてバトル画面へ！
                        startBattle(run: run)
                        
                    case .rest:
                        // ☕️ 休憩所ならHPを回復して、そのまま次のマスへ！
                        run.player.currentHP = min(run.player.maxHP, run.player.currentHP + 20)
                        run.advanceToNextNode()
                    }
                })
            }
            
        // ⚔️ バトル画面
        case .battle:
            if let manager = battleManager {
                BattleView(manager: manager, onRestart: {
                    // 🌟 勝利・敗北時の処理が大きく変わります！
                    if manager.currentState == .victory {
                        // 勝ったらマップを進めて、マップ画面に戻る！
                        runManager?.advanceToNextNode()
                        appState = .reward
                    } else {
                        // 負けたらゲームオーバー（タイトルへ）
                        appState = .title
                    }
                })
                .id(ObjectIdentifier(manager))
            }
        case .reward:
            if let run = runManager {
                RewardView(runManager: run, onComplete: {
                    run.advanceToNextNode()
                    appState = .map
                })
            }
        }
    }
    
    // MARK: - バトルの準備をする関数
    private func startBattle(run: RunManager) {

        var enemiesToFight: [Enemy] = []
        if run.currentNode?.type == .boss {
            enemiesToFight.append(EnemyDatabase.bossFlagShip())
        } else {
            let enemyCount = Int.random(in: 1...3)
            for _ in 0..<enemyCount {
                enemiesToFight.append(EnemyDatabase.randomEnemy())
            }
        }

        let freshDeckManager = BattleDeckManager(startingDeck: run.masterDeck)
        battleManager = BattleManager(player: run.player, enemies: enemiesToFight, deckManager: freshDeckManager)
        
        appState = .battle
    }
}
