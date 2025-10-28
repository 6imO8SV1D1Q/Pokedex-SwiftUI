//
//  RivalSelectionView.swift
//  Pokedex
//
//  Created on 2025-10-26.
//

import SwiftUI

/// ライバルポケモン選択ビュー（フィルター機能付き）
struct RivalSelectionView: View {
    @Binding var selectedRivals: Set<Int>
    let allPokemon: [PokemonWithMatchInfo]
    let currentPokemonId: Int  // 現在表示中のポケモンID（除外用）

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localizationManager: LocalizationManager

    // フィルター条件
    @State private var selectedTypes: Set<String> = []
    @State private var typeFilterMode: FilterMode = .or
    @State private var selectedCategories: Set<PokemonCategory> = []
    @State private var evolutionFilterMode: EvolutionFilterMode = .all
    @State private var statFilterConditions: [StatFilterCondition] = []
    @State private var selectedAbilities: Set<String> = []
    @State private var abilityMetadataFilters: [AbilityMetadataFilter] = []
    @State private var abilityFilterMode: FilterMode = .or
    @State private var selectedMovesEntities: [MoveEntity] = []
    @State private var selectedMoveCategories: Set<String> = []
    @State private var moveMetadataFilters: [MoveMetadataFilter] = []
    @State private var moveFilterMode: FilterMode = .or

    /// 選択された技の名前セット（フィルタリング用）
    private var selectedMoveNames: Set<String> {
        Set(selectedMovesEntities.map { $0.name })
    }

    // データ読み込み用
    @State private var allAbilities: [AbilityEntity] = []
    @State private var isLoadingAbilities = false
    @State private var allMoves: [MoveEntity] = []
    @State private var isLoadingMoves = false

    // 絞り込み実行フラグ
    @State private var shouldShowResults = false

    // UseCases
    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol
    let fetchAllMovesUseCase: FetchAllMovesUseCaseProtocol

    /// 絞り込まれたポケモン一覧
    private var filteredPokemon: [PokemonWithMatchInfo] {
        var result = allPokemon

        // タイプでフィルター
        if !selectedTypes.isEmpty {
            result = result.filter { pokemonWithMatch in
                let pokemonTypes = Set(pokemonWithMatch.pokemon.types.map { $0.name })
                switch typeFilterMode {
                case .or:
                    return !pokemonTypes.isDisjoint(with: selectedTypes)
                case .and:
                    return selectedTypes.isSubset(of: pokemonTypes)
                }
            }
        }

        // カテゴリーでフィルター
        if !selectedCategories.isEmpty {
            result = result.filter { pokemonWithMatch in
                guard let categoryString = pokemonWithMatch.pokemon.category,
                      let category = PokemonCategory(rawValue: categoryString) else { return false }
                return selectedCategories.contains(category)
            }
        }

        // 進化段階でフィルター
        switch evolutionFilterMode {
        case .all:
            break
        case .finalOnly:
            result = result.filter { pokemonWithMatch in
                pokemonWithMatch.pokemon.evolutionChain?.isFinalEvolution ?? false
            }
        case .evioliteOnly:
            result = result.filter { pokemonWithMatch in
                pokemonWithMatch.pokemon.evolutionChain?.canUseEviolite ?? false
            }
        }

        // 種族値でフィルター
        if !statFilterConditions.isEmpty {
            result = result.filter { pokemonWithMatch in
                let pokemon = pokemonWithMatch.pokemon
                return statFilterConditions.allSatisfy { condition in
                    let statValue: Int

                    if condition.statType == .total {
                        // 種族値合計
                        statValue = pokemon.stats.reduce(0) { $0 + $1.baseStat }
                    } else {
                        // ステータス名を取得
                        let statName: String
                        switch condition.statType {
                        case .hp: statName = "hp"
                        case .attack: statName = "attack"
                        case .defense: statName = "defense"
                        case .specialAttack: statName = "special-attack"
                        case .specialDefense: statName = "special-defense"
                        case .speed: statName = "speed"
                        case .total: statName = "" // 上で処理済み
                        }

                        // 該当するステータスを検索
                        guard let stat = pokemon.stats.first(where: { $0.name == statName }) else {
                            return false
                        }

                        statValue = stat.baseStat
                    }

                    return condition.matches(statValue)
                }
            }
        }

        // 特性でフィルター
        if !selectedAbilities.isEmpty {
            result = result.filter { pokemonWithMatch in
                let pokemonAbilities = Set(pokemonWithMatch.pokemon.abilities.map { $0.name })
                return !pokemonAbilities.isDisjoint(with: selectedAbilities)
            }
        }

        // 技でフィルター
        if !selectedMoveNames.isEmpty {
            result = result.filter { pokemonWithMatch in
                let pokemonMoves = Set(pokemonWithMatch.pokemon.moves.map { $0.name })
                return !pokemonMoves.isDisjoint(with: selectedMoveNames)
            }
        }

        // 現在表示中のポケモンを除外
        let beforeCount = result.count
        result = result.filter { $0.id != currentPokemonId }
        print("🎯 [Rival Selection] Excluded current pokemon (ID: \(currentPokemonId)): \(beforeCount) -> \(result.count)")

        return result
    }

