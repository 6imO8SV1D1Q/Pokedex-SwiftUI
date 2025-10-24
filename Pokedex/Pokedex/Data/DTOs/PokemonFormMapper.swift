//
//  PokemonFormMapper.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation
import PokemonAPI

enum PokemonFormMapper {
    /// PKMPokemonから単一のPokemonFormにマッピング
    nonisolated static func mapSingle(from pkm: PKMPokemon, isDefault: Bool) -> PokemonForm {
        let id = pkm.id ?? 0
        let name = pkm.name ?? "unknown"

        // speciesIdを取得（species.urlから抽出）
        let speciesId = extractSpeciesId(from: pkm) ?? id

        // フォーム名を取得（forms配列から、またはname自体から）
        let formName = extractFormName(from: pkm)

        // リージョンフォーム判定
        let isRegional = formName.contains("alola") ||
                        formName.contains("galar") ||
                        formName.contains("hisui") ||
                        formName.contains("paldea")

        // メガシンカ判定
        let isMega = formName.contains("mega") || formName.contains("primal")

        return PokemonForm(
            id: id,
            name: name,
            pokemonId: id,
            speciesId: speciesId,
            formName: formName,
            types: mapTypes(from: pkm.types),
            sprites: mapSprites(from: pkm.sprites),
            stats: mapStats(from: pkm.stats),
            abilities: mapAbilities(from: pkm.abilities),
            isDefault: isDefault,
            isMega: isMega,
            isRegional: isRegional,
            versionGroup: nil
        )
    }

    /// speciesIdをPKMPokemonから抽出
    nonisolated private static func extractSpeciesId(from pkm: PKMPokemon) -> Int? {
        guard let urlString = pkm.species?.url else {
            return nil
        }

        // URLの末尾の数字を抽出: "/pokemon-species/26/" → "26"
        let components = urlString.split(separator: "/")
        guard let lastComponent = components.last,
              let id = Int(lastComponent) else {
            return nil
        }

        return id
    }

    /// フォーム名を抽出
    nonisolated private static func extractFormName(from pkm: PKMPokemon) -> String {
        // nameから抽出（例: "raichu-alola" -> "alola"）
        guard let name = pkm.name else { return "normal" }

        let components = name.split(separator: "-")
        if components.count > 1 {
            // "raichu-alola" -> "alola"
            return components.dropFirst().joined(separator: "-")
        }

        return "normal"
    }

    // MARK: - Private Helpers

    nonisolated private static func mapTypes(from types: [PKMPokemonType]?) -> [PokemonType] {
        guard let types = types else { return [] }

        return types.compactMap { type in
            guard let typeName = type.type?.name else { return nil }
            return PokemonType(slot: type.slot ?? 1, name: typeName, nameJa: nil)
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
