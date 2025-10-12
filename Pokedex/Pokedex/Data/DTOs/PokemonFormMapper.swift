//
//  PokemonFormMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum PokemonFormMapper {
    /// PKMPokemonからPokemonFormにマッピング
    nonisolated static func map(from pkm: PKMPokemon) -> [PokemonForm] {
        // TODO: フェーズ1-7で実装
        // 現在はデフォルトフォームのみ返す簡易実装
        guard let id = pkm.id, let name = pkm.name else {
            return []
        }

        let defaultForm = PokemonForm(
            id: id,
            name: name,
            pokemonId: id,
            formName: "normal",
            types: mapTypes(from: pkm.types),
            sprites: mapSprites(from: pkm.sprites),
            stats: mapStats(from: pkm.stats),
            abilities: mapAbilities(from: pkm.abilities),
            isDefault: true,
            isMega: false,
            isRegional: false,
            versionGroup: nil
        )

        return [defaultForm]
    }

    // MARK: - Private Helpers

    nonisolated private static func mapTypes(from types: [PKMPokemonType]?) -> [PokemonType] {
        guard let types = types else { return [] }

        return types.compactMap { type in
            guard let typeName = type.type?.name else { return nil }
            return PokemonType(slot: type.slot ?? 1, name: typeName)
        }
    }

    nonisolated private static func mapSprites(from sprites: PKMPokemonSprites?) -> PokemonSprites {
        PokemonSprites(
            frontDefault: sprites?.frontDefault,
            frontShiny: sprites?.frontShiny,
            other: sprites?.other.map { other in
                PokemonSprites.OtherSprites(
                    home: other.home.map { home in
                        PokemonSprites.OtherSprites.HomeSprites(
                            frontDefault: home.frontDefault,
                            frontShiny: home.frontShiny
                        )
                    }
                )
            }
        )
    }

    nonisolated private static func mapStats(from stats: [PKMPokemonStat]?) -> [PokemonStat] {
        guard let stats = stats else { return [] }

        return stats.compactMap { stat in
            guard let statName = stat.stat?.name, let baseStat = stat.baseStat else {
                return nil
            }
            return PokemonStat(name: statName, baseStat: baseStat)
        }
    }

    nonisolated private static func mapAbilities(from abilities: [PKMPokemonAbility]?) -> [PokemonAbility] {
        guard let abilities = abilities else { return [] }

        return abilities.compactMap { ability in
            guard let abilityName = ability.ability?.name else { return nil }
            return PokemonAbility(
                name: abilityName,
                nameJa: nil,
                isHidden: ability.isHidden ?? false
            )
        }
    }
}
