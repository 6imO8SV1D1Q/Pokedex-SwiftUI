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
            sprites: mapSprites(from: pkm.sprites)
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
        PokemonSprites(
            frontDefault: sprites?.frontDefault,
            frontShiny: sprites?.frontShiny
        )
    }
}
