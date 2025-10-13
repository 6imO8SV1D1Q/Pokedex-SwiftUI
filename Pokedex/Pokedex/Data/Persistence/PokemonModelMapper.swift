//
//  PokemonModelMapper.swift
//  Pokedex
//
//  Domain Entity ↔ SwiftData Model ↔ JSON の変換
//

import Foundation

enum PokemonModelMapper {
    // MARK: - JSON → SwiftData Model

    /// JSON (Scarlet/Violet) → SwiftData Model
    static func fromJSON(
        _ data: PokemonData,
        abilityMap: [Int: (name: String, nameJa: String)],
        typeMap: [String: TypeData]
    ) -> PokemonModel {
        // Base Stats
        let baseStats = PokemonBaseStatsModel(
            hp: data.baseStats.hp,
            attack: data.baseStats.attack,
            defense: data.baseStats.defense,
            spAttack: data.baseStats.spAttack,
            spDefense: data.baseStats.spDefense,
            speed: data.baseStats.speed,
            total: data.baseStats.total
        )

        // Sprites
        let sprites = PokemonSpriteModel(
            normal: data.sprites.normal,
            shiny: data.sprites.shiny
        )

        // Moves
        let moves = data.moves.map { move in
            PokemonLearnedMoveModel(
                pokemonId: data.id,
                moveId: move.moveId,
                learnMethod: move.learnMethod,
                level: move.level,
                machineNumber: move.machineNumber
            )
        }

        // Evolution
        let evolutionChain = PokemonEvolutionModel(
            chainId: data.evolutionChain.chainId,
            evolutionStage: data.evolutionChain.evolutionStage,
            evolvesFrom: data.evolutionChain.evolvesFrom,
            evolvesTo: data.evolutionChain.evolvesTo,
            canUseEviolite: data.evolutionChain.canUseEviolite
        )

        // Abilities: IDから名前を引く
        let primaryAbilityNames = data.abilities.primary.compactMap { abilityMap[$0]?.name }
        let primaryAbilityNamesJa = data.abilities.primary.compactMap { abilityMap[$0]?.nameJa }
        let hiddenAbilityName = data.abilities.hidden.flatMap { abilityMap[$0]?.name }
        let hiddenAbilityNameJa = data.abilities.hidden.flatMap { abilityMap[$0]?.nameJa }

        // Types: 英語名から日本語名を引く
        let typeNamesJa = data.types.compactMap { typeMap[$0]?.nameJa }

        return PokemonModel(
            id: data.id,
            nationalDexNumber: data.nationalDexNumber,
            name: data.name,
            nameJa: data.nameJa,
            genus: data.genus,
            genusJa: data.genusJa,
            height: data.height,
            weight: data.weight,
            category: data.category,
            types: data.types,
            typeNamesJa: typeNamesJa,
            eggGroups: data.eggGroups,
            genderRate: data.genderRate,
            primaryAbilities: data.abilities.primary,
            primaryAbilityNames: primaryAbilityNames,
            primaryAbilityNamesJa: primaryAbilityNamesJa,
            hiddenAbility: data.abilities.hidden,
            hiddenAbilityName: hiddenAbilityName,
            hiddenAbilityNameJa: hiddenAbilityNameJa,
            baseStats: baseStats,
            sprites: sprites,
            moves: moves,
            evolutionChain: evolutionChain,
            varieties: data.varieties,
            pokedexNumbers: data.pokedexNumbers
        )
    }

    // MARK: - Domain Entity → SwiftData Model

