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

    @State private var inputPowerOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputPowerValue: String = ""
    @State private var inputAccuracyOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputAccuracyValue: String = ""
    @State private var inputPPOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputPPValue: String = ""

    var body: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // 威力
                numericConditionRow(
                    label: "威力",
                    operator: $inputPowerOperator,
                    value: $inputPowerValue,
                    currentCondition: powerCondition,
                    onApply: applyPowerCondition,
                    onClear: { powerCondition = nil }
                )

                // 命中率
                numericConditionRow(
                    label: "命中率",
                    operator: $inputAccuracyOperator,
                    value: $inputAccuracyValue,
                    currentCondition: accuracyCondition,
                    onApply: applyAccuracyCondition,
                    onClear: { accuracyCondition = nil }
                )

                // PP
                numericConditionRow(
                    label: "PP",
                    operator: $inputPPOperator,
                    value: $inputPPValue,
                    currentCondition: ppCondition,
                    onApply: applyPPCondition,
                    onClear: { ppCondition = nil }
                )
            }
            .padding(.vertical, 8)
        } header: {
            Text("威力・命中率・PP")
        } footer: {
            Text("条件を設定して絞り込みます。")
        }
    }

    private func numericConditionRow(
        label: String,
        operator operatorBinding: Binding<ComparisonOperator>,
        value: Binding<String>,
        currentCondition: MoveNumericCondition?,
        onApply: @escaping () -> Void,
        onClear: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(label)
                    .frame(width: 60, alignment: .leading)
                Picker("", selection: operatorBinding) {
                    ForEach(ComparisonOperator.allCases) { op in
                        Text(op.rawValue).tag(op)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .frame(width: 60)

                TextField("値", text: value)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 80)

                Button {
                    onApply()
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(value.wrappedValue.isEmpty || Int(value.wrappedValue) == nil ? .gray : .blue)
                }
                .disabled(value.wrappedValue.isEmpty || Int(value.wrappedValue) == nil)
            }

            if let condition = currentCondition {
                HStack {
                    Text("設定: \(condition.displayText(label: label))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("解除") {
                        onClear()
                    }
                    .font(.caption)
                }
            }
        }
    }

    private func applyPowerCondition() {
        guard let value = Int(inputPowerValue) else { return }
        powerCondition = MoveNumericCondition(value: value, operator: inputPowerOperator)
        inputPowerValue = ""
    }

    private func applyAccuracyCondition() {
        guard let value = Int(inputAccuracyValue) else { return }
        accuracyCondition = MoveNumericCondition(value: value, operator: inputAccuracyOperator)
        inputAccuracyValue = ""
    }

    private func applyPPCondition() {
        guard let value = Int(inputPPValue) else { return }
        ppCondition = MoveNumericCondition(value: value, operator: inputPPOperator)
        inputPPValue = ""
    }
}
