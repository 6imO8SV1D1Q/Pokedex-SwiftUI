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
    /// - Returns: フィルタリング済みのポケモンと合致した特性名のタプル配列
    func execute(
        pokemonList: [Pokemon],
        selectedAbilities: Set<String>,
        mode: FilterMode = .or
    ) -> [(pokemon: Pokemon, matchedAbilities: [String])] {
        // 選択された特性がない場合は全てを返す（合致理由なし）
        guard !selectedAbilities.isEmpty else {
            return pokemonList.map { ($0, []) }
        }

        return pokemonList.compactMap { pokemon in
            let matchedAbilities = pokemon.abilities
                .map { $0.name }
                .filter { selectedAbilities.contains($0) }

            let matchesFilter: Bool
            if mode == .or {
                // OR: いずれかの特性を持つ
                matchesFilter = !matchedAbilities.isEmpty
            } else {
                // AND: 全ての特性を持つ
                matchesFilter = selectedAbilities.allSatisfy { selectedAbility in
                    matchedAbilities.contains(selectedAbility)
                }
            }

            guard matchesFilter else {
                return nil
            }

            return (pokemon, matchedAbilities)
        }
    }
}
