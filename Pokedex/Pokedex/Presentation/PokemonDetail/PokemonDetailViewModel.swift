//
//  PokemonDetailViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

/// ポケモン詳細画面のViewModel
///
/// ポケモンの詳細情報、進化チェーン、色違い切り替え、技リストのフィルタリング機能を提供します。
@MainActor
final class PokemonDetailViewModel: ObservableObject {

    // MARK: - Published Properties

    /// ポケモンデータ
    @Published var pokemon: Pokemon

    /// 色違い表示フラグ
    @Published var isShiny = false

    /// ローディング状態
    @Published var isLoading = false

    /// エラーメッセージ
    @Published var errorMessage: String?

    /// エラー表示フラグ
    @Published var showError = false

    /// 進化チェーン（ポケモンIDのリスト）
    @Published var evolutionChain: [Int] = []

    /// 選択された技の習得方法
    @Published var selectedLearnMethod = "level-up"

    // MARK: - Private Properties

    /// 進化チェーン取得UseCase
    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol

    /// 最大再試行回数
    private let maxRetries = 3

    /// タイムアウト時間（秒）
    private let timeoutSeconds: UInt64 = 10

    // MARK: - Computed Properties

    /// フィルタリングされた技リスト
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

    /// 表示する画像URL
    var displayImageURL: String? {
        if isShiny {
            return pokemon.sprites.shinyImageURL ?? pokemon.sprites.preferredImageURL
        } else {
            return pokemon.sprites.preferredImageURL
        }
    }

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameters:
    ///   - pokemon: ポケモンデータ
    ///   - fetchEvolutionChainUseCase: 進化チェーン取得UseCase（省略時はDIContainerから取得）
    init(
        pokemon: Pokemon,
        fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol? = nil
    ) {
        self.pokemon = pokemon
        self.fetchEvolutionChainUseCase = fetchEvolutionChainUseCase ?? DIContainer.shared.makeFetchEvolutionChainUseCase()
    }

    // MARK: - Public Methods

    /// 色違い表示を切り替え
    func toggleShiny() {
        isShiny.toggle()
    }

    /// 進化チェーンを読み込む
    func loadEvolutionChain() async {
        await loadEvolutionChainWithRetry()
    }

    // MARK: - Private Methods

    /// リトライ機能付きで進化チェーンを読み込む
    /// - Parameter attempt: 現在の試行回数
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

    /// タイムアウト付きで非同期処理を実行
    /// - Parameter operation: 実行する非同期処理
    /// - Returns: 処理の結果
    /// - Throws: タイムアウトエラーまたは処理のエラー
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

    /// エラーハンドリング
    /// - Parameter error: 発生したエラー
    private func handleError(_ error: Error) {
        if let pokemonError = error as? PokemonError {
            errorMessage = pokemonError.localizedDescription
        } else {
            errorMessage = "予期しないエラーが発生しました: \(error.localizedDescription)"
        }
        showError = true
    }
}
