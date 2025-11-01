//
//  ProbabilityCalculator.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// 撃破確率計算
struct ProbabilityCalculator {

    /// 単発攻撃での撃破確率を計算
    /// - Parameters:
    ///   - damageRange: ダメージ範囲（16通り）
    ///   - targetHP: 対象のHP
    /// - Returns: 撃破確率（0.0 ~ 1.0）
    static func calculateKOProbability(
        damageRange: [Int],
        targetHP: Int
    ) -> Double {
        let koCount = damageRange.filter { $0 >= targetHP }.count
        return Double(koCount) / Double(damageRange.count)
    }

    /// 2ターン連続攻撃での撃破確率を計算
    /// - Parameters:
    ///   - firstTurnDamage: 1ターン目のダメージ範囲
    ///   - secondTurnDamage: 2ターン目のダメージ範囲
    ///   - targetHP: 対象のHP
    ///   - hitChance: 命中率（0.0 ~ 1.0、デフォルト1.0）
    /// - Returns: 2ターン連続での撃破確率
    static func calculateTwoTurnKOProbability(
        firstTurnDamage: [Int],
        secondTurnDamage: [Int],
        targetHP: Int,
        hitChance: Double = 1.0
    ) -> Double {
        var koScenarios = 0
        let totalScenarios = firstTurnDamage.count * secondTurnDamage.count

        // 全ての組み合わせをシミュレート
        for firstDamage in firstTurnDamage {
            for secondDamage in secondTurnDamage {
                let totalDamage = firstDamage + secondDamage
                if totalDamage >= targetHP {
                    koScenarios += 1
                }
            }
        }

        let baseProbability = Double(koScenarios) / Double(totalScenarios)

        // 命中率を考慮（両方当たる確率）
        return baseProbability * hitChance * hitChance
    }

    /// N発での撃破確率を計算
    /// - Parameters:
    ///   - damageRange: ダメージ範囲
    ///   - targetHP: 対象のHP
    ///   - turns: ターン数
    /// - Returns: 撃破確率
    static func calculateNTurnKOProbability(
        damageRange: [Int],
        targetHP: Int,
        turns: Int
    ) -> Double {
        guard turns > 0 else { return 0.0 }

        var koScenarios = 0
        let totalScenarios = Int(pow(Double(damageRange.count), Double(turns)))

        // 全ての組み合わせをシミュレート（再帰的）
        calculateRecursive(
            damageRange: damageRange,
            targetHP: targetHP,
            remainingTurns: turns,
            currentDamage: 0,
            koScenarios: &koScenarios
        )

        return Double(koScenarios) / Double(totalScenarios)
    }

    /// 再帰的にダメージ組み合わせを計算
    private static func calculateRecursive(
        damageRange: [Int],
        targetHP: Int,
        remainingTurns: Int,
        currentDamage: Int,
        koScenarios: inout Int
    ) {
        if remainingTurns == 0 {
            if currentDamage >= targetHP {
                koScenarios += 1
            }
            return
        }

        for damage in damageRange {
            calculateRecursive(
                damageRange: damageRange,
                targetHP: targetHP,
                remainingTurns: remainingTurns - 1,
                currentDamage: currentDamage + damage,
                koScenarios: &koScenarios
            )
        }
    }

    /// 平均ダメージを計算
    /// - Parameter damageRange: ダメージ範囲
    /// - Returns: 平均ダメージ
    static func calculateAverageDamage(damageRange: [Int]) -> Double {
        let sum = damageRange.reduce(0, +)
        return Double(sum) / Double(damageRange.count)
    }

    /// ダメージ分布を計算
    /// - Parameter damageRange: ダメージ範囲
    /// - Returns: ダメージごとの出現確率（辞書）
    static func calculateDamageDistribution(damageRange: [Int]) -> [Int: Double] {
        var distribution: [Int: Int] = [:]

        for damage in damageRange {
            distribution[damage, default: 0] += 1
        }

        return distribution.mapValues { count in
            Double(count) / Double(damageRange.count)
        }
    }
}
