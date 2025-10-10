//
//  PokemonModel.swift
//  Pokedex
//
//  SwiftData persistence model for Pokemon
//

import Foundation
import SwiftData

@Model
final class PokemonModel {
    @Attribute(.unique) var id: Int
    var speciesId: Int
    var name: String
    var height: Int
    var weight: Int

    @Relationship(deleteRule: .cascade) var types: [PokemonTypeModel]
    @Relationship(deleteRule: .cascade) var stats: [PokemonStatModel]
    @Relationship(deleteRule: .cascade) var abilities: [PokemonAbilityModel]
    @Relationship(deleteRule: .cascade) var sprites: PokemonSpriteModel?

    var moveIds: [Int]
    var availableGenerations: [Int]

    /// 取得日時（キャッシュ管理用）
    var fetchedAt: Date

    init(
        id: Int,
        speciesId: Int,
        name: String,
        height: Int,
        weight: Int,
        types: [PokemonTypeModel],
        stats: [PokemonStatModel],
        abilities: [PokemonAbilityModel],
        sprites: PokemonSpriteModel?,
        moveIds: [Int],
        availableGenerations: [Int],
        fetchedAt: Date = Date()
    ) {
        self.id = id
        self.speciesId = speciesId
        self.name = name
        self.height = height
        self.weight = weight
        self.types = types
        self.stats = stats
        self.abilities = abilities
        self.sprites = sprites
        self.moveIds = moveIds
        self.availableGenerations = availableGenerations
        self.fetchedAt = fetchedAt
    }
}

@Model
final class PokemonTypeModel {
    var slot: Int
    var name: String

    init(slot: Int, name: String) {
        self.slot = slot
        self.name = name
    }
}

@Model
final class PokemonStatModel {
    var name: String
    var baseStat: Int

    init(name: String, baseStat: Int) {
        self.name = name
        self.baseStat = baseStat
    }
}

@Model
final class PokemonAbilityModel {
    var name: String
    var isHidden: Bool

    init(name: String, isHidden: Bool) {
        self.name = name
        self.isHidden = isHidden
    }
}

@Model
final class PokemonSpriteModel {
    var frontDefault: String?
    var frontShiny: String?
    var homeFrontDefault: String?
    var homeFrontShiny: String?

    init(
        frontDefault: String?,
        frontShiny: String?,
        homeFrontDefault: String?,
        homeFrontShiny: String?
    ) {
        self.frontDefault = frontDefault
        self.frontShiny = frontShiny
        self.homeFrontDefault = homeFrontDefault
        self.homeFrontShiny = homeFrontShiny
    }
}
