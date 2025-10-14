//
//  StatFilterSection.swift
//  Pokedex
//
//  種族値フィルターセクション
//

import SwiftUI

struct StatFilterSection: View {
    @Binding var statFilterConditions: [StatFilterCondition]
    @State private var inputValues: [StatType: (min: String, max: String)] = [:]

    var body: some View {
        Section {
            // 全ステータスを一覧表示
            VStack(alignment: .leading, spacing: 12) {
                ForEach(StatType.allCases) { statType in
                    HStack(spacing: 8) {
                        // ステータス名
                        Text(statType.rawValue)
                            .frame(width: 80, alignment: .leading)
                            .font(.body)

                        // 最小値入力
                        TextField("最小", text: binding(for: statType, isMin: true))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)

                        Text("〜")
                            .foregroundColor(.secondary)

                        // 最大値入力
                        TextField("最大", text: binding(for: statType, isMin: false))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)

                        // 追加ボタン
                        Button {
                            addStatCondition(for: statType)
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(canAdd(for: statType) ? .blue : .gray)
                                .imageScale(.large)
                        }
                        .disabled(!canAdd(for: statType))

                        Spacer()
                    }
                }
            }
            .padding(.vertical, 8)

            // 選択済み条件の表示
            if !statFilterConditions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("設定中の条件")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(statFilterConditions) { condition in
                        HStack {
                            Text(condition.displayText)
                                .font(.body)

                            Spacer()

                            Button {
                                removeStatCondition(condition)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        } header: {
            Text("種族値")
        } footer: {
            Text("ポケモンの種族値で絞り込みます")
        }
    }

    private func binding(for statType: StatType, isMin: Bool) -> Binding<String> {
        Binding(
            get: {
                if isMin {
                    return inputValues[statType]?.min ?? ""
                } else {
                    return inputValues[statType]?.max ?? ""
                }
            },
            set: { newValue in
                let currentMin = inputValues[statType]?.min ?? ""
                let currentMax = inputValues[statType]?.max ?? ""
                if isMin {
                    inputValues[statType] = (min: newValue, max: currentMax)
                } else {
                    inputValues[statType] = (min: currentMin, max: newValue)
                }
            }
        )
    }

    private func canAdd(for statType: StatType) -> Bool {
        guard let values = inputValues[statType] else { return false }

        // 最小値か最大値の少なくとも一方が入力されている
        let hasMin = !values.min.isEmpty && Int(values.min) != nil
        let hasMax = !values.max.isEmpty && Int(values.max) != nil

        if !hasMin && !hasMax {
            return false
        }

        // 両方入力されている場合、最小 <= 最大をチェック
        if hasMin && hasMax {
            guard let minValue = Int(values.min), let maxValue = Int(values.max) else {
                return false
            }
            return minValue <= maxValue
        }

        return true
    }

    private func addStatCondition(for statType: StatType) {
        guard let values = inputValues[statType] else { return }

        let minValue = Int(values.min)
        let maxValue = Int(values.max)

        // 少なくとも一方が入力されている必要がある
        guard minValue != nil || maxValue != nil else { return }

        let condition = StatFilterCondition(
            statType: statType,
            mode: .range,
            minValue: minValue ?? 0,
            maxValue: maxValue
        )

        statFilterConditions.append(condition)
        inputValues[statType] = (min: "", max: "")
    }

    private func removeStatCondition(_ condition: StatFilterCondition) {
        statFilterConditions.removeAll { $0.id == condition.id }
    }
}
