//
//  PokemonListView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @State private var scrollPosition: Int?
    @State private var hasLoaded = false
    @State private var pokemonById: [Int: Pokemon] = [:] // IDからPokemonへのキャッシュ

    enum ActiveSheet: Identifiable {
        case filter
        case sort
        case versionGroup

        var id: Int {
            switch self {
            case .filter: return 0
            case .sort: return 1
            case .versionGroup: return 2
            }
        }
    }

    @State private var activeSheet: ActiveSheet?

    init(viewModel: PokemonListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            contentView
                .navigationTitle("Pokédex")
                .searchable(text: $viewModel.searchText, prompt: "ポケモンを検索")
                .onChange(of: viewModel.searchText) { _, _ in
                    viewModel.applyFilters()
                }
                .toolbar {
                // バージョングループセレクター
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        activeSheet = .versionGroup
                    } label: {
                        Image(systemName: "globe")
                    }
                }

                // 表示形式切り替え
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.toggleDisplayMode()
                    } label: {
                        Image(systemName: viewModel.displayMode == .list ? "square.grid.2x2" : "list.bullet")
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
                    viewModel: PokemonDetailViewModel(pokemon: pokemon)
                )
            }
            .navigationDestination(for: Int.self) { pokemonId in
                // まずキャッシュを確認
                if let pokemon = pokemonById[pokemonId] {
                    PokemonDetailView(
                        viewModel: PokemonDetailViewModel(pokemon: pokemon)
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
                        ProgressView(value: viewModel.loadingProgress)
                            .progressViewStyle(.linear)
                            .frame(width: 200)
                        Text("読み込み中...")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(Int(viewModel.loadingProgress * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
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
            } else {
                // 表示形式によって切り替え
                switch viewModel.displayMode {
                case .list:
                    pokemonList
                case .grid:
                    pokemonGrid
                }
            }
        }
    }

    private var pokemonList: some View {
        Group {
            if viewModel.filteredPokemons.isEmpty {
                emptyStateView
            } else {
                List(viewModel.filteredPokemons) { pokemon in
                    NavigationLink(value: pokemon) {
                        PokemonRow(pokemon: pokemon)
                    }
                }
                .scrollPosition(id: $scrollPosition)
            }
        }
    }

    private var pokemonGrid: some View {
        Group {
            if viewModel.filteredPokemons.isEmpty {
                emptyStateView
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(.flexible()), count: DesignConstants.Grid.columns),
                        spacing: DesignConstants.Grid.spacing
                    ) {
                        ForEach(viewModel.filteredPokemons) { pokemon in
                            NavigationLink(value: pokemon) {
                                PokemonGridItem(pokemon: pokemon)
                            }
                            .buttonStyle(GridItemButtonStyle())
                        }
                    }
                    .padding(DesignConstants.Spacing.medium)
                }
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
}
