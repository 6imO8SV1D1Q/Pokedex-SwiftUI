//
//  FilterPokemonByAbilityMetadataUseCase.swift
//  Pokedex
//
//  特性の詳細メタデータ条件でポケモンを絞り込むUseCase
//

import Foundation

protocol FilterPokemonByAbilityMetadataUseCaseProtocol {
    func execute(
        pokemons: [Pokemon],
        filters: [AbilityMetadataFilter],
        allMetadata: [AbilityMetadata]
    ) -> [Pokemon]
}

struct FilterPokemonByAbilityMetadataUseCase: FilterPokemonByAbilityMetadataUseCaseProtocol {
    func execute(
        pokemons: [Pokemon],
        filters: [AbilityMetadataFilter],
        allMetadata: [AbilityMetadata]
    ) -> [Pokemon] {
        guard !filters.isEmpty else {
            return pokemons
        }

        // 特性名→メタデータのマップを作成
        let metadataMap = Dictionary(uniqueKeysWithValues: allMetadata.map { ($0.name, $0) })

        return pokemons.filter { pokemon in
            // 全てのフィルター条件を満たすか確認（AND条件）
            filters.allSatisfy { filter in
                matchesFilter(pokemon: pokemon, filter: filter, metadataMap: metadataMap)
            }
        }
    }

    private func matchesFilter(
        pokemon: Pokemon,
        filter: AbilityMetadataFilter,
        metadataMap: [String: AbilityMetadata]
    ) -> Bool {
        // ポケモンが持つ全ての特性について確認
        let pokemonAbilities = pokemon.abilities.map { $0.name }

        return pokemonAbilities.contains { abilityName in
            guard let metadata = metadataMap[abilityName] else {
                return false
            }

            return matchesMetadata(metadata: metadata, filter: filter)
        }
    }

    private func matchesMetadata(metadata: AbilityMetadata, filter: AbilityMetadataFilter) -> Bool {
        var matches = true

        // 発動タイミングのチェック
        if !filter.triggers.isEmpty {
            let hasTrigger = metadata.effects.contains { effect in
                filter.triggers.contains(effect.trigger.rawValue)
            }
            if !hasTrigger {
                matches = false
            }
        }

        // 効果タイプのチェック
        if !filter.effectTypes.isEmpty {
            let hasEffectType = metadata.effects.contains { effect in
                filter.effectTypes.contains(effect.effectType.rawValue)
            }
            if !hasEffectType {
                matches = false
            }
        }

        // 能力値倍率のチェック
        if let condition = filter.statMultiplierCondition {
            let hasStatMultiplier = metadata.effects.contains { effect in
                guard effect.effectType == .statMultiplier,
                      let multiplier = effect.value?.multiplier else {
                    return false
                }
                return condition.matches(multiplier)
            }
            if !hasStatMultiplier {
                matches = false
            }
        }

        // 技威力倍率のチェック
        if let condition = filter.movePowerMultiplierCondition {
            let hasMovePowerMultiplier = metadata.effects.contains { effect in
                guard effect.effectType == .movePowerMultiplier,
                      let multiplier = effect.value?.multiplier else {
                    return false
                }
                return condition.matches(multiplier)
            }
            if !hasMovePowerMultiplier {
                matches = false
            }
        }

        // 発動確率のチェック
        if let condition = filter.probabilityCondition {
            let hasProbability = metadata.effects.contains { effect in
                guard let probability = effect.value?.probability else {
                    return false
                }
                return condition.matches(Double(probability))
            }
            if !hasProbability {
                matches = false
            }
        }

        // 天候のチェック
        if !filter.weathers.isEmpty {
            let hasWeather = metadata.effects.contains { effect in
                guard let condition = effect.condition,
                      condition.type == .weather,
                      case let .weather(weather) = condition.value else {
                    return false
                }
                return filter.weathers.contains(weather.rawValue)
            } || metadata.effects.contains { effect in
                guard effect.effectType == .setWeather,
                      let weather = effect.value?.weather else {
                    return false
                }
                return filter.weathers.contains(weather.rawValue)
            }
            if !hasWeather {
                matches = false
            }
        }

        // フィールドのチェック
        if !filter.terrains.isEmpty {
            let hasTerrain = metadata.effects.contains { effect in
                guard let condition = effect.condition,
                      condition.type == .terrain,
                      case let .terrain(terrain) = condition.value else {
                    return false
                }
                return filter.terrains.contains(terrain.rawValue)
            } || metadata.effects.contains { effect in
                guard effect.effectType == .setTerrain,
                      let terrain = effect.value?.terrain else {
                    return false
                }
                return filter.terrains.contains(terrain.rawValue)
            }
            if !hasTerrain {
                matches = false
            }
        }

        return matches
    }
}
