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

        // バッチサイズ: 50件
        let batchSize = 50

        for batchStart in stride(from: idRange.lowerBound, through: idRange.upperBound, by: batchSize) {
            let batchEnd = min(batchStart + batchSize - 1, idRange.upperBound)
            let batchRange = batchStart...batchEnd

            let batch = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
                for id in batchRange {
                    group.addTask {
                        do {
                            return try await self.fetchPokemon(id)
                        } catch {
                            // エラーが発生したポケモンはスキップ
                            print("Failed to fetch Pokemon #\(id): \(error)")
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

    func fetchAllPokemon(progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // 全ポケモンリストを取得（limit=0で総数確認）
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: 1)
        )

        guard let count = pagedObject.count else {
            return []
        }

        // 実際のポケモンリストを取得
        let fullPagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: count)
        )

        guard let results = fullPagedObject.results else {
            return []
        }

        let totalCount = results.count
        var pokemons: [Pokemon] = []

        // バッチサイズ: 50件
        let batchSize = 50

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
                            print("Failed to fetch Pokemon: \(error)")
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
}
