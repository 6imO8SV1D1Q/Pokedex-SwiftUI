//
//  StatsResultView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// 計算結果表示UI
struct StatsResultView: View {
    let pokemon: Pokemon
    let calculatedStats: [String: Int]
    let natureModifiers: [String: NatureModifier]

    private let statNames: [(key: String, label: String)] = [
        ("hp", "HP"),
        ("attack", "こうげき"),
        ("defense", "ぼうぎょ"),
        ("special-attack", "とくこう"),
        ("special-defense", "とくぼう"),
        ("speed", "すばやさ")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(L10n.StatsCalc.result)
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(statNames, id: \.key) { stat in
                    statRow(stat: stat)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - ステータス行

    private func statRow(stat: (key: String, label: String)) -> some View {
        let baseStat = pokemon.stats.first(where: { $0.name == stat.key })?.baseStat ?? 0
        let calculatedStat = calculatedStats[stat.key] ?? 0
        let natureModifier = stat.key == "hp" ? nil : natureModifiers[stat.key]

        return VStack(spacing: 4) {
            HStack {
                // ステータス名
                Text(stat.label)
                    .font(.subheadline)
                    .frame(width: 50, alignment: .leading)

                // 種族値
                Text("\(baseStat)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 40, alignment: .center)

                Spacer()

                // 性格補正アイコン（HPを除く）
                if let modifier = natureModifier {
                    modifierIcon(modifier)
                }

                // 実数値
                Text("\(calculatedStat)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(natureColor(natureModifier))
                    .frame(width: 60, alignment: .trailing)
            }

            // プログレスバー（種族値ベース）
            GeometryReader { geometry in
                let maxBaseStat: Double = 255.0
                let progress = min(Double(baseStat) / maxBaseStat, 1.0)

                ZStack(alignment: .leading) {
                    // 背景
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(height: 6)
                        .cornerRadius(3)

                    // プログレス
                    Rectangle()
                        .fill(statColor(for: baseStat))
                        .frame(width: geometry.size.width * progress, height: 6)
                        .cornerRadius(3)
                }
            }
            .frame(height: 6)
        }
    }

    // MARK: - 補正アイコン

    private func modifierIcon(_ modifier: NatureModifier) -> some View {
        Group {
            switch modifier {
            case .boosted:
                Image(systemName: "arrow.up")
                    .font(.caption2)
                    .foregroundColor(.red)
            case .hindered:
                Image(systemName: "arrow.down")
                    .font(.caption2)
                    .foregroundColor(.blue)
            case .neutral:
                EmptyView()
            }
        }
        .frame(width: 16)
    }

    // MARK: - 色の決定

    private func natureColor(_ modifier: NatureModifier?) -> Color {
        guard let modifier = modifier else { return .primary }
        switch modifier {
        case .boosted:
            return .red
        case .hindered:
            return .blue
        case .neutral:
            return .primary
        }
    }

    private func statColor(for baseStat: Int) -> Color {
        switch baseStat {
        case 0..<50:
            return .red.opacity(0.6)
        case 50..<80:
            return .orange.opacity(0.6)
        case 80..<100:
            return .yellow.opacity(0.6)
        case 100..<120:
            return .green.opacity(0.6)
        default:
            return .blue.opacity(0.6)
        }
    }
}

#Preview {
    StatsResultView(
        pokemon: Pokemon(
            id: 1,
            speciesId: 1,
            name: "bulbasaur",
            nameJa: "フシギダネ",
            genus: nil,
            genusJa: nil,
            height: 7,
            weight: 69,
            category: nil,
            types: [
                PokemonType(slot: 1, name: "grass", nameJa: "くさ"),
                PokemonType(slot: 2, name: "poison", nameJa: "どく")
            ],
            stats: [
                PokemonStat(name: "hp", baseStat: 45),
                PokemonStat(name: "attack", baseStat: 49),
                PokemonStat(name: "defense", baseStat: 49),
                PokemonStat(name: "special-attack", baseStat: 65),
                PokemonStat(name: "special-defense", baseStat: 65),
                PokemonStat(name: "speed", baseStat: 45)
            ],
            abilities: [],
            sprites: PokemonSprites(
                frontDefault: "",
                frontShiny: nil,
                other: nil
            ),
            moves: [],
            availableGenerations: [1],
            nationalDexNumber: 1,
            eggGroups: nil,
            genderRate: nil,
            pokedexNumbers: nil,
            varieties: nil,
            evolutionChain: nil
        ),
        calculatedStats: [
            "hp": 150,
            "attack": 101,
            "defense": 101,
            "special-attack": 128,
            "special-defense": 128,
            "speed": 99
        ],
        natureModifiers: [
            "attack": .neutral,
            "defense": .neutral,
            "special-attack": .boosted,
            "special-defense": .neutral,
            "speed": .hindered
        ]
    )
}
