//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(pokemon: Pokemon) {
        self.pokemon = pokemon
    }
}
