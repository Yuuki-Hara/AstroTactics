//
//  ContentView.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import SwiftUI

// 🌟 状態一覧（アプリの画面一覧）
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
    
    // 🌟 冒険の記録係。最初はとりあえず作っておき、タイトル画面で「スタート」を押した時に新品に入れ替えます！
    @State private var runManager: RunManager = RunManager()
    @State private var battleManager: BattleManager? = nil

    var body: some View {
        VStack(spacing: 0) {
            
            // 🌟 修正1：謎の変数 `runManager.cu` を `appState` に修正！
            // タイトル画面と、ゲームクリア画面ではバーを隠すようにしました。
            if appState != .title && appState != .gameClear {
                TopStatusBarView(runManager: runManager)
                    .zIndex(1)
            }
            
            // 🌟 修正2：画面の切り替え部分を ZStack で囲むと、画面サイズが崩れなくなります！
            ZStack {
                switch appState {
                    
                // 🚀 タイトル画面
                case .title:
                    TitleView(onStart: {
                        // 🌟 ここで新しい冒険（新品のRunManager）を作り直すことで、
                        // 何度ゲームオーバーになっても綺麗な状態で再スタートできます！
                        runManager = RunManager()
                        appState = .map
                    })
                    
                // 🗺️ マップ画面
                case .map:
                    MapView(runManager: runManager, onNodeSelected: { selectedNode in
                        runManager.currentNodeId = selectedNode.id
                        
                        switch selectedNode.type {
                        case .battle, .boss:
                            startBattle(run: runManager)
                        case .rest:
                            appState = .rest
                        case .treasure:
                            appState = .treasure
                        case .shop:
                            appState = .shop
                        }
                    })
                    
                // ⚔️ バトル画面
                case .battle:
                    if let manager = battleManager {
                        BattleView(manager: manager, onRestart: {
                            if manager.currentState == .victory {
                                if runManager.currentNode?.type == .boss {
                                    appState = .gameClear
                                } else {
                                    appState = .reward
                                }
                            } else {
                                appState = .title
                            }
                        })
                        .id(ObjectIdentifier(manager))
                    }
                    
                // 🎁 報酬画面
                case .reward:
                    RewardView(runManager: runManager, onComplete: {
                        runManager.advanceToNextNode()
                        appState = .map
                    })
                    
                // 🎉 クリア画面
                case .gameClear:
                    GameClearView(onReturnToTitle: {
                        appState = .title
                    })
                    
                // 🏕️ 休憩所画面
                case .rest:
                    RestView(runManager: runManager, onComplete: {
                        appState = .map
                    })
                    
                // 💎 宝箱画面
                case .treasure:
                    TreasureView(runManager: runManager, onComplete: {
                        appState = .map
                    })
                    
                // 🛒 ショップ画面
                case .shop:
                    ShopView(runManager: runManager, onComplete: {
                        appState = .map
                    })
                }
            }
        }
        // 🌟 全体の背景を宇宙の暗い色に固定！
        .background(Color(red: 0.1, green: 0.1, blue: 0.15).ignoresSafeArea())
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
