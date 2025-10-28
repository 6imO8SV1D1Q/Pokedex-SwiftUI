//
//  PokemonRepository.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import SwiftData

final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private let modelContext: ModelContext

    // v3.0 詳細情報用キャッシュ（メモリキャッシュとして残す）
    private let formCache = FormCache()
    private let locationCache = LocationCache()

    init(apiClient: PokemonAPIClient = PokemonAPIClient(), modelContext: ModelContext) {
        self.apiClient = apiClient
        self.modelContext = modelContext
    }

    /// SwiftDataキャッシュをクリア（デバッグ用）
    func clearCache() {
        do {
            try modelContext.delete(model: PokemonModel.self)
            try modelContext.save()
            print("🗑️ SwiftData cache cleared")
        } catch {
            print("⚠️ Failed to clear cache: \(error)")
        }
    }

    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        // SwiftDataキャッシュチェック
        let descriptor = FetchDescriptor<PokemonModel>(
            predicate: #Predicate { $0.id == id }
        )

        if let cached = try modelContext.fetch(descriptor).first {
            return PokemonModelMapper.toDomain(cached)
        }

        // APIから取得
        let pokemon = try await apiClient.fetchPokemon(id)

        // SwiftDataに保存
        let model = PokemonModelMapper.toModel(pokemon)
        modelContext.insert(model)
        try modelContext.save()

        return pokemon
    }

    func fetchPokemonDetail(name: String) async throws -> Pokemon {
        // APIから取得（nameでSwiftData検索は非効率なため）
        let pokemon = try await apiClient.fetchPokemon(name)

        // SwiftDataに保存
        let model = PokemonModelMapper.toModel(pokemon)
        modelContext.insert(model)
        try modelContext.save()

        return pokemon
    }

    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies {
        try await apiClient.fetchPokemonSpecies(id)
    }

    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain {
        try await apiClient.fetchEvolutionChain(id)
    }

    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // v4.0: このメソッドは非推奨（versionGroup版を使用）
        // 互換性のため、limitまでのポケモンを取得して返す
        let descriptor = FetchDescriptor<PokemonModel>(
            sortBy: [SortDescriptor(\.id)]
        )
        let allModels = try modelContext.fetch(descriptor)

        if !allModels.isEmpty {
            // キャッシュから取得
            let limitedModels = Array(allModels.prefix(limit))
            progressHandler?(1.0)
            return limitedModels.map { PokemonModelMapper.toDomain($0) }
        }

        // キャッシュがない場合はAPIから取得
        let pokemons = try await apiClient.fetchPokemonList(
            limit: limit,
            offset: offset,
            progressHandler: progressHandler
        )

        // SwiftDataに保存
        for pokemon in pokemons {
            let model = PokemonModelMapper.toModel(pokemon)
            modelContext.insert(model)
        }
        try modelContext.save()

        return pokemons
    }

    func fetchPokemonList(versionGroup: VersionGroup, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // STEP 1: SwiftDataからポケモンを取得
        print("📦 [Repository] Fetching pokemon for version group: \(versionGroup.id)")
        progressHandler?(0.05) // 開始を報告（すぐに進捗表示）

        let descriptor = FetchDescriptor<PokemonModel>(sortBy: [SortDescriptor(\.id)])
        let cachedModels = try modelContext.fetch(descriptor)

        var allPokemons: [Pokemon]

        // スキーマ変更検出: movesが埋め込み型になったため、必ず再ロード
        // UserDefaultsでスキーマバージョンを管理
        let currentSchemaVersion = "v4.2-fulldata"
        let savedSchemaVersion = UserDefaults.standard.string(forKey: "swiftdata_schema_version")
        let isSchemaChanged = savedSchemaVersion != currentSchemaVersion

        let pokedexCount = try modelContext.fetchCount(FetchDescriptor<PokedexModel>())
        let isOldCache = !cachedModels.isEmpty && (cachedModels.count != 925 || pokedexCount == 0 || isSchemaChanged)

        if isOldCache {
            let reason = isSchemaChanged ? "schema changed to \(currentSchemaVersion)" : "\(cachedModels.count) pokemon, \(pokedexCount) pokedexes"
            print("🔄 [Repository] Detected old/incomplete cache (\(reason)), clearing...")
            try modelContext.delete(model: PokemonModel.self)
            try modelContext.delete(model: AbilityModel.self)
            try modelContext.delete(model: MoveModel.self)
            try modelContext.delete(model: PokedexModel.self)
            try modelContext.save()
            print("✅ [Repository] Old cache cleared")

            // スキーマバージョンを更新
            UserDefaults.standard.set(currentSchemaVersion, forKey: "swiftdata_schema_version")
        }

        // 再度キャッシュチェック
        let freshModels = try modelContext.fetch(descriptor)

        if !freshModels.isEmpty && freshModels.count == 925 {
            // キャッシュヒット（正しいJSONデータ）
            print("✅ [SwiftData] Cache hit! Found \(freshModels.count) pokemon")
            // キャッシュヒット時は即座に100%
            progressHandler?(1.0)

            allPokemons = freshModels.map { model in
                PokemonModelMapper.toDomain(model)
            }
        } else {
            // STEP 2: プリバンドルデータをロード
            print("📦 [SwiftData] Cache miss, trying preloaded data...")
            let loaded = try PreloadedDataLoader.loadPreloadedDataIfNeeded(
                modelContext: modelContext,
                progressHandler: progressHandler
            )

            if loaded {
                // プリバンドルデータからロード成功
                let loadedModels = try modelContext.fetch(descriptor)
                print("✅ [Preloaded] Loaded \(loadedModels.count) pokemon from bundle")
                progressHandler?(1.0)

                allPokemons = loadedModels.map { model in
                    PokemonModelMapper.toDomain(model)
                }

                // スキーマバージョンを保存
                UserDefaults.standard.set(currentSchemaVersion, forKey: "swiftdata_schema_version")
            } else {
                // STEP 3: APIから取得（フォールバック）
                print("🌐 [API] Fetching from PokéAPI...")

                let fetchedPokemons = try await apiClient.fetchAllPokemon(
                    maxId: nil,  // 全ポケモン取得
                    progressHandler: progressHandler
                )

                print("✅ [API] Fetched \(fetchedPokemons.count) pokemon")

                // SwiftDataに保存
                for pokemon in fetchedPokemons {
                    let model = PokemonModelMapper.toModel(pokemon)
                    modelContext.insert(model)
                }
                try modelContext.save()
                print("💾 [SwiftData] Saved \(fetchedPokemons.count) pokemon to cache")

                allPokemons = fetchedPokemons
            }
        }

        // STEP 4: バージョングループでフィルタリング
        print("🔍 [Filter] Filtering for version group: \(versionGroup.id)")

        // 全国図鑑の場合: 特定のコスメティックフォームのみ除外
        if versionGroup.id == "national" {
            // 除外するコスメティックフォームの名前パターン
            let cosmeticPatterns = [
                "pikachu-.*-cap$",
                "vivillon-(?!$)",  // vivillon- で始まるがvivillon単体ではない
                "flabebe-(?!$)",
                "floette-(?!$)",
                "florges-(?!$)",
                "shellos-(?!$)",
                "gastrodon-(?!$)",
                "deerling-(?!$)",
                "sawsbuck-(?!$)",
                "minior-(?!red-meteor$|red$)",  // red-meteor と red 以外のminior
                "maushold-family",
                "dudunsparce-(?!$)",
                "tatsugiri-(?!$)",
                "mimikyu-busted",
                "magearna-original",
                "zarude-dada",
                "morpeko-hangry",
                "squawkabilly-(?!blue-plumage$|white-plumage$)",  // 青と白以外
                "basculin-blue-striped"
            ]

            let visiblePokemons = allPokemons.filter { pokemon in
                // コスメティックフォームパターンに一致するか確認
                for pattern in cosmeticPatterns {
                    if let regex = try? NSRegularExpression(pattern: pattern),
                       regex.firstMatch(in: pokemon.name, range: NSRange(pokemon.name.startIndex..., in: pokemon.name)) != nil {
                        return false  // 除外
                    }
                }
                return true  // 表示
            }

            print("✅ [Filter] National Dex: Returning \(visiblePokemons.count)/\(allPokemons.count) pokemon (excluding cosmetic variants)")
            return visiblePokemons
        }

        // バージョングループ別の場合: SwiftDataのPokedexから登場するspeciesIdを取得
        var speciesIds: Set<Int> = []

        if let pokedexNames = versionGroup.pokedexNames {
            // 各pokedexから登場ポケモンを取得
            for pokedexName in pokedexNames {
                // SwiftDataからPokedexを取得
                let pokedexDescriptor = FetchDescriptor<PokedexModel>(
                    predicate: #Predicate { $0.name == pokedexName }
                )

                if let pokedex = try modelContext.fetch(pokedexDescriptor).first {
                    print("✅ [SwiftData Pokedex] Hit: \(pokedexName) (\(pokedex.speciesIds.count) species)")
                    speciesIds.formUnion(pokedex.speciesIds)
                } else {
                    // SwiftDataになければAPIから取得（フォールバック）
                    print("🌐 [Pokedex API] Fetching \(pokedexName)...")
                    do {
                        let ids = try await apiClient.fetchPokedex(pokedexName)
                        speciesIds.formUnion(ids)
                    } catch {
                        print("⚠️ Failed to fetch pokedex \(pokedexName): \(error)")
                    }
                }
            }
        }

        print("📊 VersionGroup \(versionGroup.id) filtering:")
        print("  Total pokemon: \(allPokemons.count)")
        print("  Unique species IDs in pokedex: \(speciesIds.count)")

        let versionGroupPokemons: [Pokemon]
        if !speciesIds.isEmpty {
            // Pokedex + 登場可能ポケモン（Pokemon Homeなど経由）
            versionGroupPokemons = allPokemons.filter { pokemon in
                // 1. そのフォルムがこのバージョングループでまだ存在しているか（削除されていないか）
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

    func fetchFlavorText(speciesId: Int, versionGroup: String?, preferredVersion: String?, preferredLanguage: String = "ja") async throws -> PokemonFlavorText? {
        // 図鑑テキストは頻繁に変わらないので、APIから直接取得
        return try await apiClient.fetchFlavorText(speciesId: speciesId, versionGroup: versionGroup, preferredVersion: preferredVersion, preferredLanguage: preferredLanguage)
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
                nameJa: pokemon.nameJa,
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

        // PKMEvolutionChainを取得
        let pkmChain = try await apiClient.fetchPKMEvolutionChain(evolutionChainId)

        // 全てのspecies IDを抽出
        let allSpeciesIds = EvolutionChainMapper.extractAllSpeciesIds(from: pkmChain)

        // 各species IDからポケモン情報を取得してキャッシュを構築
        var pokemonCache: [Int: (name: String, nameJa: String?, imageUrl: String?, types: [String])] = [:]

        await withTaskGroup(of: (Int, (name: String, nameJa: String?, imageUrl: String?, types: [String])?)?.self) { group in
            for id in allSpeciesIds {
                group.addTask {
                    do {
                        let pokemon = try await self.fetchPokemonDetail(id: id)
                        return (id, (
                            name: pokemon.name,
                            nameJa: pokemon.nameJa,
                            imageUrl: pokemon.sprites.other?.home?.frontDefault,
                            types: pokemon.types.map { $0.name }
                        ))
                    } catch {
                        print("Failed to fetch pokemon \(id): \(error)")
                        return nil
                    }
                }
            }

            for await result in group {
                if let (id, info) = result {
                    pokemonCache[id] = info
                }
            }
        }

        // EvolutionChainEntityに変換
        return EvolutionChainMapper.mapToEntity(from: pkmChain, pokemonCache: pokemonCache)
    }
}
