//
//  FilterPokemonByMovesUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class FilterPokemonByMovesUseCaseTests: XCTestCase {
    var sut: FilterPokemonByMovesUseCase!
    var mockRepository: MockMoveRepository!

    override func setUp() async throws {
        mockRepository = MockMoveRepository()
        sut = FilterPokemonByMovesUseCase(moveRepository: mockRepository)
    }

    override func tearDown() async throws {
        sut = nil
        mockRepository = nil
    }

    // MARK: - Tests

    func test_execute_withEmptySelectedMoves_returnsAllPokemon() async throws {
        // Given
        let pokemonList = [
            PokemonFixture.pikachu,
            PokemonFixture.charizard
        ]
        let selectedMoves: [MoveEntity] = []

        // When
        let result = try await sut.execute(
            pokemonList: pokemonList,
            selectedMoves: selectedMoves,
            versionGroup: "scarlet-violet"
        )

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].pokemon.id, PokemonFixture.pikachu.id)
        XCTAssertEqual(result[1].pokemon.id, PokemonFixture.charizard.id)
    }

    func test_execute_withSingleMove_returnsOnlyPokemonThatLearnIt() async throws {
        // Given
        let pokemonList = [
            PokemonFixture.pikachu,
            PokemonFixture.charizard
        ]
        let selectedMoves = [
            MoveEntity.fixture(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
        ]

        let learnMethod = MoveLearnMethod(
            move: selectedMoves[0],
            method: .levelUp(level: 10),
            versionGroup: "scarlet-violet"
        )
        mockRepository.fetchLearnMethodsResult = .success([learnMethod])

        // When
        let result = try await sut.execute(
            pokemonList: pokemonList,
            selectedMoves: selectedMoves,
            versionGroup: "scarlet-violet"
        )

        // Then
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result[0].learnMethods.count, 1)
        XCTAssertEqual(result[0].learnMethods[0].move.id, 1)
    }

    func test_execute_withMultipleMoves_returnsOnlyPokemonThatLearnAll() async throws {
        // Given
        let pokemonList = [
            PokemonFixture.pikachu,
            PokemonFixture.charizard
        ]
        let selectedMoves = [
            MoveEntity.fixture(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric")),
            MoveEntity.fixture(id: 2, name: "surf", type: PokemonType(slot: 1, name: "water"))
        ]

        // Only 1 move can be learned (need 2, but only 1 is available)
        let learnMethod = MoveLearnMethod(
            move: selectedMoves[0],
            method: .levelUp(level: 10),
            versionGroup: "scarlet-violet"
        )
        mockRepository.fetchLearnMethodsResult = .success([learnMethod])

        // When
        let result = try await sut.execute(
            pokemonList: pokemonList,
            selectedMoves: selectedMoves,
            versionGroup: "scarlet-violet"
        )

        // Then
        XCTAssertEqual(result.count, 0, "Pokemon that cannot learn all moves should not be included")
    }

    func test_execute_withRepositoryError_throwsError() async {
        // Given
        let pokemonList = [PokemonFixture.pikachu]
        let selectedMoves = [
            MoveEntity.fixture(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
        ]
        let expectedError = NSError(domain: "TestError", code: 1)
        mockRepository.fetchLearnMethodsResult = .failure(expectedError)

        // When & Then
        do {
            _ = try await sut.execute(
                pokemonList: pokemonList,
                selectedMoves: selectedMoves,
                versionGroup: "scarlet-violet"
            )
            XCTFail("Should throw error")
        } catch {
            XCTAssertNotNil(error)
        }
    }
}
