//
//  DamageFormulaEngine.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// ダメージ計算式エンジン
///
/// 公式のダメージ計算式を実装:
/// ダメージ = ((レベル×2÷5＋2)×威力×攻撃/防御÷50＋2)×乱数×補正
struct DamageFormulaEngine {

    /// ダメージを計算
    /// - Parameters:
    ///   - attackerLevel: 攻撃側のレベル
    ///   - movePower: 技の威力
    ///   - attackStat: 攻撃側の実数値（攻撃 or 特攻）
    ///   - defenseStat: 防御側の実数値（防御 or 特防）
    ///   - modifiers: 各種補正倍率
    /// - Returns: 16通りのダメージ値
    static func calculateDamage(
        attackerLevel: Int,
        movePower: Int,
        attackStat: Int,
        defenseStat: Int,
        modifiers: DamageModifiers
    ) -> [Int] {
        // 基礎ダメージ = ((レベル×2÷5＋2)×威力×攻撃/防御÷50＋2)
        let levelFactor = Double(attackerLevel * 2) / 5.0 + 2.0
        let powerFactor = Double(movePower)
        let statRatio = Double(attackStat) / Double(defenseStat)

        let baseDamage = ((levelFactor * powerFactor * statRatio) / 50.0 + 2.0)

        // 乱数補正（0.85 ~ 1.0の16段階）
        let randomMultipliers: [Double] = [
            0.85, 0.86, 0.87, 0.88, 0.89, 0.90, 0.91, 0.92,
            0.93, 0.94, 0.95, 0.96, 0.97, 0.98, 0.99, 1.00
        ]

        // 各乱数でダメージを計算
        return randomMultipliers.map { random in
            let finalDamage = baseDamage * random * modifiers.total
            return max(1, Int(finalDamage.rounded()))
        }
    }

    /// ステータス実数値を計算
    /// - Parameters:
    ///   - base: 種族値
    ///   - level: レベル
    ///   - iv: 個体値
    ///   - ev: 努力値
    ///   - nature: 性格補正（1.1, 1.0, 0.9）
    ///   - statStage: ランク補正（-6 ~ +6）
    /// - Returns: 実数値
    static func calculateStat(
        base: Int,
        level: Int,
        iv: Int,
        ev: Int,
        nature: Double = 1.0,
        statStage: Int = 0
    ) -> Int {
        // 実数値 = ((種族値×2 + 個体値 + 努力値÷4) × レベル ÷ 100 + 5) × 性格補正
        let stat = ((Double(base * 2 + iv) + Double(ev) / 4.0) * Double(level) / 100.0 + 5.0) * nature
        let baseStat = Int(stat.rounded(.down))

        // ランク補正を適用
        let multiplier = StatStageSet.multiplier(for: statStage)
        return Int(Double(baseStat) * multiplier)
    }

    /// HP実数値を計算
    /// - Parameters:
    ///   - base: 種族値
    ///   - level: レベル
    ///   - iv: 個体値
    ///   - ev: 努力値
    /// - Returns: HP実数値
    static func calculateHP(
        base: Int,
        level: Int,
        iv: Int,
        ev: Int
    ) -> Int {
        // HP = (種族値×2 + 個体値 + 努力値÷4) × レベル ÷ 100 + レベル + 10
        let hp = (Double(base * 2 + iv) + Double(ev) / 4.0) * Double(level) / 100.0 + Double(level) + 10.0
        return Int(hp.rounded(.down))
    }

    /// タイプ一致補正（STAB）を計算
    /// - Parameters:
    ///   - moveType: 技のタイプ
    ///   - pokemonTypes: ポケモンのタイプ
    ///   - isTerastallized: テラスタル状態か
    ///   - teraType: テラスタイプ
    ///   - ogerponMaskBonus: オーガポンマスク補正（1.0, 1.2, 1.3）
    /// - Returns: タイプ一致補正
    static func calculateSTAB(
        moveType: String,
        pokemonTypes: [String],
        isTerastallized: Bool,
        teraType: String?,
        ogerponMaskBonus: Double = 1.0
    ) -> Double {
        if isTerastallized, let teraType = teraType {
            // テラスタル時
            if teraType.lowercased() == moveType.lowercased() {
                // テラスタイプと技タイプが一致
                if pokemonTypes.contains(where: { $0.lowercased() == moveType.lowercased() }) {
                    // 元々のタイプにも含まれている場合: 2.0
                    return 2.0 * ogerponMaskBonus
                } else {
                    // 元々のタイプには含まれていない場合: 1.5
                    return 1.5 * ogerponMaskBonus
                }
            } else {
                // テラスタイプと技タイプが不一致
                if pokemonTypes.contains(where: { $0.lowercased() == moveType.lowercased() }) {
                    // 元々のタイプには含まれている場合: 1.5
                    return 1.5 * ogerponMaskBonus
                } else {
                    // タイプ不一致
                    return 1.0 * ogerponMaskBonus
                }
            }
        } else {
            // 通常時
            if pokemonTypes.contains(where: { $0.lowercased() == moveType.lowercased() }) {
                return 1.5 * ogerponMaskBonus
            } else {
                return 1.0
            }
        }
    }
}
