//
//  DamageCalculatorStore.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation
import SwiftUI
import Combine

/// ダメージ計算画面の状態管理
@MainActor
final class DamageCalculatorStore: ObservableObject {
    // MARK: - Published Properties

    /// バトル状態
    @Published var battleState: BattleState

    /// 計算結果（Phase 2で実装）
    @Published var damageResult: DamageResult?

    /// ローディング状態
    @Published var isLoading: Bool = false

    /// エラーメッセージ
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let itemProvider: ItemProviderProtocol

    // MARK: - Initialization

    init(itemProvider: ItemProviderProtocol) {
        self.itemProvider = itemProvider
        self.battleState = BattleState()
    }

    // MARK: - Actions

    /// バトルモードを切り替える
    func toggleBattleMode() {
        battleState.mode = battleState.mode == .single ? .double : .single
    }

    /// 攻撃側と防御側を入れ替える
    func swapAttackerAndDefender() {
        battleState.swap()
    }

    /// 状態をリセット
    func reset() {
        battleState.reset()
        damageResult = nil
        errorMessage = nil
    }

    /// ポケモンを選択（攻撃側）
    func selectAttackerPokemon(id: Int, name: String, types: [String]) {
        battleState.attacker.pokemonId = id
        battleState.attacker.pokemonName = name
        battleState.attacker.baseTypes = types
    }

    /// ポケモンを選択（防御側）
    func selectDefenderPokemon(id: Int, name: String, types: [String]) {
        battleState.defender.pokemonId = id
        battleState.defender.pokemonName = name
        battleState.defender.baseTypes = types
    }

    /// 技を選択
    func selectMove(id: Int) {
        battleState.selectedMoveId = id
    }

    /// アイテムを選択（攻撃側）
    func selectAttackerItem(id: Int?) {
        battleState.attacker.heldItemId = id
    }

    /// アイテムを選択（防御側）
    func selectDefenderItem(id: Int?) {
        battleState.defender.heldItemId = id
    }

    /// テラスタルを切り替え（攻撃側）
    func toggleAttackerTerastallize() {
        battleState.attacker.isTerastallized.toggle()
    }

    /// テラスタルを切り替え（防御側）
    func toggleDefenderTerastallize() {
        battleState.defender.isTerastallized.toggle()
    }

    /// ダメージ計算を実行（Phase 2で実装）
    func calculateDamage() async {
        isLoading = true
        defer { isLoading = false }

        // TODO: Phase 2で実装
        // 現時点ではダミーの結果を返す
        damageResult = DamageResult(
            minDamage: 0,
            maxDamage: 0,
            damageRange: [],
            koChance: 0.0
        )
    }
}

// MARK: - Damage Result (Placeholder)

/// ダメージ計算結果（Phase 2で詳細実装）
struct DamageResult: Equatable {
    let minDamage: Int
    let maxDamage: Int
    let damageRange: [Int]
    let koChance: Double
}
