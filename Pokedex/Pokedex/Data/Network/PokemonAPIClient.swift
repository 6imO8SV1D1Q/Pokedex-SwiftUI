//
//  PokemonAPIClient.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import PokemonAPI

final class PokemonAPIClient {
    private let pokemonAPI = PokemonAPI()

    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        let pkm = try await pokemonAPI.pokemonService.fetchPokemon(id)
        return PokemonMapper.map(from: pkm)
    }

    func fetchPokemon(_ name: String) async throws -> Pokemon {
        let pkm = try await pokemonAPI.pokemonService.fetchPokemon(name)
        return PokemonMapper.map(from: pkm)
    }

    func fetchPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: limit)
        )

        guard let results = pagedObject.results else {
            return []
        }

        // 並列取得でパフォーマンス向上（最大5個ずつ）
        var pokemons: [Pokemon] = []

        for chunkStart in stride(from: 0, to: results.count, by: 5) {
            let chunkEnd = min(chunkStart + 5, results.count)
            let chunk = Array(results[chunkStart..<chunkEnd])

            let chunkPokemons = try await withThrowingTaskGroup(of: Pokemon.self) { group in
                for resource in chunk {
                    group.addTask {
                        let pkm = try await self.pokemonAPI.resourceService.fetch(resource)
                        return PokemonMapper.map(from: pkm)
                    }
                }

                var results: [Pokemon] = []
                for try await pokemon in group {
                    results.append(pokemon)
                }
                return results
            }

            pokemons.append(contentsOf: chunkPokemons)
        }

        return pokemons.sorted { $0.id < $1.id }
    }
}
