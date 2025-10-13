//
//  MoveMetadataFilterView.swift
//  Pokedex
//
//  技の条件フィルター画面
//

import SwiftUI

struct MoveMetadataFilterView: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (MoveMetadataFilter) -> Void

    // 一時的な編集用フィルター
    @State private var tempFilter: MoveMetadataFilter = MoveMetadataFilter()

    // 数値条件入力用
    @State private var inputPowerOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputPowerValue: String = ""
    @State private var inputAccuracyOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputAccuracyValue: String = ""
    @State private var inputPPOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputPPValue: String = ""

    // 優先度入力用
    @State private var selectedPriority: Double = 0

    // 全18タイプのリスト
    private let allTypes = [
        "normal", "fire", "water", "grass", "electric", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    // グリッドレイアウト（3列）
    private let gridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Form {
                typeSection
                damageClassSection
                powerAccuracyPPSection
                prioritySection
                targetSection
                categorySection
                userStatChangeSection
                opponentStatChangeSection
            }
            .navigationTitle("技の条件")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                clearButton
                applyButton
            }
        }
    }

    // MARK: - Sections

    private var typeSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(allTypes, id: \.self) { typeName in
                    moveTypeGridButton(typeName)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("技のタイプ")
        }
    }

    private var damageClassSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                moveDamageClassButton("physical", label: "物理")
                moveDamageClassButton("special", label: "特殊")
                moveDamageClassButton("status", label: "変化")
            }
            .padding(.vertical, 8)
        } header: {
            Text("分類")
        }
    }

    private var powerAccuracyPPSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                // 威力
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("威力")
                            .frame(width: 60, alignment: .leading)
                        Picker("", selection: $inputPowerOperator) {
                            ForEach(ComparisonOperator.allCases) { op in
                                Text(op.rawValue).tag(op)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 60)

                        TextField("値", text: $inputPowerValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)

                        Button {
                            applyPowerCondition()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(inputPowerValue.isEmpty || Int(inputPowerValue) == nil ? .gray : .blue)
                        }
                        .disabled(inputPowerValue.isEmpty || Int(inputPowerValue) == nil)
                    }

                    if let condition = tempFilter.powerCondition {
                        HStack {
                            Text("設定: \(condition.displayText(label: "威力"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("解除") {
                                tempFilter.powerCondition = nil
                            }
                            .font(.caption)
                        }
                    }
                }

                // 命中率
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("命中率")
                            .frame(width: 60, alignment: .leading)
                        Picker("", selection: $inputAccuracyOperator) {
                            ForEach(ComparisonOperator.allCases) { op in
                                Text(op.rawValue).tag(op)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 60)

                        TextField("値", text: $inputAccuracyValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)

                        Button {
                            applyAccuracyCondition()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(inputAccuracyValue.isEmpty || Int(inputAccuracyValue) == nil ? .gray : .blue)
                        }
                        .disabled(inputAccuracyValue.isEmpty || Int(inputAccuracyValue) == nil)
                    }

                    if let condition = tempFilter.accuracyCondition {
                        HStack {
                            Text("設定: \(condition.displayText(label: "命中率"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("解除") {
                                tempFilter.accuracyCondition = nil
                            }
                            .font(.caption)
                        }
                    }
                }

                // PP
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("PP")
                            .frame(width: 60, alignment: .leading)
                        Picker("", selection: $inputPPOperator) {
                            ForEach(ComparisonOperator.allCases) { op in
                                Text(op.rawValue).tag(op)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                        .frame(width: 60)

                        TextField("値", text: $inputPPValue)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)

                        Button {
                            applyPPCondition()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(inputPPValue.isEmpty || Int(inputPPValue) == nil ? .gray : .blue)
                        }
                        .disabled(inputPPValue.isEmpty || Int(inputPPValue) == nil)
                    }

                    if let condition = tempFilter.ppCondition {
                        HStack {
                            Text("設定: \(condition.displayText(label: "PP"))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Spacer()
                            Button("解除") {
                                tempFilter.ppCondition = nil
                            }
                            .font(.caption)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("威力・命中率・PP")
        } footer: {
            Text("条件を設定して絞り込みます。")
        }
    }

    private var prioritySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("優先度:")
                    Spacer()
                    if tempFilter.priority != nil {
                        Text(tempFilter.priority! >= 0 ? "+\(tempFilter.priority!)" : "\(tempFilter.priority!)")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Text("指定なし")
                            .foregroundColor(.secondary)
                    }
                }

                Slider(
                    value: Binding(
                        get: { tempFilter.priority.map(Double.init) ?? 0 },
                        set: { tempFilter.priority = Int($0) }
                    ),
                    in: -7...5,
                    step: 1
                )

                if tempFilter.priority != nil {
                    Button {
                        tempFilter.priority = nil
                        selectedPriority = 0
                    } label: {
                        Text("解除")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                            .background(Color.secondary.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("優先度")
        } footer: {
            Text("スライダーを動かすと即座に優先度が設定されます。")
        }
    }

    private var targetSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                targetGridButton("selected-pokemon", label: "相手単体")
                targetGridButton("user", label: "自分")
                targetGridButton("all-opponents", label: "相手全体")
                targetGridButton("all-other-pokemon", label: "自分以外")
                targetGridButton("user-and-allies", label: "味方全体")
                targetGridButton("all-pokemon", label: "全員")
            }
            .padding(.vertical, 8)
        } header: {
            Text("技の対象")
        }
    }

    private var userStatChangeSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(StatChangeFilter.allCases.filter { $0.statChangeInfo.isUser }) { statChange in
                    statChangeGridButton(statChange)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("自分の能力変化")
        }
    }

    private var opponentStatChangeSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(StatChangeFilter.allCases.filter { !$0.statChangeInfo.isUser }) { statChange in
                    statChangeGridButton(statChange)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("相手の能力変化")
        }
    }

    private var categorySection: some View {
        Section {
            ForEach(0..<MoveCategory.categoryGroups.count, id: \.self) { groupIndex in
                let group = MoveCategory.categoryGroups[groupIndex]
                VStack(alignment: .leading, spacing: 8) {
                    // グループ名
                    Text(group.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, groupIndex > 0 ? 8 : 0)

                    // カテゴリーボタン
                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(group.categories, id: \.id) { category in
                            moveCategoryGridButton(category)
                        }
                    }
                }
            }
        } header: {
            Text("技カテゴリー")
        } footer: {
            Text("各カテゴリーを個別に選択できます。")
        }
    }

    // MARK: - Toolbar

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                tempFilter = MoveMetadataFilter()
                inputPowerValue = ""
                inputAccuracyValue = ""
                inputPPValue = ""
                selectedPriority = 0
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("追加") {
                onAdd(tempFilter)
                dismiss()
            }
            .disabled(tempFilter.isEmpty)
        }
    }

    // MARK: - Helper Methods

    private func moveTypeGridButton(_ typeName: String) -> some View {
        Button {
            if tempFilter.types.contains(typeName) {
                tempFilter.types.remove(typeName)
            } else {
                tempFilter.types.insert(typeName)
            }
        } label: {
            Text(typeJapaneseName(typeName))
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.types.contains(typeName)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func moveDamageClassButton(_ damageClass: String, label: String) -> some View {
        Button {
            if tempFilter.damageClasses.contains(damageClass) {
                tempFilter.damageClasses.remove(damageClass)
            } else {
                tempFilter.damageClasses.insert(damageClass)
            }
        } label: {
            Text(label)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.damageClasses.contains(damageClass)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func applyPowerCondition() {
        guard let value = Int(inputPowerValue) else { return }
        tempFilter.powerCondition = MoveNumericCondition(value: value, operator: inputPowerOperator)
        inputPowerValue = ""
    }

    private func applyAccuracyCondition() {
        guard let value = Int(inputAccuracyValue) else { return }
        tempFilter.accuracyCondition = MoveNumericCondition(value: value, operator: inputAccuracyOperator)
        inputAccuracyValue = ""
    }

    private func applyPPCondition() {
        guard let value = Int(inputPPValue) else { return }
        tempFilter.ppCondition = MoveNumericCondition(value: value, operator: inputPPOperator)
        inputPPValue = ""
    }

    private func targetGridButton(_ target: String, label: String) -> some View {
        Button {
            if tempFilter.targets.contains(target) {
                tempFilter.targets.remove(target)
            } else {
                tempFilter.targets.insert(target)
            }
        } label: {
            Text(label)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.targets.contains(target)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func statChangeGridButton(_ statChange: StatChangeFilter) -> some View {
        Button {
            if tempFilter.statChanges.contains(statChange) {
                tempFilter.statChanges.remove(statChange)
            } else {
                tempFilter.statChanges.insert(statChange)
            }
        } label: {
            Text(statChange.rawValue)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.statChanges.contains(statChange)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func moveCategoryGridButton(_ category: (id: String, name: String)) -> some View {
        Button {
            if tempFilter.categories.contains(category.id) {
                tempFilter.categories.remove(category.id)
            } else {
                tempFilter.categories.insert(category.id)
            }
        } label: {
            Text(category.name)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.categories.contains(category.id)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    private func typeJapaneseName(_ typeName: String) -> String {
        switch typeName {
        case "normal": return "ノーマル"
        case "fire": return "ほのお"
        case "water": return "みず"
        case "grass": return "くさ"
        case "electric": return "でんき"
        case "ice": return "こおり"
        case "fighting": return "かくとう"
        case "poison": return "どく"
        case "ground": return "じめん"
        case "flying": return "ひこう"
        case "psychic": return "エスパー"
        case "bug": return "むし"
        case "rock": return "いわ"
        case "ghost": return "ゴースト"
        case "dragon": return "ドラゴン"
        case "dark": return "あく"
        case "steel": return "はがね"
        case "fairy": return "フェアリー"
        default: return typeName.capitalized
        }
    }
}
