//
//  FetchPokemonFormsUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-09.
//

import XCTest
@testable import Pokedex

@MainActor
final class FetchPokemonFormsUseCaseTests: XCTestCase {
    var sut: FetchPokemonFormsUseCase!
    var mockRepository: MockPokemonRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockPokemonRepository()
        sut = FetchPokemonFormsUseCase(pokemonRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Test Data

    /// リザードンの全フォーム（通常、メガX、メガY）
    private func charizardAllForms() -> [PokemonForm] {
        return [
            PokemonForm(
                id: 6,
                name: "charizard",
                pokemonId: 6,
                formName: "charizard",
                types: [PokemonType(slot: 1, name: "fire"), PokemonType(slot: 2, name: "flying")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: true,
                isMega: false,
                isRegional: false,
                versionGroup: nil
            ),
            PokemonForm(
                id: 10006,
                name: "charizard-mega-x",
                pokemonId: 6,
                formName: "charizard-mega-x",
                types: [PokemonType(slot: 1, name: "fire"), PokemonType(slot: 2, name: "dragon")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: false,
                isMega: true,
                isRegional: false,
                versionGroup: "x-y"
            ),
            PokemonForm(
                id: 10007,
                name: "charizard-mega-y",
                pokemonId: 6,
                formName: "charizard-mega-y",
                types: [PokemonType(slot: 1, name: "fire"), PokemonType(slot: 2, name: "flying")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: false,
                isMega: true,
                isRegional: false,
                versionGroup: "x-y"
            )
        ]
    }

    /// ニャースの全フォーム（通常、アローラ、ガラル）
    private func meowthAllForms() -> [PokemonForm] {
        return [
            PokemonForm(
                id: 52,
                name: "meowth",
                pokemonId: 52,
                formName: "meowth",
                types: [PokemonType(slot: 1, name: "normal")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: true,
                isMega: false,
                isRegional: false,
                versionGroup: nil
            ),
            PokemonForm(
                id: 10161,
                name: "meowth-alola",
                pokemonId: 52,
                formName: "meowth-alola",
                types: [PokemonType(slot: 1, name: "dark")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: false,
                isMega: false,
                isRegional: true,
                versionGroup: "sun-moon"
            ),
            PokemonForm(
                id: 10162,
                name: "meowth-galar",
                pokemonId: 52,
                formName: "meowth-galar",
                types: [PokemonType(slot: 1, name: "steel")],
                sprites: PokemonSprites(frontDefault: "", frontShiny: nil, other: nil),
                stats: [],
                abilities: [],
                isDefault: false,
                isMega: false,
                isRegional: true,
                versionGroup: "sword-shield"
            )
        ]
    }

    // MARK: - Success Cases - No Version Group

    func testFetchForms_バージョングループなし_全フォーム取得() async throws {
        // Given
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: nil)

        // Then
        XCTAssertEqual(result.count, 3, "全3フォームが返される")
        XCTAssertTrue(result.contains(where: { $0.isDefault }), "通常フォームを含む")
        XCTAssertTrue(result.contains(where: { $0.isMega && $0.formName.contains("mega-x") }), "メガXを含む")
        XCTAssertTrue(result.contains(where: { $0.isMega && $0.formName.contains("mega-y") }), "メガYを含む")
        XCTAssertEqual(mockRepository.fetchPokemonFormsCallCount, 1)
    }

    // MARK: - Success Cases - Version Group Filtering

    func testFetchForms_バージョングループXY_メガシンカあり() async throws {
        // Given
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: "x-y")

        // Then
        XCTAssertEqual(result.count, 3, "通常 + メガX + メガY = 3フォーム")
        XCTAssertTrue(result.contains(where: { $0.isDefault }), "通常フォームは常に含まれる")
        XCTAssertTrue(result.contains(where: { $0.formName.contains("mega-x") }), "メガXを含む")
        XCTAssertTrue(result.contains(where: { $0.formName.contains("mega-y") }), "メガYを含む")
    }

    func testFetchForms_バージョングループ赤緑_メガシンカなし() async throws {
        // Given
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: "red-blue")

        // Then
        XCTAssertEqual(result.count, 1, "通常フォームのみ")
        XCTAssertTrue(result[0].isDefault, "通常フォームのみ含まれる")
        XCTAssertFalse(result.contains(where: { $0.isMega }), "メガシンカは含まれない")
    }

    func testFetchForms_バージョングループ金銀_メガシンカなし() async throws {
        // Given
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: "gold-silver")

        // Then
        XCTAssertEqual(result.count, 1, "通常フォームのみ")
        XCTAssertFalse(result.contains(where: { $0.isMega }), "メガシンカは含まれない")
    }

    func testFetchForms_バージョングループサンムーン_アローラあり() async throws {
        // Given
        let allForms = meowthAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 52, versionGroup: "sun-moon")

        // Then
        XCTAssertTrue(result.contains(where: { $0.isDefault }), "通常フォームを含む")
        XCTAssertTrue(result.contains(where: { $0.formName.contains("alola") }), "アローラフォームを含む")
        XCTAssertFalse(result.contains(where: { $0.formName.contains("galar") }), "ガラルフォームは含まれない")
    }

    func testFetchForms_バージョングループ剣盾_ガラルあり() async throws {
        // Given
        let allForms = meowthAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 52, versionGroup: "sword-shield")

        // Then
        XCTAssertTrue(result.contains(where: { $0.isDefault }), "通常フォームを含む")
        XCTAssertTrue(result.contains(where: { $0.formName.contains("alola") }), "アローラフォームを含む（過去世代のフォーム）")
        XCTAssertTrue(result.contains(where: { $0.formName.contains("galar") }), "ガラルフォームを含む")
    }

