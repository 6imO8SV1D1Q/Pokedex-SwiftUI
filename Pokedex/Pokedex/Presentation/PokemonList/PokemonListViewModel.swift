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

    /// ローディング進捗（0.0〜1.0）
    @Published private(set) var loadingProgress: Double = 0.0

    /// エラーメッセージ
    @Published var errorMessage: String?

    /// エラー表示フラグ
    @Published var showError = false

    // MARK: - Filter Properties

    /// 検索テキスト
    @Published var searchText = ""

    /// 選択されたタイプ
    @Published var selectedTypes: Set<String> = []

    /// 選択された特性
    @Published var selectedAbilities: Set<String> = []

    /// 選択された世代
    @Published var selectedGeneration: Generation = .generation1

    /// 全世代リスト
    private(set) var allGenerations: [Generation] = []

    // MARK: - Display Mode

    /// 表示形式
    enum DisplayMode {
        case list
        case grid
    }

    /// 現在の表示形式
    @Published var displayMode: DisplayMode = .list

    // MARK: - Sort Properties

    /// 現在のソートオプション
    @Published var currentSortOption: SortOption = .pokedexNumber

    // MARK: - Private Properties

    /// ポケモンリスト取得UseCase
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol

    /// ポケモンソートUseCase
    private let sortPokemonUseCase: SortPokemonUseCaseProtocol

    /// 特性フィルタリングUseCase
    private let filterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol

    /// 世代情報取得UseCase
    private let fetchGenerationsUseCase: FetchGenerationsUseCaseProtocol

    /// ポケモンリポジトリ
    private let pokemonRepository: PokemonRepositoryProtocol

    /// 最大再試行回数
    private let maxRetries = 3

    /// タイムアウト時間（秒）
    private let timeoutSeconds: UInt64 = 10

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameters:
    ///   - fetchPokemonListUseCase: ポケモンリスト取得UseCase
    ///   - sortPokemonUseCase: ポケモンソートUseCase
    ///   - filterPokemonByAbilityUseCase: 特性フィルタリングUseCase
    ///   - fetchGenerationsUseCase: 世代情報取得UseCase
    ///   - pokemonRepository: ポケモンリポジトリ
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol,
        sortPokemonUseCase: SortPokemonUseCaseProtocol,
        filterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol,
        fetchGenerationsUseCase: FetchGenerationsUseCaseProtocol,
        pokemonRepository: PokemonRepositoryProtocol
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.sortPokemonUseCase = sortPokemonUseCase
        self.filterPokemonByAbilityUseCase = filterPokemonByAbilityUseCase
        self.fetchGenerationsUseCase = fetchGenerationsUseCase
        self.pokemonRepository = pokemonRepository
        self.allGenerations = fetchGenerationsUseCase.execute()
    }

    // MARK: - Public Methods

    /// ポケモンリストを読み込む
    func loadPokemons() async {
        await loadPokemonsWithRetry()
    }

    /// フィルターを適用
    func applyFilters() {
        // フィルタリング
        var filtered = pokemons.filter { pokemon in
            // 名前検索（部分一致）
            let matchesSearch = searchText.isEmpty ||
                pokemon.name.lowercased().contains(searchText.lowercased())

            // タイプフィルター
            let matchesType = selectedTypes.isEmpty ||
                pokemon.types.contains { selectedTypes.contains($0.name) }

            // 世代フィルター（speciesIdで判定）
            let matchesGeneration = selectedGeneration.pokemonRange.contains(pokemon.speciesId)

            return matchesSearch && matchesType && matchesGeneration
        }

        // 特性フィルター適用
        filtered = filterPokemonByAbilityUseCase.execute(
            pokemonList: filtered,
            selectedAbilities: selectedAbilities
        )

        // ソート適用
        filteredPokemons = sortPokemonUseCase.execute(
            pokemonList: filtered,
            sortOption: currentSortOption
        )
    }

    /// ソートオプションを変更
    /// - Parameter option: 新しいソートオプション
    func changeSortOption(_ option: SortOption) {
        currentSortOption = option
        applyFilters()
    }

    /// 表示形式を切り替え
    func toggleDisplayMode() {
        displayMode = displayMode == .list ? .grid : .list
    }

    /// 世代を変更
    /// - Parameter generation: 新しい世代
    func changeGeneration(_ generation: Generation) {
        selectedGeneration = generation
        Task {
            await loadPokemons()
        }
    }

    /// フィルターをクリア
    func clearFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedAbilities.removeAll()
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
        loadingProgress = 0.0
        errorMessage = nil
        showError = false

        do {
            pokemons = try await fetchWithTimeout {
                try await self.pokemonRepository.fetchPokemonList(
                    generation: self.selectedGeneration,
                    progressHandler: { [weak self] progress in
                        Task { @MainActor in
                            self?.loadingProgress = progress
                        }
                    }
                )
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
