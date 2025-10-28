//
//  CompactStatsInputView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// コンパクトなステータス入力UI（種族値・個体値・努力値・性格・実数値を1つの表に統合）
struct CompactStatsInputView: View {
    let pokemon: Pokemon?
    let calculatedStats: [String: Int]

    @Binding var level: Int
    @Binding var ivs: [String: Int]
    @Binding var evs: [String: Int]
    @Binding var natureModifiers: [String: NatureModifier]

    let remainingEVs: Int
    let isEVOverLimit: Bool

    let onSetAllIVsToMax: () -> Void
    let onSetAllIVsToMin: () -> Void
    let onIncrementEV: (String) -> Void
    let onDecrementEV: (String) -> Void
    let onSetNature: (String, NatureModifier) -> Void

    private let statNames: [(key: String, label: String)] = [
        ("hp", "HP"),
        ("attack", "こうげき"),
        ("defense", "ぼうぎょ"),
        ("special-attack", "とくこう"),
        ("special-defense", "とくぼう"),
        ("speed", "すばやさ")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // レベル入力
            levelInput

            Divider()

            // ヘッダー行
            headerRow

            // 各ステータス行
            ForEach(statNames, id: \.key) { stat in
                statRow(stat: stat)
                if stat.key != "speed" {
                    Divider()
                        .padding(.horizontal, 4)
                }
            }

            // 努力値情報
            evSummary
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - レベル入力

    private var levelInput: some View {
        HStack {
            Text(L10n.StatsCalc.level)
                .font(.subheadline)

            TextField("", value: $level, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 60)
                .font(.caption)
                .onChange(of: level) { _, newValue in
                    if newValue < 1 {
                        level = 1
                    } else if newValue > 100 {
                        level = 100
                    }
                }

            Text(L10n.StatsCalc.levelRange)
                .font(.system(size: 10))
                .foregroundColor(.secondary)

            Spacer()

            Button {
                onSetAllIVsToMax()
            } label: {
                Text(L10n.StatsCalc.ivSetMaxShort)
            }
            .buttonStyle(.bordered)
            .font(.system(size: 9))

            Button {
                onSetAllIVsToMin()
            } label: {
                Text(L10n.StatsCalc.ivSetMinShort)
            }
            .buttonStyle(.bordered)
            .font(.system(size: 9))
        }
    }

    // MARK: - ヘッダー行

    private var headerRow: some View {
        HStack(spacing: 2) {
            Text("")
                .frame(width: 56, alignment: .leading)

            Text(L10n.StatsCalc.baseStat)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 32)

            Text(L10n.StatsCalc.ivShort)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 28)

            Text(L10n.StatsCalc.evShort)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 28)

            Spacer()

