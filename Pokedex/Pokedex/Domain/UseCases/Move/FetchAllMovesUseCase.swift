//
//  FetchAllMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 全技リストを取得するUseCaseのプロトコル
protocol FetchAllMovesUseCaseProtocol {
    /// 全技リストを取得
    /// - Parameter versionGroup: バージョングループ（オプション）
    /// - Returns: 技のリスト（名前順）
    func execute(versionGroup: String?) async throws -> [MoveEntity]
}

/// 全技リストを取得するUseCase
/// フィルター画面での技選択に使用
final class FetchAllMovesUseCase: FetchAllMovesUseCaseProtocol {
    private let moveRepository: MoveRepositoryProtocol

    init(moveRepository: MoveRepositoryProtocol) {
        self.moveRepository = moveRepository
    }

    func execute(versionGroup: String?) async throws -> [MoveEntity] {
        return try await moveRepository.fetchAllMoves(versionGroup: versionGroup)
    }
}
