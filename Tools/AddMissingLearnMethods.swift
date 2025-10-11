#!/usr/bin/env swift

import Foundation

print("🔧 Adding Missing Learn Methods")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

// MARK: - Data Structures (same as before)

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
        let machineNumber: String?
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
}

struct AbilityData: Codable {
    let id: Int
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

// Build machine number cache from existing data
var machineCache: [Int: String] = [:]
for pokemon in data.pokemon {
    for move in pokemon.moves {
        if let machineNumber = move.machineNumber {
            machineCache[move.moveId] = machineNumber
        }
    }
}
print("  - Machine cache: \(machineCache.count) TMs")

// Process each Pokemon
print("")
print("🔍 Checking for missing learn methods...")
var totalAdded = 0
var pokemonUpdated = 0

for i in 0..<data.pokemon.count {
    let pokemonId = data.pokemon[i].id
    var newMoves: [PokemonData.LearnedMove] = []

    // Fetch Pokemon data from PokeAPI
    do {
        let pokemonJson = try await fetchJSON(from: "https://pokeapi.co/api/v2/pokemon/\(pokemonId)")
        await delay()

        // Get current moveIds for this Pokemon
        var existingMoves: [Int: Set<String>] = [:]  // moveId -> Set<learnMethod>
        for move in data.pokemon[i].moves {
            if existingMoves[move.moveId] == nil {
                existingMoves[move.moveId] = []
            }
            existingMoves[move.moveId]?.insert(move.learnMethod)
        }

        // Check all moves from PokeAPI
        let movesArray = pokemonJson["moves"] as? [[String: Any]] ?? []
        for moveEntry in movesArray {
            guard let moveInfo = moveEntry["move"] as? [String: Any],
                  let moveUrl = moveInfo["url"] as? String,
                  let moveIdStr = moveUrl.split(separator: "/").last,
                  let moveId = Int(moveIdStr),
                  let versionDetails = moveEntry["version_group_details"] as? [[String: Any]] else {
                continue
            }

            // Check scarlet-violet learn methods
            for detail in versionDetails {
                guard let versionGroup = detail["version_group"] as? [String: Any],
                      let vgName = versionGroup["name"] as? String,
                      vgName == VERSION_GROUP else {
                    continue
                }

                let learnMethod = (detail["move_learn_method"] as? [String: Any])?["name"] as? String ?? ""
                let level = detail["level_learned_at"] as? Int

                // Check if this combination already exists
                if let methods = existingMoves[moveId], methods.contains(learnMethod) {
                    continue  // Already have this learn method
                }

                // Add missing learn method
                var machineNumber: String? = nil
                if learnMethod == "machine" {
                    machineNumber = machineCache[moveId]
                }

                let newMove = PokemonData.LearnedMove(
                    moveId: moveId,
                    learnMethod: learnMethod,
                    level: level == 0 ? nil : level,
                    machineNumber: machineNumber
                )
                newMoves.append(newMove)
                totalAdded += 1
            }
        }

        if !newMoves.isEmpty {
            data.pokemon[i].moves.append(contentsOf: newMoves)
            pokemonUpdated += 1

            if pokemonUpdated % 100 == 0 {
                print("  Processed \(i + 1)/\(data.pokemon.count) Pokemon... Added \(totalAdded) methods")
            }
        }

    } catch {
        // Skip if failed
        continue
    }
}

print("")
print("✅ Added \(totalAdded) missing learn methods to \(pokemonUpdated) Pokemon")

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
print("✅ Missing learn methods added!")
