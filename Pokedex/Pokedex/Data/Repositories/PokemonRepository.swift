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
    private var generationCaches: [Int: [Pokemon]] = [:]

    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }

    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // リストキャッシュがあればそれを返す
        if let cached = listCache {
            // キャッシュヒット時は即座に100%
            progressHandler?(1.0)
            return cached
        }

        let pokemons = try await apiClient.fetchPokemonList(
            limit: limit,
            offset: offset,
            progressHandler: progressHandler
        )

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

    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        try await apiClient.fetchPokemonSpecies(id)
    }

    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain {
        try await apiClient.fetchEvolutionChain(id)
    }

    func fetchPokemonList(generation: Generation, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // 世代別キャッシュチェック
        if let cached = generationCaches[generation.id] {
            progressHandler?(1.0)
            return cached
        }

        // 全国図鑑の場合は全ポケモン（フォルム含む）を取得
        if generation.id == 0 {
            let pokemons = try await apiClient.fetchAllPokemon(progressHandler: progressHandler)
            generationCaches[generation.id] = pokemons
            for pokemon in pokemons {
                cache[pokemon.id] = pokemon
            }
            return pokemons
        }

        // 世代別の場合は全ポケモンリストから該当世代のものをフィルタリング
        let allPokemons = try await apiClient.fetchAllPokemon(progressHandler: progressHandler)

        // 該当世代のポケモン（フォルム含む）をフィルタリング
        // speciesIdで判定することでリージョンフォームも含まれる
        let generationPokemons = allPokemons.filter { pokemon in
            generation.pokemonRange.contains(pokemon.speciesId)
        }

        // 世代別キャッシュと個別キャッシュの両方に保存
        generationCaches[generation.id] = generationPokemons
        for pokemon in generationPokemons {
            cache[pokemon.id] = pokemon
        }

        return generationPokemons
    }
}
