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
                        Text(statType.localizedName)
                            .frame(width: 80, alignment: .leading)
                            .font(.body)

                        // 最小値入力
                        TextField(L10n.Filter.min, text: binding(for: statType, isMin: true))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                            .onChange(of: inputValues[statType]?.min ?? "") {
                                updateCondition(for: statType)
                            }

                        Text("〜")
                            .foregroundColor(.secondary)

                        // 最大値入力
                        TextField(L10n.Filter.max, text: binding(for: statType, isMin: false))
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 70)
                            .onChange(of: inputValues[statType]?.max ?? "") {
                                updateCondition(for: statType)
                            }

                        // クリアボタン（値が入力されているか条件が設定されている場合に表示）
                        if hasValue(for: statType) || hasCondition(for: statType) {
                            Button {
                                clearCondition(for: statType)
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .imageScale(.medium)
                            }
                        }

                        Spacer()
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.baseStats)
        } footer: {
            if statFilterConditions.isEmpty {
                Text(L10n.Filter.baseStatsDescription)
            } else {
                Text(L10n.Filter.conditionCount(statFilterConditions.count))
            }
        }
        .onAppear {
            loadConditionsToInputValues()
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

    private func hasValue(for statType: StatType) -> Bool {
        guard let values = inputValues[statType] else { return false }
        return !values.min.isEmpty || !values.max.isEmpty
    }

    private func hasCondition(for statType: StatType) -> Bool {
        return statFilterConditions.contains { $0.statType == statType }
    }

    private func updateCondition(for statType: StatType) {
        // 既存の条件を削除
        statFilterConditions.removeAll { $0.statType == statType }

        guard let values = inputValues[statType] else { return }

        let minValue = Int(values.min)
        let maxValue = Int(values.max)

        // 最小値か最大値の少なくとも一方が入力されている場合のみ条件を追加
        guard minValue != nil || maxValue != nil else { return }

        // 両方入力されている場合、最小 <= 最大をチェック
        if let min = minValue, let max = maxValue, min > max {
            return
        }

        let condition = StatFilterCondition(
            statType: statType,
            mode: .range,
            minValue: minValue ?? 0,
            maxValue: maxValue
        )

        statFilterConditions.append(condition)
    }

    private func clearCondition(for statType: StatType) {
        inputValues[statType] = (min: "", max: "")
        statFilterConditions.removeAll { $0.statType == statType }
    }

    private func loadConditionsToInputValues() {
        for condition in statFilterConditions {
            let minStr = condition.minValue > 0 ? String(condition.minValue) : ""
            let maxStr = condition.maxValue.map { String($0) } ?? ""
            inputValues[condition.statType] = (min: minStr, max: maxStr)
        }
    }
}
