#!/usr/bin/env swift

//
//  GenerateDatabase.swift
//  Pokedex
//
//  プリバンドルデータベース生成ツール
//  使い方: swift Tools/GenerateDatabase.swift [maxId]
//  例: swift Tools/GenerateDatabase.swift 151
//

import Foundation

// MARK: - 簡易版：SwiftDataを使わずにJSON形式で保存
// 理由：スタンドアロンスクリプトからSwiftDataを使うのは複雑なため

print("🚀 Pokedex Database Generator")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

// コマンドライン引数から最大IDを取得
let maxId = CommandLine.arguments.count > 1 ? Int(CommandLine.arguments[1]) ?? 151 : 151

print("📊 Target: \(maxId) Pokemon")
print("⏱️  Estimated time: ~\(maxId / 10) minutes")
print("")

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

// 出力先ディレクトリ（プロジェクト内）
let outputDir = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData"
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

var allPokemon: [PokemonData] = []
var successCount = 0
var failedIds: [Int] = []

// PokéAPIから取得
for id in 1...maxId {
    let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)/")!

    do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        // データパース
        let name = json["name"] as! String
        let height = json["height"] as! Int
        let weight = json["weight"] as! Int

        // タイプ
        let typesJson = json["types"] as! [[String: Any]]
        let types = typesJson.map { typeData -> PokemonData.TypeData in
            let slot = typeData["slot"] as! Int
            let type = typeData["type"] as! [String: Any]
            let typeName = type["name"] as! String
            return PokemonData.TypeData(slot: slot, name: typeName)
        }

        // ステータス
        let statsJson = json["stats"] as! [[String: Any]]
        let stats = statsJson.map { statData -> PokemonData.StatData in
            let baseStat = statData["base_stat"] as! Int
            let stat = statData["stat"] as! [String: Any]
            let statName = stat["name"] as! String
            return PokemonData.StatData(name: statName, baseStat: baseStat)
        }

        // 特性
        let abilitiesJson = json["abilities"] as! [[String: Any]]
        let abilities = abilitiesJson.map { abilityData -> PokemonData.AbilityData in
            let isHidden = abilityData["is_hidden"] as! Bool
            let ability = abilityData["ability"] as! [String: Any]
            let abilityName = ability["name"] as! String
            return PokemonData.AbilityData(name: abilityName, isHidden: isHidden)
        }

        // スプライト
        let spritesJson = json["sprites"] as! [String: Any]
        let frontDefault = spritesJson["front_default"] as? String
        let frontShiny = spritesJson["front_shiny"] as? String

        var homeFrontDefault: String? = nil
        var homeFrontShiny: String? = nil
        if let other = spritesJson["other"] as? [String: Any],
           let home = other["home"] as? [String: Any] {
            homeFrontDefault = home["front_default"] as? String
            homeFrontShiny = home["front_shiny"] as? String
        }

        let sprites = PokemonData.SpriteData(
            frontDefault: frontDefault,
            frontShiny: frontShiny,
            homeFrontDefault: homeFrontDefault,
            homeFrontShiny: homeFrontShiny
        )

        // 技（IDのみ）と登場世代の判定
        let movesJson = json["moves"] as! [[String: Any]]
        var moveIds: [Int] = []
        var generationSet: Set<Int> = []

        for moveData in movesJson {
            // 技IDを抽出
            if let move = moveData["move"] as? [String: Any],
               let url = move["url"] as? String,
               let idStr = url.split(separator: "/").last {
                moveIds.append(Int(idStr)!)
            }

            // version_group_detailsから登場世代を抽出
            if let versionDetails = moveData["version_group_details"] as? [[String: Any]] {
                for detail in versionDetails {
                    if let versionGroup = detail["version_group"] as? [String: Any],
                       let vgUrl = versionGroup["url"] as? String,
                       let vgIdStr = vgUrl.split(separator: "/").last,
                       let vgId = Int(vgIdStr) {
                        // version-group IDから世代を推測
                        // 1-2: gen1, 3-4: gen2, 5-7: gen3, 8-10: gen4, 11-12: gen5
                        // 13-14: gen6, 15-18: gen7, 19-21: gen8, 22-25: gen9
                        let generation: Int
                        switch vgId {
                        case 1...2: generation = 1
                        case 3...4: generation = 2
                        case 5...7: generation = 3
                        case 8...10: generation = 4
                        case 11...12: generation = 5
                        case 13...14: generation = 6
                        case 15...18: generation = 7
                        case 19...21: generation = 8
                        case 22...25: generation = 9
                        default: generation = 1
                        }
                        generationSet.insert(generation)
                    }
                }
            }
        }

        // 登場世代リストをソート
        let availableGenerations = Array(generationSet).sorted()

        let pokemon = PokemonData(
            id: id,
            name: name,
            height: height,
            weight: weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moveIds,
            availableGenerations: availableGenerations
        )

        allPokemon.append(pokemon)
        successCount += 1

        if successCount % 10 == 0 {
            print("✅ Fetched: \(successCount)/\(maxId)")
        }

        // API負荷軽減
        try await Task.sleep(nanoseconds: 50_000_000)

    } catch {
        print("⚠️ Failed to fetch Pokemon #\(id): \(error)")
        failedIds.append(id)
    }
}

// JSON形式で保存
let outputPath = "\(outputDir)/pokemon_data.json"
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let jsonData = try encoder.encode(allPokemon)
try jsonData.write(to: URL(fileURLWithPath: outputPath))

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Database generation completed!")
print("📊 Success: \(successCount)/\(maxId) Pokemon")
if !failedIds.isEmpty {
    print("⚠️ Failed IDs: \(failedIds)")
}
print("📦 Output: \(outputPath)")
let fileSize = try FileManager.default.attributesOfItem(atPath: outputPath)[.size] as! Int
print("💾 File size: \(Double(fileSize) / 1024 / 1024) MB")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
