//
//  FilterPokemonByAbilityUseCaseProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンリストを特性でフィルタリングするUseCaseのプロトコル
protocol FilterPokemonByAbilityUseCaseProtocol {
    /// ポケモンリストを特性でフィルタリング
    /// - Parameters:
    ///   - pokemonList: フィルタリング対象のポケモンリスト
    ///   - selectedAbilities: 選択された特性名のセット
    /// - Returns: フィルタリング済みのポケモンリスト
    func execute(
        pokemonList: [Pokemon],
        selectedAbilities: Set<String>
    ) -> [Pokemon]
}
