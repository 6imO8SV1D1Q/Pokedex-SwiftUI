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

    // MARK: - ポケモンリスト取得のテスト

    func test_loadPokemons_成功時にポケモンリストが更新される() async {
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

    func test_loadPokemons_エラー時にエラーメッセージが設定される() async {
        // Given
        mockFetchPokemonListUseCase.shouldThrowError = true

        // When
        await sut.loadPokemons()

        // Then
        XCTAssertNotNil(sut.errorMessage)
        XCTAssertTrue(sut.showError)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadPokemons_リトライ機能が動作する() async {
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

    // MARK: - フィルター機能のテスト

    func test_applyFilters_検索テキストでフィルタリングされる() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 4, name: "charmander"),
            Pokemon.fixture(id: 7, name: "squirtle")
        ]

        // When
        sut.searchText = "char"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].name, "charmander")
    }

    func test_applyFilters_部分一致で検索される() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]

        // When
        sut.searchText = "saur"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_大文字小文字を区別しない() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur")
        ]

        // When
        sut.searchText = "BULBA"
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
    }

    func test_applyFilters_タイプでフィルタリングされる() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]

        // When
        sut.selectedTypes = ["fire"]
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 1)
        XCTAssertEqual(sut.filteredPokemons[0].types[0].name, "fire")
    }

    func test_applyFilters_複数タイプでフィルタリングされる() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, types: [.fixture(name: "grass")]),
            Pokemon.fixture(id: 4, types: [.fixture(name: "fire")]),
            Pokemon.fixture(id: 7, types: [.fixture(name: "water")])
        ]

        // When
        sut.selectedTypes = ["fire", "water"]
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    func test_applyFilters_検索テキストが空の場合すべて表示() {
        // Given
        sut.pokemons = [
            Pokemon.fixture(id: 1, name: "bulbasaur"),
            Pokemon.fixture(id: 2, name: "ivysaur")
        ]

        // When
        sut.searchText = ""
        sut.applyFilters()

        // Then
        XCTAssertEqual(sut.filteredPokemons.count, 2)
    }

    // MARK: - 表示モード切り替えのテスト

    func test_toggleDisplayMode_リストとグリッドを切り替える() {
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

    // MARK: - フィルタークリアのテスト

    func test_clearFilters_すべてのフィルターがクリアされる() {
        // Given
        sut.pokemons = [Pokemon.fixture()]
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
