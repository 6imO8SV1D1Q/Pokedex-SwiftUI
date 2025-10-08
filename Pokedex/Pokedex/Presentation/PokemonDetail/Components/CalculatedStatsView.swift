//
//  CalculatedStatsView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// 実数値計算結果を表示するビュー
struct CalculatedStatsView: View {
    let stats: CalculatedStats

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("種族値・実数値")
                .font(.headline)

            // 各ステータスの表示
            VStack(spacing: 12) {
                StatRow(
                    name: "HP",
                    baseValue: stats.baseStats.hp,
                    minValue: stats.minStats.hp,
                    maxValue: stats.maxStats.hp,
                    color: .red
                )

                StatRow(
                    name: "こうげき",
                    baseValue: stats.baseStats.attack,
                    minValue: stats.minStats.attack,
                    maxValue: stats.maxStats.attack,
                    color: .orange
                )

                StatRow(
                    name: "ぼうぎょ",
                    baseValue: stats.baseStats.defense,
                    minValue: stats.minStats.defense,
                    maxValue: stats.maxStats.defense,
                    color: .yellow
                )

                StatRow(
                    name: "とくこう",
                    baseValue: stats.baseStats.specialAttack,
                    minValue: stats.minStats.specialAttack,
                    maxValue: stats.maxStats.specialAttack,
                    color: .blue
                )

                StatRow(
                    name: "とくぼう",
                    baseValue: stats.baseStats.specialDefense,
                    minValue: stats.minStats.specialDefense,
                    maxValue: stats.maxStats.specialDefense,
                    color: .green
                )

                StatRow(
                    name: "すばやさ",
                    baseValue: stats.baseStats.speed,
                    minValue: stats.minStats.speed,
                    maxValue: stats.maxStats.speed,
                    color: .pink
                )

                Divider()

                // 合計
                HStack {
                    Text("合計")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 80, alignment: .leading)

                    Text("\(stats.totalBaseStats)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .frame(width: 50)

                    Spacer()
                }
            }
        }
        .padding()
    }
}

/// 個別ステータス行
struct StatRow: View {
    let name: String
    let baseValue: Int
    let minValue: Int
    let maxValue: Int
    let color: Color

    // 最大種族値（バーの長さ計算用）
    private let maxBaseValue = 255

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // ステータス名
                Text(name)
                    .font(.subheadline)
                    .frame(width: 80, alignment: .leading)

                // 種族値
                Text("\(baseValue)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .frame(width: 50)

                // バー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景バー
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                            .cornerRadius(4)

                        // 実際の値バー
                        Rectangle()
                            .fill(color)
                            .frame(
                                width: geometry.size.width * CGFloat(baseValue) / CGFloat(maxBaseValue),
                                height: 8
                            )
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }

            // 実数値範囲
            HStack {
                Spacer()
                    .frame(width: 80) // ステータス名の幅分スペース

                Text("\(minValue) - \(maxValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    CalculatedStatsView(
        stats: CalculatedStats(
            baseStats: PokemonStats(
                hp: 78,
                attack: 84,
                defense: 78,
                specialAttack: 109,
                specialDefense: 85,
                speed: 100
            ),
            minStats: PokemonStats(
                hp: 292,
                attack: 166,
                defense: 154,
                specialAttack: 212,
                specialDefense: 168,
                speed: 196
            ),
            maxStats: PokemonStats(
                hp: 386,
                attack: 260,
                defense: 248,
                specialAttack: 306,
                specialDefense: 262,
                speed: 290
            )
        )
    )
}
