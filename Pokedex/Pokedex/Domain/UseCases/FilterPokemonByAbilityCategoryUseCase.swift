//
//  FilterPokemonByAbilityCategoryUseCase.swift
//  Pokedex
//
//  特性カテゴリでポケモンをフィルタリングするUseCase
//  Created by Claude Code on 2025-10-15.
//

import Foundation

protocol FilterPokemonByAbilityCategoryUseCaseProtocol {
    func execute(
        pokemons: [Pokemon],
        selectedCategories: Set<AbilityCategory>,
        abilityCategories: [String: [AbilityCategory]]
    ) -> [Pokemon]
}

struct FilterPokemonByAbilityCategoryUseCase: FilterPokemonByAbilityCategoryUseCaseProtocol {

    /// 特性カテゴリでポケモンをフィルタリング
    /// - Parameters:
    ///   - pokemons: フィルタリング対象のポケモンリスト
    ///   - selectedCategories: 選択された特性カテゴリ
    ///   - abilityCategories: 特性名→カテゴリのマッピング
    /// - Returns: フィルタリング後のポケモンリスト（OR条件：いずれかのカテゴリに該当）
    func execute(
        pokemons: [Pokemon],
        selectedCategories: Set<AbilityCategory>,
        abilityCategories: [String: [AbilityCategory]]
    ) -> [Pokemon] {
        // カテゴリが選択されていない場合は全て返す
        guard !selectedCategories.isEmpty else {
            return pokemons
        }

        return pokemons.filter { pokemon in
            // ポケモンの全特性を取得
            let pokemonAbilities = Set(pokemon.abilities.map { $0.name })

            // いずれかの特性が選択されたカテゴリに該当するか
            return pokemonAbilities.contains { abilityName in
                guard let categories = abilityCategories[abilityName] else {
                    return false
                }
                // 特性のカテゴリと選択されたカテゴリに共通部分があるか
                return !selectedCategories.isDisjoint(with: categories)
            }
        }
    }
}
