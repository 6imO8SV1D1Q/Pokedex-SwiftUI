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
    ) -> [(pokemon: Pokemon, matchedAbilities: [String])]
}

struct FilterPokemonByAbilityMetadataUseCase: FilterPokemonByAbilityMetadataUseCaseProtocol {
    func execute(
        pokemons: [Pokemon],
        filters: [AbilityMetadataFilter],
        allMetadata: [AbilityMetadata]
    ) -> [(pokemon: Pokemon, matchedAbilities: [String])] {
        guard !filters.isEmpty else {
            return pokemons.map { ($0, []) }
        }

        // 特性名→メタデータのマップを作成
        let metadataMap = Dictionary(uniqueKeysWithValues: allMetadata.map { ($0.name, $0) })

        return pokemons.compactMap { pokemon in
            let matchedAbilities = getMatchedAbilities(
                pokemon: pokemon,
                filters: filters,
                metadataMap: metadataMap
            )

            // 全てのフィルター条件を満たすか確認（AND条件）
            let matchesAllFilters = filters.allSatisfy { filter in
                matchesFilter(pokemon: pokemon, filter: filter, metadataMap: metadataMap)
            }

            guard matchesAllFilters else {
                return nil
            }

            return (pokemon, matchedAbilities)
        }
    }

    /// ポケモンが持つ特性のうち、フィルター条件に合致する特性名のリストを返す
    private func getMatchedAbilities(
        pokemon: Pokemon,
        filters: [AbilityMetadataFilter],
        metadataMap: [String: AbilityMetadata]
    ) -> [String] {
        let pokemonAbilities = pokemon.abilities.map { $0.name }

        return pokemonAbilities.filter { abilityName in
            guard let metadata = metadataMap[abilityName] else {
                return false
            }

            // いずれかのフィルター条件に合致するか確認
            return filters.contains { filter in
                matchesMetadata(metadata: metadata, filter: filter)
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

        // 天候のチェック（天候を設定する特性のみ）
        if !filter.weathers.isEmpty {
            let hasWeather = metadata.effects.contains { effect in
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

        // フィールドのチェック（フィールドを設定する特性のみ）
        if !filter.terrains.isEmpty {
            let hasTerrain = metadata.effects.contains { effect in
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

        // カテゴリのチェック
        if !filter.categories.isEmpty {
            let hasCategory = filter.categories.contains { category in
                metadata.categories.contains(category.rawValue)
            }
            if !hasCategory {
                matches = false
            }
        }

        return matches
    }
}
