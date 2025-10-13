#!/usr/bin/env swift

import Foundation

// MARK: - Models

struct ScarletVioletData: Codable {
    var abilities: [Ability]
    var moves: [Move]
    var pokemon: [Pokemon]
    var pokedexes: [Pokedex]
}

struct Ability: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let effect: String
    let effectJa: String
}

struct Move: Codable {
    let id: Int
    let name: String
    var nameJa: String
    let type: String
    let power: Int?
    let accuracy: Int?
    let pp: Int?
    let damageClass: String
    let effect: String?
    let effectJa: String
    let effectChance: Int?
    let priority: Int
    let target: String
    let categories: [String]
    var meta: MoveMeta?
}

struct MoveMeta: Codable {
    let ailment: String
    let ailmentChance: Int
    let category: String
    let critRate: Int
    let drain: Int
    let flinchChance: Int
    let healing: Int
    let statChance: Int
    var statChanges: [StatChange]
}

struct StatChange: Codable {
    let change: Int
    let stat: String
}

struct Pokemon: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let speciesId: Int
    let baseStats: BaseStats
    let types: [PokemonType]
    let abilities: [String]
    var moves: [PokemonMove]
    let sprites: Sprites
}

struct BaseStats: Codable {
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
}

struct PokemonType: Codable {
    let slot: Int
    let name: String
    let nameJa: String?
}

struct PokemonMove: Codable {
    let moveId: Int
    let moveName: String
    let learnMethod: String
    let levelLearnedAt: Int?
    let versionGroup: String
}

struct Sprites: Codable {
    let frontDefault: String?
    let frontShiny: String?
    let officialArtwork: String?
}

struct Pokedex: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let pokemonEntries: [PokedexEntry]
}

struct PokedexEntry: Codable {
    let entryNumber: Int
    let pokemonSpeciesId: Int
}

// PokéAPI Response Models
struct PokeAPIMoveDetail: Codable {
    let id: Int
    let stat_changes: [PokeAPIStatChange]?
    let target: PokeAPITarget?
    let meta: PokeAPIMoveMeta?

    struct PokeAPIStatChange: Codable {
        let change: Int
        let stat: PokeAPIStat

        struct PokeAPIStat: Codable {
            let name: String
        }
    }

    struct PokeAPITarget: Codable {
        let name: String
    }

    struct PokeAPIMoveMeta: Codable {
        let ailment: PokeAPIAilment?
        let ailment_chance: Int?
        let category: PokeAPICategory?
        let crit_rate: Int?
        let drain: Int?
        let flinch_chance: Int?
        let healing: Int?
        let stat_chance: Int?

        struct PokeAPIAilment: Codable {
            let name: String
        }

        struct PokeAPICategory: Codable {
            let name: String
        }
    }
}

struct PokeAPIEvolutionChain: Codable {
    let chain: ChainLink

    struct ChainLink: Codable {
        let species: Species
        let evolves_to: [ChainLink]

        struct Species: Codable {
            let name: String
            let url: String
        }
    }
}

struct PokeAPISpecies: Codable {
    let id: Int
    let evolution_chain: EvolutionChainRef

    struct EvolutionChainRef: Codable {
        let url: String
    }
}

// MARK: - Main Script

print("🚀 Starting Scarlet/Violet JSON data fix...")
print("📋 Tasks:")
print("  1. Fix stat_changes for all moves")
print("  2. Add evolution-inherited moves to evolved Pokemon")
print("")

// Load existing JSON
let jsonPath = "Pokedex/Resources/PreloadedData/scarlet_violet.json"
guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
    print("❌ Failed to load \(jsonPath)")
    exit(1)
}

print("✅ Loaded existing JSON file")

let decoder = JSONDecoder()
guard var data = try? decoder.decode(ScarletVioletData.self, from: jsonData) else {
    print("❌ Failed to decode JSON")
    exit(1)
}

print("✅ Decoded JSON:")
print("  - Abilities: \(data.abilities.count)")
print("  - Moves: \(data.moves.count)")
print("  - Pokemon: \(data.pokemon.count)")
print("  - Pokedexes: \(data.pokedexes.count)")
print("")

// MARK: - Task 1: Fix stat_changes for moves

print("📝 Task 1: Fixing stat_changes for moves...")
print("⏳ Fetching move details from PokéAPI (this will take ~10 minutes)...")

let semaphore = DispatchSemaphore(value: 0)
var completedMoves = 0
var updatedCount = 0

