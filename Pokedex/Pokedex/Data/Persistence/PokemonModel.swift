//
//  PokemonModel.swift
//  Pokedex
//
//  SwiftData persistence model for Pokemon (Scarlet/Violet)
//

import Foundation
import SwiftData

// MARK: - Pokemon Model

@Model
final class PokemonModel {
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int
    var nationalDexNumber: Int
    var name: String
    var nameJa: String
    var genus: String
    var genusJa: String

    var height: Int
    var weight: Int
    var category: String

    // MARK: - Game Data

    var types: [String]
    var typeNamesJa: [String]?  // 日本語名
    var eggGroups: [String]
    var genderRate: Int

    // MARK: - Abilities

    var primaryAbilities: [Int]
    var primaryAbilityNames: [String]?  // 英語名
    var primaryAbilityNamesJa: [String]?  // 日本語名
    var hiddenAbility: Int?
    var hiddenAbilityName: String?  // 英語名
    var hiddenAbilityNameJa: String?  // 日本語名

    // MARK: - Stats

    var baseStats: PokemonBaseStatsModel?

    // MARK: - Sprites

    var sprites: PokemonSpriteModel?

    // MARK: - Moves

    var moves: [PokemonLearnedMoveModel]

    // MARK: - Evolution

    var evolutionChain: PokemonEvolutionModel?

    // MARK: - Varieties & Pokedex

    var varieties: [Int]
    var pokedexNumbers: [String: Int]

    // MARK: - Cache

    var fetchedAt: Date

    init(
        id: Int,
        nationalDexNumber: Int,
        name: String,
        nameJa: String,
        genus: String,
        genusJa: String,
        height: Int,
        weight: Int,
        category: String,
        types: [String],
        typeNamesJa: [String]? = nil,
        eggGroups: [String],
        genderRate: Int,
        primaryAbilities: [Int],
        primaryAbilityNames: [String]? = nil,
        primaryAbilityNamesJa: [String]? = nil,
        hiddenAbility: Int? = nil,
        hiddenAbilityName: String? = nil,
        hiddenAbilityNameJa: String? = nil,
        baseStats: PokemonBaseStatsModel? = nil,
        sprites: PokemonSpriteModel? = nil,
        moves: [PokemonLearnedMoveModel] = [],
        evolutionChain: PokemonEvolutionModel? = nil,
        varieties: [Int] = [],
        pokedexNumbers: [String: Int] = [:],
        fetchedAt: Date = Date()
    ) {
        self.id = id
        self.nationalDexNumber = nationalDexNumber
        self.name = name
        self.nameJa = nameJa
        self.genus = genus
        self.genusJa = genusJa
        self.height = height
        self.weight = weight
        self.category = category
        self.types = types
        self.typeNamesJa = typeNamesJa
        self.eggGroups = eggGroups
        self.genderRate = genderRate
        self.primaryAbilities = primaryAbilities
        self.primaryAbilityNames = primaryAbilityNames
        self.primaryAbilityNamesJa = primaryAbilityNamesJa
        self.hiddenAbility = hiddenAbility
        self.hiddenAbilityName = hiddenAbilityName
        self.hiddenAbilityNameJa = hiddenAbilityNameJa
        self.baseStats = baseStats
        self.sprites = sprites
        self.moves = moves
        self.evolutionChain = evolutionChain
        self.varieties = varieties
        self.pokedexNumbers = pokedexNumbers
        self.fetchedAt = fetchedAt
    }
}

// MARK: - Base Stats Model

struct PokemonBaseStatsModel: Codable {
    var hp: Int
    var attack: Int
    var defense: Int
    var spAttack: Int
    var spDefense: Int
    var speed: Int
    var total: Int
}

// MARK: - Sprite Model

struct PokemonSpriteModel: Codable {
    var normal: String
    var shiny: String
}

// MARK: - Learned Move Model

struct PokemonLearnedMoveModel: Codable {
    var pokemonId: Int
    var moveId: Int
    var learnMethod: String
    var level: Int?
    var machineNumber: String?
}

// MARK: - Evolution Model

struct PokemonEvolutionModel: Codable {
    var chainId: Int
    var evolutionStage: Int
    var evolvesFrom: Int?
    var evolvesTo: [Int]
    var canUseEviolite: Bool
}
