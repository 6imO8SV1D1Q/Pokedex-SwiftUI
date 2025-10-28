//
//  NatureInputView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// 性格補正入力UI
struct NatureInputView: View {
    @Binding var natureModifiers: [String: NatureModifier]

    let onSetNature: (String, NatureModifier) -> Void

    private let statNames: [(key: String, label: String)] = [
        ("attack", "こうげき"),
        ("defense", "ぼうぎょ"),
        ("special-attack", "とくこう"),
        ("special-defense", "とくぼう"),
        ("speed", "すばやさ")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.StatsCalc.natureCorrection)
                .font(.headline)

            Text(L10n.StatsCalc.natureDescription)
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 8) {
                ForEach(statNames, id: \.key) { stat in
                    HStack {
                        Text(stat.label)
                            .frame(width: 60, alignment: .leading)

                        Spacer()

                        // 補正選択ボタン
                        HStack(spacing: 8) {
                            modifierButton(
                                stat: stat.key,
                                modifier: .boosted,
                                label: "↑",
                                color: .red
                            )

                            modifierButton(
                                stat: stat.key,
                                modifier: .neutral,
                                label: "-",
                                color: .gray
                            )

                            modifierButton(
                                stat: stat.key,
                                modifier: .hindered,
                                label: "↓",
                                color: .blue
                            )
                        }
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }

    // MARK: - 補正ボタン

    private func modifierButton(
        stat: String,
        modifier: NatureModifier,
        label: String,
        color: Color
    ) -> some View {
        Button {
            onSetNature(stat, modifier)
        } label: {
            Text(label)
                .font(.system(size: 16, weight: .semibold))
                .frame(width: 40, height: 36)
                .background(isSelected(stat: stat, modifier: modifier) ? color.opacity(0.2) : Color(.systemGray5))
                .foregroundColor(isSelected(stat: stat, modifier: modifier) ? color : .secondary)
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected(stat: stat, modifier: modifier) ? color : Color.clear, lineWidth: 2)
                )
        }
    }

    private func isSelected(stat: String, modifier: NatureModifier) -> Bool {
        natureModifiers[stat] == modifier
    }
}

#Preview {
    NatureInputView(
        natureModifiers: .constant([
            "attack": .boosted,
            "defense": .neutral,
            "special-attack": .neutral,
            "special-defense": .hindered,
            "speed": .neutral
        ]),
        onSetNature: { _, _ in }
    )
}
