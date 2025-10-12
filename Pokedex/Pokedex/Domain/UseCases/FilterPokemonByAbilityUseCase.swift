//
//  FilterPokemonByAbilityUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンリストを特性でフィルタリングするUseCase
final class FilterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol {
    /// ポケモンリストを特性でフィルタリング
    /// - Parameters:
    ///   - pokemonList: フィルタリング対象のポケモンリスト
    ///   - selectedAbilities: 選択された特性名のセット
    ///   - mode: 検索モード（OR/AND）
    /// - Returns: フィルタリング済みのポケモンリスト
    func execute(
        pokemonList: [Pokemon],
        selectedAbilities: Set<String>,
        mode: FilterMode = .or
    ) -> [Pokemon] {
        // 選択された特性がない場合は全てを返す
        guard !selectedAbilities.isEmpty else {
            return pokemonList
        }

        return pokemonList.filter { pokemon in
            if mode == .or {
                // OR: いずれかの特性を持つ
                pokemon.abilities.contains { ability in
                    selectedAbilities.contains(ability.name)
                }
            } else {
                // AND: 全ての特性を持つ
                selectedAbilities.allSatisfy { selectedAbility in
                    pokemon.abilities.contains { $0.name == selectedAbility }
                }
            }
        }
    }
}
