//
//  DIContainer.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine
import SwiftData

final class DIContainer: ObservableObject {
    // Singleton
    static let shared = DIContainer()

    private init() {}

    // MARK: - ModelContext (v4.0 SwiftData)
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        // PokemonRepositoryをリセットして、新しいModelContextで再生成
        _pokemonRepository = nil
    }

    // MARK: - Repositories
    private var _pokemonRepository: PokemonRepositoryProtocol?
    private var pokemonRepository: PokemonRepositoryProtocol {
        if let repository = _pokemonRepository {
            return repository
        }

        guard let modelContext = modelContext else {
            fatalError("❌ ModelContext not set. Call setModelContext(_:) first.")
        }

        let repository = PokemonRepository(modelContext: modelContext)
        _pokemonRepository = repository
        return repository
    }

    private lazy var abilityRepository: AbilityRepositoryProtocol = {
        AbilityRepository()
    }()

    private lazy var moveRepository: MoveRepositoryProtocol = {
        let apiClient = PokemonAPIClient()
        let cache = MoveCache()
        return MoveRepository(apiClient: apiClient, cache: cache)
    }()

    private lazy var typeRepository: TypeRepositoryProtocol = {
        TypeRepository()
    }()

    // MARK: - UseCases
    func makeFetchPokemonListUseCase() -> FetchPokemonListUseCaseProtocol {
        FetchPokemonListUseCase(repository: pokemonRepository)
    }

    func makeFetchPokemonDetailUseCase() -> FetchPokemonDetailUseCaseProtocol {
        FetchPokemonDetailUseCase(repository: pokemonRepository)
    }

    func makeFetchEvolutionChainUseCase() -> FetchEvolutionChainUseCaseProtocol {
        FetchEvolutionChainUseCase(repository: pokemonRepository)
    }

    func makeSortPokemonUseCase() -> SortPokemonUseCaseProtocol {
        SortPokemonUseCase()
    }

    func makeFilterPokemonByAbilityUseCase() -> FilterPokemonByAbilityUseCaseProtocol {
        FilterPokemonByAbilityUseCase()
    }

    func makeFetchAllAbilitiesUseCase() -> FetchAllAbilitiesUseCaseProtocol {
        FetchAllAbilitiesUseCase(abilityRepository: abilityRepository)
    }

    func makeFetchVersionGroupsUseCase() -> FetchVersionGroupsUseCaseProtocol {
        FetchVersionGroupsUseCase()
    }

    func makeFetchAllMovesUseCase() -> FetchAllMovesUseCaseProtocol {
        FetchAllMovesUseCase(moveRepository: moveRepository)
    }

    func makeFilterPokemonByMovesUseCase() -> FilterPokemonByMovesUseCaseProtocol {
        FilterPokemonByMovesUseCase(moveRepository: moveRepository)
    }

    // MARK: - v3.0 UseCases

    func makeFetchPokemonFormsUseCase() -> FetchPokemonFormsUseCaseProtocol {
        FetchPokemonFormsUseCase(pokemonRepository: pokemonRepository)
    }

    func makeFetchTypeMatchupUseCase() -> FetchTypeMatchupUseCaseProtocol {
        FetchTypeMatchupUseCase(typeRepository: typeRepository)
    }

    func makeCalculateStatsUseCase() -> CalculateStatsUseCaseProtocol {
        CalculateStatsUseCase()
    }

    func makeFetchPokemonLocationsUseCase() -> FetchPokemonLocationsUseCaseProtocol {
        FetchPokemonLocationsUseCase(pokemonRepository: pokemonRepository)
    }

    func makeFetchAbilityDetailUseCase() -> FetchAbilityDetailUseCaseProtocol {
        FetchAbilityDetailUseCase(abilityRepository: abilityRepository)
    }

    func makeFetchFlavorTextUseCase() -> FetchFlavorTextUseCaseProtocol {
        FetchFlavorTextUseCase(pokemonRepository: pokemonRepository)
    }

    // MARK: - Repositories Factory Methods

    func makeMoveRepository() -> MoveRepositoryProtocol {
        return moveRepository
    }

    func makePokemonRepository() -> PokemonRepositoryProtocol {
        return pokemonRepository
    }

    // MARK: - ViewModels
    func makePokemonListViewModel() -> PokemonListViewModel {
        PokemonListViewModel(
            fetchPokemonListUseCase: makeFetchPokemonListUseCase(),
            sortPokemonUseCase: makeSortPokemonUseCase(),
            filterPokemonByAbilityUseCase: makeFilterPokemonByAbilityUseCase(),
            filterPokemonByMovesUseCase: makeFilterPokemonByMovesUseCase(),
            fetchVersionGroupsUseCase: makeFetchVersionGroupsUseCase(),
            pokemonRepository: pokemonRepository
        )
    }
}