    /// Domain Entity → SwiftData Model
    /// Note: API経由のデータはJSON構造と異なるため、デフォルト値で補完
    static func toModel(_ pokemon: Pokemon) -> PokemonModel {
        // Types: [PokemonType] → [String]
        let types = pokemon.types.map { $0.name }

        // Stats: [PokemonStat] → PokemonBaseStatsModel
        let baseStats = PokemonBaseStatsModel(
            hp: pokemon.stats.first(where: { $0.name == "hp" })?.baseStat ?? 0,
            attack: pokemon.stats.first(where: { $0.name == "attack" })?.baseStat ?? 0,
            defense: pokemon.stats.first(where: { $0.name == "defense" })?.baseStat ?? 0,
            spAttack: pokemon.stats.first(where: { $0.name == "special-attack" })?.baseStat ?? 0,
            spDefense: pokemon.stats.first(where: { $0.name == "special-defense" })?.baseStat ?? 0,
            speed: pokemon.stats.first(where: { $0.name == "speed" })?.baseStat ?? 0,
            total: pokemon.stats.reduce(0) { $0 + $1.baseStat }
        )

        // Sprites: PokemonSprites → PokemonSpriteModel
        let sprites: PokemonSpriteModel
        if let other = pokemon.sprites.other, let home = other.home {
            sprites = PokemonSpriteModel(
                normal: home.frontDefault ?? "",
                shiny: home.frontShiny ?? ""
            )
        } else {
            sprites = PokemonSpriteModel(
                normal: pokemon.sprites.frontDefault ?? "",
                shiny: pokemon.sprites.frontShiny ?? ""
            )
        }

        // Abilities: [PokemonAbility] → [Int] + Int?
        // Note: APIはability nameしか返さないため、IDへの変換は不可能
        // ダミー値として0を使用（実際の利用は推奨されない）
        let primaryAbilities: [Int] = pokemon.abilities
            .filter { !$0.isHidden }
            .map { _ in 0 }  // ダミーID
        let hiddenAbility: Int? = pokemon.abilities.first(where: { $0.isHidden }) != nil ? 0 : nil

        // Moves: [PokemonMove] → [PokemonLearnedMoveModel]
        let moves = pokemon.moves.map { move in
            PokemonLearnedMoveModel(
                pokemonId: pokemon.id,
                moveId: move.id,
                learnMethod: move.learnMethod,
                level: move.level,
                machineNumber: move.machineNumber
            )
        }

        // Evolution: pokemon.evolutionChainがあれば使用、なければデフォルト値
        let evolutionChain: PokemonEvolutionModel
        if let evolution = pokemon.evolutionChain {
            evolutionChain = PokemonEvolutionModel(
                chainId: evolution.chainId,
                evolutionStage: evolution.evolutionStage,
                evolvesFrom: evolution.evolvesFrom,
                evolvesTo: evolution.evolvesTo,
                canUseEviolite: evolution.canUseEviolite
            )
        } else {
            // デフォルト値（API経由では取得不可）
            evolutionChain = PokemonEvolutionModel(
                chainId: 0,
                evolutionStage: 1,
                evolvesFrom: nil,
                evolvesTo: [],
                canUseEviolite: false
            )
        }

        return PokemonModel(
            id: pokemon.id,
            nationalDexNumber: pokemon.nationalDexNumber ?? pokemon.id,
            name: pokemon.name,
            nameJa: pokemon.nameJa ?? "",
            genus: pokemon.genus ?? "",
            genusJa: pokemon.genusJa ?? "",
            height: pokemon.height,
            weight: pokemon.weight,
            category: pokemon.category ?? "",
            types: types,
            eggGroups: pokemon.eggGroups ?? [],
            genderRate: pokemon.genderRate ?? -1,
            primaryAbilities: primaryAbilities,
            hiddenAbility: hiddenAbility,
            baseStats: baseStats,
            sprites: sprites,
            moves: moves,
            evolutionChain: evolutionChain,
            varieties: pokemon.varieties ?? [],
            pokedexNumbers: pokemon.pokedexNumbers ?? [:]
        )
    }

