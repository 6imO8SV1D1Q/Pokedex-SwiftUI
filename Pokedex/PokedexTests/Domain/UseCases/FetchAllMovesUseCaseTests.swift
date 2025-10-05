//
//  FetchAllMovesUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class FetchAllMovesUseCaseTests: XCTestCase {
    var sut: FetchAllMovesUseCase!
    var mockRepository: MockMoveRepository!

    override func setUp() async throws {
        mockRepository = MockMoveRepository()
        sut = FetchAllMovesUseCase(moveRepository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
    }

    // MARK: - Tests

    func test_技リストを正常に取得できる() async throws {
        // Given
        let expectedMoves = [
            MoveEntity(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric")),
            MoveEntity(id: 2, name: "surf", type: PokemonType(slot: 1, name: "water"))
        ]
        mockRepository.fetchAllMovesResult = .success(expectedMoves)

        // When
        let result = try await sut.execute(versionGroup: "scarlet-violet")

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].id, 1)
        XCTAssertEqual(result[0].name, "thunderbolt")
        XCTAssertEqual(result[1].id, 2)
        XCTAssertEqual(result[1].name, "surf")
    }

    func test_バージョングループなしでも取得できる() async throws {
        // Given
        let expectedMoves = [
            MoveEntity(id: 1, name: "tackle", type: PokemonType(slot: 1, name: "normal"))
        ]
        mockRepository.fetchAllMovesResult = .success(expectedMoves)

        // When
        let result = try await sut.execute(versionGroup: nil)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].name, "tackle")
    }

    func test_エラーが発生した場合は例外をスローする() async {
        // Given
        let expectedError = NSError(domain: "TestError", code: 1)
        mockRepository.fetchAllMovesResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.execute(versionGroup: "scarlet-violet")
            XCTFail("エラーがスローされるべき")
        } catch {
            XCTAssertNotNil(error)
        }
    }

    func test_空のリストも正常に処理できる() async throws {
        // Given
        mockRepository.fetchAllMovesResult = .success([])

        // When
        let result = try await sut.execute(versionGroup: "scarlet-violet")

        // Then
        XCTAssertEqual(result.count, 0)
    }
}
