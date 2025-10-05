//
//  FilterPokemonByMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 複数の技を習得できるポケモンを絞り込むユースケースのプロトコル
///
/// 選択された全ての技を習得可能なポケモンのみを返します。
/// 習得方法（レベル、TM/TR、タマゴ技など）も併せて取得します。
///
/// - Note: このフィルターはバージョングループ選択時のみ有効です。
///         全国図鑑モードでは技の習得可否が不明確なため使用できません。
protocol FilterPokemonByMovesUseCaseProtocol {
    /// ポケモンリストを技で絞り込む
    ///
    /// - Parameters:
    ///   - pokemonList: 絞り込み対象のポケモンリスト
    ///   - selectedMoves: 選択された技のリスト（最大4つ）
    ///   - versionGroup: 対象のバージョングループID（例: "red-blue", "scarlet-violet"）
    /// - Returns: 全ての技を習得できるポケモンと、その習得方法のタプル配列
    /// - Throws: リポジトリエラー、ネットワークエラー
    ///
    /// - Note: `selectedMoves`が空の場合、全てのポケモンをそのまま返します。
    ///         習得方法が複数ある技の場合、全ての方法が返されます。
    func execute(
        pokemonList: [Pokemon],
        selectedMoves: [MoveEntity],
        versionGroup: String
    ) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])]
}

/// 技によるポケモンフィルタリングUseCaseの実装
///
/// 指定された技をすべて習得可能なポケモンのみを抽出します。
/// MoveRepositoryを使用して各ポケモンの技習得情報を取得し、
/// 全ての選択された技を習得できるポケモンのみを結果として返します。
///
/// ## 使用例
/// ```swift
/// let useCase = FilterPokemonByMovesUseCase(moveRepository: repository)
/// let moves = [thunderbolt, surf]
/// let results = try await useCase.execute(
///     pokemonList: allPokemon,
///     selectedMoves: moves,
///     versionGroup: "scarlet-violet"
/// )
/// // results には thunderbolt と surf の両方を習得できるポケモンのみが含まれる
/// ```
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