            Text(L10n.StatsCalc.nature)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 44)

            Text(L10n.StatsCalc.calculatedStat)
                .font(.system(size: 9))
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(width: 36, alignment: .trailing)
        }
    }

    // MARK: - ステータス行

    private func statRow(stat: (key: String, label: String)) -> some View {
        let baseStat = pokemon?.stats.first(where: { $0.name == stat.key })?.baseStat ?? 0
        let calculatedStat = calculatedStats[stat.key] ?? 0
        let natureModifier = natureModifiers[stat.key]

        return HStack(spacing: 2) {
            // ステータス名
            Text(stat.label)
                .frame(width: 56, alignment: .leading)
                .font(.system(size: 11))

            // 種族値
            Text("\(baseStat)")
                .frame(width: 32)
                .font(.system(size: 11))
                .foregroundColor(.secondary)

            // 個体値（IV）
            TextField("", value: Binding(
                get: { ivs[stat.key] ?? 0 },
                set: { newValue in
                    ivs[stat.key] = min(max(newValue, 0), 31)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .frame(width: 28)
            .font(.system(size: 10))
            .multilineTextAlignment(.center)

            // 努力値（EV）
            TextField("", value: Binding(
                get: { evs[stat.key] ?? 0 },
                set: { newValue in
                    evs[stat.key] = min(max(newValue, 0), 252)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .frame(width: 28)
            .font(.system(size: 10))
            .multilineTextAlignment(.center)

            // EV調整ボタン
            HStack(spacing: 0) {
                Button {
                    onDecrementEV(stat.key)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(width: 20, height: 20)

                Button {
                    onIncrementEV(stat.key)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(width: 20, height: 20)

                Menu {
                    Button {
                        evs[stat.key] = 252
                    } label: {
                        Text(L10n.StatsCalc.evSetMax)
                    }
                    Button {
                        evs[stat.key] = 0
                    } label: {
                        Text(L10n.StatsCalc.evSetZero)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .frame(width: 20, height: 20)
            }

            Spacer(minLength: 2)

            // 性格補正（HPは除外）
            if stat.key != "hp" {
                HStack(spacing: 2) {
                    natureButton(stat: stat.key, modifier: .boosted, label: "↑", color: .red)
                    natureButton(stat: stat.key, modifier: .hindered, label: "↓", color: .blue)
                }
            } else {
                // HPの場合は空白
                Color.clear
                    .frame(width: 44)
            }

            // 実数値
            Text("\(calculatedStat)")
                .frame(width: 36, alignment: .trailing)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(natureColor(natureModifier))
        }
    }

    // MARK: - 性格補正ボタン

    private func natureButton(
        stat: String,
        modifier: NatureModifier,
        label: String,
        color: Color
    ) -> some View {
        Button {
            onSetNature(stat, modifier)
        } label: {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .frame(width: 21, height: 21)
                .background(isNatureSelected(stat: stat, modifier: modifier) ? color.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(isNatureSelected(stat: stat, modifier: modifier) ? color : .secondary)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isNatureSelected(stat: stat, modifier: modifier) ? color : Color.clear, lineWidth: 1.5)
                )
        }
    }

    private func isNatureSelected(stat: String, modifier: NatureModifier) -> Bool {
        natureModifiers[stat] == modifier
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

    // MARK: - 努力値サマリー

    private var evSummary: some View {
        HStack {
            Text(L10n.StatsCalc.evRemaining(remainingEVs))
                .font(.caption)
                .foregroundColor(isEVOverLimit ? .red : .secondary)

            if isEVOverLimit {
                Text(L10n.StatsCalc.evOverLimit)
                    .font(.system(size: 10))
                    .foregroundColor(.red)
            }

            Spacer()
        }
    }
}

#Preview {
    CompactStatsInputView(
        pokemon: Pokemon(
            id: 898,
            speciesId: 898,
            name: "calyrex-shadow",
            nameJa: "バドレックス",
            genus: nil,
            genusJa: nil,
            height: 24,
            weight: 536,
            category: nil,
            types: [
                PokemonType(slot: 1, name: "psychic", nameJa: "エスパー"),
                PokemonType(slot: 2, name: "ghost", nameJa: "ゴースト")
            ],
            stats: [
                PokemonStat(name: "hp", baseStat: 100),
                PokemonStat(name: "attack", baseStat: 85),
                PokemonStat(name: "defense", baseStat: 80),
                PokemonStat(name: "special-attack", baseStat: 165),
                PokemonStat(name: "special-defense", baseStat: 100),
                PokemonStat(name: "speed", baseStat: 150)
            ],
            abilities: [],
            sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
            moves: [],
            availableGenerations: [8],
            nationalDexNumber: 898,
            eggGroups: nil,
            genderRate: nil,
            pokedexNumbers: nil,
            varieties: nil,
            evolutionChain: nil
        ),
        calculatedStats: [
            "hp": 175,
            "attack": 105,
            "defense": 100,
            "special-attack": 252,
            "special-defense": 120,
            "speed": 222
        ],
        level: .constant(50),
        ivs: .constant([
            "hp": 31, "attack": 31, "defense": 31,
            "special-attack": 31, "special-defense": 31, "speed": 31
        ]),
        evs: .constant([
            "hp": 252, "attack": 4, "defense": 0,
            "special-attack": 0, "special-defense": 0, "speed": 252
        ]),
        natureModifiers: .constant([
            "attack": .neutral,
            "defense": .neutral,
            "special-attack": .boosted,
            "special-defense": .neutral,
            "speed": .neutral
        ]),
        remainingEVs: 2,
        isEVOverLimit: false,
        onSetAllIVsToMax: {},
        onSetAllIVsToMin: {},
        onIncrementEV: { _ in },
        onDecrementEV: { _ in },
        onSetNature: { _, _ in }
    )
}
