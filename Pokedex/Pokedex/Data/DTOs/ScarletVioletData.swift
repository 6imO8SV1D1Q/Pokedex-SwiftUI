//
//  ScarletVioletData.swift
//  Pokedex
//
//  JSON data structures for Scarlet/Violet preloaded data
//

import Foundation

// MARK: - Game Data

struct GameData: Codable {
    let dataVersion: String
    let lastUpdated: String
    let versionGroup: String
    let versionGroupId: Int
    let generation: Int
    let pokemon: [PokemonData]
    let moves: [MoveData]
    let abilities: [AbilityData]
    let types: [String: TypeData]
    let pokedexes: [PokedexData]?
}

struct PokedexData: Codable {
    let name: String
    let speciesIds: [Int]
}

// MARK: - Type Data

struct TypeData: Codable {
    let name: String
    let nameJa: String
}

// MARK: - Pokemon Data

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
    let moves: [LearnedMove]
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

// MARK: - Move Data

struct MoveData: Codable {
    let id: Int
    let name: String?
    let nameJa: String?
    let type: String?
    let damageClass: String?
    let power: Int?
    let accuracy: Int?
    let pp: Int?
    let priority: Int?
    let effectChance: Int?
    let effect: String?
    let effectJa: String?
    let categories: [String]?
    let meta: MoveMeta?

    struct MoveMeta: Codable {
        let ailment: String?
        let ailmentChance: Int?
        let category: String?
        let critRate: Int?
        let drain: Int?
        let flinchChance: Int?
        let healing: Int?
        let statChance: Int?
        let statChanges: [StatChange]?

        struct StatChange: Codable {
            let stat: String
            let change: Int
        }
    }
}

// MARK: - Ability Data

struct AbilityData: Codable {
    let id: Int
    let name: String?
    let nameJa: String?
    let effect: String?
    let effectJa: String?
}
