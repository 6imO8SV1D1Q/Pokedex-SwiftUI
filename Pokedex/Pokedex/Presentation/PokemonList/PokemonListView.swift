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

                // フィルターボタン
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                SearchFilterView(viewModel: viewModel)
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
            .task {
                await viewModel.loadPokemons()
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
            }
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(
                viewModel: PokemonDetailViewModel(pokemon: pokemon)
            )
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
            }
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(
                viewModel: PokemonDetailViewModel(pokemon: pokemon)
            )
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
