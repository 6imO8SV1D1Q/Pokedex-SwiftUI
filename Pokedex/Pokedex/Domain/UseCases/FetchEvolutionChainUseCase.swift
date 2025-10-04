//
//  FetchEvolutionChainUseCase.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

protocol FetchEvolutionChainUseCaseProtocol {
    func execute(pokemonId: Int) async throws -> [Int]
}

final class FetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pokemonId: Int) async throws -> [Int] {
        // 1. pokemon-speciesを取得して進化チェーンIDを取得
        let species = try await repository.fetchPokemonSpecies(id: pokemonId)

        guard let evolutionChainId = species.evolutionChain.id else {
            return [pokemonId]
        }

        // 2. 進化チェーンを取得
        let evolutionChain = try await repository.fetchEvolutionChain(id: evolutionChainId)

        // 3. チェーンを再帰的に辿ってIDリストを作成
        var pokemonIds: [Int] = []
        extractPokemonIds(from: evolutionChain.chain, into: &pokemonIds)

        return pokemonIds
    }

    private func extractPokemonIds(from chainLink: EvolutionChain.ChainLink, into ids: inout [Int]) {
        if let id = chainLink.species.id {
            ids.append(id)
        }

        for evolvedForm in chainLink.evolvesTo {
            extractPokemonIds(from: evolvedForm, into: &ids)
        }
    }
}
