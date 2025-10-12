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
    /// - Parameters:
    ///   - moveId: 技ID
    ///   - versionGroup: バージョングループ（マシン番号取得用、nilの場合は番号なし）
    /// - Returns: 技の詳細情報
    func fetchMoveDetail(moveId: Int, versionGroup: String?) async throws -> MoveEntity

    /// 複数ポケモンの技習得方法を一括取得（パフォーマンス最適化版）
    /// - Parameters:
    ///   - pokemonIds: ポケモンIDのリスト
    ///   - moveIds: 技IDのリスト
    ///   - versionGroup: バージョングループID
    /// - Returns: ポケモンIDをキーとした習得方法の辞書
    func fetchBulkLearnMethods(
        pokemonIds: [Int],
        moveIds: [Int],
        versionGroup: String
    ) async throws -> [Int: [MoveLearnMethod]]
}