    @ViewBuilder
    private var searchButtonView: some View {
        if hasActiveFilters {
            Button {
                shouldShowResults = true
                // 絞り込み結果の全ポケモンを選択状態にする
                selectedRivals = Set(filteredPokemon.map { $0.id })
            } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text(L10n.PokemonDetail.searchButton)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    @ViewBuilder
    private var resultsView: some View {
        if shouldShowResults {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(L10n.PokemonDetail.filterResultsCount(filteredPokemon.count))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(filteredPokemon) { pokemonWithMatch in
                            spriteButton(for: pokemonWithMatch)
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func spriteButton(for pokemonWithMatch: PokemonWithMatchInfo) -> some View {
        Button {
            if selectedRivals.contains(pokemonWithMatch.id) {
                selectedRivals.remove(pokemonWithMatch.id)
            } else {
                selectedRivals.insert(pokemonWithMatch.id)
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                // スプライト
                AsyncImage(url: URL(string: pokemonWithMatch.pokemon.displayImageURL ?? "")) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .empty:
                        ProgressView()
                    case .failure:
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 70, height: 70)
                .background(Color(.systemGray6))
                .clipShape(Circle())

                // 選択チェックマーク
                if selectedRivals.contains(pokemonWithMatch.id) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .background(Circle().fill(Color.white))
                        .offset(x: 4, y: -4)
                }
            }
        }
    }

    private var filterFormView: some View {
        Form {
            basicFiltersView
            abilityAndMoveFiltersView
        }
        .onAppear {
            loadAbilities()
            loadMoves()
        }
    }

    @ViewBuilder
    private var basicFiltersView: some View {
        TypeFilterSection(
            selectedTypes: $selectedTypes,
            filterMode: $typeFilterMode
        )

        CategoryFilterSection(
            selectedCategories: $selectedCategories
        )

        EvolutionFilterSection(
            evolutionFilterMode: $evolutionFilterMode
        )

        StatFilterSection(
            statFilterConditions: $statFilterConditions
        )
    }

    @ViewBuilder
    private var abilityAndMoveFiltersView: some View {
        AbilityFilterSection(
            selectedAbilities: $selectedAbilities,
            abilityMetadataFilters: $abilityMetadataFilters,
            filterMode: $abilityFilterMode,
            allAbilities: allAbilities,
            isLoading: isLoadingAbilities
        )

        MoveFilterSection(
            selectedMoves: $selectedMovesEntities,
            selectedMoveCategories: $selectedMoveCategories,
            moveMetadataFilters: $moveMetadataFilters,
            filterMode: $moveFilterMode,
            allMoves: allMoves,
            isLoading: isLoadingMoves
        )
    }

    private func loadAbilities() {
        guard allAbilities.isEmpty && !isLoadingAbilities else { return }
        isLoadingAbilities = true
        Task {
            do {
                let abilities = try await fetchAllAbilitiesUseCase.execute()
                await MainActor.run {
                    self.allAbilities = abilities
                    self.isLoadingAbilities = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingAbilities = false
                }
            }
        }
    }

    private func loadMoves() {
        guard allMoves.isEmpty && !isLoadingMoves else { return }
        isLoadingMoves = true
        Task {
            do {
                let moves = try await fetchAllMovesUseCase.execute(versionGroup: "scarlet-violet")
                await MainActor.run {
                    self.allMoves = moves
                    self.isLoadingMoves = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingMoves = false
                }
            }
        }
    }

    var body: some View {
        NavigationStack {
            contentView
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(L10n.Common.done) {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .navigationBarLeading) {
                        clearMenuButton
                    }
                }
        }
    }

    /// フィルター条件のハッシュ値（変更検知用）
    private var filterHash: Int {
        var hasher = Hasher()
        hasher.combine(selectedTypes)
        hasher.combine(typeFilterMode)
        hasher.combine(selectedCategories)
        hasher.combine(evolutionFilterMode)
        hasher.combine(statFilterConditions.count)
        hasher.combine(selectedAbilities)
        hasher.combine(abilityMetadataFilters.count)
        hasher.combine(selectedMoveNames)
        hasher.combine(selectedMoveCategories)
        hasher.combine(moveMetadataFilters.count)
        return hasher.finalize()
    }

    @ViewBuilder
    private var contentView: some View {
        VStack(spacing: 0) {
            filterFormView
            searchButtonView
            resultsView
        }
        .navigationTitle(L10n.PokemonDetail.rivalSelection)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: filterHash) { _, _ in
            shouldShowResults = false
        }
    }

    @ViewBuilder
    private var clearMenuButton: some View {
        Menu {
            if !selectedRivals.isEmpty {
                Button(L10n.PokemonDetail.clearSelection) {
                    selectedRivals.removeAll()
                }
            }
            if hasActiveFilters {
                Button(L10n.PokemonDetail.clearFilter) {
                    clearFilters()
                }
            }
        } label: {
            Text(L10n.PokemonDetail.clearButton)
        }
        .disabled(selectedRivals.isEmpty && !hasActiveFilters)
    }

    /// フィルターが有効かどうか
    private var hasActiveFilters: Bool {
        !selectedTypes.isEmpty ||
        !selectedCategories.isEmpty ||
        evolutionFilterMode != .all ||
        !statFilterConditions.isEmpty ||
        !selectedAbilities.isEmpty ||
        !abilityMetadataFilters.isEmpty ||
        !selectedMovesEntities.isEmpty ||
        !selectedMoveCategories.isEmpty ||
        !moveMetadataFilters.isEmpty
    }

    /// フィルターをクリア
    private func clearFilters() {
        selectedTypes.removeAll()
        selectedCategories.removeAll()
        evolutionFilterMode = .all
        statFilterConditions.removeAll()
        selectedAbilities.removeAll()
        abilityMetadataFilters.removeAll()
        selectedMovesEntities.removeAll()
        selectedMoveCategories.removeAll()
        moveMetadataFilters.removeAll()
        shouldShowResults = false
    }
}
