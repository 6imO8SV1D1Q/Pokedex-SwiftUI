//
//  FetchPokemonListUseCase.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

protocol FetchPokemonListUseCaseProtocol {
    func execute(limit: Int, offset: Int) async throws -> [Pokemon]
}

final class FetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(limit: Int = 151, offset: Int = 0) async throws -> [Pokemon] {
        return try await repository.fetchPokemonList(limit: limit, offset: offset)
    }
}
