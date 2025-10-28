//
//  CalculatedStatsView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 実数値計算結果を表示するビュー（5パターン表形式）
struct CalculatedStatsView: View {
    let stats: CalculatedStats
    let baseStats: [PokemonStat]

    /// パターンを順番に取得（理想、252、無振り、最低、下降）
    private var orderedPatterns: [CalculatedStats.StatsPattern] {
        let order = ["ideal", "max", "neutral", "min", "hindered"]
        return order.compactMap { id in
            stats.patterns.first { $0.id == id }
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 8) {
                    // ヘッダー行（パターン名）
                    HStack(spacing: 0) {
                        // 左側の空白（ステータス名用）
                        Text("")
                            .frame(width: 80, alignment: .leading)

                        // 各パターンのヘッダー
                        ForEach(orderedPatterns) { pattern in
                            VStack(spacing: 2) {
                                Text(FilterHelpers.patternName(pattern.id))
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                Text(pattern.config.displayText)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 60)
                        }
                    }

                    Divider()

                    // 各ステータス行
                    StatsTableRow(name: FilterHelpers.statName("hp"), getValue: { $0.hp })
                    StatsTableRow(name: FilterHelpers.statName("attack"), getValue: { $0.attack })
                    StatsTableRow(name: FilterHelpers.statName("defense"), getValue: { $0.defense })
                    StatsTableRow(name: FilterHelpers.statName("special-attack"), getValue: { $0.specialAttack })
                    StatsTableRow(name: FilterHelpers.statName("special-defense"), getValue: { $0.specialDefense })
                    StatsTableRow(name: FilterHelpers.statName("speed"), getValue: { $0.speed })
                }
                .padding()
            }
        }
        .padding()
        .environment(\.orderedPatterns, orderedPatterns)
    }
}

/// 個別ステータス行
struct StatsTableRow: View {
    let name: String
    let getValue: (CalculatedStats.StatsPattern) -> Int

    @Environment(\.orderedPatterns) private var patterns

    var body: some View {
        HStack(spacing: 0) {
            // ステータス名
            Text(name)
                .font(.subheadline)
                .frame(width: 80, alignment: .leading)

            // 各パターンの値
            ForEach(patterns) { pattern in
                Text("\(getValue(pattern))")
                    .font(.subheadline)
                    .frame(width: 60)
            }
        }
    }
}

/// Environment Key for patterns
private struct OrderedPatternsKey: EnvironmentKey {
    static let defaultValue: [CalculatedStats.StatsPattern] = []
}

extension EnvironmentValues {
    var orderedPatterns: [CalculatedStats.StatsPattern] {
        get { self[OrderedPatternsKey.self] }
        set { self[OrderedPatternsKey.self] = newValue }
    }
}

#Preview {
    let sampleBaseStats = [
        PokemonStat(name: "hp", baseStat: 78),
        PokemonStat(name: "attack", baseStat: 84),
        PokemonStat(name: "defense", baseStat: 78),
        PokemonStat(name: "special-attack", baseStat: 109),
        PokemonStat(name: "special-defense", baseStat: 85),
        PokemonStat(name: "speed", baseStat: 100)
    ]

    let useCase = CalculateStatsUseCase()
    let calculatedStats = useCase.execute(baseStats: sampleBaseStats)

    return CalculatedStatsView(
        stats: calculatedStats,
        baseStats: sampleBaseStats
    )
}
