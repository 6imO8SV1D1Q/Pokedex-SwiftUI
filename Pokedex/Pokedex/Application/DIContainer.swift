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
        // Repositoryをリセットして、新しいModelContextで再生成
        _pokemonRepository = nil
        _abilityRepository = nil
        _moveRepository = nil
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

    private var _abilityRepository: AbilityRepositoryProtocol?
    private var abilityRepository: AbilityRepositoryProtocol {
        if let repository = _abilityRepository {
            return repository
        }

        guard let modelContext = modelContext else {
            fatalError("❌ ModelContext not set. Call setModelContext(_:) first.")
        }

        let repository = AbilityRepository(modelContext: modelContext)
        _abilityRepository = repository
        return repository
    }

    private var _moveRepository: MoveRepositoryProtocol?
    private var moveRepository: MoveRepositoryProtocol {
        if let repository = _moveRepository {
            return repository
        }

        guard let modelContext = modelContext else {
            fatalError("❌ ModelContext not set. Call setModelContext(_:) first.")
        }

        let cache = MoveCache()
        let repository = MoveRepository(modelContext: modelContext, cache: cache)
        _moveRepository = repository
        return repository
    }

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

    func makeGetAbilityCategoriesUseCase() -> GetAbilityCategoriesUseCaseProtocol {
        GetAbilityCategoriesUseCase()
    }

    func makeFilterPokemonByAbilityCategoryUseCase() -> FilterPokemonByAbilityCategoryUseCaseProtocol {
        FilterPokemonByAbilityCategoryUseCase()
    }

    func makeLoadAbilityMetadataUseCase() -> LoadAbilityMetadataUseCaseProtocol {
        LoadAbilityMetadataUseCase()
    }

    func makeFilterPokemonByAbilityMetadataUseCase() -> FilterPokemonByAbilityMetadataUseCaseProtocol {
        FilterPokemonByAbilityMetadataUseCase()
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
            calculateStatsUseCase: makeCalculateStatsUseCase(),
            getAbilityCategoriesUseCase: makeGetAbilityCategoriesUseCase(),
            filterPokemonByAbilityCategoryUseCase: makeFilterPokemonByAbilityCategoryUseCase(),
            loadAbilityMetadataUseCase: makeLoadAbilityMetadataUseCase(),
            filterPokemonByAbilityMetadataUseCase: makeFilterPokemonByAbilityMetadataUseCase(),
            pokemonRepository: pokemonRepository,
            moveRepository: moveRepository
        )
    }

    func makeStatsCalculatorViewModel() -> StatsCalculatorViewModel {
        StatsCalculatorViewModel(
            pokemonRepository: pokemonRepository
        )
    }
}
