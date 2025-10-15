//
//  AbilityNumericConditionSection.swift
//  Pokedex
//
//  特性の数値条件（倍率・確率）入力セクション
//

import SwiftUI

struct AbilityNumericConditionSection: View {
    @Binding var statMultiplierCondition: NumericCondition?
    @Binding var movePowerMultiplierCondition: NumericCondition?
    @Binding var probabilityCondition: NumericCondition?

    @State private var statMultiplierMin: String = ""
    @State private var statMultiplierMax: String = ""
    @State private var movePowerMultiplierMin: String = ""
    @State private var movePowerMultiplierMax: String = ""
    @State private var probabilityMin: String = ""
    @State private var probabilityMax: String = ""

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // 能力値倍率
                HStack(spacing: 8) {
                    Text("能力値倍率")
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField("最小", text: $statMultiplierMin)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField("最大", text: $statMultiplierMax)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Button {
                        applyStatMultiplierCondition()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(canAddStatMultiplier() ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .disabled(!canAddStatMultiplier())

                    Spacer()
                }

                // 技威力倍率
                HStack(spacing: 8) {
                    Text("技威力倍率")
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField("最小", text: $movePowerMultiplierMin)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField("最大", text: $movePowerMultiplierMax)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Button {
                        applyMovePowerMultiplierCondition()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(canAddMovePowerMultiplier() ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .disabled(!canAddMovePowerMultiplier())

                    Spacer()
                }

                // 発動確率
                HStack(spacing: 8) {
                    Text("発動確率（%）")
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField("最小", text: $probabilityMin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField("最大", text: $probabilityMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)

                    Button {
                        applyProbabilityCondition()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(canAddProbability() ? .blue : .gray)
                            .imageScale(.large)
                    }
                    .disabled(!canAddProbability())

                    Spacer()
                }
            }
            .padding(.vertical, 8)

            // 設定済み条件の表示
            if statMultiplierCondition != nil || movePowerMultiplierCondition != nil || probabilityCondition != nil {
                VStack(alignment: .leading, spacing: 8) {
                    Text("設定中の条件")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let condition = statMultiplierCondition {
                        conditionRow(
                            label: "能力値倍率",
                            condition: condition,
                            onRemove: { statMultiplierCondition = nil }
                        )
                    }

                    if let condition = movePowerMultiplierCondition {
                        conditionRow(
                            label: "技威力倍率",
                            condition: condition,
                            onRemove: { movePowerMultiplierCondition = nil }
                        )
                    }

                    if let condition = probabilityCondition {
                        conditionRow(
                            label: "発動確率",
                            condition: condition,
                            onRemove: { probabilityCondition = nil }
                        )
                    }
                }
            }
        } header: {
            Text("数値条件")
        } footer: {
            Text("倍率や確率の範囲を設定して絞り込みます")
        }
    }

    private func conditionRow(label: String, condition: NumericCondition, onRemove: @escaping () -> Void) -> some View {
        HStack {
            Text(condition.displayText(label: label))
                .font(.body)

            Spacer()

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Validation

    private func canAddStatMultiplier() -> Bool {
        let hasMin = !statMultiplierMin.isEmpty && Double(statMultiplierMin) != nil
        let hasMax = !statMultiplierMax.isEmpty && Double(statMultiplierMax) != nil

        if !hasMin && !hasMax {
            return false
        }

        if hasMin && hasMax {
            guard let minValue = Double(statMultiplierMin), let maxValue = Double(statMultiplierMax) else {
                return false
            }
            return minValue <= maxValue
        }

        return true
    }

    private func canAddMovePowerMultiplier() -> Bool {
        let hasMin = !movePowerMultiplierMin.isEmpty && Double(movePowerMultiplierMin) != nil
        let hasMax = !movePowerMultiplierMax.isEmpty && Double(movePowerMultiplierMax) != nil

        if !hasMin && !hasMax {
            return false
        }

        if hasMin && hasMax {
            guard let minValue = Double(movePowerMultiplierMin), let maxValue = Double(movePowerMultiplierMax) else {
                return false
            }
            return minValue <= maxValue
        }

        return true
    }

    private func canAddProbability() -> Bool {
        let hasMin = !probabilityMin.isEmpty && Double(probabilityMin) != nil
        let hasMax = !probabilityMax.isEmpty && Double(probabilityMax) != nil

        if !hasMin && !hasMax {
            return false
        }

        if hasMin && hasMax {
            guard let minValue = Double(probabilityMin), let maxValue = Double(probabilityMax) else {
                return false
            }
            return minValue <= maxValue
        }

        return true
    }

    // MARK: - Actions

    private func applyStatMultiplierCondition() {
        let minValue = Double(statMultiplierMin)
        let maxValue = Double(statMultiplierMax)

        guard minValue != nil || maxValue != nil else { return }

        // 範囲条件として保存（とりあえず最小値のgreaterThanOrEqualで表現）
        if let min = minValue {
            statMultiplierCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            statMultiplierCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }

        statMultiplierMin = ""
        statMultiplierMax = ""
    }

    private func applyMovePowerMultiplierCondition() {
        let minValue = Double(movePowerMultiplierMin)
        let maxValue = Double(movePowerMultiplierMax)

        guard minValue != nil || maxValue != nil else { return }

        if let min = minValue {
            movePowerMultiplierCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            movePowerMultiplierCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }

        movePowerMultiplierMin = ""
        movePowerMultiplierMax = ""
    }

    private func applyProbabilityCondition() {
        let minValue = Double(probabilityMin)
        let maxValue = Double(probabilityMax)

        guard minValue != nil || maxValue != nil else { return }

        if let min = minValue {
            probabilityCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            probabilityCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }

        probabilityMin = ""
        probabilityMax = ""
    }
}
