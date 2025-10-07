//
//  CalculateStatsUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 種族値から実数値を計算するUseCaseのプロトコル
protocol CalculateStatsUseCaseProtocol {
    /// 種族値から5パターンの実数値を計算
    /// - Parameter baseStats: 種族値のリスト
    /// - Returns: 計算された実数値（5パターン）
    func execute(baseStats: [PokemonStat]) -> CalculatedStats
}

/// 種族値から実数値を計算するUseCase
final class CalculateStatsUseCase: CalculateStatsUseCaseProtocol {
    private let level = 50

    func execute(baseStats: [PokemonStat]) -> CalculatedStats {
        // 5パターンの設定を定義
        let idealConfig = CalculatedStats.StatsPattern.PatternConfig(
            iv: 31,
            ev: 252,
            nature: .boosted
        )
        let maxConfig = CalculatedStats.StatsPattern.PatternConfig(
            iv: 31,
            ev: 252,
            nature: .neutral
        )
        let neutralConfig = CalculatedStats.StatsPattern.PatternConfig(
            iv: 31,
            ev: 0,
            nature: .neutral
        )
        let minConfig = CalculatedStats.StatsPattern.PatternConfig(
            iv: 0,
            ev: 0,
            nature: .neutral
        )
        let hinderedConfig = CalculatedStats.StatsPattern.PatternConfig(
            iv: 0,
            ev: 0,
            nature: .hindered
        )

        let patterns: [CalculatedStats.StatsPattern] = [
            calculatePattern(id: "ideal", displayName: "理想", baseStats: baseStats, config: idealConfig),
            calculatePattern(id: "max", displayName: "252", baseStats: baseStats, config: maxConfig),
            calculatePattern(id: "neutral", displayName: "無振り", baseStats: baseStats, config: neutralConfig),
            calculatePattern(id: "min", displayName: "最低", baseStats: baseStats, config: minConfig),
            calculatePattern(id: "hindered", displayName: "下降", baseStats: baseStats, config: hinderedConfig)
        ]

        return CalculatedStats(patterns: patterns)
    }

    // MARK: - Private Methods

    /// 指定されたパターンで実数値を計算
    private func calculatePattern(
        id: String,
        displayName: String,
        baseStats: [PokemonStat],
        config: CalculatedStats.StatsPattern.PatternConfig
    ) -> CalculatedStats.StatsPattern {
        let natureMultiplier: Double = {
            switch config.nature {
            case .boosted: return 1.1
            case .neutral: return 1.0
            case .hindered: return 0.9
            }
        }()

        let hp = calculateHP(
            base: getBaseStat(baseStats, name: "hp"),
            iv: config.iv,
            ev: config.ev
        )

        let attack = calculateStat(
            base: getBaseStat(baseStats, name: "attack"),
            iv: config.iv,
            ev: config.ev,
            nature: natureMultiplier
        )

        let defense = calculateStat(
            base: getBaseStat(baseStats, name: "defense"),
            iv: config.iv,
            ev: config.ev,
            nature: natureMultiplier
        )

        let specialAttack = calculateStat(
            base: getBaseStat(baseStats, name: "special-attack"),
            iv: config.iv,
            ev: config.ev,
            nature: natureMultiplier
        )

        let specialDefense = calculateStat(
            base: getBaseStat(baseStats, name: "special-defense"),
            iv: config.iv,
            ev: config.ev,
            nature: natureMultiplier
        )

        let speed = calculateStat(
            base: getBaseStat(baseStats, name: "speed"),
            iv: config.iv,
            ev: config.ev,
            nature: natureMultiplier
        )

        return CalculatedStats.StatsPattern(
            id: id,
            displayName: displayName,
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: specialAttack,
            specialDefense: specialDefense,
            speed: speed,
            config: config
        )
    }

    /// HPの実数値を計算
    /// 計算式: floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + level + 10
    private func calculateHP(base: Int, iv: Int, ev: Int) -> Int {
        let baseValue = (base * 2 + iv + (ev / 4)) * level
        return (baseValue / 100) + level + 10
    }

    /// HP以外の能力値を計算
    /// 計算式: floor((floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + 5) * nature)
    private func calculateStat(base: Int, iv: Int, ev: Int, nature: Double) -> Int {
        let baseValue = (base * 2 + iv + (ev / 4)) * level
        let statValue = (baseValue / 100) + 5
        return Int(floor(Double(statValue) * nature))
    }

    /// 種族値リストから特定の能力値を取得
    private func getBaseStat(_ stats: [PokemonStat], name: String) -> Int {
        stats.first { $0.name == name }?.baseStat ?? 0
    }
}
