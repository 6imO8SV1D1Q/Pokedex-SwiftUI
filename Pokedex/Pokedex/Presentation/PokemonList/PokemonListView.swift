//
//  PokemonListView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var scrollPosition: Int?
    @State private var hasLoaded = false
    @State private var pokemonById: [Int: Pokemon] = [:] // IDからPokemonへのキャッシュ

    enum ActiveSheet: Identifiable {
        case filter
        case sort
        case versionGroup
        case settings

        var id: Int {
            switch self {
            case .filter: return 0
            case .sort: return 1
            case .versionGroup: return 2
            case .settings: return 3
            }
        }
    }

    @State private var activeSheet: ActiveSheet?

    init(viewModel: PokemonListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 図鑑切り替えSegmented Control
                Picker(L10n.Common.pokedex, selection: $viewModel.selectedPokedex) {
                    ForEach(PokedexType.allCases) { pokedex in
                        Text(localizationManager.displayName(for: pokedex))
                            .tag(pokedex)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color(uiColor: .systemGroupedBackground))
                .onChange(of: viewModel.selectedPokedex) { oldValue, newValue in
                    if oldValue != newValue {
                        viewModel.changePokedex(newValue)
                    }
                }

                // ポケモン件数表示
                if !viewModel.isLoading {
                    pokemonCountView
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                        .background(Color(uiColor: .systemGroupedBackground))
                }

                contentView
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle(L10n.PokemonList.title)
            .searchable(text: $viewModel.searchText, prompt: Text(L10n.PokemonList.searchPrompt))
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.applyFilters()
            }
            .toolbar {
                // 設定ボタン
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        activeSheet = .settings
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }

                // ソートボタン
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .sort
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }

                // フィルターボタン
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        activeSheet = .filter
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .navigationDestination(for: Pokemon.self) { pokemon in
                let allPokemon = viewModel.filteredPokemons
                PokemonDetailView(
                    viewModel: PokemonDetailViewModel(
                        pokemon: pokemon,
                        allPokemon: allPokemon,
                        versionGroup: "scarlet-violet"
                    )
                )
            }
            .navigationDestination(for: Int.self) { pokemonId in
                let allPokemon = viewModel.filteredPokemons
                // まずキャッシュを確認
                if let pokemon = pokemonById[pokemonId] {
                    PokemonDetailView(
                        viewModel: PokemonDetailViewModel(
                            pokemon: pokemon,
                            allPokemon: allPokemon,
                            versionGroup: "scarlet-violet"
                        )
                    )
                } else {
                    // キャッシュにない場合は非同期で取得
                    PokemonLoadingView(pokemonId: pokemonId) { pokemon in
                        pokemonById[pokemonId] = pokemon
                    }
                }
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .filter:
                    SearchFilterView(
                        viewModel: viewModel,
                        fetchAllAbilitiesUseCase: DIContainer.shared.makeFetchAllAbilitiesUseCase(),
                        fetchAllMovesUseCase: DIContainer.shared.makeFetchAllMovesUseCase()
                    )
                case .sort:
                    SortOptionView(
                        currentSortOption: $viewModel.currentSortOption,
                        onSortChange: { option in
                            viewModel.changeSortOption(option)
                        }
                    )
                case .versionGroup:
                    NavigationStack {
                        List {
                            ForEach(viewModel.allVersionGroups) { versionGroup in
                                Button {
                                    viewModel.changeVersionGroup(versionGroup)
                                    activeSheet = nil
                                } label: {
                                    HStack {
                                        Text(versionGroup.displayName)
                                        Spacer()
                                        if viewModel.selectedVersionGroup.id == versionGroup.id {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                        .navigationTitle(L10n.Common.versionGroup)
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(L10n.Common.done) {
                                    activeSheet = nil
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                case .settings:
                    SettingsView()
                }
            }
            .alert(L10n.Common.error, isPresented: $viewModel.showError) {
                Button(L10n.Common.ok) {
                    viewModel.showError = false
                }
                Button("再試行") {
                    Task {
                        await viewModel.loadPokemons()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? L10n.Common.unknownError)
            }
            .onAppear {
                if !hasLoaded {
                    Task {
                        await viewModel.loadPokemons()
                        hasLoaded = true
                    }
                }
            }
        }
    }

    private var contentView: some View {
        Group {
            if viewModel.isLoading {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        if viewModel.loadingProgress >= 0.01 {
                            // 進捗が1%以上の場合はプログレスバー表示
                            ProgressView(value: viewModel.loadingProgress)
                                .progressViewStyle(.linear)
                                .frame(width: 200)
                            Text(viewModel.loadingProgress > 0.1 ? L10n.Message.registeringData : L10n.Message.loading)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text(L10n.Message.percent(Int(viewModel.loadingProgress * 100)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            // 進捗が0の場合は不定形プログレス
                            ProgressView()
                            Text(L10n.Message.loading)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
            } else if viewModel.isFiltering {
                VStack {
                    Spacer()
                    VStack(spacing: 16) {
                        ProgressView()
                        Text(L10n.PokemonList.filteringMoves)
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text(L10n.PokemonList.pleaseWait)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemGroupedBackground))
            } else {
                pokemonList
            }
        }
    }

    private var pokemonList: some View {
        Group {
            if viewModel.filteredPokemons.isEmpty && !viewModel.isLoading && hasLoaded {
                // ロード完了後にポケモンが0の場合のみ表示
                emptyStateView
            } else if !viewModel.filteredPokemons.isEmpty {
                List(viewModel.filteredPokemons) { pokemonWithMatch in
                    NavigationLink(value: pokemonWithMatch.pokemon) {
                        PokemonRow(
                            pokemon: pokemonWithMatch.pokemon,
                            selectedPokedex: viewModel.selectedPokedex,
                            matchInfo: pokemonWithMatch.matchInfo,
                            statFilterConditions: viewModel.statFilterConditions,
                            selectedMoves: viewModel.selectedMoves,
                            moveMetadataFilters: viewModel.moveMetadataFilters
                        )
                    }
                }
                .listStyle(.insetGrouped)
                .scrollContentBackground(.visible)
                .contentMargins(.top, 0, for: .scrollContent)
                .scrollPosition(id: $scrollPosition)
            }
        }
    }

    private var emptyStateView: some View {
        EmptyStateView(
            title: NSLocalizedString("pokemon_list.empty_title", comment: ""),
            message: NSLocalizedString("pokemon_list.empty_message", comment: ""),
            systemImage: "magnifyingglass",
            actionTitle: NSLocalizedString("pokemon_list.clear_filters", comment: ""),
            action: {
                viewModel.clearFilters()
            }
        )
    }

    private var pokemonCountView: some View {
        HStack(spacing: 0) {
            if hasActiveFilters {
                // フィルターがある場合
                Text(L10n.PokemonList.filterResult(viewModel.filteredPokemons.count))
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(L10n.PokemonList.countSeparator + L10n.PokemonList.totalCount(viewModel.pokemons.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // フィルターがない場合
                Text(L10n.PokemonList.totalCount(viewModel.filteredPokemons.count))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    /// フィルターや検索が有効かどうか
    private var hasActiveFilters: Bool {
        !viewModel.searchText.isEmpty ||
        !viewModel.selectedTypes.isEmpty ||
        !viewModel.selectedAbilities.isEmpty ||
        !viewModel.selectedMoves.isEmpty ||
        !viewModel.selectedMoveCategories.isEmpty ||
        !viewModel.selectedCategories.isEmpty ||
        viewModel.evolutionFilterMode != .all ||
        !viewModel.statFilterConditions.isEmpty ||
        !viewModel.moveMetadataFilters.isEmpty
    }
}
