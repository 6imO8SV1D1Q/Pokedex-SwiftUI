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
    /// - Parameters:
    ///   - modelContext: SwiftData ModelContext
    ///   - progressHandler: 進捗ハンドラー（0.0〜1.0）
    /// - Returns: ロードした場合true、既存データがあればfalse
    static func loadPreloadedDataIfNeeded(
        modelContext: ModelContext,
        progressHandler: ((Double) -> Void)? = nil
    ) throws -> Bool {
        // 既存データチェック
        let existingPokemonCount = try modelContext.fetchCount(FetchDescriptor<PokemonModel>())
        let existingAbilityCount = try modelContext.fetchCount(FetchDescriptor<AbilityModel>())
        let existingMoveCount = try modelContext.fetchCount(FetchDescriptor<MoveModel>())
        let existingPokedexCount = try modelContext.fetchCount(FetchDescriptor<PokedexModel>())

        // 全てのデータが揃っている場合はスキップ
        if existingPokemonCount > 0 && existingAbilityCount > 0 && existingMoveCount > 0 && existingPokedexCount > 0 {
            print("✅ [Preloaded] Skip loading: \(existingPokemonCount) pokemon, \(existingAbilityCount) abilities, \(existingMoveCount) moves, \(existingPokedexCount) pokedexes already exist")
            return false
        }

        // 初期進捗報告
        progressHandler?(0.01)

        print("📦 [Preloaded] Loading Scarlet/Violet JSON from bundle...")
        print("   Current: \(existingPokemonCount) pokemon, \(existingAbilityCount) abilities, \(existingMoveCount) moves")

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

        progressHandler?(0.1) // JSON読み込み完了

        // 特性マスタを辞書に変換（名前がない場合はID文字列を使用）
        var abilityMap: [Int: (name: String, nameJa: String)] = [:]
        for ability in gameData.abilities {
            let name = ability.name ?? "ability-\(ability.id)"
            let nameJa = ability.nameJa ?? "特性\(ability.id)"
            abilityMap[ability.id] = (name: name, nameJa: nameJa)
        }

        // 特性データをSwiftDataに保存
        print("💾 [Preloaded] Saving abilities to SwiftData...")
        for (index, abilityData) in gameData.abilities.enumerated() {
            let model = AbilityModel(
                id: abilityData.id,
                name: abilityData.name ?? "ability-\(abilityData.id)",
                nameJa: abilityData.nameJa ?? "特性\(abilityData.id)",
                effect: abilityData.effect ?? "",
                effectJa: abilityData.effectJa ?? ""
            )
            modelContext.insert(model)

            if (index + 1) % 50 == 0 {
                try modelContext.save()
                print("   Saved \(index + 1)/\(gameData.abilities.count) abilities...")
            }
        }
        try modelContext.save()
        print("✅ [Preloaded] Successfully loaded \(gameData.abilities.count) abilities")
        progressHandler?(0.2) // Abilities保存完了

        // 技データをSwiftDataに保存
        print("💾 [Preloaded] Saving moves to SwiftData...")
        for (index, moveData) in gameData.moves.enumerated() {
            // MoveMetaModelを作成
            let metaModel: MoveMetaModel? = {
                guard let meta = moveData.meta else { return nil }
                return MoveMetaModel(
                    ailment: meta.ailment ?? "none",
                    ailmentChance: meta.ailmentChance ?? 0,
                    category: meta.category ?? "damage",
                    critRate: meta.critRate ?? 0,
                    drain: meta.drain ?? 0,
                    flinchChance: meta.flinchChance ?? 0,
                    healing: meta.healing ?? 0,
                    statChance: meta.statChance ?? 0,
                    statChanges: meta.statChanges?.map { MoveStatChange(stat: $0.stat, change: $0.change) } ?? []
                )
            }()

            // MoveModelを作成
            let model = MoveModel(
                id: moveData.id,
                name: moveData.name ?? "move-\(moveData.id)",
                nameJa: moveData.nameJa ?? "技\(moveData.id)",
                type: moveData.type ?? "normal",
                damageClass: moveData.damageClass ?? "status",
                power: moveData.power,
                accuracy: moveData.accuracy,
                pp: moveData.pp ?? 0,
                priority: moveData.priority ?? 0,
                effectChance: moveData.effectChance,
                effect: moveData.effect ?? "",
                effectJa: moveData.effectJa ?? "",
                categories: moveData.categories ?? [],
                meta: metaModel
            )
            modelContext.insert(model)

            if (index + 1) % 100 == 0 {
                try modelContext.save()
                print("   Saved \(index + 1)/\(gameData.moves.count) moves...")
            }
        }
        try modelContext.save()
        print("✅ [Preloaded] Successfully loaded \(gameData.moves.count) moves")
        progressHandler?(0.4) // Moves保存完了

        // PokedexデータをSwiftDataに保存
        if let pokedexes = gameData.pokedexes {
            print("💾 [Preloaded] Saving pokedexes to SwiftData...")
            for pokedexData in pokedexes {
                let model = PokedexModel(
                    name: pokedexData.name,
                    speciesIds: pokedexData.speciesIds
                )
                modelContext.insert(model)
            }
            try modelContext.save()
            print("✅ [Preloaded] Successfully loaded \(pokedexes.count) pokedexes")
        }
        progressHandler?(0.45) // Pokedex保存完了

        // ポケモンデータをSwiftDataに変換して保存（既存データがない場合のみ）
        if existingPokemonCount == 0 {
            print("💾 [Preloaded] Saving pokemon to SwiftData...")

            let totalCount = gameData.pokemon.count
            for (index, pokemonData) in gameData.pokemon.enumerated() {
                let model = PokemonModelMapper.fromJSON(
                    pokemonData,
                    abilityMap: abilityMap,
                    typeMap: gameData.types
                )
                modelContext.insert(model)

                // 100匹ごとに中間保存＆進捗表示
                if (index + 1) % 100 == 0 {
                    try modelContext.save()
                    let progress = 0.45 + 0.55 * Double(index + 1) / Double(totalCount)
                    progressHandler?(progress)
                    print("   Saved \(index + 1)/\(totalCount) pokemon... (\(Int(progress * 100))%)")
                }
            }

            // 最終保存
            try modelContext.save()
            progressHandler?(1.0) // 完了

            print("✅ [Preloaded] Successfully loaded \(gameData.pokemon.count) pokemon into SwiftData")
        } else {
            print("⏭️  [Preloaded] Skipping pokemon save: \(existingPokemonCount) already exist")
            progressHandler?(1.0) // スキップの場合も完了を報告
        }

        return true
    }
}
