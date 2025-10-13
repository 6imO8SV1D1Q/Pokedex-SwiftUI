//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine
import Kingfisher

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

    /// 選択された技カテゴリー
    @Published var selectedMoveCategories: Set<String> = []

    /// 選択された技
    @Published var selectedMoves: [MoveEntity] = []

    /// 選択されたバージョングループ
    @Published var selectedVersionGroup: VersionGroup = .nationalDex

    /// 全バージョングループリスト
    private(set) var allVersionGroups: [VersionGroup] = []

    /// 選択された図鑑区分
    @Published var selectedPokedex: PokedexType = .national

    // MARK: - Filter Mode Properties

    /// タイプフィルターの検索モード
    @Published var typeFilterMode: FilterMode = .or

    /// 特性フィルターの検索モード
    @Published var abilityFilterMode: FilterMode = .or

    /// 技フィルターの検索モード
    @Published var moveFilterMode: FilterMode = .and

    /// 選択されたポケモン区分
    @Published var selectedCategories: Set<PokemonCategory> = []

    /// 最終進化のみ表示フラグ
    @Published var filterFinalEvolutionOnly: Bool = false

    /// 進化のきせき適用可フラグ
    @Published var filterEvioliteOnly: Bool = false

    /// 実数値フィルター条件
    @Published var statFilterConditions: [StatFilterCondition] = []

    /// 技のメタデータフィルター条件
    @Published var moveMetadataFilter: MoveMetadataFilter = MoveMetadataFilter()

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

    /// 実数値計算UseCase
    private let calculateStatsUseCase: CalculateStatsUseCaseProtocol

    /// ポケモンリポジトリ
    private let pokemonRepository: PokemonRepositoryProtocol

    /// 最大再試行回数
    private let maxRetries = 3

    /// タイムアウト時間（秒）
    /// v4.0: 151匹で約2分、全ポケモンで10分程度を想定
    private let timeoutSeconds: UInt64 = 600

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameters:
    ///   - fetchPokemonListUseCase: ポケモンリスト取得UseCase
    ///   - sortPokemonUseCase: ポケモンソートUseCase
    ///   - filterPokemonByAbilityUseCase: 特性フィルタリングUseCase
    ///   - filterPokemonByMovesUseCase: 技フィルタリングUseCase
    ///   - fetchVersionGroupsUseCase: バージョングループ情報取得UseCase
    ///   - calculateStatsUseCase: 実数値計算UseCase
    ///   - pokemonRepository: ポケモンリポジトリ
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol,
        sortPokemonUseCase: SortPokemonUseCaseProtocol,
        filterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol,
        filterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol,
        fetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol,
        calculateStatsUseCase: CalculateStatsUseCaseProtocol,
        pokemonRepository: PokemonRepositoryProtocol
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.sortPokemonUseCase = sortPokemonUseCase
        self.filterPokemonByAbilityUseCase = filterPokemonByAbilityUseCase
        self.filterPokemonByMovesUseCase = filterPokemonByMovesUseCase
        self.fetchVersionGroupsUseCase = fetchVersionGroupsUseCase
        self.calculateStatsUseCase = calculateStatsUseCase
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
        // 重複ロード防止
        guard !isLoading else {
            return
        }

        // 全国図鑑の場合は、VersionGroupをnationalDexにする
        if selectedPokedex == .national && selectedVersionGroup != .nationalDex {
            selectedVersionGroup = .nationalDex
        }

        await loadPokemonsWithRetry()
    }

    /// キャッシュをクリアして再読み込み（デバッグ用）
    func clearCacheAndReload() async {
        // SwiftDataキャッシュをクリア
        pokemonRepository.clearCache()

        // Kingfisher画像キャッシュをクリア
        await clearImageCache()

        // 再読み込み
        await loadPokemons()
    }

    /// 画像キャッシュをクリア
    private func clearImageCache() async {
        await withCheckedContinuation { continuation in
            KingfisherManager.shared.cache.clearMemoryCache()
            KingfisherManager.shared.cache.clearDiskCache {
                print("🗑️ Kingfisher cache cleared")
                continuation.resume()
            }
        }
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
            // 図鑑フィルター
            let matchesPokedex: Bool
            if selectedPokedex == .national {
                // 全国図鑑の場合は全て表示
                matchesPokedex = true
            } else {
                // 選択された図鑑に含まれるかチェック
                matchesPokedex = pokemon.pokedexNumbers?[selectedPokedex.rawValue] != nil
            }

            // 名前検索（部分一致、英語名と日本語名の両方）
            let matchesSearch = searchText.isEmpty ||
                pokemon.name.lowercased().contains(searchText.lowercased()) ||
                (pokemon.nameJa?.contains(searchText) ?? false)

            // タイプフィルター
            let matchesType: Bool
            if selectedTypes.isEmpty {
                matchesType = true
            } else if typeFilterMode == .or {
                // OR: いずれかのタイプを持つ
                matchesType = pokemon.types.contains { selectedTypes.contains($0.name) }
            } else {
                // AND: 全てのタイプを持つ
                matchesType = selectedTypes.allSatisfy { selectedType in
                    pokemon.types.contains { $0.name == selectedType }
                }
            }

            // 区分フィルター
            let matchesCategory: Bool
            if selectedCategories.isEmpty {
                matchesCategory = true
            } else {
                // 選択された区分のいずれかに該当するか（OR条件）
                if let categoryString = pokemon.category,
                   let category = PokemonCategory(rawValue: categoryString) {
                    matchesCategory = selectedCategories.contains(category)
                } else {
                    matchesCategory = false
                }
            }

            // 進化フィルター
            let matchesEvolution: Bool
            if filterFinalEvolutionOnly {
                // 最終進化のみ表示
                matchesEvolution = pokemon.evolutionChain?.isFinalEvolution ?? false
            } else if filterEvioliteOnly {
                // 進化のきせき適用可のみ表示
                matchesEvolution = pokemon.evolutionChain?.canUseEviolite ?? false
            } else {
                matchesEvolution = true
            }

            // 実数値フィルター
            let matchesStatFilter: Bool
            if !statFilterConditions.isEmpty {
                let calculatedStats = calculateStatsUseCase.execute(baseStats: pokemon.stats)

                // 全ての条件を満たすか確認
                matchesStatFilter = statFilterConditions.allSatisfy { condition in
                    // 「<」「≤」の場合は最小実数値、それ以外は最大実数値で判定
                    let pattern: CalculatedStats.StatsPattern?
                    if condition.operator == .lessThan || condition.operator == .lessThanOrEqual {
                        // 個体値0、努力値0、性格補正0.9（最小値）
                        pattern = calculatedStats.patterns.first { $0.id == "hindered" }
                    } else {
                        // 個体値31、努力値252、性格補正1.1（最大値）
                        pattern = calculatedStats.patterns.first { $0.id == "ideal" }
                    }

                    guard let pattern = pattern else {
                        return false
                    }

                    let actualValue: Int
                    switch condition.statType {
                    case .hp: actualValue = pattern.hp
                    case .attack: actualValue = pattern.attack
                    case .defense: actualValue = pattern.defense
                    case .specialAttack: actualValue = pattern.specialAttack
                    case .specialDefense: actualValue = pattern.specialDefense
                    case .speed: actualValue = pattern.speed
                    }
                    return condition.matches(actualValue)
                }
            } else {
                matchesStatFilter = true
            }

            return matchesPokedex && matchesSearch && matchesType && matchesCategory && matchesEvolution && matchesStatFilter
        }

        // 特性フィルター適用
        filtered = filterPokemonByAbilityUseCase.execute(
            pokemonList: filtered,
            selectedAbilities: selectedAbilities,
            mode: abilityFilterMode
        )

        // 技フィルター適用
        if !selectedMoves.isEmpty {
            isFiltering = true
            do {
                let moveFilteredResults = try await filterPokemonByMovesUseCase.execute(
                    pokemonList: filtered,
                    selectedMoves: selectedMoves,
                    versionGroup: selectedVersionGroup.id,
                    mode: moveFilterMode
                )
                // 技フィルター結果からポケモンのみを抽出
                filtered = moveFilteredResults.map { $0.pokemon }
            } catch {
                // エラー時は技フィルターをスキップ
            }
            isFiltering = false
        }

        // ソート適用
        var sorted = sortPokemonUseCase.execute(
            pokemonList: filtered,
            sortOption: currentSortOption
        )

        // 図鑑番号ソートの場合、選択された図鑑の番号でソート
        if currentSortOption == .pokedexNumber && selectedPokedex != .national {
            sorted = sorted.sorted { pokemon1, pokemon2 in
                let num1 = pokemon1.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
                let num2 = pokemon2.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
                return num1 < num2
            }
        }

        filteredPokemons = sorted
    }

    /// ソートオプションを変更
    /// - Parameter option: 新しいソートオプション
    func changeSortOption(_ option: SortOption) {
        currentSortOption = option
        applyFilters()
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

    /// 図鑑区分を変更
    ///
    /// - Parameter pokedex: 新しい図鑑区分
    ///
    /// - Note: 図鑑区分変更時はフィルターが再適用されます。
    ///         全国図鑑選択時は全ポケモンをロードし直します。
    func changePokedex(_ pokedex: PokedexType) {
        selectedPokedex = pokedex

        // 全国図鑑の場合は全ポケモンをロード
        if pokedex == .national {
            if selectedVersionGroup != .nationalDex {
                // 地域図鑑から全国図鑑に切り替えた場合のみ再ロード
                selectedVersionGroup = .nationalDex
                Task {
                    await loadPokemons()
                }
            } else {
                // 既に全国図鑑の場合はフィルターのみ
                applyFilters()
            }
        } else {
            // 地域図鑑の場合
            if selectedVersionGroup == .nationalDex {
                // 全国図鑑から地域図鑑に切り替えた場合は、scarlet-violetに戻して再ロード
                selectedVersionGroup = .scarletViolet
                Task {
                    await loadPokemons()
                }
            } else {
                // 同じバージョングループ内の地域図鑑切り替えはフィルターのみ
                applyFilters()
            }
        }
    }

    /// フィルターをクリア
    func clearFilters() {
        searchText = ""
        selectedTypes.removeAll()
        selectedCategories.removeAll()
        selectedAbilities.removeAll()
        selectedMoveCategories.removeAll()
        selectedMoves.removeAll()
        filterFinalEvolutionOnly = false
        filterEvioliteOnly = false
        statFilterConditions.removeAll()
        moveMetadataFilter = MoveMetadataFilter()
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
            // リトライ前に isLoading をリセット（重要！）
            isLoading = false

            if attempt < maxRetries - 1 {
                // 再試行前に少し待つ
                try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
                await loadPokemonsWithRetry(attempt: attempt + 1)
            } else {
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
