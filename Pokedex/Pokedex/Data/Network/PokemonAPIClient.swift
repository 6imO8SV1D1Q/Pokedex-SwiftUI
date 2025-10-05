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

    func fetchPokemonSpecies(_ id: Int) async throws -> PokemonSpecies {
        let species = try await pokemonAPI.pokemonService.fetchPokemonSpecies(id)
        return PokemonSpeciesMapper.map(from: species)
    }

    func fetchEvolutionChain(_ id: Int) async throws -> EvolutionChain {
        let chain = try await pokemonAPI.evolutionService.fetchEvolutionChain(id)
        return EvolutionChainMapper.map(from: chain)
    }

    func fetchAllAbilities() async throws -> [String] {
        // 第1世代のポケモン（1-151）から全特性を収集
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: 151)
        )

        guard let results = pagedObject.results else {
            return []
        }

        var allAbilities: Set<String> = []

        // 並列取得でパフォーマンス向上（最大5個ずつ）
        for chunkStart in stride(from: 0, to: results.count, by: 5) {
            let chunkEnd = min(chunkStart + 5, results.count)
            let chunk = Array(results[chunkStart..<chunkEnd])

            let chunkAbilities = try await withThrowingTaskGroup(of: [String].self) { group in
                for resource in chunk {
                    group.addTask {
                        let pkm = try await self.pokemonAPI.resourceService.fetch(resource)
                        return pkm.abilities?.compactMap { $0.ability?.name } ?? []
                    }
                }

                var results: [String] = []
                for try await abilities in group {
                    results.append(contentsOf: abilities)
                }
                return results
            }

            allAbilities.formUnion(chunkAbilities)
        }

        return allAbilities.sorted()
    }
}
