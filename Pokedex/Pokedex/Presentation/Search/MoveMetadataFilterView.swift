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

    // 範囲入力用
    @State private var inputPowerMin: String = ""
    @State private var inputPowerMax: String = ""
    @State private var inputAccuracyMin: String = ""
    @State private var inputAccuracyMax: String = ""
    @State private var inputPPMin: String = ""
    @State private var inputPPMax: String = ""

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
            VStack(alignment: .leading, spacing: 12) {
                // 威力
                HStack {
                    Text("威力")
                        .frame(width: 60, alignment: .leading)
                    TextField("最小", text: $inputPowerMin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("〜")
                    TextField("最大", text: $inputPowerMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        applyPowerRange()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                if tempFilter.powerRange != nil {
                    HStack {
                        Text("設定: \(tempFilter.powerRange!.lowerBound)〜\(tempFilter.powerRange!.upperBound)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("解除") {
                            tempFilter.powerRange = nil
                        }
                        .font(.caption)
                    }
                }

                // 命中率
                HStack {
                    Text("命中率")
                        .frame(width: 60, alignment: .leading)
                    TextField("最小", text: $inputAccuracyMin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("〜")
                    TextField("最大", text: $inputAccuracyMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        applyAccuracyRange()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                if tempFilter.accuracyRange != nil {
                    HStack {
                        Text("設定: \(tempFilter.accuracyRange!.lowerBound)〜\(tempFilter.accuracyRange!.upperBound)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("解除") {
                            tempFilter.accuracyRange = nil
                        }
                        .font(.caption)
                    }
                }

                // PP
                HStack {
                    Text("PP")
                        .frame(width: 60, alignment: .leading)
                    TextField("最小", text: $inputPPMin)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Text("〜")
                    TextField("最大", text: $inputPPMax)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Button {
                        applyPPRange()
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                    }
                }
                if tempFilter.ppRange != nil {
                    HStack {
                        Text("設定: \(tempFilter.ppRange!.lowerBound)〜\(tempFilter.ppRange!.upperBound)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("解除") {
                            tempFilter.ppRange = nil
                        }
                        .font(.caption)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("威力・命中率・PP")
        } footer: {
            Text("範囲で絞り込みます。両方入力してチェックボタンを押してください。")
        }
    }

    private var prioritySection: some View {
        Section {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(Array(-7...5), id: \.self) { priority in
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
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(0..<MoveCategory.categoryGroups.count, id: \.self) { groupIndex in
                    let group = MoveCategory.categoryGroups[groupIndex]
                    categoryGroupButton(group: group, index: groupIndex)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("技カテゴリーグループ")
        } footer: {
            Text("グループ全体を選択できます。選択されたグループに属するいずれかの技を持つポケモンを表示します。")
        }
    }

    // MARK: - Toolbar

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                tempFilter = MoveMetadataFilter()
                inputPowerMin = ""
                inputPowerMax = ""
                inputAccuracyMin = ""
                inputAccuracyMax = ""
                inputPPMin = ""
                inputPPMax = ""
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

    private func applyPowerRange() {
        guard let min = Int(inputPowerMin), let max = Int(inputPowerMax), min <= max else { return }
        tempFilter.powerRange = min...max
        inputPowerMin = ""
        inputPowerMax = ""
    }

    private func applyAccuracyRange() {
        guard let min = Int(inputAccuracyMin), let max = Int(inputAccuracyMax), min <= max else { return }
        tempFilter.accuracyRange = min...max
        inputAccuracyMin = ""
        inputAccuracyMax = ""
    }

    private func applyPPRange() {
        guard let min = Int(inputPPMin), let max = Int(inputPPMax), min <= max else { return }
        tempFilter.ppRange = min...max
        inputPPMin = ""
        inputPPMax = ""
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

    private func categoryGroupButton(group: MoveCategory.CategoryGroup, index: Int) -> some View {
        let groupCategoryIds = Set(group.categories.map { $0.id })
        let isSelected = !groupCategoryIds.isDisjoint(with: tempFilter.categories)

        return Button {
            if isSelected {
                // グループ内の全カテゴリーを削除
                tempFilter.categories.subtract(groupCategoryIds)
            } else {
                // グループ内の全カテゴリーを追加
                tempFilter.categories.formUnion(groupCategoryIds)
            }
        } label: {
            Text(group.name)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    isSelected
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
