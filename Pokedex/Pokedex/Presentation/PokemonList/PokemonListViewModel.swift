//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine

/// ポケモン一覧画面のViewModel
///
/// ポケモンのリスト取得、検索、フィルタリング、表示形式の切り替え機能を提供します。
@MainActor
final class PokemonListViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 取得したポケモンの全リスト
    @Published private(set) var pokemons: [Pokemon] = []

    /// フィルタリング後のポケモンリスト
    @Published private(set) var filteredPokemons: [Pokemon] = []

    /// ローディング状態
    @Published private(set) var isLoading = false

    /// エラーメッセージ
    @Published var errorMessage: String?

    /// エラー表示フラグ
    @Published var showError = false

    // MARK: - Filter Properties

    /// 検索テキスト
    @Published var searchText = ""

    /// 選択されたタイプ
    @Published var selectedTypes: Set<String> = []

    /// 選択された世代（現在は第1世代のみ）
    @Published var selectedGeneration = 1

    // MARK: - Display Mode

    /// 表示形式
    enum DisplayMode {
        case list
        case grid
    }

    /// 現在の表示形式
    @Published var displayMode: DisplayMode = .list

    // MARK: - Private Properties

    /// ポケモンリスト取得UseCase
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol

    /// 最大再試行回数
    private let maxRetries = 3

    /// タイムアウト時間（秒）
    private let timeoutSeconds: UInt64 = 10

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameter fetchPokemonListUseCase: ポケモンリスト取得UseCase
    init(fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
    }

    // MARK: - Public Methods

    /// ポケモンリストを読み込む
    func loadPokemons() async {
        await loadPokemonsWithRetry()
    }

    /// フィルターを適用
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

    /// 表示形式を切り替え
    func toggleDisplayMode() {
        displayMode = displayMode == .list ? .grid : .list
    }

    /// フィルターをクリア
    func clearFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedGeneration = 1
        applyFilters()
    }

    // MARK: - Private Methods

    /// リトライ機能付きでポケモンリストを読み込む
    /// - Parameter attempt: 現在の試行回数
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
