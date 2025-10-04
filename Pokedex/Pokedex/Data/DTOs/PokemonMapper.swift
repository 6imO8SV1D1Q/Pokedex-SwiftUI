//
//  PokemonMapper.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import PokemonAPI

enum PokemonMapper {
    nonisolated static func map(from pkm: PKMPokemon) -> Pokemon {
        Pokemon(
            id: pkm.id ?? 0,
            name: pkm.name ?? "",
            height: pkm.height ?? 0,
            weight: pkm.weight ?? 0,
            types: mapTypes(from: pkm.types),
            stats: mapStats(from: pkm.stats),
            abilities: mapAbilities(from: pkm.abilities),
            sprites: mapSprites(from: pkm.sprites),
            moves: mapMoves(from: pkm.moves)
        )
    }

    private static func mapTypes(from types: [PKMPokemonType]?) -> [PokemonType] {
        guard let types = types else { return [] }
        return types.compactMap { type in
            guard let slot = type.slot, let name = type.type?.name else { return nil }
            return PokemonType(slot: slot, name: name)
        }
    }

    private static func mapStats(from stats: [PKMPokemonStat]?) -> [PokemonStat] {
        guard let stats = stats else { return [] }
        return stats.compactMap { stat in
            guard let name = stat.stat?.name, let baseStat = stat.baseStat else { return nil }
            return PokemonStat(name: name, baseStat: baseStat)
        }
    }

    private static func mapAbilities(from abilities: [PKMPokemonAbility]?) -> [PokemonAbility] {
        guard let abilities = abilities else { return [] }
        return abilities.compactMap { ability in
            guard let name = ability.ability?.name else { return nil }
            return PokemonAbility(name: name, isHidden: ability.isHidden ?? false)
        }
    }

    private static func mapSprites(from sprites: PKMPokemonSprites?) -> PokemonSprites {
        let homeSprites: PokemonSprites.OtherSprites.HomeSprites? = {
            guard let home = sprites?.other?.home else { return nil }
            return PokemonSprites.OtherSprites.HomeSprites(
                frontDefault: home.frontDefault,
                frontShiny: home.frontShiny
            )
        }()

        let otherSprites: PokemonSprites.OtherSprites? = homeSprites != nil ?
            PokemonSprites.OtherSprites(home: homeSprites) : nil

        return PokemonSprites(
            frontDefault: sprites?.frontDefault,
            frontShiny: sprites?.frontShiny,
            other: otherSprites
        )
    }

    private static func mapMoves(from moves: [PKMPokemonMove]?) -> [PokemonMove] {
        guard let moves = moves else { return [] }
        return moves.compactMap { move in
            guard let moveName = move.move?.name else { return nil }

            // 最新の習得方法を取得（versionGroupDetailsの最後の要素）
            guard let latestDetail = move.versionGroupDetails?.last else { return nil }

            return PokemonMove(
                name: moveName,
                learnMethod: latestDetail.moveLearnMethod?.name ?? "unknown",
                level: latestDetail.levelLearnedAt
            )
        }
    }
}