    /// SwiftData Model → Domain Entity
    static func toDomain(_ model: PokemonModel) -> Pokemon {
        // Types: [String] → [PokemonType]
        let types = model.types.enumerated().map { (index, typeName) in
            let nameJa = model.typeNamesJa?[safe: index]
            return PokemonType(slot: index + 1, name: typeName, nameJa: nameJa)
        }

        // Stats: PokemonBaseStatsModel → [PokemonStat]
        var stats: [PokemonStat] = []
        if let baseStats = model.baseStats {
            stats = [
                PokemonStat(name: "hp", baseStat: baseStats.hp),
                PokemonStat(name: "attack", baseStat: baseStats.attack),
                PokemonStat(name: "defense", baseStat: baseStats.defense),
                PokemonStat(name: "special-attack", baseStat: baseStats.spAttack),
                PokemonStat(name: "special-defense", baseStat: baseStats.spDefense),
                PokemonStat(name: "speed", baseStat: baseStats.speed)
            ]
        }

        // Abilities: 保存されている特性名を使用（英語名を使用、フィルタリング用）
        var abilities: [PokemonAbility] = []
        for (index, abilityId) in model.primaryAbilities.enumerated() {
            let name: String
            let nameJa: String?

            if let names = model.primaryAbilityNames, index < names.count {
                name = names[index]  // 英語名を使用
            } else if let namesJa = model.primaryAbilityNamesJa, index < namesJa.count {
                name = namesJa[index]  // 日本語名はフォールバック
            } else {
                name = "ability-\(abilityId)"  // フォールバック
            }

            if let namesJa = model.primaryAbilityNamesJa, index < namesJa.count {
                nameJa = namesJa[index]
            } else {
                nameJa = nil
            }

            abilities.append(PokemonAbility(name: name, nameJa: nameJa, isHidden: false))
        }
        if model.hiddenAbility != nil {
            let name = model.hiddenAbilityName ?? model.hiddenAbilityNameJa ?? "hidden-ability"
            let nameJa = model.hiddenAbilityNameJa
            abilities.append(PokemonAbility(name: name, nameJa: nameJa, isHidden: true))
        }

        // Moves: [PokemonLearnedMoveModel] → [PokemonMove]
        let moves = model.moves.map { learnedMove in
            PokemonMove(
                id: learnedMove.moveId,
                name: "move-\(learnedMove.moveId)",  // 実際の名前は別途取得が必要
                learnMethod: learnedMove.learnMethod,
                level: learnedMove.level,
                machineNumber: learnedMove.machineNumber
            )
        }

        // Sprites: PokemonSpriteModel → PokemonSprites
        let sprites: PokemonSprites
        if let spriteModel = model.sprites {
            sprites = PokemonSprites(
                frontDefault: nil,
                frontShiny: nil,
                other: PokemonSprites.OtherSprites(
                    home: PokemonSprites.OtherSprites.HomeSprites(
                        frontDefault: spriteModel.normal,
                        frontShiny: spriteModel.shiny
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

        // availableGenerations: movesから判定（簡略版）
        let availableGenerations = [model.nationalDexNumber <= 151 ? 1 :
                                     model.nationalDexNumber <= 251 ? 2 :
                                     model.nationalDexNumber <= 386 ? 3 :
                                     model.nationalDexNumber <= 493 ? 4 :
                                     model.nationalDexNumber <= 649 ? 5 :
                                     model.nationalDexNumber <= 721 ? 6 :
                                     model.nationalDexNumber <= 809 ? 7 :
                                     model.nationalDexNumber <= 905 ? 8 : 9]

        // 進化情報の変換
        let evolutionChain: PokemonEvolution? = if let evolutionModel = model.evolutionChain {
            PokemonEvolution(
                chainId: evolutionModel.chainId,
                evolutionStage: evolutionModel.evolutionStage,
                evolvesFrom: evolutionModel.evolvesFrom,
                evolvesTo: evolutionModel.evolvesTo,
                canUseEviolite: evolutionModel.canUseEviolite
            )
        } else {
            nil
        }

        return Pokemon(
            id: model.id,
            speciesId: model.nationalDexNumber,
            name: model.name,
            nameJa: model.nameJa,
            genus: model.genus,
            genusJa: model.genusJa,
            height: model.height,
            weight: model.weight,
            category: model.category,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moves,
            availableGenerations: availableGenerations,
            nationalDexNumber: model.nationalDexNumber,
            eggGroups: model.eggGroups,
            genderRate: model.genderRate,
            pokedexNumbers: model.pokedexNumbers,
            varieties: model.varieties,
            evolutionChain: evolutionChain
        )
    }
}
