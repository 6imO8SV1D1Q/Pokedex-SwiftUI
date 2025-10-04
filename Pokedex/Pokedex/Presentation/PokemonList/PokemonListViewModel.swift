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
    @Published var errorMessage: String?
    @Published var showError = false

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

    // Constants
    private let maxRetries = 3
    private let timeoutSeconds: UInt64 = 10

    init(fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
    }

    func loadPokemons() async {
        await loadPokemonsWithRetry()
    }

    private func loadPokemonsWithRetry(attempt: Int = 0) async {
        guard attempt < maxRetries else {
            handleError(PokemonError.networkError(NSError(domain: "PokemonError", code: -1, userInfo: [NSLocalizedDescriptionKey: "最大再試行回数を超えました"])))
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        do {
            pokemons = try await fetchWithTimeout {
                try await self.fetchPokemonListUseCase.execute(limit: 151, offset: 0)
            }
            applyFilters()
            isLoading = false
        } catch {
            if attempt < maxRetries - 1 {
                // 再試行前に少し待つ
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
                await loadPokemonsWithRetry(attempt: attempt + 1)
            } else {
                isLoading = false
                handleError(error)
            }
        }
    }

    private func fetchWithTimeout<T>(_ operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: self.timeoutSeconds * 1_000_000_000)
                throw PokemonError.timeout
            }

            guard let result = try await group.next() else {
                throw PokemonError.timeout
            }

            group.cancelAll()
            return result
        }
    }

    private func handleError(_ error: Error) {
        if let pokemonError = error as? PokemonError {
            errorMessage = pokemonError.localizedDescription
        } else {
            errorMessage = "予期しないエラーが発生しました: \(error.localizedDescription)"
        }
        showError = true
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
