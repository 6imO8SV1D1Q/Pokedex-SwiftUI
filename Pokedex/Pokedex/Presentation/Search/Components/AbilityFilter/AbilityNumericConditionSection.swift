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
                    Text(L10n.Filter.statMultiplier)
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField(L10n.Filter.min, text: $statMultiplierMin)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: statMultiplierMin) {
                            updateStatMultiplierCondition()
                        }

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField(L10n.Filter.max, text: $statMultiplierMax)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: statMultiplierMax) {
                            updateStatMultiplierCondition()
                        }

                    // クリアボタン
                    if hasStatMultiplierValue() || statMultiplierCondition != nil {
                        Button {
                            clearStatMultiplierCondition()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.medium)
                        }
                    }

                    Spacer()
                }

                // 技威力倍率
                HStack(spacing: 8) {
                    Text(L10n.Filter.movePowerMultiplier)
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField(L10n.Filter.min, text: $movePowerMultiplierMin)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: movePowerMultiplierMin) {
                            updateMovePowerMultiplierCondition()
                        }

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField(L10n.Filter.max, text: $movePowerMultiplierMax)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: movePowerMultiplierMax) {
                            updateMovePowerMultiplierCondition()
                        }

                    // クリアボタン
                    if hasMovePowerMultiplierValue() || movePowerMultiplierCondition != nil {
                        Button {
                            clearMovePowerMultiplierCondition()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.medium)
                        }
                    }

                    Spacer()
                }

                // 発動確率
                HStack(spacing: 8) {
                    Text(L10n.Filter.activationRatePercent)
                        .frame(width: 100, alignment: .leading)
                        .font(.body)

                    TextField(L10n.Filter.min, text: $probabilityMin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: probabilityMin) {
                            updateProbabilityCondition()
                        }

                    Text("〜")
                        .foregroundColor(.secondary)

                    TextField(L10n.Filter.max, text: $probabilityMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: probabilityMax) {
                            updateProbabilityCondition()
                        }

                    // クリアボタン
                    if hasProbabilityValue() || probabilityCondition != nil {
                        Button {
                            clearProbabilityCondition()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                                .imageScale(.medium)
                        }
                    }

                    Spacer()
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.numericConditions)
        } footer: {
            let count = [statMultiplierCondition, movePowerMultiplierCondition, probabilityCondition].compactMap { $0 }.count
            if count == 0 {
                Text(L10n.Filter.numericConditionsDescription)
            } else {
                Text(L10n.Filter.conditionCount(count))
            }
        }
        .onAppear {
            loadConditionsToInputValues()
        }
    }

    // MARK: - Value Check

    private func hasStatMultiplierValue() -> Bool {
        return !statMultiplierMin.isEmpty || !statMultiplierMax.isEmpty
    }

    private func hasMovePowerMultiplierValue() -> Bool {
        return !movePowerMultiplierMin.isEmpty || !movePowerMultiplierMax.isEmpty
    }

    private func hasProbabilityValue() -> Bool {
        return !probabilityMin.isEmpty || !probabilityMax.isEmpty
    }

    // MARK: - Update Conditions

    private func updateStatMultiplierCondition() {
        let minValue = Double(statMultiplierMin)
        let maxValue = Double(statMultiplierMax)

        guard minValue != nil || maxValue != nil else {
            statMultiplierCondition = nil
            return
        }

        // 両方入力されている場合、最小 <= 最大をチェック
        if let min = minValue, let max = maxValue, min > max {
            return
        }

        // 範囲条件として保存（最小値優先）
        if let min = minValue {
            statMultiplierCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            statMultiplierCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }
    }

    private func updateMovePowerMultiplierCondition() {
        let minValue = Double(movePowerMultiplierMin)
        let maxValue = Double(movePowerMultiplierMax)

        guard minValue != nil || maxValue != nil else {
            movePowerMultiplierCondition = nil
            return
        }

        if let min = minValue, let max = maxValue, min > max {
            return
        }

        if let min = minValue {
            movePowerMultiplierCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            movePowerMultiplierCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }
    }

    private func updateProbabilityCondition() {
        let minValue = Double(probabilityMin)
        let maxValue = Double(probabilityMax)

        guard minValue != nil || maxValue != nil else {
            probabilityCondition = nil
            return
        }

        if let min = minValue, let max = maxValue, min > max {
            return
        }

        if let min = minValue {
            probabilityCondition = NumericCondition(value: min, comparisonOperator: .greaterThanOrEqual)
        } else if let max = maxValue {
            probabilityCondition = NumericCondition(value: max, comparisonOperator: .lessThanOrEqual)
        }
    }

    // MARK: - Clear Conditions

    private func clearStatMultiplierCondition() {
        statMultiplierMin = ""
        statMultiplierMax = ""
        statMultiplierCondition = nil
    }

    private func clearMovePowerMultiplierCondition() {
        movePowerMultiplierMin = ""
        movePowerMultiplierMax = ""
        movePowerMultiplierCondition = nil
    }

    private func clearProbabilityCondition() {
        probabilityMin = ""
        probabilityMax = ""
        probabilityCondition = nil
    }

    private func loadConditionsToInputValues() {
        if let condition = statMultiplierCondition {
            if condition.comparisonOperator == .greaterThanOrEqual {
                statMultiplierMin = String(condition.value)
            } else if condition.comparisonOperator == .lessThanOrEqual {
                statMultiplierMax = String(condition.value)
            }
        }
        if let condition = movePowerMultiplierCondition {
            if condition.comparisonOperator == .greaterThanOrEqual {
                movePowerMultiplierMin = String(condition.value)
            } else if condition.comparisonOperator == .lessThanOrEqual {
                movePowerMultiplierMax = String(condition.value)
            }
        }
        if let condition = probabilityCondition {
            if condition.comparisonOperator == .greaterThanOrEqual {
                probabilityMin = String(condition.value)
            } else if condition.comparisonOperator == .lessThanOrEqual {
                probabilityMax = String(condition.value)
            }
        }
    }
}
