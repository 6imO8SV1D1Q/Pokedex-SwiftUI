//
//  PreloadedDataLoader.swift
//  Pokedex
//
//  プリバンドルデータベースローダー（Folder References対応）
//

import Foundation
import SwiftData

enum PreloadedDataLoader {
    /// プリバンドルデータ構造（GenerateDatabase.swiftの出力形式）
    struct PokemonData: Codable {
        let id: Int
        let name: String
        let height: Int
        let weight: Int
        let types: [TypeData]
        let stats: [StatData]
        let abilities: [AbilityData]
        let sprites: SpriteData
        let moves: [Int]
        let availableGenerations: [Int]

        struct TypeData: Codable {
            let slot: Int
            let name: String
        }

        struct StatData: Codable {
            let name: String
            let baseStat: Int
        }

        struct AbilityData: Codable {
            let name: String
            let isHidden: Bool
        }

        struct SpriteData: Codable {
            let frontDefault: String?
            let frontShiny: String?
            let homeFrontDefault: String?
            let homeFrontShiny: String?
        }
    }

    /// プリバンドルデータをSwiftDataにロード（必要な場合のみ）
    /// - Returns: ロードした場合true、既存データがあればfalse
    static func loadPreloadedDataIfNeeded(modelContext: ModelContext) throws -> Bool {
        // 既存データチェック
        let existingCount = try modelContext.fetchCount(FetchDescriptor<PokemonModel>())
        if existingCount > 0 {
            print("✅ [Preloaded] Skip loading: \(existingCount) pokemon already exist")
            return false
        }

        print("📦 [Preloaded] Loading prebundled data...")

        // 複数のパスパターンを試す
        var fileURL: URL?

        // パターン1: Bundle.main.url(forResource:) - 最も標準的な方法
        fileURL = Bundle.main.url(forResource: "pokemon_data", withExtension: "json")

        // パターン2: PreloadedDataサブディレクトリ内
        if fileURL == nil {
            fileURL = Bundle.main.url(forResource: "pokemon_data", withExtension: "json", subdirectory: "PreloadedData")
        }

        // パターン3: Resourcesサブディレクトリ内
        if fileURL == nil {
            fileURL = Bundle.main.url(forResource: "pokemon_data", withExtension: "json", subdirectory: "Resources/PreloadedData")
        }

        // パターン4: resourcePath直下（フラット構造）
        if fileURL == nil, let resourcePath = Bundle.main.resourcePath {
            let directPath = URL(fileURLWithPath: resourcePath).appendingPathComponent("pokemon_data.json")
            if FileManager.default.fileExists(atPath: directPath.path) {
                fileURL = directPath
            }
        }

        // ファイルが見つからない場合
        guard let fileURL = fileURL else {
            print("⚠️ [Preloaded] pokemon_data.json not found in bundle")

            // デバッグ：resourcePath配下のファイル一覧を表示
            if let resourcePath = Bundle.main.resourcePath,
               let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                print("   Files in resourcePath: \(contents)")
            }

            return false
        }

        print("🔍 [Preloaded] Found file at: \(fileURL.path)")

        // JSONファイル読み込み
        let data = try Data(contentsOf: fileURL)
        print("📄 [Preloaded] File size: \(Double(data.count) / 1024 / 1024) MB")

        let decoder = JSONDecoder()
        let pokemonDataList = try decoder.decode([PokemonData].self, from: data)
        print("🔄 [Preloaded] Decoded \(pokemonDataList.count) pokemon")

        // SwiftDataモデルに変換して保存
        for pokemonData in pokemonDataList {
            let model = convertToModel(pokemonData)
            modelContext.insert(model)
        }

        try modelContext.save()
        print("✅ [Preloaded] Successfully loaded \(pokemonDataList.count) pokemon into SwiftData")

        return true
    }

    /// PokemonData → PokemonModel 変換
    private static func convertToModel(_ data: PokemonData) -> PokemonModel {
        let types = data.types.map { typeData in
            PokemonTypeModel(slot: typeData.slot, name: typeData.name)
        }

        let stats = data.stats.map { statData in
            PokemonStatModel(name: statData.name, baseStat: statData.baseStat)
        }

        let abilities = data.abilities.map { abilityData in
            PokemonAbilityModel(name: abilityData.name, isHidden: abilityData.isHidden)
        }

        let sprites = PokemonSpriteModel(
            frontDefault: data.sprites.frontDefault,
            frontShiny: data.sprites.frontShiny,
            homeFrontDefault: data.sprites.homeFrontDefault,
            homeFrontShiny: data.sprites.homeFrontShiny
        )

        return PokemonModel(
            id: data.id,
            speciesId: data.id, // プリバンドルデータでは id == speciesId
            name: data.name,
            height: data.height,
            weight: data.weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moveIds: data.moves,
            availableGenerations: data.availableGenerations
        )
    }
}
