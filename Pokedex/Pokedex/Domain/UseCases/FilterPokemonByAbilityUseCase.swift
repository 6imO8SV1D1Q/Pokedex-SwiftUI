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
    /// - Returns: フィルタリング済みのポケモンリスト
    func execute(
        pokemonList: [Pokemon],
        selectedAbilities: Set<String>
    ) -> [Pokemon] {
        // 選択された特性がない場合は全てを返す
        guard !selectedAbilities.isEmpty else {
            return pokemonList
        }

        // 選択された特性を持つポケモンのみフィルタリング
        return pokemonList.filter { pokemon in
            pokemon.abilities.contains { ability in
                selectedAbilities.contains(ability.name)
            }
        }
    }
}
