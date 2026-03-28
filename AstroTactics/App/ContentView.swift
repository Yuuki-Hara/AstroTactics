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
    case rest
    case gameClear
    case treasure
    case shop
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
                MapView(runManager: run, onNodeSelected: { selectedNode in
                    // 🌟 1. 選んだマスを「現在の所在地」として記憶する！
                    run.currentNodeId = selectedNode.id
                    
                    // 🌟 2. マスの種類によって、行く画面を切り替える！
                    switch selectedNode.type {
                    case .battle, .boss:
                        startBattle(run: run) // バトル準備をしてバトル画面へ
                    case .rest:
                        appState = .rest      // 休憩所画面へ
                    case .treasure:
                        appState = .treasure
                    case .shop:
                        appState = .shop
                    }
                })
            }
            
        // ⚔️ バトル画面
        case .battle:
            if let manager = battleManager, let run = runManager {
                BattleView(manager: manager, onRestart: {
                    // 🌟 勝利・敗北時の処理が大きく変わります！
                    if manager.currentState == .victory {
                        // 勝ったらマップを進めて、マップ画面に戻る！
                        if run.currentNode?.type == .boss {
                            appState = .gameClear
                        } else {
                            appState = .reward
                        }
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
        case .gameClear:
            GameClearView(onReturnToTitle: {
                runManager = nil
                appState = .title
            })
        case .rest:
            if let run = runManager {
                RestView(runManager: run, onComplete: {
                    // 休憩が終わったらマップに戻る
                    appState = .map
                })
            }
        case .treasure:
            if let run = runManager {
                TreasureView(runManager: run, onComplete: {
                    // 休憩が終わったらマップに戻る
                    appState = .map
                })
            }
        case .shop:
            if let run = runManager {
                ShopView(runManager: run, onComplete: {
                    // 休憩が終わったらマップに戻る
                    appState = .map
                })
            }
        }
    }
    
    // MARK: - バトルの準備をする関数
    private func startBattle(run: RunManager) {

        var enemiesToFight: [Enemy] = []
        if run.currentNode?.type == .boss {
            enemiesToFight.append(EnemyDatabase.bossFlagship())
        } else {
            let enemyCount = Int.random(in: 1...3)
            for _ in 0..<enemyCount {
                enemiesToFight.append(EnemyDatabase.randomEnemy())
            }
        }

        let freshDeckManager = BattleDeckManager(startingDeck: run.masterDeck)
        battleManager = BattleManager(player: run.player, enemies: enemiesToFight, relics: run.relics, deckManager: freshDeckManager)
        
        appState = .battle
    }
}
