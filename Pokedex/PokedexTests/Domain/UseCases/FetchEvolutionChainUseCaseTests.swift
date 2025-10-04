//
//  FetchEvolutionChainUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import XCTest
@testable import Pokedex

final class FetchEvolutionChainUseCaseTests: XCTestCase {
    var sut: FetchEvolutionChainUseCase!
    var mockRepository: MockPokemonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonRepository()
        sut = FetchEvolutionChainUseCase(repository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Success Cases

    func test_execute_noEvolution_returnsSelfIdOnly() async throws {
        // Given
        let pokemonId = 132 // Ditto (進化しない)
        mockRepository.speciesToReturn = PokemonSpecies.fixture(
            id: pokemonId,
            evolutionChain: .fixture(url: "https://pokeapi.co/api/v2/evolution-chain/67/")
        )

        let evolutionChain = EvolutionChain.fixture(
            chain: .fixture(
                species: .fixture(name: "ditto", url: "https://pokeapi.co/api/v2/pokemon-species/132/"),
                evolvesTo: []
            )
        )
        mockRepository.evolutionChainToReturn = evolutionChain

        // When
        let result = try await sut.execute(pokemonId: pokemonId)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], 132)
        XCTAssertEqual(mockRepository.fetchPokemonSpeciesCallCount, 1)
        XCTAssertEqual(mockRepository.fetchEvolutionChainCallCount, 1)
    }

    func test_execute_twoStageEvolution_returnsAllIds() async throws {
        // Given (Bulbasaur -> Ivysaur -> Venusaur)
        let pokemonId = 1
        mockRepository.speciesToReturn = PokemonSpecies.fixture(
            id: pokemonId,
            evolutionChain: .fixture(url: "https://pokeapi.co/api/v2/evolution-chain/1/")
        )

        let evolutionChain = EvolutionChain.fixture(
            chain: .fixture(
                species: .fixture(name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon-species/1/"),
                evolvesTo: [
                    .fixture(
                        species: .fixture(name: "ivysaur", url: "https://pokeapi.co/api/v2/pokemon-species/2/"),
                        evolvesTo: [
                            .fixture(
                                species: .fixture(name: "venusaur", url: "https://pokeapi.co/api/v2/pokemon-species/3/"),
                                evolvesTo: []
                            )
                        ]
                    )
                ]
            )
        )
        mockRepository.evolutionChainToReturn = evolutionChain

        // When
        let result = try await sut.execute(pokemonId: pokemonId)

        // Then
        XCTAssertEqual(result.count, 3)
        XCTAssertEqual(result[0], 1) // Bulbasaur
        XCTAssertEqual(result[1], 2) // Ivysaur
        XCTAssertEqual(result[2], 3) // Venusaur
    }

    func test_execute_branchEvolution_returnsAllIds() async throws {
        // Given (Eevee -> Vaporeon/Jolteon/Flareon)
        let pokemonId = 133 // Eevee
        mockRepository.speciesToReturn = PokemonSpecies.fixture(
            id: pokemonId,
            evolutionChain: .fixture(url: "https://pokeapi.co/api/v2/evolution-chain/67/")
        )

        let evolutionChain = EvolutionChain.fixture(
            chain: .fixture(
                species: .fixture(name: "eevee", url: "https://pokeapi.co/api/v2/pokemon-species/133/"),
                evolvesTo: [
                    .fixture(
                        species: .fixture(name: "vaporeon", url: "https://pokeapi.co/api/v2/pokemon-species/134/"),
                        evolvesTo: []
                    ),
                    .fixture(
                        species: .fixture(name: "jolteon", url: "https://pokeapi.co/api/v2/pokemon-species/135/"),
                        evolvesTo: []
                    ),
                    .fixture(
                        species: .fixture(name: "flareon", url: "https://pokeapi.co/api/v2/pokemon-species/136/"),
                        evolvesTo: []
                    )
                ]
            )
        )
        mockRepository.evolutionChainToReturn = evolutionChain

        // When
        let result = try await sut.execute(pokemonId: pokemonId)

        // Then
        XCTAssertEqual(result.count, 4)
        XCTAssertTrue(result.contains(133)) // Eevee
        XCTAssertTrue(result.contains(134)) // Vaporeon
        XCTAssertTrue(result.contains(135)) // Jolteon
        XCTAssertTrue(result.contains(136)) // Flareon
    }

    // MARK: - Error Cases

    func test_execute_invalidChainUrl_returnsSelfIdOnly() async throws {
        // Given
        let pokemonId = 1
        mockRepository.speciesToReturn = PokemonSpecies.fixture(
            id: pokemonId,
            evolutionChain: .fixture(url: "invalid-url") // IDが取得できないURL
        )

        // When
        let result = try await sut.execute(pokemonId: pokemonId)

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0], pokemonId)
        XCTAssertEqual(mockRepository.fetchPokemonSpeciesCallCount, 1)
        XCTAssertEqual(mockRepository.fetchEvolutionChainCallCount, 0) // 呼ばれない
    }

    func test_execute_networkError_throwsError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = PokemonError.networkError(NSError(domain: "test", code: -1))

        // When & Then
        do {
            _ = try await sut.execute(pokemonId: 1)
            XCTFail("エラーがthrowされるべき")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
    }
}
