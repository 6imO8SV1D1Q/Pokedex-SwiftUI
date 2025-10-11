#!/usr/bin/env swift

import Foundation

// JSON structures (same as before)
struct ScarletVioletData: Codable {
    let dataVersion: String
    let lastUpdated: String
    let versionGroup: String
    let versionGroupId: Int
    let generation: Int
    var pokemon: [PokemonData]
    var moves: [MoveData]
    var abilities: [AbilityData]
}

struct PokemonData: Codable {
    let id: Int
    let nationalDexNumber: Int
    let name: String
    let nameJa: String
    let genus: String
    let genusJa: String
    let sprites: Sprites
    let types: [String]
    let abilities: AbilitySet
    let baseStats: BaseStats
    let moves: [LearnedMove]
    let eggGroups: [String]
    let genderRate: Int
    let height: Int
    let weight: Int
    let evolutionChain: EvolutionChain
    let varieties: [Int]
    let pokedexNumbers: [String: Int]
    let category: String

    struct Sprites: Codable {
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

    struct EvolutionChain: Codable {
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
    var effectJa: String
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
    var effectJa: String
}

// Translation dictionary structure
struct TranslationDictionary: Codable {
    let moves: [String: String]
    let abilities: [String: String]
}

// Main process
print("📖 Applying Translations...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

let jsonPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"
let dictPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Tools/translation_dictionary.json"

// Read translation dictionary
guard let dictData = try? Data(contentsOf: URL(fileURLWithPath: dictPath)) else {
    print("❌ Failed to read translation dictionary")
    exit(1)
}

let decoder = JSONDecoder()
guard let dict = try? decoder.decode(TranslationDictionary.self, from: dictData) else {
    print("❌ Failed to decode translation dictionary")
    exit(1)
}

print("✅ Translation dictionary loaded")
print("  - Move translations: \(dict.moves.count)")
print("  - Ability translations: \(dict.abilities.count)")

// Read JSON
guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
    print("❌ Failed to read JSON file")
    exit(1)
}

guard var data = try? decoder.decode(ScarletVioletData.self, from: jsonData) else {
    print("❌ Failed to decode JSON")
    exit(1)
}

print("✅ JSON loaded")

// Apply translations
var movesTranslated = 0
for i in 0..<data.moves.count {
    var effect = data.moves[i].effect
    // Normalize smart quotes to regular quotes (Unicode -> ASCII)
    effect = effect.replacingOccurrences(of: "\u{2018}", with: "'")  // ' -> '
    effect = effect.replacingOccurrences(of: "\u{2019}", with: "'")  // ' -> '
    effect = effect.replacingOccurrences(of: "\u{201C}", with: "\"") // " -> "
    effect = effect.replacingOccurrences(of: "\u{201D}", with: "\"") // " -> "

    if let translation = dict.moves[effect] {
        data.moves[i].effectJa = translation
        movesTranslated += 1
    }
}

var abilitiesTranslated = 0
for i in 0..<data.abilities.count {
    var effect = data.abilities[i].effect
    // Normalize smart quotes to regular quotes (Unicode -> ASCII)
    effect = effect.replacingOccurrences(of: "\u{2018}", with: "'")  // ' -> '
    effect = effect.replacingOccurrences(of: "\u{2019}", with: "'")  // ' -> '
    effect = effect.replacingOccurrences(of: "\u{201C}", with: "\"") // " -> "
    effect = effect.replacingOccurrences(of: "\u{201D}", with: "\"") // " -> "

    if let translation = dict.abilities[effect] {
        data.abilities[i].effectJa = translation
        abilitiesTranslated += 1
    }
}

print("")
print("✅ Translations applied:")
print("  - Moves: \(movesTranslated)/\(data.moves.count)")
print("  - Abilities: \(abilitiesTranslated)/\(data.abilities.count)")

// Write back
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
print("✅ Translation application completed!")
