#!/usr/bin/env swift

import Foundation

// JSON structure
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

// Translation helper
func translateMoveEffect(_ effect: String) -> String {
    // Common patterns translation
    var translated = effect

    // Basic damage patterns
    translated = translated.replacingOccurrences(of: "Inflicts regular damage.", with: "通常のダメージを与える。")
    translated = translated.replacingOccurrences(of: "Inflicts damage", with: "ダメージを与える")

    // Chance patterns
    translated = translated.replacingOccurrences(of: "Has a (\\d+)% chance", with: "$1%の確率", options: .regularExpression)
    translated = translated.replacingOccurrences(of: "to paralyze the target", with: "で相手をまひ状態にする")
    translated = translated.replacingOccurrences(of: "to burn the target", with: "で相手をやけど状態にする")
    translated = translated.replacingOccurrences(of: "to freeze the target", with: "で相手をこおり状態にする")
    translated = translated.replacingOccurrences(of: "to poison the target", with: "で相手をどく状態にする")
    translated = translated.replacingOccurrences(of: "to confuse the target", with: "で相手をこんらん状態にする")
    translated = translated.replacingOccurrences(of: "to make the target flinch", with: "で相手をひるませる")

    // Priority
    translated = translated.replacingOccurrences(of: "Inflicts regular damage with no additional effect.", with: "通常のダメージを与える。追加効果なし。")

    // Multi-hit
    translated = translated.replacingOccurrences(of: "Hits 2-5 times in one turn.", with: "1ターンに2〜5回連続で攻撃する。")
    translated = translated.replacingOccurrences(of: "Hits twice in one turn.", with: "1ターンに2回攻撃する。")

    // Stats
    translated = translated.replacingOccurrences(of: "Raises the user's Attack", with: "自分の攻撃")
    translated = translated.replacingOccurrences(of: "Lowers the target's Defense", with: "相手の防御")
    translated = translated.replacingOccurrences(of: "by one stage", with: "を1段階上げる")
    translated = translated.replacingOccurrences(of: "by two stages", with: "を2段階上げる")

    // If still same as original (not translated), return it with note
    if translated == effect && !effect.isEmpty {
        // Keep English for now - will translate in batches
        return effect
    }

    return translated
}

func translateAbilityEffect(_ effect: String) -> String {
    var translated = effect

    // Common patterns
    translated = translated.replacingOccurrences(of: "This Pokémon's", with: "このポケモンの")
    translated = translated.replacingOccurrences(of: "When this Pokémon", with: "このポケモンが")
    translated = translated.replacingOccurrences(of: "enters battle", with: "戦闘に出たとき")

    // If still same, keep English for now
    if translated == effect && !effect.isEmpty {
        return effect
    }

    return translated
}

// Main process
print("📖 Translation Process Starting...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

let inputPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"
let outputPath = inputPath // Overwrite the same file

// Read JSON
guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: inputPath)) else {
    print("❌ Failed to read JSON file")
    exit(1)
}

let decoder = JSONDecoder()
guard var data = try? decoder.decode(ScarletVioletData.self, from: jsonData) else {
    print("❌ Failed to decode JSON")
    exit(1)
}

print("✅ JSON loaded successfully")
print("  - Moves: \(data.moves.count)")
print("  - Abilities: \(data.abilities.count)")
print("")

// Translate moves
print("📊 Translating move effects...")
for i in 0..<data.moves.count {
    let original = data.moves[i].effect
    data.moves[i].effectJa = translateMoveEffect(original)

    if (i + 1) % 100 == 0 {
        print("  [\(i + 1)/\(data.moves.count)] moves processed")
    }
}
print("✅ All moves translated")

// Translate abilities
print("📊 Translating ability effects...")
for i in 0..<data.abilities.count {
    let original = data.abilities[i].effect
    data.abilities[i].effectJa = translateAbilityEffect(original)

    if (i + 1) % 50 == 0 {
        print("  [\(i + 1)/\(data.abilities.count)] abilities processed")
    }
}
print("✅ All abilities translated")

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
    try updatedJson.write(to: URL(fileURLWithPath: outputPath))
    print("✅ JSON updated successfully")
    print("📦 Output: \(outputPath)")
} catch {
    print("❌ Failed to write JSON: \(error)")
    exit(1)
}

print("")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print("✅ Translation completed!")
