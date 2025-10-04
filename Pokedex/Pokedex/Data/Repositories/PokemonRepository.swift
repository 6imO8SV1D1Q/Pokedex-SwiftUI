//
//  PokemonRepository.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private var cache: [Int: Pokemon] = [:]
    private var listCache: [Pokemon]?

    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }

    func fetchPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        // リストキャッシュがあればそれを返す
        if let cached = listCache {
            return cached
        }

        let pokemons = try await apiClient.fetchPokemonList(limit: limit, offset: offset)

        // リストキャッシュと個別キャッシュの両方に保存
        listCache = pokemons
        for pokemon in pokemons {
            cache[pokemon.id] = pokemon
        }

        return pokemons
    }

    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        // キャッシュチェック
        if let cached = cache[id] {
            return cached
        }

        let pokemon = try await apiClient.fetchPokemon(id)
        cache[id] = pokemon
        return pokemon
    }

    func fetchPokemonDetail(name: String) async throws -> Pokemon {
        let pokemon = try await apiClient.fetchPokemon(name)
        cache[pokemon.id] = pokemon
        return pokemon
    }
}