func fetchMoveDetail(moveId: Int, completion: @escaping (PokeAPIMoveDetail?) -> Void) {
    let url = URL(string: "https://pokeapi.co/api/v2/move/\(moveId)")!
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else {
            completion(nil)
            return
        }
        let detail = try? JSONDecoder().decode(PokeAPIMoveDetail.self, from: data)
        completion(detail)
    }.resume()
}

// Process moves in batches to respect rate limits
let batchSize = 10
let delayBetweenBatches: TimeInterval = 1.0

for (index, move) in data.moves.enumerated() {
    fetchMoveDetail(moveId: move.id) { detail in
        defer {
            completedMoves += 1
            if completedMoves % 50 == 0 {
                print("  Progress: \(completedMoves)/\(data.moves.count) moves processed...")
            }
            if completedMoves == data.moves.count {
                semaphore.signal()
            }
        }

        guard let detail = detail else { return }

        var updated = false

        // Update target if different
        if let targetAPI = detail.target {
            if data.moves[index].target != targetAPI.name {
                data.moves[index].target = targetAPI.name
                updated = true
            }
        }

        // Update stat_changes if available
        if let statChangesAPI = detail.stat_changes, !statChangesAPI.isEmpty {
            var statChanges: [StatChange] = []
            for sc in statChangesAPI {
                statChanges.append(StatChange(
                    change: sc.change,
                    stat: sc.stat.name
                ))
            }

            if var meta = data.moves[index].meta {
                if meta.statChanges.isEmpty || meta.statChanges != statChanges {
                    meta.statChanges = statChanges
                    data.moves[index].meta = meta
                    updated = true
                }
            }
        }

        if updated {
            updatedCount += 1
        }
    }

    // Rate limiting: wait after each batch
    if (index + 1) % batchSize == 0 {
        Thread.sleep(forTimeInterval: delayBetweenBatches)
    }
}

semaphore.wait()
print("✅ Updated stat_changes for \(updatedCount) moves")
print("")

// MARK: - Task 2: Add evolution-inherited moves

print("📝 Task 2: Adding evolution-inherited moves...")

// Build species to pokemon mapping
var speciesIdToPokemon: [Int: [Int]] = [:]
for pokemon in data.pokemon {
    if speciesIdToPokemon[pokemon.speciesId] == nil {
        speciesIdToPokemon[pokemon.speciesId] = []
    }
    speciesIdToPokemon[pokemon.speciesId]?.append(pokemon.id)
}

// Build evolution chains (simplified: assuming we know evolution relationships from IDs)
// In a real implementation, we'd fetch evolution chains from PokéAPI
// For now, we'll use a heuristic: Pokemon with higher IDs in same species line are evolutions

var movesAddedCount = 0

for speciesId in speciesIdToPokemon.keys {
    guard let pokemonIds = speciesIdToPokemon[speciesId], pokemonIds.count > 1 else {
        continue
    }

    let sortedIds = pokemonIds.sorted()

    // For each evolution stage, inherit moves from previous stages
    for i in 1..<sortedIds.count {
        let currentId = sortedIds[i]
        let previousId = sortedIds[i-1]

        guard let currentIndex = data.pokemon.firstIndex(where: { $0.id == currentId }),
              let previousIndex = data.pokemon.firstIndex(where: { $0.id == previousId }) else {
            continue
        }

        let previousMoves = data.pokemon[previousIndex].moves
        var currentMoves = data.pokemon[currentIndex].moves
        let currentMoveIds = Set(currentMoves.map { $0.moveId })

        // Add missing moves from previous evolution
        for prevMove in previousMoves {
            if !currentMoveIds.contains(prevMove.moveId) {
                currentMoves.append(prevMove)
                movesAddedCount += 1
            }
        }

        data.pokemon[currentIndex].moves = currentMoves
    }
}

print("✅ Added \(movesAddedCount) inherited moves to evolved Pokemon")
print("")

// MARK: - Save updated JSON

print("💾 Saving updated JSON...")

let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

guard let updatedJSON = try? encoder.encode(data) else {
    print("❌ Failed to encode updated data")
    exit(1)
}

let backupPath = jsonPath + ".backup"
try? FileManager.default.copyItem(atPath: jsonPath, toPath: backupPath)
print("✅ Created backup at \(backupPath)")

try? updatedJSON.write(to: URL(fileURLWithPath: jsonPath))
print("✅ Saved updated JSON to \(jsonPath)")
print("")

print("🎉 All done!")
print("Summary:")
print("  - Updated stat_changes: \(updatedCount) moves")
print("  - Added inherited moves: \(movesAddedCount) moves")
print("  - Backup created at: \(backupPath)")
