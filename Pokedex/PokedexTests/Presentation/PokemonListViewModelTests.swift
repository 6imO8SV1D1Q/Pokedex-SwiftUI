//
//  PokemonListViewModelTests.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import XCTest
@testable import Pokedex

@MainActor
final class PokemonListViewModelTests: XCTestCase {
    var sut: PokemonListViewModel!
    var mockFetchPokemonListUseCase: MockFetchPokemonListUseCase!

    override func setUp() {
        super.setUp()
        mockFetchPokemonListUseCase = MockFetchPokemonListUseCase()
        sut = PokemonListViewModel(
            fetchPokemonListUseCase: mockFetchPokemonListUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockFetchPokemonListUseCase = nil
        super.tearDown()
    }

    // MARK: - Load Pokemons Tests

    func test_loadPokemons_success_updatesPokemonsList() async {
        // Given
        let expectedPokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        mockFetchPokemonListUseCase.pokemonsToReturn = expectedPokemons

        // When
        await sut.loadPokemons()

        // Then
        XCTAssertEqual(sut.pokemons.count, 2)
        XCTAssertEqual(sut.pokemons[0].name, "bulbasaur")
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.errorMessage)
    }

    func test_loadPokemons_error_setsErrorMessage() async {
        // Given
        mockFetchPokemonListUseCase.shouldThrowError = true
        mockFetchPokemonListUseCase.failCount = 999 // 常に失敗させる

        // When
        await sut.loadPokemons()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadPokemons_retry_succeedsAfterRetries() async {
        // Given
        mockFetchPokemonListUseCase.shouldThrowError = true
        mockFetchPokemonListUseCase.failCount = 2 // 2回失敗後、成功
        mockFetchPokemonListUseCase.pokemonsToReturn = [Pokemon.fixture()]

        // When
        await sut.loadPokemons()

        // Then
        // リトライ後に成功するため、ポケモンが取得できる
        XCTAssertEqual(sut.pokemons.count, 1)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Filter Tests

    func test_applyFilters_searchText_filtersPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 4, name: "charmander"),
            Pokemon.fixture(id: 7, name: "squirtle")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "char"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].name, "charmander")
    }

    func test_applyFilters_partialMatch_filtersPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "saur"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_caseInsensitive_filtersPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "BULBA"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
    }

    func test_applyFilters_type_filtersPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]
        await sut.loadPokemons()

        // When
        sut.selectedTypes = ["fire"]
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].types[0].name, "fire")
    }

    func test_applyFilters_multipleTypes_filtersPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]
        await sut.loadPokemons()

        // When
        sut.selectedTypes = ["fire", "water"]
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_emptySearchText_showsAllPokemons() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = ""
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    // MARK: - Display Mode Tests

    func test_toggleDisplayMode_togglesBetweenListAndGrid() {
        // Given
        XCTAssertEqual(sut.displayMode, .list)

        // When
        sut.toggleDisplayMode()

        // Then
        XCTAssertEqual(sut.displayMode, .grid)

        // When
        sut.toggleDisplayMode()

        // Then
        XCTAssertEqual(sut.displayMode, .list)
    }

    // MARK: - Clear Filters Tests

    func test_clearFilters_clearsAllFilters() async {
        // Given
        mockFetchPokemonListUseCase.pokemonsToReturn = [Pokemon.fixture()]
        await sut.loadPokemons()
        sut.searchText = "test"
        sut.selectedTypes = ["fire", "water"]
        sut.selectedGeneration = 2

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.searchText, "")
        XCTAssertTrue(sut.selectedTypes.isEmpty)
        XCTAssertEqual(sut.selectedGeneration, 1)
    }
}

// MARK: - Mock UseCase

final class MockFetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {
    var pokemonsToReturn: [Pokemon] = []
    var shouldThrowError = false
    var failCount = 0
    private var callCount = 0

    func execute(limit: Int, offset: Int) async throws -> [Pokemon] {
        callCount += 1

        if shouldThrowError {
            if callCount <= failCount {
                throw PokemonError.networkError(NSError(domain: "test", code: -1))
            }
        }

        return pokemonsToReturn
    }
}
