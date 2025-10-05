//
//  DIContainer.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

final class DIContainer: ObservableObject {
    // Singleton
    static let shared = DIContainer()

    private init() {}

    // MARK: - Repositories
    private lazy var pokemonRepository: PokemonRepositoryProtocol = {
        PokemonRepository()
    }()

    private lazy var abilityRepository: AbilityRepositoryProtocol = {
        AbilityRepository()
    }()

    private lazy var moveRepository: MoveRepositoryProtocol = {
        let apiClient = PokemonAPIClient()
        let cache = MoveCache()
        return MoveRepository(apiClient: apiClient, cache: cache)
    }()

    // MARK: - UseCases
    func makeFetchPokemonListUseCase() -> FetchPokemonListUseCaseProtocol {
        FetchPokemonListUseCase(repository: pokemonRepository)
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
