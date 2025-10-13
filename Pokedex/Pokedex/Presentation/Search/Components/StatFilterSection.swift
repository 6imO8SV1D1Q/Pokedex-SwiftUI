//
//  StatFilterSection.swift
//  Pokedex
//
//  実数値フィルターセクション
//

import SwiftUI

struct StatFilterSection: View {
    @Binding var statFilterConditions: [StatFilterCondition]
    @State private var inputStatType: StatType = .hp
    @State private var inputOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputStatValue: String = ""

    var body: some View {
        Section {
            // 条件入力エリア
            VStack(alignment: .leading, spacing: 12) {
                Text("新しい条件を追加")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // ステータス種類
                HStack {
                    Text("ステータス")
                        .frame(width: 80, alignment: .leading)
                    Picker("ステータス", selection: $inputStatType) {
                        ForEach(StatType.allCases) { statType in
                            Text(statType.rawValue).tag(statType)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                }

                // 条件と値
                HStack(spacing: 12) {
                    Text("条件")
                        .frame(width: 80, alignment: .leading)

                    // 比較演算子
                    Picker("条件", selection: $inputOperator) {
                        ForEach(ComparisonOperator.allCases) { op in
                            Text(op.rawValue).tag(op)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .frame(width: 60)

                    // 数値入力
                    TextField("値", text: $inputStatValue)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)

                    // 追加ボタン
                    Button {
                        addStatCondition()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(inputStatValue.isEmpty || Int(inputStatValue) == nil ? .gray : .blue)
                            .imageScale(.large)
                    }
                    .disabled(inputStatValue.isEmpty || Int(inputStatValue) == nil)
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
            Text("実数値")
        } footer: {
            Text("レベル50、個体値31、努力値252、性格補正1.1での実数値で絞り込みます")
        }
    }

    private func addStatCondition() {
        guard let value = Int(inputStatValue), value > 0 else { return }

        let condition = StatFilterCondition(
            statType: inputStatType,
            operator: inputOperator,
            value: value
        )

        statFilterConditions.append(condition)
        inputStatValue = ""
    }

    private func removeStatCondition(_ condition: StatFilterCondition) {
        statFilterConditions.removeAll { $0.id == condition.id }
    }
}
