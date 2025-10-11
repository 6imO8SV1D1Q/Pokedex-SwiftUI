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
    @State private var allAbilities: [String] = []
    @State private var isLoadingAbilities = false
    @State private var allMoves: [MoveEntity] = []
    @State private var isLoadingMoves = false

    // 検索テキスト
    @State private var abilitySearchText = ""
    @State private var moveSearchText = ""

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
                abilityFilterSection
                moveCategoryFilterSection
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
        Section("タイプ") {
            LazyVGrid(columns: typeGridColumns, spacing: 10) {
                ForEach(allTypes, id: \.self) { typeName in
                    typeGridButton(typeName)
                }
            }
            .padding(.vertical, 8)
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

    // MARK: - Ability Section (with Search)

    private var abilityFilterSection: some View {
        Section {
            if isLoadingAbilities {
                ProgressView()
            } else {
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
                ForEach(filteredAbilities.prefix(50), id: \.self) { abilityName in
                    abilitySelectionButton(abilityName)
                }
            }
        } header: {
            Text("特性")
        }
    }

    private var filteredAbilities: [String] {
        // 検索テキストが空の場合は候補を表示しない
        if abilitySearchText.isEmpty {
            return []
        }
        // 前方一致で検索
        return allAbilities.filter { ability in
            ability.lowercased().hasPrefix(abilitySearchText.lowercased())
        }
    }

    private func abilitySelectionButton(_ abilityName: String) -> some View {
        Button {
            toggleAbilitySelection(abilityName)
        } label: {
            HStack {
                Text(abilityName.capitalized)
                Spacer()
            }
        }
        .foregroundColor(.primary)
    }

    // MARK: - Move Category Section

    private var moveCategoryFilterSection: some View {
        Section {
            LazyVGrid(columns: typeGridColumns, spacing: 10) {
                ForEach(allMoveCategories, id: \.id) { category in
                    moveCategoryGridButton(category)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("技カテゴリー")
        }
    }

    private func moveCategoryGridButton(_ category: (id: String, name: String)) -> some View {
        Button {
            toggleMoveCategorySelection(category.id)
        } label: {
            Text(category.name)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(
                    viewModel.selectedMoveCategories.contains(category.id)
                        ? Color.blue.opacity(0.2)
                        : Color.secondary.opacity(0.1)
                )
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Move Section (with Search)

    private var moveFilterSection: some View {
        Section {
            if !isMoveFilterEnabled {
                Text("技フィルターはバージョングループを選択した場合のみ利用可能です。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else if isLoadingMoves {
                ProgressView()
            } else {
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
            }
        } header: {
            Text("技")
        }
    }

    // カテゴリー + 検索でフィルタリング
    private var searchFilteredMoves: [MoveEntity] {
        // 検索テキストもカテゴリーも空の場合は候補を表示しない
        if moveSearchText.isEmpty && viewModel.selectedMoveCategories.isEmpty {
            return []
        }

        var moves = filteredMoves // カテゴリーフィルター適用済み

        // 検索テキストがある場合は前方一致でフィルタ
        if !moveSearchText.isEmpty {
            moves = moves.filter { move in
                move.name.lowercased().hasPrefix(moveSearchText.lowercased())
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
                Text(move.name.capitalized)
                Spacer()
            }
        }
        .foregroundColor(.primary)
    }

    // MARK: - Helpers

    private var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.blue)
    }

    private var isMoveFilterEnabled: Bool {
        viewModel.selectedVersionGroup.id != "national"
    }

    private var clearButton: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("クリア") {
                viewModel.selectedTypes.removeAll()
                viewModel.selectedAbilities.removeAll()
                viewModel.selectedMoveCategories.removeAll()
                viewModel.selectedMoves.removeAll()
                viewModel.searchText = ""
                abilitySearchText = ""
                moveSearchText = ""
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

    private func toggleMoveCategorySelection(_ categoryId: String) {
        if viewModel.selectedMoveCategories.contains(categoryId) {
            viewModel.selectedMoveCategories.remove(categoryId)
        } else {
            viewModel.selectedMoveCategories.insert(categoryId)
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
        guard isMoveFilterEnabled else { return }

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
        Task {
            do {
                let result = try await fetch()
                onSuccess(result)
            } catch {
                onError()
            }
            isLoading.wrappedValue = false
        }
    }

    // MARK: - Selected Item Chips

    private func selectedAbilityChip(_ abilityName: String) -> some View {
        HStack(spacing: 4) {
            Text(abilityName.capitalized)
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
            Text(move.name.capitalized)
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
}
