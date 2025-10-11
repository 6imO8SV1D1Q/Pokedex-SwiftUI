//
//  PreloadedDataLoader.swift
//  Pokedex
//
//  Loads preloaded Scarlet/Violet JSON data into SwiftData
//

import Foundation
import SwiftData

enum PreloadedDataLoader {

    /// プリバンドルデータをSwiftDataにロード（必要な場合のみ）
    /// - Returns: ロードした場合true、既存データがあればfalse
    static func loadPreloadedDataIfNeeded(modelContext: ModelContext) throws -> Bool {
        // 既存データチェック
        let existingCount = try modelContext.fetchCount(FetchDescriptor<PokemonModel>())
        if existingCount > 0 {
            print("✅ [Preloaded] Skip loading: \(existingCount) pokemon already exist")
            return false
        }

        print("📦 [Preloaded] Loading Scarlet/Violet JSON from bundle...")

        // バンドルからJSONを読み込み
        guard let bundleURL = Bundle.main.url(
            forResource: "scarlet_violet",
            withExtension: "json"
        ) else {
            print("⚠️ [Preloaded] scarlet_violet.json not found in bundle")

            // デバッグ：resourcePath配下のファイル一覧を表示
            if let resourcePath = Bundle.main.resourcePath,
               let contents = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                print("   Files in resourcePath: \(contents.prefix(20))")
            }

            return false
        }

        print("🔍 [Preloaded] Found file at: \(bundleURL.path)")

        // JSONファイル読み込み
        let data = try Data(contentsOf: bundleURL)
        print("📄 [Preloaded] File size: \(String(format: "%.2f", Double(data.count) / 1024 / 1024)) MB")

        let decoder = JSONDecoder()
        let gameData = try decoder.decode(GameData.self, from: data)

        print("📊 [Preloaded] Decoded JSON:")
        print("   - Version: \(gameData.versionGroup) (Gen \(gameData.generation))")
        print("   - Pokemon: \(gameData.pokemon.count)")
        print("   - Moves: \(gameData.moves.count)")
        print("   - Abilities: \(gameData.abilities.count)")

        // 特性マスタを辞書に変換（名前がない場合はID文字列を使用）
        var abilityMap: [Int: (name: String, nameJa: String)] = [:]
        for ability in gameData.abilities {
            let name = ability.name ?? "ability-\(ability.id)"
            let nameJa = ability.nameJa ?? "特性\(ability.id)"
            abilityMap[ability.id] = (name: name, nameJa: nameJa)
        }

        // ポケモンデータをSwiftDataに変換して保存
        print("💾 [Preloaded] Saving pokemon to SwiftData...")

        for (index, pokemonData) in gameData.pokemon.enumerated() {
            let model = PokemonModelMapper.fromJSON(pokemonData, abilityMap: abilityMap)
            modelContext.insert(model)

            // 100匹ごとに中間保存＆進捗表示
            if (index + 1) % 100 == 0 {
                try modelContext.save()
                print("   Saved \(index + 1)/\(gameData.pokemon.count) pokemon...")
            }
        }

        // 最終保存
        try modelContext.save()

        print("✅ [Preloaded] Successfully loaded \(gameData.pokemon.count) pokemon into SwiftData")

        return true
    }
}
