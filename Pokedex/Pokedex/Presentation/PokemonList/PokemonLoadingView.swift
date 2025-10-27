//
//  PokemonLoadingView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// ポケモン詳細を非同期で読み込むView
struct PokemonLoadingView: View {
    let pokemonId: Int
    let onLoaded: (Pokemon) -> Void

    @State private var pokemon: Pokemon?
    @State private var isLoading = true
    @State private var errorMessage: String?

    private let fetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol

    init(
        pokemonId: Int,
        fetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol? = nil,
        onLoaded: @escaping (Pokemon) -> Void
    ) {
        self.pokemonId = pokemonId
        self.onLoaded = onLoaded
        self.fetchPokemonDetailUseCase = fetchPokemonDetailUseCase ?? DIContainer.shared.makeFetchPokemonDetailUseCase()
    }

    var body: some View {
        Group {
            if isLoading {
                VStack {
                    ProgressView()
                    Text(L10n.Common.loading)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if let pokemon = pokemon {
                PokemonDetailView(
                    viewModel: PokemonDetailViewModel(pokemon: pokemon, versionGroup: "scarlet-violet")
                )
            } else if let errorMessage = errorMessage {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
            }
        }
        .task {
            await loadPokemon()
        }
    }

    private func loadPokemon() async {
        isLoading = true
        errorMessage = nil

        do {
            let fetchedPokemon = try await fetchPokemonDetailUseCase.execute(pokemonId: pokemonId)
            pokemon = fetchedPokemon
            onLoaded(fetchedPokemon)
        } catch {
            errorMessage = L10n.Message.loadingFailed(error.localizedDescription)
        }

        isLoading = false
    }
}
