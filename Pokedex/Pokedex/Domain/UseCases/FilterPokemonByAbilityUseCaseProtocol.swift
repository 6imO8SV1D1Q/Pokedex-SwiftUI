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
    ///   - mode: 検索モード（OR/AND）
    /// - Returns: フィルタリング済みのポケモンと合致した特性名のタプル配列
    func execute(
        pokemonList: [Pokemon],
        selectedAbilities: Set<String>,
        mode: FilterMode
    ) -> [(pokemon: Pokemon, matchedAbilities: [String])]
}
