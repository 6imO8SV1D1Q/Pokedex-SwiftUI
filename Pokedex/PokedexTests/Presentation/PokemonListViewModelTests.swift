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
    var mockSortPokemonUseCase: MockSortPokemonUseCase!
    var mockFilterPokemonByAbilityUseCase: MockFilterPokemonByAbilityUseCase!
    var mockFilterPokemonByMovesUseCase: MockFilterPokemonByMovesUseCase!
    var mockFetchVersionGroupsUseCase: MockFetchVersionGroupsUseCase!
    var mockPokemonRepository: MockPokemonRepository!

    override func setUp() {
        super.setUp()
        mockFetchPokemonListUseCase = MockFetchPokemonListUseCase()
        mockSortPokemonUseCase = MockSortPokemonUseCase()
        mockFilterPokemonByAbilityUseCase = MockFilterPokemonByAbilityUseCase()
        mockFilterPokemonByMovesUseCase = MockFilterPokemonByMovesUseCase()
        mockFetchVersionGroupsUseCase = MockFetchVersionGroupsUseCase()
        mockPokemonRepository = MockPokemonRepository()
        // ViewModelの初期化は各テストメソッド内で行う
    }

    override func tearDown() async throws {
        sut = nil
        mockFetchPokemonListUseCase = nil
        mockSortPokemonUseCase = nil
        mockFilterPokemonByAbilityUseCase = nil
        mockFilterPokemonByMovesUseCase = nil
        mockFetchVersionGroupsUseCase = nil
        mockPokemonRepository = nil
        try await super.tearDown()
    }

    // MARK: - Helper Methods

    private func createViewModel() -> PokemonListViewModel {
        PokemonListViewModel(
            fetchPokemonListUseCase: mockFetchPokemonListUseCase,
            sortPokemonUseCase: mockSortPokemonUseCase,
            filterPokemonByAbilityUseCase: mockFilterPokemonByAbilityUseCase,
            filterPokemonByMovesUseCase: mockFilterPokemonByMovesUseCase,
            fetchVersionGroupsUseCase: mockFetchVersionGroupsUseCase,
            pokemonRepository: mockPokemonRepository
        )
    }

    // MARK: - Load Pokemons Tests

    func test_loadPokemons_success_updatesPokemonsList() async {
        // Given
        sut = createViewModel()
        let expectedPokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        mockPokemonRepository.pokemonsToReturn = expectedPokemons

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
        sut = createViewModel()
        mockPokemonRepository.shouldThrowError = true
        mockPokemonRepository.failCount = 999 // 常に失敗させる

        // When
        await sut.loadPokemons()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadPokemons_retry_succeedsAfterRetries() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.shouldThrowError = true
        mockPokemonRepository.failCount = 2 // 2回失敗後、成功
        mockPokemonRepository.pokemonsToReturn = [Pokemon.fixture()]

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
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 4, name: "charmander"),
            Pokemon.fixture(id: 7, name: "squirtle")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "char"
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].name, "charmander")
    }

    func test_applyFilters_partialMatch_filtersPokemons() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "saur"
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_caseInsensitive_filtersPokemons() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = "BULBA"
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
    }

    func test_applyFilters_type_filtersPokemons() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]
        await sut.loadPokemons()

        // When
        sut.selectedTypes = ["fire"]
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].types[0].name, "fire")
    }

    func test_applyFilters_multipleTypes_filtersPokemons() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]
        await sut.loadPokemons()

        // When
        sut.selectedTypes = ["fire", "water"]
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_emptySearchText_showsAllPokemons() async {
        // Given
        sut = createViewModel()
        mockPokemonRepository.pokemonsToReturn = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]
        await sut.loadPokemons()

        // When
        sut.searchText = ""
        sut.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    // MARK: - Display Mode Tests

    func test_toggleDisplayMode_togglesBetweenListAndGrid() async {
        // Given
        sut = createViewModel()
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
        sut = createViewModel()
        mockFetchPokemonListUseCase.pokemonsToReturn = [Pokemon.fixture()]
        await sut.loadPokemons()
        sut.searchText = "test"
        sut.selectedTypes = ["fire", "water"]
        sut.selectedAbilities = ["overgrow"]

        // When
        sut.clearFilters()

        // Then
        XCTAssertEqual(sut.searchText, "")
        XCTAssertTrue(sut.selectedTypes.isEmpty)
        XCTAssertTrue(sut.selectedAbilities.isEmpty)
    }
}

// MARK: - Mock UseCases

final class MockFetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {
    var pokemonsToReturn: [Pokemon] = []
    var shouldThrowError = false
    var failCount = 0
    private var callCount = 0

    func execute(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        callCount += 1

        if shouldThrowError {
            if callCount <= failCount {
                throw PokemonError.networkError(NSError(domain: "test", code: -1))
            }
        }

        return pokemonsToReturn
    }
}

final class MockSortPokemonUseCase: SortPokemonUseCaseProtocol {
    func execute(pokemonList: [Pokemon], sortOption: SortOption) -> [Pokemon] {
        return pokemonList
    }
}

final class MockFilterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol {
    func execute(pokemonList: [Pokemon], selectedAbilities: Set<String>) -> [Pokemon] {
        return pokemonList
    }
}

final class MockFilterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol {
    var resultsToReturn: [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])] = []
    var shouldThrowError = false

    func execute(pokemonList: [Pokemon], selectedMoves: [MoveEntity], versionGroup: String) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])] {
        if shouldThrowError {
            throw PokemonError.networkError(NSError(domain: "test", code: -1))
        }
        return resultsToReturn
    }
}

final class MockFetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol {
    var versionGroupsToReturn: [VersionGroup] = [.nationalDex]

    func execute() -> [VersionGroup] {
        return versionGroupsToReturn
    }
}
