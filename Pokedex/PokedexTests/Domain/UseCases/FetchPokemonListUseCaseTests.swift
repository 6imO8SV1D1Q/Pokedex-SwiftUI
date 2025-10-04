//
//  FetchPokemonListUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import XCTest
@testable import Pokedex

final class FetchPokemonListUseCaseTests: XCTestCase {
    var sut: FetchPokemonListUseCase!
    var mockRepository: MockPokemonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonRepository()
        sut = FetchPokemonListUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - 正常系テスト

    func test_execute_成功時にポケモンリストを返す() async throws {
        // Given
        let expectedPokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        mockRepository.pokemonsToReturn = expectedPokemons

        // When
        let result = try await sut.execute(limit: 2, offset: 0)

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].name, "bulbasaur")
        XCTAssertEqual(result[1].name, "ivysaur")
        XCTAssertEqual(mockRepository.fetchPokemonListCallCount, 1)
    }

    func test_execute_デフォルトパラメータで実行できる() async throws {
        // Given
        mockRepository.pokemonsToReturn = [Pokemon.fixture()]

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(mockRepository.fetchPokemonListCallCount, 1)
    }

    // MARK: - 異常系テスト

    func test_execute_ネットワークエラー時にエラーをthrowする() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = PokemonError.networkError(NSError(domain: "test", code: -1))

        // When & Then
        do {
            _ = try await sut.execute()
            XCTFail("エラーがthrowされるべき")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
    }

    // MARK: - エッジケース

    func test_execute_空のリストを返す() async throws {
        // Given
        mockRepository.pokemonsToReturn = []

        // When
        let result = try await sut.execute()

        // Then
        XCTAssertTrue(result.isEmpty)
    }

    func test_execute_大量のポケモンを返す() async throws {
        // Given
        let manyPokemons = (1...151).map { Pokemon.fixture(id: $0, name: "pokemon\($0)") }
        mockRepository.pokemonsToReturn = manyPokemons

        // When
        let result = try await sut.execute(limit: 151, offset: 0)

        // Then
        XCTAssertEqual(result.count, 151)
        XCTAssertEqual(result.first?.id, 1)
        XCTAssertEqual(result.last?.id, 151)
    }
}
