//
//  PokemonListView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @State private var showingFilter = false
    @State private var showingSortOptions = false
    @State private var scrollPosition: Int?
    @State private var hasLoaded = false

    init(viewModel: PokemonListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView(message: "ポケモンを読み込んでいます...")
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
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchText, prompt: "ポケモンを検索")
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.applyFilters()
            }
            .toolbar {
                // 表示形式切り替えボタン
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        viewModel.toggleDisplayMode()
                    } label: {
                        Image(systemName: viewModel.displayMode == .list ? "square.grid.2x2" : "list.bullet")
                    }
                }

                // ソートボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSortOptions = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(viewModel.currentSortOption.displayName)
                                .font(.caption)
                        }
                    }
                }

                // フィルターボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilter = true
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
            .sheet(isPresented: $showingFilter) {
                SearchFilterView(
                    viewModel: viewModel,
                    fetchAllAbilitiesUseCase: DIContainer.shared.makeFetchAllAbilitiesUseCase()
                )
            }
            .sheet(isPresented: $showingSortOptions) {
                SortOptionView(
                    currentSortOption: $viewModel.currentSortOption,
                    onSortChange: { option in
                        viewModel.changeSortOption(option)
                    }
                )
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
