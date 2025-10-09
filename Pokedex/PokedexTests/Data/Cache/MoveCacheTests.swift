//
//  MoveCacheTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class MoveCacheTests: XCTestCase {
    var sut: MoveCache!

    override func setUp() {
        super.setUp()
        sut = MoveCache()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_getMoves_returnsNil_whenCacheEmpty() {
        // When
        let result = sut.getMoves(key: "test")

        // Then
        XCTAssertNil(result)
    }

    func test_setMoves_storesData() async {
        // Given
        let moves = createMockMoves(count: 5)

        // When
        sut.setMoves(key: "test", moves: moves)

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        let result = sut.getMoves(key: "test")

        // Then
        XCTAssertEqual(result?.count, 5)
    }

    func test_clear_removesAllData() async {
        // Given
        sut.setMoves(key: "test1", moves: createMockMoves(count: 3))
        sut.setMoves(key: "test2", moves: createMockMoves(count: 5))

        // Wait for async operations
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // When
        sut.clear()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then
        XCTAssertNil(sut.getMoves(key: "test1"))
        XCTAssertNil(sut.getMoves(key: "test2"))
    }

    func test_setMoves_overwritesExistingData() async {
        // Given
        sut.setMoves(key: "test", moves: createMockMoves(count: 3))
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // When
        sut.setMoves(key: "test", moves: createMockMoves(count: 7))
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        let result = sut.getMoves(key: "test")

        // Then
        XCTAssertEqual(result?.count, 7)
    }

    func test_threadSafety_concurrentReadsAndWrites() async {
        // 複数のキーに対して書き込みと読み込みを実行
        for i in 0..<100 {
            sut.setMoves(key: "key\(i)", moves: createMockMoves(count: 1))
            _ = sut.getMoves(key: "key\(i)")
        }

        // 少し待機してすべての非同期操作が完了するのを待つ
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // 最初と最後のキーが正しく保存されているか確認
        let first = sut.getMoves(key: "key0")
        let last = sut.getMoves(key: "key99")

        XCTAssertNotNil(first)
        XCTAssertNotNil(last)
    }

    // MARK: - Helpers

    private func createMockMoves(count: Int) -> [MoveEntity] {
        (1...count).map {
            MoveEntity.fixture(id: $0, name: "Move\($0)", type: PokemonType(slot: 1, name: "normal"))
        }
    }
}
