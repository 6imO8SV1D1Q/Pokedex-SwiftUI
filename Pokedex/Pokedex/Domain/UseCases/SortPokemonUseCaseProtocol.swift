//
//  SortPokemonUseCaseProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンリストをソートするUseCaseのプロトコル
protocol SortPokemonUseCaseProtocol {
    /// ポケモンリストを指定されたソートオプションでソート
    /// - Parameters:
    ///   - pokemonList: ソート対象のポケモンリスト
    ///   - sortOption: ソートオプション
    /// - Returns: ソート済みのポケモンリスト
    func execute(
        pokemonList: [Pokemon],
        sortOption: SortOption
    ) -> [Pokemon]
}
