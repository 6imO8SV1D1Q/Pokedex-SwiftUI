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

    func test_空の技リストで実行すると全ポケモンが返される() async throws {
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

    func test_技を習得できるポケモンのみが返される() async throws {
        // Given
        let pokemonList = [
            PokemonFixture.pikachu,
            PokemonFixture.charizard
        ]
        let selectedMoves = [
            MoveEntity(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
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

    func test_すべての技を習得できないポケモンは除外される() async throws {
        // Given
        let pokemonList = [
            PokemonFixture.pikachu,
            PokemonFixture.charizard
        ]
        let selectedMoves = [
            MoveEntity(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric")),
            MoveEntity(id: 2, name: "surf", type: PokemonType(slot: 1, name: "water"))
        ]

        // 1つの技しか習得できない（2つ必要だが1つだけ）
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
        XCTAssertEqual(result.count, 0, "すべての技を習得できないポケモンは結果に含まれない")
    }

    func test_エラーが発生した場合は例外をスローする() async {
        // Given
        let pokemonList = [PokemonFixture.pikachu]
        let selectedMoves = [
            MoveEntity(id: 1, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
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
            XCTFail("エラーがスローされるべき")
        } catch {
            // エラーが正しくスローされた
            XCTAssertNotNil(error)
        }
    }
}
