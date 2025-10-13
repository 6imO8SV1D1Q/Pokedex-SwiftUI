//
//  SortIntegrationTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class SortIntegrationTests: XCTestCase {
    var container: DIContainer!
    var viewModel: PokemonListViewModel!

    override func setUp() async throws {
        try await super.setUp()
        container = DIContainer.shared
        viewModel = container.makePokemonListViewModel()
        await viewModel.loadPokemons()
    }

    override func tearDown() async throws {
        viewModel = nil
        container = nil
        try await super.tearDown()
    }

    // MARK: - Sort Tests

    func test_sortByTotalStats_descendingOrder() async throws {
        // When
        viewModel.changeSortOption(.totalStats(ascending: false))

        // Wait for sorting to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: First pokemon has highest total stats
        guard viewModel.filteredPokemons.count >= 2 else {
            XCTFail("Not enough pokemon to test sorting")
            return
        }

        let first = viewModel.filteredPokemons[0]
        let second = viewModel.filteredPokemons[1]
        let firstTotal = first.stats.reduce(0) { $0 + $1.baseStat }
        let secondTotal = second.stats.reduce(0) { $0 + $1.baseStat }
        XCTAssertGreaterThanOrEqual(firstTotal, secondTotal)

        // Verify multiple pairs
        for i in 0..<min(10, viewModel.filteredPokemons.count - 1) {
            let current = viewModel.filteredPokemons[i]
            let next = viewModel.filteredPokemons[i + 1]
            let currentTotal = current.stats.reduce(0) { $0 + $1.baseStat }
            let nextTotal = next.stats.reduce(0) { $0 + $1.baseStat }
            XCTAssertGreaterThanOrEqual(currentTotal, nextTotal,
                                       "Pokemon at index \(i) should have higher total than index \(i+1)")
        }
    }

    func test_sortByHP_descendingOrder() async throws {
        // When
        viewModel.changeSortOption(.hp(ascending: false))

        // Wait for sorting to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: HP values are in descending order
        guard viewModel.filteredPokemons.count >= 2 else {
            XCTFail("Not enough pokemon to test sorting")
            return
        }

        for i in 0..<min(10, viewModel.filteredPokemons.count - 1) {
            let current = viewModel.filteredPokemons[i]
            let next = viewModel.filteredPokemons[i + 1]
            let currentHP = current.stats.first { $0.name == "hp" }?.baseStat ?? 0
            let nextHP = next.stats.first { $0.name == "hp" }?.baseStat ?? 0
            XCTAssertGreaterThanOrEqual(currentHP, nextHP,
                                       "Pokemon at index \(i) should have higher HP than index \(i+1)")
        }
    }

    func test_defaultSort_isPokedexNumber() async throws {
        // Then: Default sort is by pokedex number
        XCTAssertEqual(viewModel.currentSortOption, .pokedexNumber(ascending: true))

        // And: Pokemon are in ID order
        if viewModel.filteredPokemons.count >= 2 {
            let first = viewModel.filteredPokemons[0]
            let second = viewModel.filteredPokemons[1]
            XCTAssertLessThan(first.id, second.id)
        }
    }

    func test_sortByAttack_ascendingOrder() async throws {
        // When
        viewModel.changeSortOption(.attack(ascending: true))

        // Wait for sorting to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Attack values are in ascending order
        guard viewModel.filteredPokemons.count >= 2 else {
            XCTFail("Not enough pokemon to test sorting")
            return
        }

        for i in 0..<min(10, viewModel.filteredPokemons.count - 1) {
            let current = viewModel.filteredPokemons[i]
            let next = viewModel.filteredPokemons[i + 1]
            let currentAttack = current.stats.first { $0.name == "attack" }?.baseStat ?? 0
            let nextAttack = next.stats.first { $0.name == "attack" }?.baseStat ?? 0
            XCTAssertLessThanOrEqual(currentAttack, nextAttack,
                                    "Pokemon at index \(i) should have lower or equal attack than index \(i+1)")
        }
    }

    func test_sortPersists_afterFiltering() async throws {
        // Given: Sort by attack
        viewModel.changeSortOption(.attack(ascending: false))

        // Wait for sorting to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // When: Apply filter
        viewModel.searchText = "saur"
        viewModel.applyFilters()

        // Wait for filtering to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Sort is still by attack
        XCTAssertEqual(viewModel.currentSortOption, .attack(ascending: false))

        // And: Filtered results are sorted
        if viewModel.filteredPokemons.count >= 2 {
            for i in 0..<viewModel.filteredPokemons.count - 1 {
                let current = viewModel.filteredPokemons[i]
                let next = viewModel.filteredPokemons[i + 1]
                let currentAttack = current.stats.first { $0.name == "attack" }?.baseStat ?? 0
                let nextAttack = next.stats.first { $0.name == "attack" }?.baseStat ?? 0
                XCTAssertGreaterThanOrEqual(currentAttack, nextAttack,
                                        "Filtered pokemon should maintain sort order")
            }
        }
    }

    func test_sortBySpeed_descendingOrder() async throws {
        // When
        viewModel.changeSortOption(.speed(ascending: false))

        // Wait for sorting to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Speed values are in descending order
        guard viewModel.filteredPokemons.count >= 2 else {
            XCTFail("Not enough pokemon to test sorting")
            return
        }

        for i in 0..<min(10, viewModel.filteredPokemons.count - 1) {
            let current = viewModel.filteredPokemons[i]
            let next = viewModel.filteredPokemons[i + 1]
            let currentSpeed = current.stats.first { $0.name == "speed" }?.baseStat ?? 0
            let nextSpeed = next.stats.first { $0.name == "speed" }?.baseStat ?? 0
            XCTAssertGreaterThanOrEqual(currentSpeed, nextSpeed,
                                       "Pokemon at index \(i) should have higher speed than index \(i+1)")
        }
    }
}
