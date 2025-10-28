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

    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: limit)
        )

        guard let results = pagedObject.results else {
            return []
        }

        let totalCount = results.count

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

            // 進捗通知
            let progress = Double(pokemons.count) / Double(totalCount)
            progressHandler?(progress)
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

    /// PKMEvolutionChainを直接取得（v3.0用）
    func fetchPKMEvolutionChain(_ id: Int) async throws -> PKMEvolutionChain {
        return try await pokemonAPI.evolutionService.fetchEvolutionChain(id)
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

    func fetchPokemonList(idRange: ClosedRange<Int>, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        let totalCount = idRange.count
        var pokemons: [Pokemon] = []

        // バッチサイズ: 10件（並列度を下げて安定性向上）
        let batchSize = 10

        for batchStart in stride(from: idRange.lowerBound, through: idRange.upperBound, by: batchSize) {
            let batchEnd = min(batchStart + batchSize - 1, idRange.upperBound)
            let batchRange = batchStart...batchEnd

            let batch = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
                for id in batchRange {
                    group.addTask {
                        do {
                            return try await self.fetchPokemon(id)
                        } catch {
                            // キャンセルエラーは無視、その他のエラーはログ出力
                            if let urlError = error as? URLError, urlError.code == .cancelled {
                                return nil
                            }
                            print("⚠️ Failed to fetch Pokemon #\(id): \(error)")
                            return nil
                        }
                    }
                }

                var results: [Pokemon] = []
                for try await pokemon in group {
                    if let pokemon = pokemon {
                        results.append(pokemon)
                    }
                }
                return results
            }

            pokemons.append(contentsOf: batch)

            // 進捗通知
            let progress = Double(pokemons.count) / Double(totalCount)
            progressHandler?(progress)
        }

        return pokemons.sorted { $0.id < $1.id }
    }

    func fetchAllPokemon(maxId: Int? = nil, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // 全ポケモンリストを取得（limit=0で総数確認）
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: 1)
        )

        guard let count = pagedObject.count else {
            return []
        }

        // maxIdが指定されている場合は、それを上限とする
        let targetCount = maxId ?? count

        // 実際のポケモンリストを取得
        let fullPagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: targetCount)
        )

        guard let results = fullPagedObject.results else {
            return []
        }

        let totalCount = results.count
        var pokemons: [Pokemon] = []

        // バッチサイズ: 10件（並列度を下げて安定性向上）
        let batchSize = 10

        for batchStart in stride(from: 0, to: results.count, by: batchSize) {
            let batchEnd = min(batchStart + batchSize, results.count)
            let batch = Array(results[batchStart..<batchEnd])

            let batchPokemons = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
                for resource in batch {
                    group.addTask {
                        do {
                            let pkm = try await self.pokemonAPI.resourceService.fetch(resource)
                            return PokemonMapper.map(from: pkm)
                        } catch {
                            // キャンセルエラーは無視、その他のエラーはログ出力
                            if let urlError = error as? URLError, urlError.code == .cancelled {
                                // キャンセルは無視（タスクグループの正常な動作）
                                return nil
                            }
                            print("⚠️ Failed to fetch Pokemon from \(resource.url ?? "unknown"): \(error)")
                            return nil
                        }
                    }
                }

                var results: [Pokemon] = []
                for try await pokemon in group {
                    if let pokemon = pokemon {
                        results.append(pokemon)
                    }
                }
                return results
            }

            pokemons.append(contentsOf: batchPokemons)

            // 進捗通知
            let progress = Double(pokemons.count) / Double(totalCount)
            progressHandler?(progress)
        }

        return pokemons.sorted { $0.id < $1.id }
    }

    func fetchPokedex(_ name: String) async throws -> [Int] {
        let pokedex = try await pokemonAPI.gameService.fetchPokedex(name)

        guard let pokemonEntries = pokedex.pokemonEntries else {
            return []
        }

        // pokemon_speciesのIDを抽出
        return pokemonEntries.compactMap { entry in
            guard let urlString = entry.pokemonSpecies?.url,
                  let components = urlString.split(separator: "/").last,
                  let id = Int(components) else {
                return nil
            }
            return id
        }.sorted()
    }

    // MARK: - Move API

    func fetchAllMoves() async throws -> [(id: Int, name: String)] {
        // 技リストを取得（limit=1000で十分）
        let pagedObject = try await pokemonAPI.moveService.fetchMoveList(
            paginationState: .initial(pageLimit: 1000)
        )

        guard let results = pagedObject.results else {
            return []
        }

        // リソースからIDと名前を抽出（詳細取得せずに高速化）
        let moves = results.compactMap { resource -> (id: Int, name: String)? in
            guard let name = resource.name,
                  let urlString = resource.url,
                  let idString = urlString.split(separator: "/").last,
                  let id = Int(idString) else {
                return nil
            }
            return (id: id, name: name)
        }

        return moves
    }

    func fetchMove(_ id: Int) async throws -> PKMMove {
        return try await pokemonAPI.moveService.fetchMove(id)
    }

    // MARK: - Raw Pokemon API (for move version group details)

    func fetchRawPokemon(_ id: Int) async throws -> PKMPokemon {
        return try await pokemonAPI.pokemonService.fetchPokemon(id)
    }

    // MARK: - Pokemon Forms

    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        // 1. pokemon-speciesを取得してvarietiesを確認
        let species = try await pokemonAPI.pokemonService.fetchPokemonSpecies(pokemonId)

        guard let varieties = species.varieties, !varieties.isEmpty else {
            // varietiesがない場合は通常のpokemonのみ
            let pkm = try await pokemonAPI.pokemonService.fetchPokemon(pokemonId)
            return [PokemonFormMapper.mapSingle(from: pkm, isDefault: true)]
        }

        // 2. 各varietyのpokemonを並列で取得
        let forms = try await withThrowingTaskGroup(of: (PokemonForm, Int)?.self) { group in
            for (index, variety) in varieties.enumerated() {
                group.addTask {
                    guard let pokemonResource = variety.pokemon,
                          let urlString = pokemonResource.url,
                          let components = urlString.split(separator: "/").last,
                          let varietyPokemonId = Int(components) else {
                        return nil
                    }

                    let pkm = try await self.pokemonAPI.pokemonService.fetchPokemon(varietyPokemonId)
                    let isDefault = variety.isDefault ?? false
                    return (PokemonFormMapper.mapSingle(from: pkm, isDefault: isDefault), index)
                }
            }

            var results: [(PokemonForm, Int)] = []
            for try await result in group {
                if let result = result {
                    results.append(result)
                }
            }
            return results
        }

        // 元の順序でソート
        return forms.sorted(by: { $0.1 < $1.1 }).map { $0.0 }
    }

    // MARK: - Pokemon Locations

    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation] {
        // PokéAPIの/pokemon/{id}/encountersエンドポイントを直接呼び出す
        // PokemonAPIライブラリにはこのメソッドがないため、空配列を返す
        // TODO: Phase 1-7で適切に実装
        return []
    }

    // MARK: - Type Details

    func fetchTypeDetail(typeName: String) async throws -> TypeDetail {
        let pkmType = try await pokemonAPI.pokemonService.fetchType(typeName)
        return TypeDetailMapper.map(from: pkmType)
    }

    // MARK: - Ability Details

    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail {
        let pkmAbility = try await pokemonAPI.pokemonService.fetchAbility(abilityId)
        return AbilityDetailMapper.map(from: pkmAbility, isHidden: false)
    }

    func fetchAbilityDetail(abilityName: String, isHidden: Bool = false) async throws -> AbilityDetail {
        let pkmAbility = try await pokemonAPI.pokemonService.fetchAbility(abilityName)
        return AbilityDetailMapper.map(from: pkmAbility, isHidden: isHidden)
    }

    // MARK: - Flavor Text

    func fetchFlavorText(speciesId: Int, versionGroup: String?, preferredVersion: String? = nil, preferredLanguage: String = "ja") async throws -> PokemonFlavorText? {
        let species = try await pokemonAPI.pokemonService.fetchPokemonSpecies(speciesId)
        return FlavorTextMapper.mapFlavorText(from: species, versionGroup: versionGroup, preferredVersion: preferredVersion, preferredLanguage: preferredLanguage)
    }

    // MARK: - Machine API

    /// マシン情報を取得
    /// - Parameter machineId: マシンID
    /// - Returns: PKMMachine（マシン情報）
    func fetchMachine(_ machineId: Int) async throws -> PKMMachine {
        return try await pokemonAPI.machineService.fetchMachine(machineId)
    }
}
