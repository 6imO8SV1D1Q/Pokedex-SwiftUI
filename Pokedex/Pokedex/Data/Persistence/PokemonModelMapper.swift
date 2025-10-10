//
//  PokemonModelMapper.swift
//  Pokedex
//
//  Domain Entity ↔ SwiftData Model の変換
//

import Foundation

enum PokemonModelMapper {
    /// Domain Entity → SwiftData Model
    static func toModel(_ pokemon: Pokemon) -> PokemonModel {
        let types = pokemon.types.map { type in
            PokemonTypeModel(slot: type.slot, name: type.name)
        }

        let stats = pokemon.stats.map { stat in
            PokemonStatModel(name: stat.name, baseStat: stat.baseStat)
        }

        let abilities = pokemon.abilities.map { ability in
            PokemonAbilityModel(name: ability.name, isHidden: ability.isHidden)
        }

        // moves → moveIds に変換
        let moveIds = pokemon.moves.map { $0.id }

        let sprites: PokemonSpriteModel?
        if let other = pokemon.sprites.other, let home = other.home {
            sprites = PokemonSpriteModel(
                frontDefault: pokemon.sprites.frontDefault,
                frontShiny: pokemon.sprites.frontShiny,
                homeFrontDefault: home.frontDefault,
                homeFrontShiny: home.frontShiny
            )
        } else {
            sprites = PokemonSpriteModel(
                frontDefault: pokemon.sprites.frontDefault,
                frontShiny: pokemon.sprites.frontShiny,
                homeFrontDefault: nil,
                homeFrontShiny: nil
            )
        }

        return PokemonModel(
            id: pokemon.id,
            speciesId: pokemon.speciesId,
            name: pokemon.name,
            height: pokemon.height,
            weight: pokemon.weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moveIds: moveIds,
            availableGenerations: pokemon.availableGenerations
        )
    }

    /// SwiftData Model → Domain Entity
    static func toDomain(_ model: PokemonModel) -> Pokemon {
        let types = model.types.map { typeModel in
            PokemonType(slot: typeModel.slot, name: typeModel.name)
        }

        let stats = model.stats.map { statModel in
            PokemonStat(name: statModel.name, baseStat: statModel.baseStat)
        }

        let abilities = model.abilities.map { abilityModel in
            PokemonAbility(name: abilityModel.name, isHidden: abilityModel.isHidden)
        }

        // moveIds → moves に変換（最小限の情報のみ）
        let moves = model.moveIds.map { moveId in
            PokemonMove(
                id: moveId,
                name: "",  // プリバンドルデータには名前なし
                learnMethod: "",
                level: nil,
                machineNumber: nil
            )
        }

        let sprites: PokemonSprites
        if let spriteModel = model.sprites {
            sprites = PokemonSprites(
                frontDefault: spriteModel.frontDefault,
                frontShiny: spriteModel.frontShiny,
                other: PokemonSprites.OtherSprites(
                    home: PokemonSprites.OtherSprites.HomeSprites(
                        frontDefault: spriteModel.homeFrontDefault,
                        frontShiny: spriteModel.homeFrontShiny
                    )
                )
            )
        } else {
            sprites = PokemonSprites(
                frontDefault: nil,
                frontShiny: nil,
                other: nil
            )
        }

        return Pokemon(
            id: model.id,
            speciesId: model.speciesId,
            name: model.name,
            height: model.height,
            weight: model.weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moves,
            availableGenerations: model.availableGenerations
        )
    }
}
