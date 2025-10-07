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
    private var versionGroupCaches: [String: [Pokemon]] = [:]

    // v3.0 新規キャッシュ
    private let formCache = FormCache()
    private let locationCache = LocationCache()

    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }

    /// キャッシュをクリア（デバッグ用）
    func clearCache() {
        cache.removeAll()
        listCache = nil
        versionGroupCaches.removeAll()
        print("🗑️ Cache cleared")
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

    func fetchPokemonList(versionGroup: VersionGroup, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // バージョングループ別キャッシュチェック
        if let cached = versionGroupCaches[versionGroup.id] {
            progressHandler?(1.0)
            return cached
        }

        // 全国図鑑の場合は全ポケモン（フォルム含む）を取得
        if versionGroup.id == "national" {
            let pokemons = try await apiClient.fetchAllPokemon(progressHandler: progressHandler)
            versionGroupCaches[versionGroup.id] = pokemons
            for pokemon in pokemons {
                cache[pokemon.id] = pokemon
            }
            return pokemons
        }

        // バージョングループ別の場合: pokedexから実際に登場するspeciesIdを取得
        var speciesIds: Set<Int> = []

        if let pokedexNames = versionGroup.pokedexNames {
            // 各pokedexから登場ポケモンを取得
            for pokedexName in pokedexNames {
                do {
                    let ids = try await apiClient.fetchPokedex(pokedexName)
                    speciesIds.formUnion(ids)
                } catch {
                    print("⚠️ Failed to fetch pokedex \(pokedexName): \(error)")
                }
            }
        }

        // 全ポケモンリストから該当バージョングループのものをフィルタリング
        let allPokemons = try await apiClient.fetchAllPokemon(progressHandler: progressHandler)

        print("📊 VersionGroup \(versionGroup.id) filtering:")
        print("  Total pokemon fetched: \(allPokemons.count)")
        print("  Unique species IDs in pokedex: \(speciesIds.count)")

        let versionGroupPokemons: [Pokemon]
        if !speciesIds.isEmpty {
            // Pokedex + 登場可能ポケモン（Pokemon Homeなど経由）
            versionGroupPokemons = allPokemons.filter { pokemon in
                // 1. そのフォルムがこのバージョングループでまだ存在しているか（削除されていないか）
                // これを最初にチェックすることで、キョダイマックスやメガシンカを除外
                if let lastGen = pokemon.lastAvailableGeneration {
                    guard versionGroup.generation <= lastGen else {
                        return false
                    }
                }

                // 2. そのフォルムがこのバージョングループ以降に初登場しているか
                guard pokemon.introductionGeneration <= versionGroup.generation else {
                    return false
                }

                // 3. このバージョングループに登場可能か判定
                // 3-1: Pokedexに登録されている
                if speciesIds.contains(pokemon.speciesId) {
                    return true
                }

                // 3-2: Pokedexには載っていないが、movesから判定して登場可能
                // （Pokemon Home連携など）
                if pokemon.availableGenerations.contains(versionGroup.generation) {
                    return true
                }

                return false
            }

            print("  Filtered pokemon count: \(versionGroupPokemons.count)")
            print("  (Pokedex registered + Home transferable)")
        } else {
            // pokedex情報がない場合（後方互換）
            versionGroupPokemons = allPokemons.filter { pokemon in
                guard pokemon.introductionGeneration <= versionGroup.generation else {
                    return false
                }

                if let lastGen = pokemon.lastAvailableGeneration {
                    return versionGroup.generation <= lastGen
                }

                return true
            }
        }

        // バージョングループ別キャッシュと個別キャッシュの両方に保存
        versionGroupCaches[versionGroup.id] = versionGroupPokemons
        for pokemon in versionGroupPokemons {
            cache[pokemon.id] = pokemon
        }

        return versionGroupPokemons
    }

    // MARK: - v3.0 新規メソッド

    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        // キャッシュチェック
        if let cached = await formCache.get(pokemonId: pokemonId) {
            return cached
        }

        // API呼び出し
        let forms = try await apiClient.fetchPokemonForms(pokemonId: pokemonId)

        // キャッシュに保存
        await formCache.set(pokemonId: pokemonId, forms: forms)

        return forms
    }

    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation] {
        // キャッシュチェック
        if let cached = await locationCache.get(pokemonId: pokemonId) {
            return cached
        }

        // API呼び出し
        let locations = try await apiClient.fetchPokemonLocations(pokemonId: pokemonId)

        // キャッシュに保存
        await locationCache.set(pokemonId: pokemonId, locations: locations)

        return locations
    }

    func fetchFlavorText(speciesId: Int, versionGroup: String?) async throws -> PokemonFlavorText? {
        // 図鑑テキストは頻繁に変わらないので、APIから直接取得
        return try await apiClient.fetchFlavorText(speciesId: speciesId, versionGroup: versionGroup)
    }

    func fetchEvolutionChainEntity(speciesId: Int) async throws -> EvolutionChainEntity {
        // speciesIdから進化チェーンIDを取得
        let species = try await apiClient.fetchPokemonSpecies(speciesId)

        guard let evolutionChainId = species.evolutionChain.id else {
            // 進化チェーンがない場合は、単体のノードを返す
            let pokemon = try await fetchPokemonDetail(id: speciesId)
            let singleNode = EvolutionNode(
                id: speciesId,
                speciesId: speciesId,
                name: pokemon.name,
                imageUrl: pokemon.sprites.other?.home?.frontDefault,
                types: pokemon.types.map { $0.name },
                evolvesTo: [],
                evolvesFrom: nil
            )
            return EvolutionChainEntity(
                id: speciesId,
                rootNode: singleNode
            )
        }

        // 既存のEvolutionChainを取得し、EvolutionChainEntityに変換
        let chain = try await fetchEvolutionChain(id: evolutionChainId)

        // TODO: Phase 2以降で完全な実装
        // 現在は簡易的にEvolutionChainEntityを構築
        let pokemon = try await fetchPokemonDetail(id: speciesId)
        let rootNode = EvolutionNode(
            id: evolutionChainId,
            speciesId: speciesId,
            name: pokemon.name,
            imageUrl: pokemon.sprites.other?.home?.frontDefault,
            types: pokemon.types.map { $0.name },
            evolvesTo: [],
            evolvesFrom: nil
        )

        return EvolutionChainEntity(
            id: evolutionChainId,
            rootNode: rootNode
        )
    }
}
