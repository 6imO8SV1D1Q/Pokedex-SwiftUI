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
    var evolutionChainEntityToReturn: EvolutionChainEntity?
    var formsToReturn: [PokemonForm] = []
    var locationsToReturn: [PokemonLocation] = []
    var flavorTextToReturn: PokemonFlavorText?
    var shouldThrowError = false
    var errorToThrow: Error = PokemonError.networkError(NSError(domain: "test", code: -1))
    var failCount = 0

    // 呼び出し回数の記録
    var fetchPokemonListCallCount = 0
    var fetchPokemonDetailCallCount = 0
    var fetchPokemonSpeciesCallCount = 0
    var fetchEvolutionChainCallCount = 0
    var fetchPokemonFormsCallCount = 0
    var fetchPokemonLocationsCallCount = 0
    var fetchFlavorTextCallCount = 0
    var fetchEvolutionChainEntityCallCount = 0

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

    // MARK: - v3.0 Methods

    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        fetchPokemonFormsCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return formsToReturn
    }

    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation] {
        fetchPokemonLocationsCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return locationsToReturn
    }

    func fetchFlavorText(speciesId: Int, versionGroup: String?) async throws -> PokemonFlavorText? {
        fetchFlavorTextCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        return flavorTextToReturn
    }

    func fetchEvolutionChainEntity(speciesId: Int) async throws -> EvolutionChainEntity {
        fetchEvolutionChainEntityCallCount += 1

        if shouldThrowError {
            throw errorToThrow
        }

        guard let entity = evolutionChainEntityToReturn else {
            throw PokemonError.notFound
        }

        return entity
    }
}
