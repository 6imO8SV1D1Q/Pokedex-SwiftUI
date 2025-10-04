//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

@MainActor
final class PokemonListViewModel: ObservableObject {
    // Published プロパティ
    @Published private(set) var pokemons: [Pokemon] = []
    @Published var filteredPokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    // 検索・フィルター用
    @Published var searchText = ""
    @Published var selectedTypes: Set<String> = []
    @Published var selectedGeneration = 1

    // 表示形式
    enum DisplayMode {
        case list
        case grid
    }

    @Published var displayMode: DisplayMode = .list

    // Dependencies
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol

    init(fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
    }

    func loadPokemons() async {
        isLoading = true
        errorMessage = nil

        do {
            pokemons = try await fetchPokemonListUseCase.execute(limit: 151, offset: 0)
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func applyFilters() {
        filteredPokemons = pokemons.filter { pokemon in
            // 名前検索（部分一致）
            let matchesSearch = searchText.isEmpty ||
                pokemon.name.lowercased().contains(searchText.lowercased())

            // タイプフィルター
            let matchesType = selectedTypes.isEmpty ||
                pokemon.types.contains { selectedTypes.contains($0.name) }

            // 世代フィルター(今回は第1世代のみなので常にtrue)
            let matchesGeneration = selectedGeneration == 1 && pokemon.id <= 151

            return matchesSearch && matchesType && matchesGeneration
        }
    }

    func toggleDisplayMode() {
        displayMode = displayMode == .list ? .grid : .list
    }

    func clearFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedGeneration = 1
        applyFilters()
    }
}
