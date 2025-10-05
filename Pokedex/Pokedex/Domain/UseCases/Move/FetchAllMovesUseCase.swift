//
//  FetchAllMovesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 全技リストを取得するUseCaseのプロトコル
protocol FetchAllMovesUseCaseProtocol {
    func execute(versionGroup: String?) async throws -> [MoveEntity]
}

/// 全技リストを取得するUseCase
final class FetchAllMovesUseCase: FetchAllMovesUseCaseProtocol {
    private let moveRepository: MoveRepositoryProtocol

    init(moveRepository: MoveRepositoryProtocol) {
        self.moveRepository = moveRepository
    }

    func execute(versionGroup: String?) async throws -> [MoveEntity] {
        return try await moveRepository.fetchAllMoves(versionGroup: versionGroup)
    }
}
