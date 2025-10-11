#!/usr/bin/env swift

import Foundation

print("🔧 Adding Machine Numbers to Pokemon Data")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

// MARK: - Data Structures

struct GameData: Codable {
    let dataVersion: String
    let lastUpdated: String
    let versionGroup: String
    let versionGroupId: Int
    let generation: Int
    var pokemon: [PokemonData]
    let moves: [MoveData]
    let abilities: [AbilityData]
}

struct PokemonData: Codable {
    let id: Int
    let nationalDexNumber: Int
    let name: String
    let nameJa: String
    let genus: String
    let genusJa: String
    let sprites: SpriteData
    let types: [String]
    let abilities: AbilitySet
    let baseStats: BaseStats
    var moves: [LearnedMove]
    let eggGroups: [String]
    let genderRate: Int
    let height: Int
    let weight: Int
    let evolutionChain: EvolutionInfo
    let varieties: [Int]
    let pokedexNumbers: [String: Int]
    let category: String

    struct SpriteData: Codable {
        let normal: String
        let shiny: String
    }

    struct AbilitySet: Codable {
        let primary: [Int]
        let hidden: Int?
    }

    struct BaseStats: Codable {
        let hp: Int
        let attack: Int
        let defense: Int
        let spAttack: Int
        let spDefense: Int
        let speed: Int
        let total: Int
    }

    struct LearnedMove: Codable {
        let moveId: Int
        let learnMethod: String
        let level: Int?
        var machineNumber: String?
    }

    struct EvolutionInfo: Codable {
        let chainId: Int
        let evolutionStage: Int
        let evolvesFrom: Int?
        let evolvesTo: [Int]
        let canUseEviolite: Bool
    }
}

struct MoveData: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let type: String
    let damageClass: String
    let power: Int?
    let accuracy: Int?
    let pp: Int
    let priority: Int
    let effectChance: Int?
    let effect: String
    let effectJa: String
    let meta: MoveMeta

    struct MoveMeta: Codable {
        let ailment: String
        let ailmentChance: Int
        let category: String
        let critRate: Int
        let drain: Int
        let flinchChance: Int
        let healing: Int
        let statChance: Int
        let statChanges: [StatChange]

        struct StatChange: Codable {
            let stat: String
            let change: Int
        }
    }
}

struct AbilityData: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let effect: String
    let effectJa: String
}

// MARK: - Helper Functions

func fetchJSON(from urlString: String) async throws -> [String: Any] {
    let url = URL(string: urlString)!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONSerialization.jsonObject(with: data) as! [String: Any]
}

func delay() async {
    try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
}

// MARK: - Main Process

let jsonPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"
let VERSION_GROUP = "scarlet-violet"

// Read JSON
print("📖 Reading JSON...")
guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
    print("❌ Failed to read JSON")
    exit(1)
}

let decoder = JSONDecoder()
guard var data = try? decoder.decode(GameData.self, from: jsonData) else {
    print("❌ Failed to decode JSON")
    exit(1)
}

print("✅ JSON loaded")
print("  - Pokemon: \(data.pokemon.count)")
print("  - Moves: \(data.moves.count)")

// Build machine number cache
print("")
print("🔍 Building machine number cache...")
var machineCache: [Int: String] = [:]  // moveId -> "TM126"

for move in data.moves {
    // Fetch move data from PokeAPI
    do {
        let moveJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/move/\(move.id)")
        await delay()

        let machinesArray = moveJson["machines"] as? [[String: Any]] ?? []
        for machineEntry in machinesArray {
            guard let versionGroup = machineEntry["version_group"] as? [String: Any],
                  let vgName = versionGroup["name"] as? String,
                  vgName == VERSION_GROUP else {
                continue
            }

            // Get machine ID
            guard let machine = machineEntry["machine"] as? [String: Any],
                  let machineUrl = machine["url"] as? String,
                  let machineIdStr = machineUrl.split(separator: "/").last,
                  let machineId = Int(machineIdStr) else {
                continue
            }

            // Fetch machine details
            let machineJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/machine/\(machineId)")
            await delay()

            if let item = machineJson["item"] as? [String: Any],
               let itemName = item["name"] as? String {
                // itemName is like "tm001" or "tm126"
                let machineNumber = itemName.uppercased()  // "TM001" or "TM126"
                machineCache[move.id] = machineNumber
                print("  ✅ \(move.nameJa) (\(move.name)) -> \(machineNumber)")
            }

            break
        }
    } catch {
        // Skip if failed
    }
}

print("")
print("✅ Machine cache built: \(machineCache.count) TMs")

// Update Pokemon moves
print("")
print("🔄 Updating Pokemon move data...")
var updatedCount = 0

for i in 0..<data.pokemon.count {
    var pokemonUpdated = false

    for j in 0..<data.pokemon[i].moves.count {
        let moveId = data.pokemon[i].moves[j].moveId
        let learnMethod = data.pokemon[i].moves[j].learnMethod

        if learnMethod == "machine", let machineNumber = machineCache[moveId] {
            data.pokemon[i].moves[j].machineNumber = machineNumber
            pokemonUpdated = true
        }
    }

    if pokemonUpdated {
        updatedCount += 1
        if updatedCount % 100 == 0 {
            print("  Updated \(updatedCount)/\(data.pokemon.count) Pokemon...")
        }
    }
}

print("✅ Updated \(updatedCount) Pokemon")

// Write back to JSON
print("")
print("💾 Writing updated JSON...")
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

guard let updatedJson = try? encoder.encode(data) else {
    print("❌ Failed to encode JSON")
    exit(1)
}

do {
    try updatedJson.write(to: URL(fileURLWithPath: jsonPath))
    let fileSize = Double(updatedJson.count) / 1_000_000.0
    print("✅ JSON updated successfully")
    print("📦 Output: \(jsonPath)")
    print("💾 File size: \(String(format: "%.2f", fileSize)) MB")
} catch {
    print("❌ Failed to write JSON: \(error)")
    exit(1)
}

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Machine numbers added!")
