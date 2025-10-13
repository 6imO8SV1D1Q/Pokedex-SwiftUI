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
                ailmentSection
                specialEffectSection
                userStatChangeSection
                opponentStatChangeSection
                categorySection
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
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(Array((-7...5).reversed()), id: \.self) { priority in
                    priorityGridButton(priority)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("優先度")
        }
    }

    private var ailmentSection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(Ailment.allCases) { ailment in
                    ailmentGridButton(ailment)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("状態異常")
        }
    }

    private var specialEffectSection: some View {
        Section {
            Toggle("急所率アップ", isOn: $tempFilter.hasHighCritRate)
            Toggle("HP吸収", isOn: $tempFilter.hasDrain)
            Toggle("HP回復", isOn: $tempFilter.hasHealing)
            Toggle("ひるみ", isOn: $tempFilter.hasFlinch)
        } header: {
            Text("特殊効果")
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
                DisclosureGroup(group.name) {
                    LazyVGrid(columns: gridColumns, spacing: 10) {
                        ForEach(group.categories, id: \.id) { category in
                            moveCategoryGridButton(category)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        } header: {
            Text("技カテゴリー")
        } footer: {
            Text("グループを展開して個別にカテゴリーを選択できます。")
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

    private func priorityGridButton(_ priority: Int) -> some View {
        Button {
            if tempFilter.priorities.contains(priority) {
                tempFilter.priorities.remove(priority)
            } else {
                tempFilter.priorities.insert(priority)
            }
        } label: {
            Text(priority >= 0 ? "+\(priority)" : "\(priority)")
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.priorities.contains(priority)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
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

    private func ailmentGridButton(_ ailment: Ailment) -> some View {
        Button {
            if tempFilter.ailments.contains(ailment) {
                tempFilter.ailments.remove(ailment)
            } else {
                tempFilter.ailments.insert(ailment)
            }
        } label: {
            Text(ailment.rawValue)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    tempFilter.ailments.contains(ailment)
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
