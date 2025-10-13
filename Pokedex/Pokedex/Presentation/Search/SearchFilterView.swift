//
//  SearchFilterView.swift
//  Pokedex
//
//  フィルター画面（UI改善版）
//

import SwiftUI

struct SearchFilterView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: PokemonListViewModel
    @State private var allAbilities: [AbilityEntity] = []
    @State private var isLoadingAbilities = false
    @State private var allMoves: [MoveEntity] = []
    @State private var isLoadingMoves = false

    // 検索テキスト
    @State private var abilitySearchText = ""
    @State private var moveSearchText = ""

    // 実数値フィルター入力用
    @State private var inputStatType: StatType = .hp
    @State private var inputOperator: ComparisonOperator = .greaterThanOrEqual
    @State private var inputStatValue: String = ""

    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol
    let fetchAllMovesUseCase: FetchAllMovesUseCaseProtocol

    // 全18タイプのリスト
    private let allTypes = [
        "normal", "fire", "water", "grass", "electric", "ice",
        "fighting", "poison", "ground", "flying", "psychic", "bug",
        "rock", "ghost", "dragon", "dark", "steel", "fairy"
    ]

    // 技カテゴリーのリスト（MoveCategory.swiftから取得）
    private let allMoveCategories = MoveCategory.allCategories

    // グリッドレイアウト（3列）
    private let typeGridColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            Form {
                typeFilterSection
                categoryFilterSection
                evolutionFilterSection
                statFilterSection
                abilityFilterSection
                moveFilterSection
            }
            .navigationTitle("フィルター")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                clearButton
                applyButton
            }
            .onAppear {
                loadAbilities()
                loadMoves()
            }
        }
    }

    // MARK: - Type Section (Grid Layout)

    private var typeFilterSection: some View {
        Section {
            // OR/AND切り替え
            Picker("検索モード", selection: $viewModel.typeFilterMode) {
                Text("OR（いずれか）").tag(FilterMode.or)
                Text("AND（全て）").tag(FilterMode.and)
            }
            .pickerStyle(.segmented)

            LazyVGrid(columns: typeGridColumns, spacing: 10) {
                ForEach(allTypes, id: \.self) { typeName in
                    typeGridButton(typeName)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("タイプ")
        } footer: {
            Text(viewModel.typeFilterMode == .or
                 ? "選択したタイプのいずれかを持つポケモンを表示"
                 : "選択したタイプを全て持つポケモンを表示")
        }
    }

    private func typeGridButton(_ typeName: String) -> some View {
        Button {
            toggleTypeSelection(typeName)
        } label: {
            Text(typeJapaneseName(typeName))
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    viewModel.selectedTypes.contains(typeName)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Section (Grid Layout)

    private var categoryFilterSection: some View {
        Section {
            LazyVGrid(columns: typeGridColumns, spacing: 10) {
                ForEach(PokemonCategory.allCases) { category in
                    categoryGridButton(category)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("区分")
        } footer: {
            Text("選択した区分のいずれかに該当するポケモンを表示")
        }
    }

    private func categoryGridButton(_ category: PokemonCategory) -> some View {
        Button {
            toggleCategorySelection(category)
        } label: {
            Text(category.displayName)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    viewModel.selectedCategories.contains(category)
                        ? Color.purple.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Evolution Section

    private var evolutionFilterSection: some View {
        Section {
            Picker("表示する進化段階", selection: $viewModel.evolutionFilterMode) {
                ForEach(EvolutionFilterMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text("進化")
        } footer: {
            switch viewModel.evolutionFilterMode {
            case .all:
                Text("全ての進化段階のポケモンを表示します")
            case .finalOnly:
                Text("最終進化形のポケモンのみを表示します")
            case .evioliteOnly:
                Text("進化のきせきが使用可能なポケモン（進化前・進化途中）のみを表示します")
            }
        }
    }

    // MARK: - Stat Filter Section

    private var statFilterSection: some View {
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
            if !viewModel.statFilterConditions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("設定中の条件")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ForEach(viewModel.statFilterConditions) { condition in
                        statConditionRow(condition)
                    }
                }
            }
        } header: {
            Text("実数値")
        } footer: {
            Text("レベル50、個体値31、努力値252、性格補正1.1での実数値で絞り込みます")
        }
    }

    private func statConditionRow(_ condition: StatFilterCondition) -> some View {
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

    // MARK: - Ability Section (with Search)

    private var abilityFilterSection: some View {
        Section {
            if isLoadingAbilities {
                ProgressView()
            } else {
                // OR/AND切り替え
                Picker("検索モード", selection: $viewModel.abilityFilterMode) {
                    Text("OR（いずれか）").tag(FilterMode.or)
                    Text("AND（全て）").tag(FilterMode.and)
                }
                .pickerStyle(.segmented)

                // 検索バー
                TextField("特性を検索", text: $abilitySearchText)
                    .textFieldStyle(.roundedBorder)

                // 選択済み特性の表示
                if !viewModel.selectedAbilities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(viewModel.selectedAbilities), id: \.self) { abilityName in
                                selectedAbilityChip(abilityName)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 特性リスト
                ForEach(filteredAbilities.prefix(50)) { ability in
                    abilitySelectionButton(ability)
                }
            }
        } header: {
            Text("特性")
        } footer: {
            Text(viewModel.abilityFilterMode == .or
                 ? "選択した特性のいずれかを持つポケモンを表示"
                 : "選択した特性を全て持つポケモンを表示")
        }
    }

    private var filteredAbilities: [AbilityEntity] {
        // 検索テキストが空の場合は候補を表示しない
        if abilitySearchText.isEmpty {
            return []
        }
        // 部分一致で検索（全角/半角を区別しない、日本語名と英語名両方で検索）
        return allAbilities.filter { ability in
            ability.nameJa.range(of: abilitySearchText, options: [.caseInsensitive, .widthInsensitive]) != nil ||
            ability.name.range(of: abilitySearchText, options: [.caseInsensitive, .widthInsensitive]) != nil
        }
    }

    private func abilitySelectionButton(_ ability: AbilityEntity) -> some View {
        Button {
            toggleAbilitySelection(ability.name)
        } label: {
            HStack {
                Text(ability.nameJa)
                Spacer()
                Text(ability.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }

    // MARK: - Move Section (Unified)

    private var moveFilterSection: some View {
        Section {
            if isLoadingMoves {
                ProgressView()
            } else {
                // OR/AND切り替え
                Picker("検索モード", selection: $viewModel.moveFilterMode) {
                    Text("OR（いずれか）").tag(FilterMode.or)
                    Text("AND（全て）").tag(FilterMode.and)
                }
                .pickerStyle(.segmented)

                // 検索バー
                TextField("技を検索", text: $moveSearchText)
                    .textFieldStyle(.roundedBorder)

                // 選択済み技の表示
                if !viewModel.selectedMoves.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("選択中: \(viewModel.selectedMoves.count)件")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(viewModel.selectedMoves) { move in
                                    selectedMoveChip(move)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                // 技リスト
                ForEach(searchFilteredMoves.prefix(50)) { move in
                    moveSelectionButton(move)
                }

                // 技の条件を追加
                NavigationLink(destination: MoveMetadataFilterView(onAdd: { filter in
                    viewModel.moveMetadataFilters.append(filter)
                })) {
                    HStack {
                        Text("技の条件を追加")
                        Spacer()
                        Image(systemName: "plus.circle")
                    }
                }

                // 設定中の条件を表示
                if !viewModel.moveMetadataFilters.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("設定中の条件")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ForEach(Array(viewModel.moveMetadataFilters.enumerated()), id: \.offset) { index, filter in
                            moveMetadataConditionRow(filter: filter, index: index)
                        }
                    }
                }
            }
        } header: {
            Text("技")
        } footer: {
            VStack(alignment: .leading, spacing: 4) {
                if !viewModel.moveMetadataFilters.isEmpty {
                    Text("技の条件: メタデータで絞り込んだ技も含まれます")
                        .font(.caption)
                }
                Text(viewModel.moveFilterMode == .or
                     ? "選択した技のいずれかを覚えられるポケモンを表示"
                     : "選択した技を全て覚えられるポケモンを表示")
                    .font(.caption)
            }
        }
    }

    // カテゴリー + 検索でフィルタリング
    private var searchFilteredMoves: [MoveEntity] {
        // 検索テキストもカテゴリーも空の場合は候補を表示しない
        if moveSearchText.isEmpty && viewModel.selectedMoveCategories.isEmpty {
            return []
        }

        var moves = filteredMoves // カテゴリーフィルター適用済み

        // 検索テキストがある場合は部分一致でフィルタ（全角/半角を区別しない、日本語名と英語名両方で検索）
        if !moveSearchText.isEmpty {
            moves = moves.filter { move in
                move.nameJa.range(of: moveSearchText, options: [.caseInsensitive, .widthInsensitive]) != nil ||
                move.name.range(of: moveSearchText, options: [.caseInsensitive, .widthInsensitive]) != nil
            }
        }

        return moves
    }

    // カテゴリーでフィルタリング
    private var filteredMoves: [MoveEntity] {
        guard !viewModel.selectedMoveCategories.isEmpty else {
            return allMoves
        }
        return allMoves.filter { move in
            MoveCategory.moveMatchesAnyCategory(move.name, categories: viewModel.selectedMoveCategories)
        }
    }

    private func moveSelectionButton(_ move: MoveEntity) -> some View {
        Button {
            toggleMoveSelection(move)
        } label: {
            HStack {
                Text(move.nameJa)
                Spacer()
                Text(move.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .foregroundColor(.primary)
    }

    // MARK: - Helpers

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.blue)
    }

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                viewModel.selectedTypes.removeAll()
                viewModel.selectedCategories.removeAll()
                viewModel.selectedAbilities.removeAll()
                viewModel.selectedMoveCategories.removeAll()
                viewModel.selectedMoves.removeAll()
                viewModel.evolutionFilterMode = .all
                viewModel.statFilterConditions.removeAll()
                viewModel.moveMetadataFilters.removeAll()
                viewModel.searchText = ""
                abilitySearchText = ""
                moveSearchText = ""
                inputStatValue = ""
                viewModel.applyFilters()
            }
        }
    }

    private var applyButton: some ToolbarContent {
        ToolbarItem(placement: .confirmationAction) {
            Button("適用") {
                viewModel.applyFilters()
                dismiss()
            }
        }
    }

    // MARK: - Actions

    private func addStatCondition() {
        guard let value = Int(inputStatValue), value > 0 else { return }

        let condition = StatFilterCondition(
            statType: inputStatType,
            operator: inputOperator,
            value: value
        )

        viewModel.statFilterConditions.append(condition)

        // 入力をリセット
        inputStatValue = ""
    }

    private func removeStatCondition(_ condition: StatFilterCondition) {
        viewModel.statFilterConditions.removeAll { $0.id == condition.id }
    }

    private func toggleTypeSelection(_ typeName: String) {
        if viewModel.selectedTypes.contains(typeName) {
            viewModel.selectedTypes.remove(typeName)
        } else {
            viewModel.selectedTypes.insert(typeName)
        }
    }

    private func toggleAbilitySelection(_ abilityName: String) {
        if viewModel.selectedAbilities.contains(abilityName) {
            viewModel.selectedAbilities.remove(abilityName)
        } else {
            viewModel.selectedAbilities.insert(abilityName)
            // 選択したら検索バーをクリア
            abilitySearchText = ""
        }
    }

    private func toggleCategorySelection(_ category: PokemonCategory) {
        if viewModel.selectedCategories.contains(category) {
            viewModel.selectedCategories.remove(category)
        } else {
            viewModel.selectedCategories.insert(category)
        }
    }

    private func toggleMoveSelection(_ move: MoveEntity) {
        if let index = viewModel.selectedMoves.firstIndex(where: { $0.id == move.id }) {
            viewModel.selectedMoves.remove(at: index)
        } else {
            viewModel.selectedMoves.append(move)
            // 選択したら検索バーをクリア
            moveSearchText = ""
        }
    }

    // MARK: - Data Loading

    private func loadAbilities() {
        guard allAbilities.isEmpty else { return }

        loadData(
            isLoading: $isLoadingAbilities,
            fetch: { try await fetchAllAbilitiesUseCase.execute() },
            onSuccess: { allAbilities = $0 },
            onError: { allAbilities = [] }
        )
    }

    private func loadMoves() {
        guard allMoves.isEmpty else { return }

        loadData(
            isLoading: $isLoadingMoves,
            fetch: { try await fetchAllMovesUseCase.execute(versionGroup: viewModel.selectedVersionGroup.id) },
            onSuccess: { allMoves = $0 },
            onError: { allMoves = [] }
        )
    }

    private func loadData<T>(
        isLoading: Binding<Bool>,
        fetch: @escaping () async throws -> T,
        onSuccess: @escaping (T) -> Void,
        onError: @escaping () -> Void
    ) {
        isLoading.wrappedValue = true
        Task { @MainActor in
            do {
                let result = try await fetch()
                onSuccess(result)
                print("✅ Loaded data successfully, count: \(result as? Array<Any> != nil ? (result as! Array<Any>).count : 0)")
            } catch {
                print("❌ Failed to load data: \(error)")
                onError()
            }
            isLoading.wrappedValue = false
        }
    }

    // MARK: - Selected Item Chips

    private func selectedAbilityChip(_ abilityName: String) -> some View {
        // allAbilitiesから該当する特性を探して日本語名を取得
        let ability = allAbilities.first { $0.name == abilityName }
        let displayName = ability?.nameJa ?? abilityName

        return HStack(spacing: 4) {
            Text(displayName)
                .font(.caption)
            Button {
                toggleAbilitySelection(abilityName)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }

    private func selectedMoveChip(_ move: MoveEntity) -> some View {
        HStack(spacing: 4) {
            Text(move.nameJa)
                .font(.caption)
            Button {
                toggleMoveSelection(move)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.blue.opacity(0.2))
        .cornerRadius(12)
    }

    // MARK: - Type Japanese Name

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

    // MARK: - Move Metadata Filter Helpers

    private func moveMetadataConditionRow(filter: MoveMetadataFilter, index: Int) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("条件\(index + 1)")
                    .font(.caption)
                    .fontWeight(.bold)

                if !filter.types.isEmpty {
                    Text("タイプ: \(filter.types.map { typeJapaneseName($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.damageClasses.isEmpty {
                    Text("分類: \(filter.damageClasses.map { damageClassLabel($0) }.joined(separator: ", "))")
                        .font(.caption)
                }
                if let condition = filter.powerCondition {
                    Text(condition.displayText(label: "威力"))
                        .font(.caption)
                }
                if let condition = filter.accuracyCondition {
                    Text(condition.displayText(label: "命中率"))
                        .font(.caption)
                }
                if let condition = filter.ppCondition {
                    Text(condition.displayText(label: "PP"))
                        .font(.caption)
                }
                if let priority = filter.priority {
                    Text("優先度: \(priority >= 0 ? "+\(priority)" : "\(priority)")")
                        .font(.caption)
                }
                if !filter.targets.isEmpty {
                    Text("対象: \(filter.targets.count)件")
                        .font(.caption)
                }
                if !filter.ailments.isEmpty {
                    Text("状態異常: \(filter.ailments.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.caption)
                }
                if filter.hasDrain || filter.hasHealing {
                    Text("回復: \(healingEffectsText(filter: filter))")
                        .font(.caption)
                }
                if !filter.statChanges.isEmpty {
                    Text("能力変化: \(filter.statChanges.map { $0.rawValue }.joined(separator: ", "))")
                        .font(.caption)
                }
                if !filter.categories.isEmpty {
                    Text("カテゴリー: \(filter.categories.count)件")
                        .font(.caption)
                }
            }

            Spacer()

            Button {
                removeMoveMetadataFilter(at: index)
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }

    private func removeMoveMetadataFilter(at index: Int) {
        viewModel.moveMetadataFilters.remove(at: index)
    }

    private func damageClassLabel(_ damageClass: String) -> String {
        switch damageClass {
        case "physical": return "物理"
        case "special": return "特殊"
        case "status": return "変化"
        default: return damageClass
        }
    }

    private func healingEffectsText(filter: MoveMetadataFilter) -> String {
        var effects: [String] = []
        if filter.hasDrain { effects.append("HP吸収") }
        if filter.hasHealing { effects.append("HP回復") }
        return effects.joined(separator: ", ")
    }
}