    func testFetchForms_バージョングループ赤緑_リージョンなし() async throws {
        // Given
        let allForms = meowthAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 52, versionGroup: "red-blue")

        // Then
        XCTAssertEqual(result.count, 1, "通常フォームのみ")
        XCTAssertTrue(result[0].isDefault, "通常フォームのみ")
        XCTAssertFalse(result.contains(where: { $0.isRegional }), "リージョンフォームは含まれない")
    }

    // MARK: - Version Group Order Tests

    func testFetchForms_バージョン順序_OMASではメガあり() async throws {
        // Given: オメガルビー・アルファサファイア
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: "omega-ruby-alpha-sapphire")

        // Then
        XCTAssertTrue(result.contains(where: { $0.isMega }), "X-Y以降なのでメガシンカを含む")
    }

    func testFetchForms_バージョン順序_ダイパではメガなし() async throws {
        // Given: ダイヤモンド・パール（メガシンカより前）
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: "diamond-pearl")

        // Then
        XCTAssertFalse(result.contains(where: { $0.isMega }), "X-Yより前なのでメガシンカなし")
    }

    // MARK: - Error Cases

    func testFetchForms_networkError_throwsError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = PokemonError.networkError(NSError(domain: "test", code: -1))

        // When & Then
        do {
            _ = try await sut.execute(pokemonId: 6, versionGroup: nil)
            XCTFail("エラーがthrowされるべき")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
    }

    // MARK: - Edge Cases

    func testFetchForms_emptyForms_returnsEmpty() async throws {
        // Given
        mockRepository.formsToReturn = []

        // When
        let result = try await sut.execute(pokemonId: 999, versionGroup: nil)

        // Then
        XCTAssertTrue(result.isEmpty, "フォームがない場合は空配列")
    }

    func testFetchForms_unknownVersionGroup_includesDefault() async throws {
        // Given
        let allForms = charizardAllForms()
        mockRepository.formsToReturn = allForms

        // When: 存在しないバージョングループ
        let result = try await sut.execute(pokemonId: 6, versionGroup: "unknown-version")

        // Then
        XCTAssertTrue(result.contains(where: { $0.isDefault }), "通常フォームは常に含まれる")
        // メガシンカは除外される（バージョン順序で見つからないため）
        XCTAssertFalse(result.contains(where: { $0.isMega }), "不明なバージョンではメガシンカ除外")
    }
}
