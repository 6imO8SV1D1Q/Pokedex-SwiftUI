//
//  VersionGroupIntegrationTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class VersionGroupIntegrationTests: XCTestCase {
    var container: DIContainer!
    var viewModel: PokemonListViewModel!

    override func setUp() async throws {
        try await super.setUp()
        container = DIContainer.shared
        viewModel = container.makePokemonListViewModel()
    }

    override func tearDown() async throws {
        viewModel = nil
        container = nil
        try await super.tearDown()
    }

    // MARK: - Version Group Switching Tests

    func test_switchingToRedBlue_loads151Pokemon() async throws {
        // Given: National dex is selected by default
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "national")

        // When: Switch to red-blue
        viewModel.changeVersionGroup(.redBlue)
        await viewModel.loadPokemons()

        // Then: Only 151 pokemon are displayed
        XCTAssertEqual(viewModel.pokemons.count, 151)
        XCTAssertEqual(viewModel.pokemons.first?.id, 1)
        XCTAssertEqual(viewModel.pokemons.last?.id, 151)
    }

    func test_switchingVersionGroup_maintainsSortOption() async throws {
        // Given: Sort by total stats
        viewModel.changeSortOption(.totalStats(ascending: false))

        // Load initial pokemons
        await viewModel.loadPokemons()

        // When: Switch version group
        viewModel.changeVersionGroup(.redBlue)
        await viewModel.loadPokemons()

        // Wait for async operations to complete
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 sec

        // Then: Sort option is maintained
        XCTAssertEqual(viewModel.currentSortOption, .totalStats(ascending: false))

        // And: Pokemon are actually sorted (check filteredPokemons, not pokemons)
        if viewModel.filteredPokemons.count >= 2 {
            let first = viewModel.filteredPokemons[0]
            let second = viewModel.filteredPokemons[1]
            let firstTotal = first.stats.reduce(0) { $0 + $1.baseStat }
            let secondTotal = second.stats.reduce(0) { $0 + $1.baseStat }
            XCTAssertGreaterThanOrEqual(firstTotal, secondTotal,
                                       "First pokemon (\(first.name): \(firstTotal)) should have >= stats than second (\(second.name): \(secondTotal))")
        }
    }

    func test_cacheImproves_secondLoadTime() async throws {
        // Given: red-blue version group
        viewModel.changeVersionGroup(.redBlue)

        // First load
        let firstStart = Date()
        await viewModel.loadPokemons()
        let firstLoadTime = Date().timeIntervalSince(firstStart)

        XCTAssertFalse(viewModel.pokemons.isEmpty, "First load should return pokemon")

        // When: Load again
        let secondStart = Date()
        await viewModel.loadPokemons()
        let secondLoadTime = Date().timeIntervalSince(secondStart)

        // Then: Second load is significantly faster
        XCTAssertLessThan(secondLoadTime, firstLoadTime * 0.5,
                         "Second load (\(secondLoadTime)s) should be much faster than first (\(firstLoadTime)s)")
    }

    func test_allVersionGroups_areAvailable() {
        // Then: All version groups are accessible
        XCTAssertFalse(viewModel.allVersionGroups.isEmpty)
        XCTAssertTrue(viewModel.allVersionGroups.contains(where: { $0.id == "national" }))
        XCTAssertTrue(viewModel.allVersionGroups.contains(where: { $0.id == "red-blue" }))
        XCTAssertTrue(viewModel.allVersionGroups.contains(where: { $0.id == "scarlet-violet" }))
    }

    func test_switchingToScarletViolet_loadsCorrectPokemon() async throws {
        // When: Switch to scarlet-violet
        viewModel.changeVersionGroup(.scarletViolet)
        await viewModel.loadPokemons()

        // Then: Pokemon are loaded
        XCTAssertFalse(viewModel.pokemons.isEmpty)
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "scarlet-violet")
    }
}
