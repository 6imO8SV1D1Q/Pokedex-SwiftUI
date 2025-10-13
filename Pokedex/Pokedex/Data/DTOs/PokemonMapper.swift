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
        /// Version groupと世代のマッピング
        let versionGroupToGeneration: [String: Int] = [
            "red-blue": 1, "yellow": 1,
            "gold-silver": 2, "crystal": 2,
            "ruby-sapphire": 3, "emerald": 3, "firered-leafgreen": 3, "colosseum": 3, "xd": 3,
            "diamond-pearl": 4, "platinum": 4, "heartgold-soulsilver": 4,
            "black-white": 5, "black-2-white-2": 5,
            "x-y": 6, "omega-ruby-alpha-sapphire": 6,
            "sun-moon": 7, "ultra-sun-ultra-moon": 7, "lets-go-pikachu-lets-go-eevee": 7,
            "sword-shield": 8, "brilliant-diamond-shining-pearl": 8, "legends-arceus": 8,
            "scarlet-violet": 9
        ]
        // species.urlからIDを抽出（例: "https://pokeapi.co/api/v2/pokemon-species/25/" → 25）
        let speciesId: Int = {
            guard let urlString = pkm.species?.url else {
                return pkm.id ?? 0
            }

            // URLの末尾の数字を抽出: "/pokemon-species/26/" → "26"
            let components = urlString.split(separator: "/")
            guard components.count >= 2,
                  let id = Int(components[components.count - 1]) else {
                return pkm.id ?? 0
            }

            return id
        }()

        // movesから登場可能な世代を抽出
        let availableGenerations = extractAvailableGenerations(from: pkm.moves, versionMapping: versionGroupToGeneration)

        return Pokemon(
            id: pkm.id ?? 0,
            speciesId: speciesId,
            name: pkm.name ?? "",
            nameJa: nil,  // API経由では取得不可
            genus: nil,  // API経由では取得不可
            genusJa: nil,  // API経由では取得不可
            height: pkm.height ?? 0,
            weight: pkm.weight ?? 0,
            category: nil,  // API経由では取得不可
            types: mapTypes(from: pkm.types),
            stats: mapStats(from: pkm.stats),
            abilities: mapAbilities(from: pkm.abilities),
            sprites: mapSprites(from: pkm.sprites),
            moves: mapMoves(from: pkm.moves),
            availableGenerations: availableGenerations,
            nationalDexNumber: nil,  // API経由では取得不可
            eggGroups: nil,  // API経由では取得不可
            genderRate: nil,  // API経由では取得不可
            pokedexNumbers: nil,  // API経由では取得不可
            varieties: nil,  // API経由では取得不可
            evolutionChain: nil  // API経由では取得不可
        )
    }

    /// movesから登場可能な世代を抽出
    nonisolated private static func extractAvailableGenerations(from moves: [PKMPokemonMove]?, versionMapping: [String: Int]) -> [Int] {
        guard let moves = moves, !moves.isEmpty else { return [] }

        var generations = Set<Int>()

        for move in moves {
            guard let versionGroupDetails = move.versionGroupDetails else { continue }

            for detail in versionGroupDetails {
                guard let versionGroupName = detail.versionGroup?.name else { continue }

                if let generation = versionMapping[versionGroupName] {
                    generations.insert(generation)
                }
            }
        }

        return generations.sorted()
    }

    nonisolated private static func mapTypes(from types: [PKMPokemonType]?) -> [PokemonType] {
        guard let types = types else { return [] }
        return types.compactMap { type in
            guard let slot = type.slot, let name = type.type?.name else { return nil }
            return PokemonType(slot: slot, name: name, nameJa: nil)
        }
    }

    nonisolated private static func mapStats(from stats: [PKMPokemonStat]?) -> [PokemonStat] {
        guard let stats = stats else { return [] }
        return stats.compactMap { stat in
            guard let name = stat.stat?.name, let baseStat = stat.baseStat else { return nil }
            return PokemonStat(name: name, baseStat: baseStat)
        }
    }

    nonisolated private static func mapAbilities(from abilities: [PKMPokemonAbility]?) -> [PokemonAbility] {
        guard let abilities = abilities else { return [] }
        return abilities.compactMap { ability in
            guard let name = ability.ability?.name else { return nil }
            return PokemonAbility(name: name, nameJa: nil, isHidden: ability.isHidden ?? false)
        }
    }

    nonisolated private static func mapSprites(from sprites: PKMPokemonSprites?) -> PokemonSprites {
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

    nonisolated private static func mapMoves(from moves: [PKMPokemonMove]?) -> [PokemonMove] {
        guard let moves = moves else { return [] }
        return moves.compactMap { move in
            guard let moveName = move.move?.name else { return nil }

            // URLから技IDを抽出
            let moveId: Int
            if let urlString = move.move?.url,
               let urlComponents = urlString.split(separator: "/").last,
               let id = Int(urlComponents) {
                moveId = id
            } else {
                return nil  // IDが取得できない場合はスキップ
            }

            // 最新の習得方法を取得（versionGroupDetailsの最後の要素）
            guard let latestDetail = move.versionGroupDetails?.last else { return nil }

            let learnMethod = latestDetail.moveLearnMethod?.name ?? "unknown"

            // レベルアップ技の場合のみlevelを設定
            let level: Int? = (learnMethod == "level-up") ? latestDetail.levelLearnedAt : nil

            return PokemonMove(
                id: moveId,
                name: moveName,
                learnMethod: learnMethod,
                level: level,
                machineNumber: nil  // マシン番号は技詳細取得時に設定
            )
        }
    }
}
