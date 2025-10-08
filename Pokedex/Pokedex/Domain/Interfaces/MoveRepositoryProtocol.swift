//
//  MoveRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技情報を管理するRepositoryのプロトコル
protocol MoveRepositoryProtocol {
    /// 全技リストを取得
    /// - Parameter versionGroup: バージョングループID (nilの場合は全技)
    /// - Returns: 技のリスト
    func fetchAllMoves(versionGroup: String?) async throws -> [MoveEntity]

    /// ポケモンの技習得方法を取得
    /// - Parameters:
    ///   - pokemonId: ポケモンID
    ///   - moveIds: 技IDのリスト
    ///   - versionGroup: バージョングループID
    /// - Returns: 習得方法のリスト
    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        versionGroup: String
    ) async throws -> [MoveLearnMethod]

    /// 技の詳細情報を取得
    /// - Parameter moveId: 技ID
    /// - Returns: 技の詳細情報
    func fetchMoveDetail(moveId: Int) async throws -> MoveEntity
}
