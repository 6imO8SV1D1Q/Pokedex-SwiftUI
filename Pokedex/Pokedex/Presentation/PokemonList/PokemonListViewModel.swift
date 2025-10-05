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
/// ポケモンのリスト取得、検索、フィルタリング、ソート、表示形式の切り替え機能を提供します。
///
/// ## 主な機能
/// - バージョングループ別のポケモンリスト取得
/// - 名前検索（部分一致）
/// - タイプ、特性、技による複合フィルタリング
/// - 種族値やステータスによるソート
/// - リスト/グリッド表示の切り替え
/// - 進捗表示付きローディング
/// - 自動リトライ機能（最大3回）
///
/// ## フィルター制約
/// - 技フィルター: バージョングループ選択時のみ有効（全国図鑑モードでは無効）
/// - 特性フィルター: 第3世代以降で有効（第1〜2世代では無効）
///
/// ## 使用例
/// ```swift
/// let viewModel = container.makePokemonListViewModel()
/// await viewModel.loadPokemons()
/// viewModel.searchText = "pikachu"
/// viewModel.selectedTypes = ["electric"]
/// viewModel.applyFilters()
/// ```
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

    /// フィルター処理中
    @Published private(set) var isFiltering = false

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

    /// 選択された技
    @Published var selectedMoves: [MoveEntity] = []

    /// 選択されたバージョングループ
    @Published var selectedVersionGroup: VersionGroup = .nationalDex

    /// 全バージョングループリスト
    private(set) var allVersionGroups: [VersionGroup] = []

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

    /// 技フィルタリングUseCase
    private let filterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol

    /// 世代情報取得UseCase
    private let fetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol

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
    ///   - filterPokemonByMovesUseCase: 技フィルタリングUseCase
    ///   - fetchVersionGroupsUseCase: バージョングループ情報取得UseCase
    ///   - pokemonRepository: ポケモンリポジトリ
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol,
        sortPokemonUseCase: SortPokemonUseCaseProtocol,
        filterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol,
        filterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol,
        fetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol,
        pokemonRepository: PokemonRepositoryProtocol
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.sortPokemonUseCase = sortPokemonUseCase
        self.filterPokemonByAbilityUseCase = filterPokemonByAbilityUseCase
        self.filterPokemonByMovesUseCase = filterPokemonByMovesUseCase
        self.fetchVersionGroupsUseCase = fetchVersionGroupsUseCase
        self.pokemonRepository = pokemonRepository
        self.allVersionGroups = fetchVersionGroupsUseCase.execute()
    }

    // MARK: - Public Methods

    /// ポケモンリストを読み込む
    ///
    /// 現在選択されているバージョングループのポケモンをすべて取得します。
    /// 取得後は自動的にフィルターとソートが適用されます。
    ///
    /// - Note: 初回ロード時は2〜3秒かかる場合があります。
    ///         2回目以降はキャッシュが効くため高速に取得できます。
    ///         ネットワークエラー時は最大3回まで自動リトライします。
    func loadPokemons() async {
        await loadPokemonsWithRetry()
    }

    /// キャッシュをクリアして再読み込み（デバッグ用）
    func clearCacheAndReload() async {
        pokemonRepository.clearCache()
        await loadPokemons()
    }

    /// フィルターを適用
    ///
    /// 検索テキスト、タイプ、特性、技の条件に基づいてポケモンをフィルタリングします。
    /// フィルタリング後は現在のソートオプションが自動的に適用されます。
    ///
    /// - Note: 技フィルターはAPIリクエストが発生するため、他のフィルターより時間がかかります。
    ///         技フィルター実行中は`isFiltering`がtrueになります。
    func applyFilters() {
        Task {
            await applyFiltersAsync()
        }
    }

    /// フィルターを適用（非同期版）
    private func applyFiltersAsync() async {
        // フィルタリング
        // 注: 世代フィルターはRepositoryで既に適用済みなので、ここでは検索とタイプのみ
        var filtered = pokemons.filter { pokemon in
            // 名前検索（部分一致）
            let matchesSearch = searchText.isEmpty ||
                pokemon.name.lowercased().contains(searchText.lowercased())

            // タイプフィルター
            let matchesType = selectedTypes.isEmpty ||
                pokemon.types.contains { selectedTypes.contains($0.name) }

            return matchesSearch && matchesType
        }

        // 特性フィルター適用
        filtered = filterPokemonByAbilityUseCase.execute(
            pokemonList: filtered,
            selectedAbilities: selectedAbilities
        )

        // 技フィルター適用
        if !selectedMoves.isEmpty {
            isFiltering = true
            do {
                let moveFilteredResults = try await filterPokemonByMovesUseCase.execute(
                    pokemonList: filtered,
                    selectedMoves: selectedMoves,
                    versionGroup: selectedVersionGroup.id
                )
                // 技フィルター結果からポケモンのみを抽出
                filtered = moveFilteredResults.map { $0.pokemon }
            } catch {
                // エラー時は技フィルターをスキップ
            }
            isFiltering = false
        }

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

    /// バージョングループを変更
    ///
    /// - Parameter versionGroup: 新しいバージョングループ
    ///
    /// - Note: バージョングループ変更時はポケモンリストが再読み込みされます。
    ///         キャッシュがある場合は約0.3秒、ない場合は約1〜2秒かかります。
    func changeVersionGroup(_ versionGroup: VersionGroup) {
        selectedVersionGroup = versionGroup
        Task {
            await loadPokemons()
        }
    }

    /// フィルターをクリア
    func clearFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedAbilities.removeAll()
        selectedMoves.removeAll()
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
                    versionGroup: self.selectedVersionGroup,
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
