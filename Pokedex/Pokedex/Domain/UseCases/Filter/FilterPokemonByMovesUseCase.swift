//
//  FilterPokemonByMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技によるポケモンフィルタリングUseCaseのプロトコル
protocol FilterPokemonByMovesUseCaseProtocol {
    /// 選択された技をすべて習得できるポケモンのみを抽出
    /// - Parameters:
    ///   - pokemonList: フィルター対象のポケモンリスト
    ///   - selectedMoves: 選択された技のリスト
    ///   - versionGroup: 対象バージョングループ
    /// - Returns: ポケモンと習得方法のタプルの配列
    func execute(
        pokemonList: [Pokemon],
        selectedMoves: [MoveEntity],
        versionGroup: String
    ) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])]
}

/// 技によるポケモンフィルタリングUseCase
/// 指定された技をすべて習得可能なポケモンのみを抽出する
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
