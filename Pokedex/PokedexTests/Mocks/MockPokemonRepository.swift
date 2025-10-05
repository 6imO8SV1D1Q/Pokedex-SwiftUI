//
//  MockPokemonRepository.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import Foundation
@testable import Pokedex

final class MockPokemonRepository: PokemonRepositoryProtocol {
    // テスト用の設定
    var pokemonsToReturn: [Pokemon] = []
    var pokemonToReturn: Pokemon?
    var speciesToReturn: PokemonSpecies?
    var evolutionChainToReturn: EvolutionChain?
    var shouldThrowError = false
    var errorToThrow: Error = PokemonError.networkError(NSError(domain: "test", code: -1))
    var failCount = 0

    // 呼び出し回数の記録
    var fetchPokemonListCallCount = 0
    var fetchPokemonDetailCallCount = 0
    var fetchPokemonSpeciesCallCount = 0
    var fetchEvolutionChainCallCount = 0

    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)? = nil) async throws -> [Pokemon] {
        fetchPokemonListCallCount += 1

        if shouldThrowError {
            if fetchPokemonListCallCount <= failCount {
                throw errorToThrow
            }
        }

        return pokemonsToReturn
    }

    func fetchPokemonList(versionGroup: VersionGroup, progressHandler: ((Double) -> Void)? = nil) async throws -> [Pokemon] {
        fetchPokemonListCallCount += 1

        if shouldThrowError {
            if fetchPokemonListCallCount <= failCount {
                throw errorToThrow
            }
        }

        return pokemonsToReturn
    }

    func clearCache() {
        // Mock implementation - do nothing
    }

    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        fetchPokemonDetailCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let pokemon = pokemonToReturn else {
            throw PokemonError.notFound
        }

        return pokemon
    }

    func fetchPokemonDetail(name: String) async throws -> Pokemon {
        fetchPokemonDetailCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let pokemon = pokemonToReturn else {
            throw PokemonError.notFound
        }

        return pokemon
    }

    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        fetchPokemonSpeciesCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let species = speciesToReturn else {
            throw PokemonError.notFound
        }

        return species
    }

    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain {
        fetchEvolutionChainCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let chain = evolutionChainToReturn else {
            throw PokemonError.notFound
        }

        return chain
    }
}
