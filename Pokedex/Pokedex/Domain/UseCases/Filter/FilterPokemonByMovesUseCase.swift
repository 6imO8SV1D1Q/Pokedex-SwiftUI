//
//  FilterPokemonByMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 複数の技を習得できるポケモンを絞り込むユースケースのプロトコル
///
/// 選択された技に基づいてポケモンを絞り込みます。
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
    ///   - mode: 検索モード（OR: いずれか / AND: 全て）
    /// - Returns: 条件に合うポケモンと、その習得方法のタプル配列
    /// - Throws: リポジトリエラー、ネットワークエラー
    ///
    /// - Note: `selectedMoves`が空の場合、全てのポケモンをそのまま返します。
    ///         習得方法が複数ある技の場合、全ての方法が返されます。
    func execute(
        pokemonList: [Pokemon],
        selectedMoves: [MoveEntity],
        versionGroup: String,
        mode: FilterMode
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
        versionGroup: String,
        mode: FilterMode = .and
    ) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])] {

        guard !selectedMoves.isEmpty else {
            return pokemonList.map { ($0, []) }
        }

        // 一括取得（1025回のクエリ → 2回のクエリに最適化）
        let pokemonIds = pokemonList.map { $0.id }
        let moveIds = selectedMoves.map { $0.id }
        let bulkLearnMethods = try await moveRepository.fetchBulkLearnMethods(
            pokemonIds: pokemonIds,
            moveIds: moveIds,
            versionGroup: versionGroup
        )

        var results: [(Pokemon, [MoveLearnMethod])] = []

        for pokemon in pokemonList {
            guard let learnMethods = bulkLearnMethods[pokemon.id] else {
                continue
            }

            if mode == .and {
                // AND: すべての技を習得できる場合のみ
                // 習得可能な技のIDセットを作成
                let learnedMoveIds = Set(learnMethods.map { $0.move.id })
                let selectedMoveIds = Set(selectedMoves.map { $0.id })

                // 選択した全ての技IDが習得可能な技IDに含まれているかチェック
                if selectedMoveIds.isSubset(of: learnedMoveIds) {
                    results.append((pokemon, learnMethods))
                }
            } else {
                // OR: いずれかの技を習得できる場合
                if !learnMethods.isEmpty {
                    results.append((pokemon, learnMethods))
                }
            }
        }

        return results
    }
}
