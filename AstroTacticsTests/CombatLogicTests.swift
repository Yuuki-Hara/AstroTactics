//
//  CombatLogicTests.swift
//  AstroTactics
//
//  Created by 原裕貴 on 2026/03/21.
//

import Testing

@testable import AstroTactics  // ※プロジェクト名に合わせて変更してください

// @Suite をつけることで、関連するテストをグループ化できます
@Suite("戦闘ロジックのテスト")
@MainActor
struct CombatLogicTests {

  @Test("HPとダメージ計算の基本テスト")
  func testBasicDamage() {
    // 1. 準備 (Arrange)
    let player = PlayerShip(name: "プレイヤー旗艦", maxHP: 50, maxEnergy: 3)
    let enemy = Enemy(id: "alien_scout", name: "エイリアン偵察機", maxHP: 30)

    // 2. 実行 (Act): プレイヤーが15ダメージを与える
    enemy.takeDamage(amount: 15)

    // 3. 検証 (Assert): 敵のHPが30 -> 15になっているか確認する
    #expect(enemy.currentHP == 15, "敵のHPが正しく15減っていること")

    // 2. 実行 (Act): 敵が10ダメージを与える
    player.takeDamage(amount: 10)

    // 3. 検証 (Assert): プレイヤーのHPが50 -> 40になっているか確認する
    #expect(player.currentHP == 40, "プレイヤーのHPが正しく10減っていること")
  }

  @Test("シールドによるダメージ軽減テスト")
  func testShieldMitigation() {
    // 1. 準備 (Arrange)
    let player = PlayerShip(name: "プレイヤー旗艦", maxHP: 50, maxEnergy: 3)

    // 2. 実行 (Act): シールドを15張り、20のダメージを受ける
    player.shield += 15
    player.takeDamage(amount: 20)

    // 3. 検証 (Assert): シールドが破壊され、超過した5ダメージだけがHPから引かれるか確認する
    #expect(player.shield == 0, "シールドがすべて消費されていること")
    #expect(player.currentHP == 45, "シールドを超過した5ダメージだけがHPから引かれていること")
  }
}
