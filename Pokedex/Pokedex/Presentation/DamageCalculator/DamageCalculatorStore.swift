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

    /// ダメージ計算を実行
    func calculateDamage() async {
        isLoading = true
        defer { isLoading = false }

        // バリデーション
        guard battleState.attacker.pokemonId != nil,
              battleState.defender.pokemonId != nil,
              battleState.selectedMoveId != nil else {
            errorMessage = "ポケモンと技を選択してください"
            return
        }

        do {
            // アイテムを取得
            let attackerItem: ItemEntity? = if let itemId = battleState.attacker.heldItemId {
                try await itemProvider.fetchItem(id: itemId)
            } else {
                nil
            }

            // 簡易的なステータス計算（固定値）
            // TODO: PokemonRepositoryから実際の種族値を取得
            let attackStat = DamageFormulaEngine.calculateStat(
                base: 100,  // 仮の種族値
                level: battleState.attacker.level,
                iv: battleState.attacker.individualValues.attack,
                ev: battleState.attacker.effortValues.attack,
                nature: 1.0,
                statStage: battleState.attacker.statStages.attack
            )

            let defenseStat = DamageFormulaEngine.calculateStat(
                base: 100,  // 仮の種族値
                level: battleState.defender.level,
                iv: battleState.defender.individualValues.defense,
                ev: battleState.defender.effortValues.defense,
                nature: 1.0,
                statStage: battleState.defender.statStages.defense
            )

            let defenderMaxHP = DamageFormulaEngine.calculateHP(
                base: 100,  // 仮の種族値
                level: battleState.defender.level,
                iv: battleState.defender.individualValues.hp,
                ev: battleState.defender.effortValues.hp
            )

            // 補正を計算
            let modifiers = BattleModifierResolver.resolveModifiers(
                battleState: battleState,
                moveType: "normal",  // TODO: MoveRepositoryから取得
                isPhysical: true,
                attackerItem: attackerItem
            )

            // ダメージを計算
            let damageRange = DamageFormulaEngine.calculateDamage(
                attackerLevel: battleState.attacker.level,
                movePower: 80,  // TODO: MoveRepositoryから取得
                attackStat: attackStat,
                defenseStat: defenseStat,
                modifiers: modifiers
            )

            let minDamage = damageRange.min() ?? 0
            let maxDamage = damageRange.max() ?? 0

            // 撃破確率を計算
            let koChance = ProbabilityCalculator.calculateKOProbability(
                damageRange: damageRange,
                targetHP: defenderMaxHP
            )

            // 確定数を計算
            let hitsToKO = defenderMaxHP > 0 ? Int(ceil(Double(defenderMaxHP) / Double(maxDamage))) : 0

            // 平均ダメージを計算
            let averageDamage = ProbabilityCalculator.calculateAverageDamage(damageRange: damageRange)

            // 2ターン撃破確率を計算（簡易版：同じ技を使用）
            let twoTurnKOChance = ProbabilityCalculator.calculateTwoTurnKOProbability(
                firstTurnDamage: damageRange,
                secondTurnDamage: damageRange,
                targetHP: defenderMaxHP
            )

            // 結果を設定
            damageResult = DamageResult(
                minDamage: minDamage,
                maxDamage: maxDamage,
                damageRange: damageRange,
                koChance: koChance,
                hitsToKO: hitsToKO,
                defenderMaxHP: defenderMaxHP,
                modifiers: modifiers,
                twoTurnKOChance: twoTurnKOChance,
                averageDamage: averageDamage
            )

            errorMessage = nil

        } catch {
            errorMessage = "計算エラー: \(error.localizedDescription)"
            damageResult = nil
        }
    }
}

// MARK: - Damage Result

/// ダメージ計算結果
struct DamageResult: Equatable {
    let minDamage: Int
    let maxDamage: Int
    let damageRange: [Int]
    let koChance: Double
    let hitsToKO: Int
    let defenderMaxHP: Int
    let modifiers: DamageModifiers
    let twoTurnKOChance: Double
    let averageDamage: Double
}
