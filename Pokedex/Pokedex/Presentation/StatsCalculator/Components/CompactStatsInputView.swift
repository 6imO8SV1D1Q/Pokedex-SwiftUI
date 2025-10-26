//
//  CompactStatsInputView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// コンパクトなステータス入力UI（個体値・努力値・性格を1つの表に統合）
struct CompactStatsInputView: View {
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
        ("attack", "攻撃"),
        ("defense", "防御"),
        ("special-attack", "特攻"),
        ("special-defense", "特防"),
        ("speed", "素早さ")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                        .padding(.horizontal, 8)
                }
            }

            // 努力値情報
            evSummary
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - レベル入力

    private var levelInput: some View {
        HStack {
            Text("レベル")
                .font(.headline)

            TextField("レベル", value: $level, format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.numberPad)
                .frame(width: 80)
                .onChange(of: level) { _, newValue in
                    if newValue < 1 {
                        level = 1
                    } else if newValue > 100 {
                        level = 100
                    }
                }

            Text("(1-100)")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
    }

    // MARK: - ヘッダー行

    private var headerRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("")
                    .frame(width: 50, alignment: .leading)

                Text("IV")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 50)

                Spacer()
                    .frame(width: 8)

                Text("EV")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .frame(width: 50)

                Spacer()

                Text("性格")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 4) {
                Spacer()

                Button("IV 31") {
                    onSetAllIVsToMax()
                }
                .buttonStyle(.bordered)
                .font(.caption2)

                Button("IV 0") {
                    onSetAllIVsToMin()
                }
                .buttonStyle(.bordered)
                .font(.caption2)
            }
        }
    }

    // MARK: - ステータス行

    private func statRow(stat: (key: String, label: String)) -> some View {
        HStack(spacing: 8) {
            // ステータス名
            Text(stat.label)
                .frame(width: 50, alignment: .leading)
                .font(.subheadline)

            // 個体値（IV）
            TextField("", value: Binding(
                get: { ivs[stat.key] ?? 0 },
                set: { newValue in
                    ivs[stat.key] = min(max(newValue, 0), 31)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .frame(width: 50)
            .multilineTextAlignment(.center)

            Spacer()
                .frame(width: 8)

            // 努力値（EV）
            TextField("", value: Binding(
                get: { evs[stat.key] ?? 0 },
                set: { newValue in
                    evs[stat.key] = min(max(newValue, 0), 252)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(.numberPad)
            .frame(width: 50)
            .multilineTextAlignment(.center)

            // EV調整ボタン
            HStack(spacing: 4) {
                Button {
                    onDecrementEV(stat.key)
                } label: {
                    Image(systemName: "minus")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .frame(width: 28, height: 28)

                Button {
                    onIncrementEV(stat.key)
                } label: {
                    Image(systemName: "plus")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .frame(width: 28, height: 28)

                Button {
                    evs[stat.key] = 252
                } label: {
                    Text("252")
                        .font(.caption2)
                }
                .buttonStyle(.bordered)
                .frame(width: 36, height: 28)
            }

            Spacer()

            // 性格補正（HPは除外）
            if stat.key != "hp" {
                HStack(spacing: 4) {
                    natureButton(stat: stat.key, modifier: .boosted, label: "↑", color: .red)
                    natureButton(stat: stat.key, modifier: .neutral, label: "-", color: .gray)
                    natureButton(stat: stat.key, modifier: .hindered, label: "↓", color: .blue)
                }
            } else {
                // HPの場合は空白
                Color.clear
                    .frame(width: 100)
            }
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
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 28, height: 28)
                .background(isNatureSelected(stat: stat, modifier: modifier) ? color.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(isNatureSelected(stat: stat, modifier: modifier) ? color : .secondary)
                .cornerRadius(4)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(isNatureSelected(stat: stat, modifier: modifier) ? color : Color.clear, lineWidth: 2)
                )
        }
    }

    private func isNatureSelected(stat: String, modifier: NatureModifier) -> Bool {
        natureModifiers[stat] == modifier
    }

    // MARK: - 努力値サマリー

    private var evSummary: some View {
        HStack {
            Text("努力値 残り: \(remainingEVs)")
                .font(.subheadline)
                .foregroundColor(isEVOverLimit ? .red : .secondary)

            if isEVOverLimit {
                Text("（510を超えています）")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            Spacer()
        }
    }
}

#Preview {
    CompactStatsInputView(
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
            "special-attack": .neutral,
            "special-defense": .neutral,
            "speed": .boosted
        ]),
        remainingEVs: 254,
        isEVOverLimit: false,
        onSetAllIVsToMax: {},
        onSetAllIVsToMin: {},
        onIncrementEV: { _ in },
        onDecrementEV: { _ in },
        onSetNature: { _, _ in }
    )
}
