//
//  PerformanceTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class PerformanceTests: XCTestCase {

    func test_initialLoad_completesWithinReasonableTime() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        // Measure initial load time
        let start = Date()
        await viewModel.loadPokemons()
        let duration = Date().timeIntervalSince(start)

        // Assert reasonable time
        XCTAssertLessThan(duration, 30.0, "Initial load should complete within 30 seconds")
        XCTAssertFalse(viewModel.pokemons.isEmpty, "Should have loaded pokemon")
    }

    func test_versionGroupSwitch_completesQuickly() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        // Load initial pokemon
        await viewModel.loadPokemons()

        // Measure switch time (without measure block for async)
        let start = Date()
        viewModel.changeVersionGroup(.redBlue)
        await viewModel.loadPokemons()
        let duration = Date().timeIntervalSince(start)

        // Assert reasonable time
        XCTAssertLessThan(duration, 10.0, "Version group switch should complete within 10 seconds")
    }

    func test_sortOperation_isFast() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        await viewModel.loadPokemons()

        // Measure sort time
        measure {
            viewModel.changeSortOption(.totalStats(ascending: false))
        }
    }

    func test_filterOperation_isFast() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        await viewModel.loadPokemons()

        // Measure filter time
        let start = Date()
        viewModel.searchText = "char"
        viewModel.selectedTypes = ["fire"]
        viewModel.applyFilters()

        // Wait for filter to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        let duration = Date().timeIntervalSince(start)

        // Assert reasonable time
        XCTAssertLessThan(duration, 2.0, "Filter operation should complete within 2 seconds")
    }

    func test_abilityFilter_performance() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        await viewModel.loadPokemons()

        // Measure ability filter time
        let start = Date()
        viewModel.selectedAbilities = ["overgrow", "blaze", "torrent"]
        viewModel.applyFilters()

        // Wait for filter to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec
        let duration = Date().timeIntervalSince(start)

        // Assert reasonable time
        XCTAssertLessThan(duration, 2.0, "Ability filter should complete within 2 seconds")
    }

    func test_multipleFilterChanges_performance() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        await viewModel.loadPokemons()

        // Measure multiple filter changes
        let start = Date()

        // Change 1
        viewModel.searchText = "pi"
        viewModel.applyFilters()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Change 2
        viewModel.selectedTypes = ["electric"]
        viewModel.applyFilters()
        try? await Task.sleep(nanoseconds: 200_000_000)

        // Change 3
        viewModel.searchText = "pikachu"
        viewModel.applyFilters()
        try? await Task.sleep(nanoseconds: 200_000_000)

        let duration = Date().timeIntervalSince(start)

        // Assert reasonable time
        XCTAssertLessThan(duration, 3.0, "Multiple filter changes should complete within 3 seconds")
    }

    func test_cachedLoad_isFasterThanInitial() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        viewModel.changeVersionGroup(.redBlue)

        // First load
        let firstStart = Date()
        await viewModel.loadPokemons()
        let firstLoadTime = Date().timeIntervalSince(firstStart)

        // Second load (cached)
        let secondStart = Date()
        await viewModel.loadPokemons()
        let secondLoadTime = Date().timeIntervalSince(secondStart)

        // Assert second load is faster
        XCTAssertLessThan(secondLoadTime, firstLoadTime * 0.5,
                         "Cached load (\(secondLoadTime)s) should be significantly faster than initial load (\(firstLoadTime)s)")
    }

    func test_largePokemonList_sortPerformance() async throws {
        let container = DIContainer.shared
        let viewModel = container.makePokemonListViewModel()

        // Load all pokemon (national dex)
        await viewModel.loadPokemons()

        // Measure sort on large list
        measure {
            viewModel.changeSortOption(.totalStats(ascending: false))
            viewModel.changeSortOption(.hp(ascending: false))
            viewModel.changeSortOption(.attack(ascending: false))
            viewModel.changeSortOption(.pokedexNumber(ascending: true))
        }
    }
}
