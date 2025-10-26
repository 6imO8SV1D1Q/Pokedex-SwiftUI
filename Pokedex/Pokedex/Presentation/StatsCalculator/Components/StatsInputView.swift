//
//  StatsInputView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// ステータス入力UI（レベル、個体値、努力値）
struct StatsInputView: View {
    @Binding var level: Int
    @Binding var ivs: [String: Int]
    @Binding var evs: [String: Int]

    let remainingEVs: Int
    let isEVOverLimit: Bool

    let onSetAllIVsToMax: () -> Void
    let onSetAllIVsToMin: () -> Void
    let onIncrementEV: (String) -> Void
    let onDecrementEV: (String) -> Void

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

            // 個体値入力
            ivInput

            Divider()

            // 努力値入力
            evInput
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - レベル入力

    private var levelInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("レベル")
                .font(.headline)

            HStack {
                TextField("レベル", value: $level, format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .onChange(of: level) { _, newValue in
                        // 1-100の範囲に制限
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
    }

    // MARK: - 個体値入力

    private var ivInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("個体値 (IV)")
                    .font(.headline)

                Spacer()

                Button("すべて31") {
                    onSetAllIVsToMax()
                }
                .buttonStyle(.bordered)
                .font(.caption)

                Button("すべて0") {
                    onSetAllIVsToMin()
                }
                .buttonStyle(.bordered)
                .font(.caption)
            }

            ForEach(statNames, id: \.key) { stat in
                HStack {
                    Text(stat.label)
                        .frame(width: 60, alignment: .leading)

                    TextField("", value: Binding(
                        get: { ivs[stat.key] ?? 0 },
                        set: { newValue in
                            // 0-31の範囲に制限
                            ivs[stat.key] = min(max(newValue, 0), 31)
                        }
                    ), format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 60)

                    Text("(0-31)")
                        .font(.caption2)
                        .foregroundColor(.secondary)

                    Spacer()
                }
            }
        }
    }

    // MARK: - 努力値入力

    private var evInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("努力値 (EV)")
                    .font(.headline)

                Spacer()

                Text("残り: \(remainingEVs)")
                    .font(.subheadline)
                    .foregroundColor(isEVOverLimit ? .red : .secondary)
            }

            if isEVOverLimit {
                Text("努力値が510を超えています")
                    .font(.caption)
                    .foregroundColor(.red)
            }

            ForEach(statNames, id: \.key) { stat in
                HStack {
                    Text(stat.label)
                        .frame(width: 60, alignment: .leading)

                    TextField("", value: Binding(
                        get: { evs[stat.key] ?? 0 },
                        set: { newValue in
                            // 0-252の範囲に制限
                            let limited = min(max(newValue, 0), 252)
                            evs[stat.key] = limited
                        }
                    ), format: .number)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.numberPad)
                    .frame(width: 60)

                    Button {
                        onIncrementEV(stat.key)
                    } label: {
                        Image(systemName: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 36, height: 36)

                    Button {
                        onDecrementEV(stat.key)
                    } label: {
                        Image(systemName: "minus")
                            .font(.caption)
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 36, height: 36)

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    StatsInputView(
        level: .constant(50),
        ivs: .constant([
            "hp": 31, "attack": 31, "defense": 31,
            "special-attack": 31, "special-defense": 31, "speed": 31
        ]),
        evs: .constant([
            "hp": 252, "attack": 4, "defense": 0,
            "special-attack": 0, "special-defense": 0, "speed": 0
        ]),
        remainingEVs: 254,
        isEVOverLimit: false,
        onSetAllIVsToMax: {},
        onSetAllIVsToMin: {},
        onIncrementEV: { _ in },
        onDecrementEV: { _ in }
    )
}
