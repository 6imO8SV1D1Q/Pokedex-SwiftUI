//
//  FilterPokemonByMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技によるポケモンフィルタリングUseCaseのプロトコル
protocol FilterPokemonByMovesUseCaseProtocol {
    func execute(
        pokemonList: [Pokemon],
        selectedMoves: [MoveEntity],
        versionGroup: String
    ) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])]
}

/// 技によるポケモンフィルタリングUseCase
final class FilterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol {
    private let moveRepository: MoveRepositoryProtocol

    init(moveRepository: MoveRepositoryProtocol) {
        self.moveRepository = moveRepository
    }

    func execute(
        pokemonList: [Pokemon],
        selectedMoves: [MoveEntity],
        versionGroup: String
    ) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])] {

        guard !selectedMoves.isEmpty else {
            return pokemonList.map { ($0, []) }
        }

        var results: [(Pokemon, [MoveLearnMethod])] = []

        for pokemon in pokemonList {
            // このポケモンが選択された技をすべて習得できるか確認
            let learnMethods = try await moveRepository.fetchLearnMethods(
                pokemonId: pokemon.id,
                moveIds: selectedMoves.map { $0.id },
                versionGroup: versionGroup
            )

            // すべての技を習得できる場合のみ結果に含める
            if learnMethods.count == selectedMoves.count {
                results.append((pokemon, learnMethods))
            }
        }

        return results
    }
}
