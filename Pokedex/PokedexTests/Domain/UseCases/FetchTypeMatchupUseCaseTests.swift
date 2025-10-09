//
//  FetchTypeMatchupUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-09.
//

import XCTest
@testable import Pokedex

@MainActor
final class FetchTypeMatchupUseCaseTests: XCTestCase {
    var sut: FetchTypeMatchupUseCase!
    var mockRepository: MockTypeRepository!

    override func setUp() {
        super.setUp()
        mockRepository = MockTypeRepository()
        mockRepository.setupMockData()
        sut = FetchTypeMatchupUseCase(typeRepository: mockRepository)
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        super.tearDown()
    }

    // MARK: - Success Cases - Single Type

    func testFetchTypeMatchup_単タイプ_ほのお() async throws {
        // Given
        let fireType = PokemonType(slot: 1, name: "fire")

        // When
        let result = try await sut.execute(types: [fireType])

        // Then: 攻撃面
        XCTAssertTrue(result.offensive.superEffective.contains("grass"), "ほのおはくさに効果ばつぐん")
        XCTAssertTrue(result.offensive.superEffective.contains("ice"), "ほのおはこおりに効果ばつぐん")
        XCTAssertTrue(result.offensive.superEffective.contains("bug"), "ほのおはむしに効果ばつぐん")
        XCTAssertTrue(result.offensive.superEffective.contains("steel"), "ほのおははがねに効果ばつぐん")

        // Then: 防御面 - 弱点
        XCTAssertTrue(result.defensive.doubleWeak.contains("water"), "ほのおはみずが弱点")
        XCTAssertTrue(result.defensive.doubleWeak.contains("ground"), "ほのおはじめんが弱点")
        XCTAssertTrue(result.defensive.doubleWeak.contains("rock"), "ほのおはいわが弱点")
        XCTAssertFalse(result.defensive.quadrupleWeak.contains("water"), "4倍弱点はない")

        // Then: 防御面 - 耐性
        XCTAssertTrue(result.defensive.doubleResist.contains("fire"), "ほのおタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("grass"), "くさタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("ice"), "こおりタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("bug"), "むしタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("steel"), "はがねタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("fairy"), "フェアリータイプは半減")

        // Then: 防御面 - 無効
        XCTAssertTrue(result.defensive.immune.isEmpty, "無効タイプはない")

        XCTAssertEqual(mockRepository.fetchTypeDetailCallCount, 1, "1回APIを呼び出す")
    }

    func testFetchTypeMatchup_単タイプ_でんき() async throws {
        // Given
        let electricType = PokemonType(slot: 1, name: "electric")

        // When
        let result = try await sut.execute(types: [electricType])

        // Then: 攻撃面
        XCTAssertTrue(result.offensive.superEffective.contains("water"), "でんきはみずに効果ばつぐん")
        XCTAssertTrue(result.offensive.superEffective.contains("flying"), "でんきはひこうに効果ばつぐん")

        // Then: 防御面 - 弱点
        XCTAssertTrue(result.defensive.doubleWeak.contains("ground"), "でんきはじめんが弱点")
        XCTAssertEqual(result.defensive.doubleWeak.count, 1, "弱点は1つ")

        // Then: 防御面 - 耐性
        XCTAssertTrue(result.defensive.doubleResist.contains("electric"), "でんきタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("flying"), "ひこうタイプは半減")
        XCTAssertTrue(result.defensive.doubleResist.contains("steel"), "はがねタイプは半減")
    }

    // MARK: - Success Cases - Dual Type

    func testFetchTypeMatchup_複合タイプ_ほのおひこう_4倍弱点() async throws {
        // Given: リザードンのタイプ（ほのお・ひこう）
        let fireType = PokemonType(slot: 1, name: "fire")
        let flyingType = PokemonType(slot: 2, name: "flying")

        // When
        let result = try await sut.execute(types: [fireType, flyingType])

        // Then: 防御面 - 4倍弱点
        XCTAssertTrue(result.defensive.quadrupleWeak.contains("rock"), "いわタイプは4倍弱点")
        XCTAssertEqual(result.defensive.quadrupleWeak.count, 1, "4倍弱点は1つ")

        // Then: 防御面 - 2倍弱点（いわ以外）
        XCTAssertTrue(result.defensive.doubleWeak.contains("water"), "みずタイプは2倍弱点")
        XCTAssertTrue(result.defensive.doubleWeak.contains("electric"), "でんきタイプは2倍弱点")
        XCTAssertFalse(result.defensive.doubleWeak.contains("rock"), "いわは4倍弱点なので2倍には含まれない")

        // Then: 防御面 - 無効
        XCTAssertTrue(result.defensive.immune.contains("ground"), "じめんタイプは無効")

        // Then: 防御面 - 1/4倍耐性
        XCTAssertTrue(result.defensive.quadrupleResist.contains("grass"), "くさタイプは1/4倍")
        XCTAssertTrue(result.defensive.quadrupleResist.contains("bug"), "むしタイプは1/4倍")

        XCTAssertEqual(mockRepository.fetchTypeDetailCallCount, 2, "2回APIを呼び出す")
    }

    func testFetchTypeMatchup_複合タイプ_みずひこう_耐性() async throws {
        // Given: ギャラドスのタイプ（みず・ひこう）
        let waterType = PokemonType(slot: 1, name: "water")
        let flyingType = PokemonType(slot: 2, name: "flying")

        // When
        let result = try await sut.execute(types: [waterType, flyingType])

        // Then: 防御面 - 4倍弱点
        XCTAssertTrue(result.defensive.quadrupleWeak.contains("electric"), "でんきタイプは4倍弱点")

        // Then: 防御面 - 無効
        XCTAssertTrue(result.defensive.immune.contains("ground"), "じめんタイプは無効")

        // Then: 防御面 - 1/2倍耐性
        XCTAssertTrue(result.defensive.doubleResist.contains("fire"), "ほのおタイプは1/2倍（みずで0.5、ひこうで1.0）")
        XCTAssertTrue(result.defensive.doubleResist.contains("bug"), "むしタイプは1/2倍（みずで1.0、ひこうで0.5）")
        XCTAssertTrue(result.defensive.doubleResist.contains("fighting"), "かくとうタイプは1/2倍（みずで1.0、ひこうで0.5）")
    }

    // MARK: - Offensive Matchup Tests

    func testOffensiveMatchup_集約() async throws {
        // Given: ほのお・ひこう（リザードン）
        let fireType = PokemonType(slot: 1, name: "fire")
        let flyingType = PokemonType(slot: 2, name: "flying")

        // When
        let result = try await sut.execute(types: [fireType, flyingType])

        // Then: 両タイプの効果ばつぐんを統合
        // ほのお: grass, ice, bug, steel
        // ひこう: grass, fighting, bug
        // 統合: grass, ice, bug, steel, fighting
        XCTAssertTrue(result.offensive.superEffective.contains("grass"))
        XCTAssertTrue(result.offensive.superEffective.contains("ice"))
        XCTAssertTrue(result.offensive.superEffective.contains("bug"))
        XCTAssertTrue(result.offensive.superEffective.contains("steel"))
        XCTAssertTrue(result.offensive.superEffective.contains("fighting"))
    }

    // MARK: - Defensive Matchup Calculation Tests

    func testDefensiveMatchup_倍率計算() async throws {
        // Given: ほのお・ひこう
        let fireType = PokemonType(slot: 1, name: "fire")
        let flyingType = PokemonType(slot: 2, name: "flying")

        // When
        let result = try await sut.execute(types: [fireType, flyingType])

        // Then: じめん無効（ほのお2倍 * ひこう0倍 = 0倍）
        XCTAssertTrue(result.defensive.immune.contains("ground"))

        // Then: いわ4倍（ほのお2倍 * ひこう2倍 = 4倍）
        XCTAssertTrue(result.defensive.quadrupleWeak.contains("rock"))

        // Then: くさ1/4倍（ほのお0.5倍 * ひこう0.5倍 = 0.25倍）
        XCTAssertTrue(result.defensive.quadrupleResist.contains("grass"))
        XCTAssertTrue(result.defensive.quadrupleResist.contains("bug"))
    }

    func testDefensiveMatchup_タイプ番号順() async throws {
        // Given
        let fireType = PokemonType(slot: 1, name: "fire")

        // When
        let result = try await sut.execute(types: [fireType])

        // Then: ソートされている
        let doubleWeak = result.defensive.doubleWeak
        XCTAssertEqual(doubleWeak, doubleWeak.sorted(), "2倍弱点はソート済み")

        let doubleResist = result.defensive.doubleResist
        XCTAssertEqual(doubleResist, doubleResist.sorted(), "耐性はソート済み")
    }

    // MARK: - Error Cases

    func testFetchTypeMatchup_networkError_throwsError() async {
        // Given
        mockRepository.shouldThrowError = true
        mockRepository.errorToThrow = PokemonError.networkError(NSError(domain: "test", code: -1))
        let fireType = PokemonType(slot: 1, name: "fire")

        // When & Then
        do {
            _ = try await sut.execute(types: [fireType])
            XCTFail("エラーがthrowされるべき")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
    }

    func testFetchTypeMatchup_unknownType_throwsNotFoundError() async {
        // Given
        let unknownType = PokemonType(slot: 1, name: "unknown-type")

        // When & Then
        do {
            _ = try await sut.execute(types: [unknownType])
            XCTFail("エラーがthrowされるべき")
        } catch let error as PokemonError {
            if case .notFound = error {
                // Success
            } else {
                XCTFail("PokemonError.notFoundがthrowされるべき")
            }
        } catch {
            XCTFail("PokemonError.notFoundがthrowされるべき")
        }
    }

    // MARK: - Edge Cases

    func testFetchTypeMatchup_emptyTypes_returnsEmptyMatchup() async throws {
        // Given
        let emptyTypes: [PokemonType] = []

        // When
        let result = try await sut.execute(types: emptyTypes)

        // Then
        XCTAssertTrue(result.offensive.superEffective.isEmpty, "攻撃面は空")
        XCTAssertTrue(result.defensive.doubleWeak.isEmpty, "弱点は空")
        XCTAssertTrue(result.defensive.immune.isEmpty, "無効は空")
        XCTAssertEqual(mockRepository.fetchTypeDetailCallCount, 0, "APIは呼ばれない")
    }
}
