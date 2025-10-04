//
//  PokemonListView.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import SwiftUI

struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel

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
        List(viewModel.pokemons) { pokemon in
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
