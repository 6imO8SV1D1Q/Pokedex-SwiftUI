//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
    // Published プロパティ
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // Dependencies
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol

    init(fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
    }

    func loadPokemons() async {
        isLoading = true
        errorMessage = nil

        do {
            pokemons = try await fetchPokemonListUseCase.execute(limit: 151, offset: 0)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
