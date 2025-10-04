//
//  PokemonDetailViewModelTests.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import XCTest
@testable import Pokedex

@MainActor
final class PokemonDetailViewModelTests: XCTestCase {
    var sut: PokemonDetailViewModel!
    var mockFetchEvolutionChainUseCase: MockFetchEvolutionChainUseCase!

    override func setUp() {
        super.setUp()
        mockFetchEvolutionChainUseCase = MockFetchEvolutionChainUseCase()
        let testPokemon = Pokemon.fixture()
        sut = PokemonDetailViewModel(
            pokemon: testPokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )
    }

    override func tearDown() {
        sut = nil
        mockFetchEvolutionChainUseCase = nil
        super.tearDown()
    }

    // MARK: - 初期化のテスト

    func test_init_ポケモンが正しく設定される() {
        // Given & When
        let pokemon = Pokemon.fixture(id: 25, name: "pikachu")
        let viewModel = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // Then
        XCTAssertEqual(viewModel.pokemon.id, 25)
        XCTAssertEqual(viewModel.pokemon.name, "pikachu")
        XCTAssertFalse(viewModel.isShiny)
    }

    // MARK: - 色違い切り替えのテスト

    func test_toggleShiny_色違いフラグが切り替わる() {
        // Given
        XCTAssertFalse(sut.isShiny)

        // When
        sut.toggleShiny()

        // Then
        XCTAssertTrue(sut.isShiny)

        // When
        sut.toggleShiny()

        // Then
        XCTAssertFalse(sut.isShiny)
    }

    func test_displayImageURL_通常時はpreferredImageURLを返す() {
        // Given
        let sprites = PokemonSprites.fixture(
            frontDefault: "https://example.com/normal.png",
            frontShiny: "https://example.com/shiny.png"
        )
        let pokemon = Pokemon.fixture(sprites: sprites)
        sut = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // When
        sut.isShiny = false

        // Then
        XCTAssertEqual(sut.displayImageURL, "https://example.com/normal.png")
    }

    func test_displayImageURL_色違い時はshinyImageURLを返す() {
        // Given
        let sprites = PokemonSprites.fixture(
            frontDefault: "https://example.com/normal.png",
            frontShiny: "https://example.com/shiny.png"
        )
        let pokemon = Pokemon.fixture(sprites: sprites)
        sut = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // When
        sut.isShiny = true

        // Then
        XCTAssertEqual(sut.displayImageURL, "https://example.com/shiny.png")
    }

    // MARK: - 進化チェーン読み込みのテスト

    func test_loadEvolutionChain_成功時に進化チェーンが更新される() async {
        // Given
        mockFetchEvolutionChainUseCase.evolutionChainToReturn = [1, 2, 3]

        // When
        await sut.loadEvolutionChain()

        // Then
        XCTAssertEqual(sut.evolutionChain.count, 3)
        XCTAssertEqual(sut.evolutionChain[0], 1)
        XCTAssertEqual(sut.evolutionChain[1], 2)
        XCTAssertEqual(sut.evolutionChain[2], 3)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadEvolutionChain_エラー時は空配列になる() async {
        // Given
        mockFetchEvolutionChainUseCase.shouldThrowError = true

        // When
        await sut.loadEvolutionChain()

        // Then
        // 進化チェーンの取得失敗は致命的ではないため、空配列のまま
        XCTAssertTrue(sut.evolutionChain.isEmpty)
        XCTAssertFalse(sut.isLoading)
    }

    func test_loadEvolutionChain_リトライ機能が動作する() async {
        // Given
        mockFetchEvolutionChainUseCase.shouldThrowError = true
        mockFetchEvolutionChainUseCase.failCount = 2 // 2回失敗後、成功
        mockFetchEvolutionChainUseCase.evolutionChainToReturn = [1, 2]

        // When
        await sut.loadEvolutionChain()

        // Then
        XCTAssertEqual(sut.evolutionChain.count, 2)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - 技のフィルタリングのテスト

    func test_filteredMoves_習得方法でフィルタリングされる() {
        // Given
        let moves = [
            PokemonMove.fixture(name: "tackle", learnMethod: "level-up", level: 1),
            PokemonMove.fixture(name: "thunderbolt", learnMethod: "machine", level: nil),
            PokemonMove.fixture(name: "body-slam", learnMethod: "level-up", level: 10)
        ]
        let pokemon = Pokemon.fixture(moves: moves)
        sut = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // When
        sut.selectedLearnMethod = "level-up"

        // Then
        XCTAssertEqual(sut.filteredMoves.count, 2)
        XCTAssertEqual(sut.filteredMoves[0].name, "tackle")
        XCTAssertEqual(sut.filteredMoves[1].name, "body-slam")
    }

    func test_filteredMoves_レベル順にソートされる() {
        // Given
        let moves = [
            PokemonMove.fixture(name: "move3", learnMethod: "level-up", level: 30),
            PokemonMove.fixture(name: "move1", learnMethod: "level-up", level: 1),
            PokemonMove.fixture(name: "move2", learnMethod: "level-up", level: 15)
        ]
        let pokemon = Pokemon.fixture(moves: moves)
        sut = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // When
        sut.selectedLearnMethod = "level-up"

        // Then
        XCTAssertEqual(sut.filteredMoves[0].level, 1)
        XCTAssertEqual(sut.filteredMoves[1].level, 15)
        XCTAssertEqual(sut.filteredMoves[2].level, 30)
    }

    func test_filteredMoves_マシン技を選択した場合正しくフィルタリングされる() {
        // Given
        let moves = [
            PokemonMove.fixture(name: "tackle", learnMethod: "level-up", level: 1),
            PokemonMove.fixture(name: "thunderbolt", learnMethod: "machine", level: nil)
        ]
        let pokemon = Pokemon.fixture(moves: moves)
        sut = PokemonDetailViewModel(
            pokemon: pokemon,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase
        )

        // When
        sut.selectedLearnMethod = "machine"

        // Then
        XCTAssertEqual(sut.filteredMoves.count, 1)
        XCTAssertEqual(sut.filteredMoves[0].name, "thunderbolt")
    }
}

// MARK: - Mock UseCase

final class MockFetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol {
    var evolutionChainToReturn: [Int] = []
    var shouldThrowError = false
    var failCount = 0
    private var callCount = 0

    func execute(pokemonId: Int) async throws -> [Int] {
        callCount += 1

        if shouldThrowError {
            if callCount <= failCount {
                throw PokemonError.networkError(NSError(domain: "test", code: -1))
            }
        }

        return evolutionChainToReturn
    }
}
