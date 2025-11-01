//
//  ItemProviderTests.swift
//  PokedexTests
//
//  Created on 2025-11-01.
//

import XCTest
@testable import Pokedex

final class ItemProviderTests: XCTestCase {
    var sut: ItemProvider!
    var testBundle: Bundle!

    override func setUp() async throws {
        try await super.setUp()

        // テスト用のバンドルを使用（実際のJSONファイルを読み込む）
        testBundle = Bundle.main
        sut = ItemProvider(bundle: testBundle)
    }

    override func tearDown() async throws {
        sut = nil
        testBundle = nil
        try await super.tearDown()
    }

    // MARK: - fetchAllItems Tests

    func test_fetchAllItems_returnsItemsFromJSON() async throws {
        // When
        let items = try await sut.fetchAllItems()

        // Then
        XCTAssertFalse(items.isEmpty, "Items should not be empty")
        XCTAssertGreaterThanOrEqual(items.count, 10, "Should have at least 10 items")

        // ID順にソートされているか確認
        let sortedItems = items.sorted { $0.id < $1.id }
        XCTAssertEqual(items.map(\.id), sortedItems.map(\.id), "Items should be sorted by ID")
    }

    func test_fetchAllItems_cachesResult() async throws {
        // Given
        let firstFetch = try await sut.fetchAllItems()

        // When
        let secondFetch = try await sut.fetchAllItems()

        // Then
        XCTAssertEqual(firstFetch.count, secondFetch.count)
        // キャッシュが効いているので、同じインスタンスが返される
    }

    // MARK: - fetchItem(id:) Tests

    func test_fetchItemById_returnsCorrectItem() async throws {
        // Given: Choice Band (ID: 234)
        let expectedId = 234

        // When
        let item = try await sut.fetchItem(id: expectedId)

        // Then
        XCTAssertEqual(item.id, expectedId)
        XCTAssertEqual(item.name, "choice-band")
        XCTAssertEqual(item.nameJa, "こだわりハチマキ")
        XCTAssertEqual(item.category, "held-item")
        XCTAssertNotNil(item.effects?.statMultiplier)
        XCTAssertEqual(item.effects?.statMultiplier?.stat, "attack")
        XCTAssertEqual(item.effects?.statMultiplier?.multiplier, 1.5)
    }

    func test_fetchItemById_withInvalidId_throwsError() async {
        // Given: 存在しないID
        let invalidId = 99999

        // When & Then
        do {
            _ = try await sut.fetchItem(id: invalidId)
            XCTFail("Should throw itemNotFound error")
        } catch ItemProviderError.itemNotFound(let id) {
            XCTAssertEqual(id, invalidId)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - fetchItem(name:) Tests

    func test_fetchItemByName_returnsCorrectItem() async throws {
        // Given: Life Orb
        let expectedName = "life-orb"

        // When
        let item = try await sut.fetchItem(name: expectedName)

        // Then
        XCTAssertEqual(item.name, expectedName)
        XCTAssertEqual(item.id, 245)
        XCTAssertEqual(item.nameJa, "いのちのたま")
        XCTAssertNotNil(item.effects?.damageMultiplier)
        XCTAssertEqual(item.effects?.damageMultiplier?.condition, "all_damaging_moves")
        XCTAssertEqual(item.effects?.damageMultiplier?.baseMultiplier, 1.3)
    }

    func test_fetchItemByName_withInvalidName_throwsError() async {
        // Given: 存在しない名前
        let invalidName = "non-existent-item"

        // When & Then
        do {
            _ = try await sut.fetchItem(name: invalidName)
            XCTFail("Should throw itemNotFound error")
        } catch ItemProviderError.itemNotFound {
            // Success
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - fetchItems(category:) Tests

    func test_fetchItemsByCategory_returnsFilteredItems() async throws {
        // Given
        let category = "held-item"

        // When
        let items = try await sut.fetchItems(category: category)

        // Then
        XCTAssertFalse(items.isEmpty)
        XCTAssertTrue(items.allSatisfy { $0.category == category })
    }

    func test_fetchItemsByCategory_withNoMatches_returnsEmptyArray() async throws {
        // Given: 存在しないカテゴリー
        let category = "non-existent-category"

        // When
        let items = try await sut.fetchItems(category: category)

        // Then
        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - Ogerpon Mask Tests

    func test_fetchOgerponMasks_haveCorrectProperties() async throws {
        // Given: オーガポンのマスク
        let maskNames = ["wellspring-mask", "hearthflame-mask", "cornerstone-mask", "teal-mask"]
        let expectedTypes = ["water", "fire", "rock", "grass"]

        for (index, maskName) in maskNames.enumerated() {
            // When
            let mask = try await sut.fetchItem(name: maskName)

            // Then
            XCTAssertNotNil(mask.effects?.damageMultiplier)
            let damageEffect = mask.effects?.damageMultiplier

            XCTAssertEqual(damageEffect?.condition, "same_type_as_mask")
            XCTAssertEqual(damageEffect?.types?.first, expectedTypes[index])
            XCTAssertEqual(damageEffect?.baseMultiplier, 1.2)
            XCTAssertEqual(damageEffect?.teraMultiplier, 1.3)
            XCTAssertEqual(damageEffect?.appliesDuringTera, true)
            XCTAssertTrue(damageEffect?.isOgerponMask ?? false)
        }
    }

    func test_damageMultiplierEffect_canApplyToPokemon() {
        // Given: オーガポン専用マスクの効果
        let effect = DamageMultiplierEffect.fixture(
            restrictedTo: ["ogerpon-wellspring-mask"]
        )

        // When & Then
        XCTAssertTrue(effect.canApply(to: "ogerpon-wellspring-mask"))
        XCTAssertFalse(effect.canApply(to: "pikachu"))
    }

    func test_damageMultiplierEffect_appliesToType() {
        // Given: 水タイプ限定の効果
        let effect = DamageMultiplierEffect.fixture(
            types: ["water"]
        )

        // When & Then
        XCTAssertTrue(effect.appliesToType("water"))
        XCTAssertFalse(effect.appliesToType("fire"))
    }

    // MARK: - Performance Tests

    func test_fetchAllItems_performance() {
        measure {
            Task {
                _ = try? await sut.fetchAllItems()
            }
        }
    }
}
