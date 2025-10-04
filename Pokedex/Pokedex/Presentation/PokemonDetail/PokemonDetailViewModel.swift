//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon
    @Published var isShiny = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var evolutionChain: [Int] = []
    @Published var selectedLearnMethod = "level-up"

    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol

    // Constants
    private let maxRetries = 3
    private let timeoutSeconds: UInt64 = 10

    // フィルタリングされた技リスト
    var filteredMoves: [PokemonMove] {
        pokemon.moves.filter { move in
            move.learnMethod == selectedLearnMethod
        }
        .sorted { move1, move2 in
            if let level1 = move1.level, let level2 = move2.level {
                return level1 < level2
            }
            return move1.name < move2.name
        }
    }

    init(
        pokemon: Pokemon,
        fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol? = nil
    ) {
        self.pokemon = pokemon
        self.fetchEvolutionChainUseCase = fetchEvolutionChainUseCase ?? DIContainer.shared.makeFetchEvolutionChainUseCase()
    }

    // 表示する画像URLを返す
    var displayImageURL: String? {
        if isShiny {
            return pokemon.sprites.shinyImageURL ?? pokemon.sprites.preferredImageURL
        } else {
            return pokemon.sprites.preferredImageURL
        }
    }

    func toggleShiny() {
        isShiny.toggle()
    }

    func loadEvolutionChain() async {
        await loadEvolutionChainWithRetry()
    }

    private func loadEvolutionChainWithRetry(attempt: Int = 0) async {
        guard attempt < maxRetries else {
            handleError(PokemonError.networkError(NSError(domain: "PokemonError", code: -1, userInfo: [NSLocalizedDescriptionKey: "最大再試行回数を超えました"])))
            return
        }

        isLoading = true
        errorMessage = nil
        showError = false

        do {
            evolutionChain = try await fetchWithTimeout {
                try await self.fetchEvolutionChainUseCase.execute(pokemonId: self.pokemon.id)
            }
            isLoading = false
        } catch {
            if attempt < maxRetries - 1 {
                // 再試行前に少し待つ
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
                await loadEvolutionChainWithRetry(attempt: attempt + 1)
            } else {
                isLoading = false
                // 進化チェーンの取得失敗は致命的ではないため、エラーを表示せず空配列のまま
                evolutionChain = []
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
}
