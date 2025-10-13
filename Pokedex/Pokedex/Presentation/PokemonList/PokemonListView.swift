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
                Picker("図鑑", selection: $viewModel.selectedPokedex) {
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
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchText, prompt: "ポケモンを検索")
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
                PokemonDetailView(
                    viewModel: PokemonDetailViewModel(pokemon: pokemon, versionGroup: "scarlet-violet")
                )
            }
            .navigationDestination(for: Int.self) { pokemonId in
                // まずキャッシュを確認
                if let pokemon = pokemonById[pokemonId] {
                    PokemonDetailView(
                        viewModel: PokemonDetailViewModel(pokemon: pokemon, versionGroup: "scarlet-violet")
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
                        .navigationTitle("バージョングループ")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("完了") {
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
            .alert("エラー", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.showError = false
                }
                Button("再試行") {
                    Task {
                        await viewModel.loadPokemons()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "不明なエラーが発生しました")
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
                            Text(viewModel.loadingProgress > 0.1 ? "データ登録中..." : "読み込み中...")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("\(Int(viewModel.loadingProgress * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            // 進捗が0の場合は不定形プログレス
                            ProgressView()
                            Text("読み込み中...")
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
                        Text("技フィルター処理中...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("しばらくお待ちください")
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
                List(viewModel.filteredPokemons) { pokemon in
                    NavigationLink(value: pokemon) {
                        PokemonRow(pokemon: pokemon, selectedPokedex: viewModel.selectedPokedex)
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
            title: "ポケモンが見つかりません",
            message: "検索条件やフィルターを変更してみてください",
            systemImage: "magnifyingglass",
            actionTitle: "フィルターをクリア",
            action: {
                viewModel.clearFilters()
            }
        )
    }

    private var pokemonCountView: some View {
        HStack(spacing: 0) {
            if hasActiveFilters {
                // フィルターがある場合
                Text("絞り込み結果: \(viewModel.filteredPokemons.count)匹")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(" / 全\(viewModel.pokemons.count)匹")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                // フィルターがない場合
                Text("全\(viewModel.filteredPokemons.count)匹")
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
