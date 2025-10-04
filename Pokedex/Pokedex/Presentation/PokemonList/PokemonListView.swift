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
                    pokemonList
                }
            }
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchText, prompt: "ポケモンを検索")
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.applyFilters()
            }
            .toolbar {
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
            .navigationDestination(for: Pokemon.self) { pokemon in
                PokemonDetailView(
                    viewModel: PokemonDetailViewModel(pokemon: pokemon)
                )
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
