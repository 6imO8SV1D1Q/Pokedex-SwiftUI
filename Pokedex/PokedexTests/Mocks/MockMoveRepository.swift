//
//  MockMoveRepository.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import Foundation
@testable import Pokedex

/// テスト用のMockMoveRepository
final class MockMoveRepository: MoveRepositoryProtocol {
    var fetchAllMovesResult: Result<[MoveEntity], Error> = .success([])
    var fetchLearnMethodsResult: Result<[MoveLearnMethod], Error> = .success([])
    var fetchMoveDetailResult: Result<MoveEntity, Error> = .success(.fixture())

    func fetchAllMoves(versionGroup: String?) async throws -> [MoveEntity] {
        switch fetchAllMovesResult {
        case .success(let moves):
            return moves
        case .failure(let error):
            throw error
        }
    }

    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        versionGroup: String
    ) async throws -> [MoveLearnMethod] {
        switch fetchLearnMethodsResult {
        case .success(let methods):
            return methods
        case .failure(let error):
            throw error
        }
    }

    func fetchMoveDetail(moveId: Int, versionGroup: String?) async throws -> MoveEntity {
        switch fetchMoveDetailResult {
        case .success(let move):
            return move
        case .failure(let error):
            throw error
        }
    }
}
