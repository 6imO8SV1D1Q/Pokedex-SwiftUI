//
//  MoveNumericConditionSection.swift
//  Pokedex
//
//  技の数値条件（威力・命中率・PP）入力セクション
//

import SwiftUI

struct MoveNumericConditionSection: View {
    @Binding var powerCondition: MoveNumericCondition?
    @Binding var accuracyCondition: MoveNumericCondition?
    @Binding var ppCondition: MoveNumericCondition?

    @State private var powerMin: String = ""
    @State private var powerMax: String = ""
    @State private var accuracyMin: String = ""
    @State private var accuracyMax: String = ""
    @State private var ppMin: String = ""
    @State private var ppMax: String = ""

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                // 威力
                rangeConditionRow(
                    label: NSLocalizedString("stat.power", comment: ""),
                    minValue: $powerMin,
                    maxValue: $powerMax,
                    onUpdate: updatePowerCondition,
                    onClear: clearPowerCondition,
                    hasCondition: powerCondition != nil
                )

                // 命中率
                rangeConditionRow(
                    label: NSLocalizedString("stat.accuracy", comment: ""),
                    minValue: $accuracyMin,
                    maxValue: $accuracyMax,
                    onUpdate: updateAccuracyCondition,
                    onClear: clearAccuracyCondition,
                    hasCondition: accuracyCondition != nil
                )

                // PP
                rangeConditionRow(
                    label: NSLocalizedString("stat.pp", comment: ""),
                    minValue: $ppMin,
                    maxValue: $ppMax,
                    onUpdate: updatePPCondition,
                    onClear: clearPPCondition,
                    hasCondition: ppCondition != nil
                )
            }
            .padding(.vertical, 8)
        } header: {
            Text(L10n.Filter.powerAccuracyPP)
        } footer: {
            let count = [powerCondition, accuracyCondition, ppCondition].compactMap { $0 }.count
            if count == 0 {
                Text(L10n.Filter.setConditionsDescription)
            } else {
                Text(L10n.Filter.conditionCount(count))
            }
        }
        .onAppear {
            loadConditionsToInputValues()
        }
    }

    private func rangeConditionRow(
        label: String,
        minValue: Binding<String>,
        maxValue: Binding<String>,
        onUpdate: @escaping () -> Void,
        onClear: @escaping () -> Void,
        hasCondition: Bool
    ) -> some View {
        HStack(spacing: 8) {
            Text(label)
                .frame(width: 60, alignment: .leading)
                .font(.body)

            TextField(L10n.Filter.min, text: minValue)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .onChange(of: minValue.wrappedValue) {
                    onUpdate()
                }

            Text("〜")
                .foregroundColor(.secondary)

            TextField(L10n.Filter.max, text: maxValue)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .onChange(of: maxValue.wrappedValue) {
                    onUpdate()
                }

            // クリアボタン（値が入力されているか条件が設定されている場合に表示）
            if !minValue.wrappedValue.isEmpty || !maxValue.wrappedValue.isEmpty || hasCondition {
                Button {
                    onClear()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.medium)
                }
            }

            Spacer()
        }
    }

    private func updatePowerCondition() {
        let minValue = Int(powerMin)
        let maxValue = Int(powerMax)

        guard minValue != nil || maxValue != nil else {
            powerCondition = nil
            return
        }

        // 両方入力されている場合、最小 <= 最大をチェック
        if let min = minValue, let max = maxValue, min > max {
            return
        }

        // 範囲条件として保存（最小値優先）
        if let min = minValue {
            powerCondition = MoveNumericCondition(value: min, operator: .greaterThanOrEqual)
        } else if let max = maxValue {
            powerCondition = MoveNumericCondition(value: max, operator: .lessThanOrEqual)
        }
    }

    private func clearPowerCondition() {
        powerMin = ""
        powerMax = ""
        powerCondition = nil
    }

    private func updateAccuracyCondition() {
        let minValue = Int(accuracyMin)
        let maxValue = Int(accuracyMax)

        guard minValue != nil || maxValue != nil else {
            accuracyCondition = nil
            return
        }

        if let min = minValue, let max = maxValue, min > max {
            return
        }

        if let min = minValue {
            accuracyCondition = MoveNumericCondition(value: min, operator: .greaterThanOrEqual)
        } else if let max = maxValue {
            accuracyCondition = MoveNumericCondition(value: max, operator: .lessThanOrEqual)
        }
    }

    private func clearAccuracyCondition() {
        accuracyMin = ""
        accuracyMax = ""
        accuracyCondition = nil
    }

    private func updatePPCondition() {
        let minValue = Int(ppMin)
        let maxValue = Int(ppMax)

        guard minValue != nil || maxValue != nil else {
            ppCondition = nil
            return
        }

        if let min = minValue, let max = maxValue, min > max {
            return
        }

        if let min = minValue {
            ppCondition = MoveNumericCondition(value: min, operator: .greaterThanOrEqual)
        } else if let max = maxValue {
            ppCondition = MoveNumericCondition(value: max, operator: .lessThanOrEqual)
        }
    }

    private func clearPPCondition() {
        ppMin = ""
        ppMax = ""
        ppCondition = nil
    }

    private func loadConditionsToInputValues() {
        if let condition = powerCondition {
            if condition.`operator` == .greaterThanOrEqual {
                powerMin = String(condition.value)
            } else if condition.`operator` == .lessThanOrEqual {
                powerMax = String(condition.value)
            }
        }
        if let condition = accuracyCondition {
            if condition.`operator` == .greaterThanOrEqual {
                accuracyMin = String(condition.value)
            } else if condition.`operator` == .lessThanOrEqual {
                accuracyMax = String(condition.value)
            }
        }
        if let condition = ppCondition {
            if condition.`operator` == .greaterThanOrEqual {
                ppMin = String(condition.value)
            } else if condition.`operator` == .lessThanOrEqual {
                ppMax = String(condition.value)
            }
        }
    }
}
