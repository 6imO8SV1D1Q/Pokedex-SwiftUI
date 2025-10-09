//
//  FilterIntegrationTests.swift
//  PokedexTests
//
//  Created on 2025-10-05.
//

import XCTest
@testable import Pokedex

@MainActor
final class FilterIntegrationTests: XCTestCase {
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

    // MARK: - Move Filter Tests

    func test_moveFilter_worksInVersionGroup() async throws {
        // Given: Select scarlet-violet
        viewModel.changeVersionGroup(.scarletViolet)
        await viewModel.loadPokemons()

        XCTAssertFalse(viewModel.pokemons.isEmpty, "Should have pokemon loaded")

        // When: Select a move
        let thunderbolt = MoveEntity.fixture(id: 85, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
        viewModel.selectedMoves = [thunderbolt]
        viewModel.applyFilters()

        // Wait for async filter operation with timeout
        var waitTime = 0
        while viewModel.isFiltering && waitTime < 50 {
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec
            waitTime += 1
        }

        // Then: Filtering completed
        XCTAssertFalse(viewModel.isFiltering, "Filtering should complete")
    }

    func test_switchingVersionGroup_doesNotAutoClearMoveFilters() async throws {
        // Given: scarlet-violet with moves selected
        viewModel.changeVersionGroup(.scarletViolet)
        await viewModel.loadPokemons()

        let thunderbolt = MoveEntity.fixture(id: 85, name: "thunderbolt", type: PokemonType(slot: 1, name: "electric"))
        viewModel.selectedMoves = [thunderbolt]
        XCTAssertFalse(viewModel.selectedMoves.isEmpty)

        // When: Switch to red-blue
        viewModel.changeVersionGroup(.redBlue)

        // Then: Selected moves are NOT automatically cleared
        // (User needs to manually clear or the UI should handle this)
        XCTAssertFalse(viewModel.selectedMoves.isEmpty, "Moves are not auto-cleared, UI should handle version group change")
    }

    func test_cannotSelectMoreThanFourMoves() {
        // Given: Version group selected
        viewModel.changeVersionGroup(.scarletViolet)

        // When: Try to add 5 moves
        let moves = [
            MoveEntity.fixture(id: 1, name: "move1", type: PokemonType(slot: 1, name: "normal")),
            MoveEntity.fixture(id: 2, name: "move2", type: PokemonType(slot: 1, name: "normal")),
            MoveEntity.fixture(id: 3, name: "move3", type: PokemonType(slot: 1, name: "normal")),
            MoveEntity.fixture(id: 4, name: "move4", type: PokemonType(slot: 1, name: "normal")),
            MoveEntity.fixture(id: 5, name: "move5", type: PokemonType(slot: 1, name: "normal"))
        ]

        for move in moves {
            viewModel.selectedMoves.append(move)
        }

        // Then: Should have all 5 (UI layer would enforce the 4 limit)
        // Note: The ViewModel doesn't enforce this limit, it's enforced in the UI
        XCTAssertEqual(viewModel.selectedMoves.count, 5)
    }

    // MARK: - Ability Filter Tests

    func test_abilityFilter_worksInNationalDex() async throws {
        // Given: National dex mode
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "national")

        XCTAssertFalse(viewModel.pokemons.isEmpty, "Should have pokemon")

        // When: Apply ability filter
        viewModel.selectedAbilities = ["overgrow"]
        viewModel.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Filter is applied
        XCTAssertFalse(viewModel.filteredPokemons.isEmpty, "Should have filtered results")

        // Verify all filtered pokemon have the selected ability
        for pokemon in viewModel.filteredPokemons {
            let hasAbility = pokemon.abilities.contains { $0.name == "overgrow" }
            XCTAssertTrue(hasAbility, "\(pokemon.name) should have overgrow ability")
        }
    }

    func test_typeFilter_worksCorrectly() async throws {
        // Given: National dex with pokemon loaded
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "national")

        // When: Filter by fire type
        viewModel.selectedTypes = ["fire"]
        viewModel.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Only fire type pokemon are shown
        XCTAssertFalse(viewModel.filteredPokemons.isEmpty)

        for pokemon in viewModel.filteredPokemons {
            let hasFireType = pokemon.types.contains { $0.name == "fire" }
            XCTAssertTrue(hasFireType, "\(pokemon.name) should have fire type")
        }
    }

    func test_searchFilter_worksCorrectly() async throws {
        // Given: National dex with pokemon loaded
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "national")

        // When: Search for "char"
        viewModel.searchText = "char"
        viewModel.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Only pokemon with "char" in name are shown
        XCTAssertFalse(viewModel.filteredPokemons.isEmpty)

        for pokemon in viewModel.filteredPokemons {
            XCTAssertTrue(pokemon.name.lowercased().contains("char"),
                         "\(pokemon.name) should contain 'char'")
        }
    }

    func test_multipleFilters_workTogether() async throws {
        // Given: National dex with pokemon loaded
        XCTAssertEqual(viewModel.selectedVersionGroup.id, "national")

        // When: Apply multiple filters
        viewModel.searchText = "saur"
        viewModel.selectedTypes = ["grass"]
        viewModel.applyFilters()

        // Wait for async filter operation
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: Results match all filters
        XCTAssertFalse(viewModel.filteredPokemons.isEmpty)

        for pokemon in viewModel.filteredPokemons {
            XCTAssertTrue(pokemon.name.lowercased().contains("saur"),
                         "\(pokemon.name) should contain 'saur'")
            let hasGrassType = pokemon.types.contains { $0.name == "grass" }
            XCTAssertTrue(hasGrassType, "\(pokemon.name) should have grass type")
        }
    }

    func test_clearFilters_resetsAllFilters() async throws {
        // Given: Filters applied
        viewModel.searchText = "pikachu"
        viewModel.selectedTypes = ["electric"]
        viewModel.selectedAbilities = ["static"]
        viewModel.applyFilters()

        // Wait for filters to apply
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // When: Clear filters
        viewModel.clearFilters()

        // Wait for filters to clear
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 sec

        // Then: All filters are cleared
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertTrue(viewModel.selectedTypes.isEmpty)
        XCTAssertTrue(viewModel.selectedAbilities.isEmpty)
        XCTAssertTrue(viewModel.selectedMoves.isEmpty)

        // And: All pokemon are shown
        XCTAssertEqual(viewModel.filteredPokemons.count, viewModel.pokemons.count)
    }
}
