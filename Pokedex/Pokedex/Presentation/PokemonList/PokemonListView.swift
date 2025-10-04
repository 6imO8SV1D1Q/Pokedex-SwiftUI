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
                    ProgressView("読み込み中...")
                } else if let error = viewModel.errorMessage {
                    errorView(message: error)
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
            .task {
                await viewModel.loadPokemons()
            }
        }
    }

    private var pokemonList: some View {
        List(viewModel.filteredPokemons) { pokemon in
            NavigationLink(value: pokemon) {
                PokemonRow(pokemon: pokemon)
            }
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(
                viewModel: PokemonDetailViewModel(pokemon: pokemon)
            )
        }
    }

    private var pokemonGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ],
                spacing: 16
            ) {
                ForEach(viewModel.filteredPokemons) { pokemon in
                    NavigationLink(value: pokemon) {
                        PokemonGridItem(pokemon: pokemon)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(
                viewModel: PokemonDetailViewModel(pokemon: pokemon)
            )
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(.red)

            Text(message)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button("再試行") {
                Task {
                    await viewModel.loadPokemons()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
