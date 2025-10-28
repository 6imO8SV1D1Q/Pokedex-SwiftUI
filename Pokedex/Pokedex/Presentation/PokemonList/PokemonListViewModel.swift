//
//  PokemonListViewModel.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import Combine
import Kingfisher

/// 進化段階フィルターモード
enum EvolutionFilterMode: String, CaseIterable, Identifiable {
    case all
    case finalOnly
    case evioliteOnly

    var id: String { rawValue }

    /// 表示名
    var displayName: String {
        switch self {
        case .all:
            return L10n.EvolutionMode.all
        case .finalOnly:
            return L10n.EvolutionMode.finalOnly
        case .evioliteOnly:
            return L10n.EvolutionMode.evioliteOnly
        }
    }
}

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

    /// フィルタリング後のポケモンリスト（合致理由付き）
    @Published private(set) var filteredPokemons: [PokemonWithMatchInfo] = []

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

    /// 選択された特性カテゴリ
    @Published var abilityMetadataFilters: [AbilityMetadataFilter] = []

    /// 進化段階フィルターモード
    @Published var evolutionFilterMode: EvolutionFilterMode = .all

    /// 種族値フィルター条件
    @Published var statFilterConditions: [StatFilterCondition] = []

    /// 技のメタデータフィルター条件（複数設定可能）
    @Published var moveMetadataFilters: [MoveMetadataFilter] = []

    // MARK: - Sort Properties

    /// 現在のソートオプション
    @Published var currentSortOption: SortOption = .pokedexNumber(ascending: true)

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

    /// 技リポジトリ
    private let moveRepository: MoveRepositoryProtocol

    /// 特性カテゴリ取得UseCase
    private let getAbilityCategoriesUseCase: GetAbilityCategoriesUseCaseProtocol

    /// 特性カテゴリフィルタリングUseCase
    private let filterPokemonByAbilityCategoryUseCase: FilterPokemonByAbilityCategoryUseCaseProtocol

    /// 特性メタデータ読み込みUseCase
    private let loadAbilityMetadataUseCase: LoadAbilityMetadataUseCaseProtocol

    /// 特性メタデータフィルタリングUseCase
    private let filterPokemonByAbilityMetadataUseCase: FilterPokemonByAbilityMetadataUseCaseProtocol

    /// 特性カテゴリマッピング（特性名 → カテゴリ配列）
    private var abilityCategories: [String: [AbilityCategory]] = [:]

    /// 特性メタデータ（全特性の詳細情報）
    private var allAbilityMetadata: [AbilityMetadata] = []

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
    ///   - moveRepository: 技リポジトリ
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol,
        sortPokemonUseCase: SortPokemonUseCaseProtocol,
        filterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCaseProtocol,
        filterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol,
        fetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol,
        calculateStatsUseCase: CalculateStatsUseCaseProtocol,
        getAbilityCategoriesUseCase: GetAbilityCategoriesUseCaseProtocol,
        filterPokemonByAbilityCategoryUseCase: FilterPokemonByAbilityCategoryUseCaseProtocol,
        loadAbilityMetadataUseCase: LoadAbilityMetadataUseCaseProtocol,
        filterPokemonByAbilityMetadataUseCase: FilterPokemonByAbilityMetadataUseCaseProtocol,
        pokemonRepository: PokemonRepositoryProtocol,
        moveRepository: MoveRepositoryProtocol
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.sortPokemonUseCase = sortPokemonUseCase
        self.filterPokemonByAbilityUseCase = filterPokemonByAbilityUseCase
        self.filterPokemonByMovesUseCase = filterPokemonByMovesUseCase
        self.fetchVersionGroupsUseCase = fetchVersionGroupsUseCase
        self.calculateStatsUseCase = calculateStatsUseCase
        self.getAbilityCategoriesUseCase = getAbilityCategoriesUseCase
        self.filterPokemonByAbilityCategoryUseCase = filterPokemonByAbilityCategoryUseCase
        self.loadAbilityMetadataUseCase = loadAbilityMetadataUseCase
        self.filterPokemonByAbilityMetadataUseCase = filterPokemonByAbilityMetadataUseCase
        self.pokemonRepository = pokemonRepository
        self.moveRepository = moveRepository
        self.allVersionGroups = fetchVersionGroupsUseCase.execute()
        self.abilityCategories = getAbilityCategoriesUseCase.execute()

        // 特性メタデータを読み込み
        do {
            self.allAbilityMetadata = try loadAbilityMetadataUseCase.execute()
        } catch {
            print("❌ Failed to load ability metadata: \(error)")
            self.allAbilityMetadata = []
        }
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
        // 合致情報を保持するマップ（ポケモンID → 合致情報）
        var matchInfoMap: [Int: PokemonMatchInfo] = [:]

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
            switch evolutionFilterMode {
            case .all:
                matchesEvolution = true
            case .finalOnly:
                matchesEvolution = pokemon.evolutionChain?.isFinalEvolution ?? false
            case .evioliteOnly:
                matchesEvolution = pokemon.evolutionChain?.canUseEviolite ?? false
            }

            // 種族値フィルター
            let matchesStatFilter: Bool
            if !statFilterConditions.isEmpty {
                // 全ての条件を満たすか確認
                matchesStatFilter = statFilterConditions.allSatisfy { condition in
                    let baseStatValue: Int

                    if condition.statType == .total {
                        // 種族値合計
                        baseStatValue = pokemon.stats.reduce(0) { $0 + $1.baseStat }
                    } else {
                        // ステータス名を取得
                        let statName: String
                        switch condition.statType {
                        case .hp: statName = "hp"
                        case .attack: statName = "attack"
                        case .defense: statName = "defense"
                        case .specialAttack: statName = "special-attack"
                        case .specialDefense: statName = "special-defense"
                        case .speed: statName = "speed"
                        case .total: statName = "" // 上で処理済み
                        }

                        // 該当するステータスを検索
                        guard let stat = pokemon.stats.first(where: { $0.name == statName }) else {
                            return false
                        }

                        baseStatValue = stat.baseStat
                    }

                    return condition.matches(baseStatValue)
                }
            } else {
                matchesStatFilter = true
            }

            return matchesPokedex && matchesSearch && matchesType && matchesCategory && matchesEvolution && matchesStatFilter
        }

        // 特性フィルター適用（合致した特性を収集）
        let abilityFilterResults = filterPokemonByAbilityUseCase.execute(
            pokemonList: filtered,
            selectedAbilities: selectedAbilities,
            mode: abilityFilterMode
        )
        filtered = abilityFilterResults.map { $0.pokemon }

        // 合致した特性を記録
        for (pokemon, matchedAbilities) in abilityFilterResults {
            var matchInfo = matchInfoMap[pokemon.id] ?? PokemonMatchInfo.empty
            matchInfo = PokemonMatchInfo(
                matchedAbilities: (matchInfo.matchedAbilities + matchedAbilities).unique(),
                matchedMoves: matchInfo.matchedMoves
            )
            matchInfoMap[pokemon.id] = matchInfo
        }

        // 特性メタデータフィルター適用（合致した特性を収集）
        if !abilityMetadataFilters.isEmpty {
            let metadataFilterResults = filterPokemonByAbilityMetadataUseCase.execute(
                pokemons: filtered,
                filters: abilityMetadataFilters,
                allMetadata: allAbilityMetadata
            )
            filtered = metadataFilterResults.map { $0.pokemon }

            // 合致した特性を記録
            for (pokemon, matchedAbilities) in metadataFilterResults {
                var matchInfo = matchInfoMap[pokemon.id] ?? PokemonMatchInfo.empty
                matchInfo = PokemonMatchInfo(
                    matchedAbilities: (matchInfo.matchedAbilities + matchedAbilities).unique(),
                    matchedMoves: matchInfo.matchedMoves
                )
                matchInfoMap[pokemon.id] = matchInfo
            }
        }

        // 技フィルター適用（合致した技を収集）
        if !selectedMoves.isEmpty {
            isFiltering = true
            do {
                let moveFilteredResults = try await filterPokemonByMovesUseCase.execute(
                    pokemonList: filtered,
                    selectedMoves: selectedMoves,
                    versionGroup: selectedVersionGroup.id,
                    mode: moveFilterMode
                )
                filtered = moveFilteredResults.map { $0.pokemon }

                // 合致した技を記録
                for (pokemon, learnMethods) in moveFilteredResults {
                    var matchInfo = matchInfoMap[pokemon.id] ?? PokemonMatchInfo.empty
                    matchInfo = PokemonMatchInfo(
                        matchedAbilities: matchInfo.matchedAbilities,
                        matchedMoves: (matchInfo.matchedMoves + learnMethods).uniqueByMoveId()
                    )
                    matchInfoMap[pokemon.id] = matchInfo
                }
            } catch {
                // エラー時は技フィルターをスキップ
            }
            isFiltering = false
        }

        // 技メタデータフィルター適用（OR/AND切り替え対応、合致した技を収集）
        if !moveMetadataFilters.isEmpty {
            isFiltering = true
            do {
                // 1. 全技を取得
                let allMoves = try await moveRepository.fetchAllMoves(versionGroup: selectedVersionGroup.id)

                // 2. 各条件ごとに合致するポケモンを絞り込み（OR/AND検索）
                var matchingPokemonIds: Set<Int>? = nil
                var pokemonLearnMethodsMap: [Int: [MoveLearnMethod]] = [:]  // ポケモンID → 合致した技
                let pokemonIds = filtered.map { $0.id }

                for filter in moveMetadataFilters {
                    let matchingMoves = allMoves.filter { move in
                        matchesMoveMetadata(move: move, filter: filter)
                    }

                    let filterMoveIds = Set(matchingMoves.map { $0.id })

                    // この条件に合致する技を覚えるポケモンを取得
                    if !filterMoveIds.isEmpty {
                        let bulkLearnMethods = try await moveRepository.fetchBulkLearnMethods(
                            pokemonIds: pokemonIds,
                            moveIds: Array(filterMoveIds),
                            versionGroup: selectedVersionGroup.id
                        )

                        let pokemonsWhoLearnTheseMoves = Set(
                            bulkLearnMethods.keys.filter { bulkLearnMethods[$0]?.isEmpty == false }
                        )

                        // 習得方法を記録
                        for (pokemonId, learnMethods) in bulkLearnMethods where !learnMethods.isEmpty {
                            pokemonLearnMethodsMap[pokemonId, default: []] += learnMethods
                        }

                        // 最初の条件は初期化、2つ目以降はOR/ANDモードに応じて結合
                        if matchingPokemonIds == nil {
                            matchingPokemonIds = pokemonsWhoLearnTheseMoves
                        } else {
                            if moveFilterMode == .or {
                                // OR検索: いずれかの条件に合致するポケモン
                                matchingPokemonIds = matchingPokemonIds?.union(pokemonsWhoLearnTheseMoves)
                            } else {
                                // AND検索: 全ての条件に合致するポケモン（交差）
                                matchingPokemonIds = matchingPokemonIds?.intersection(pokemonsWhoLearnTheseMoves)
                            }
                        }
                    } else {
                        // 条件に合致する技が0件の場合
                        if moveFilterMode == .and {
                            // AND検索では0件
                            matchingPokemonIds = Set()
                        }
                    }
                }

                // 3. 条件に合致するポケモンのみを残す
                if let finalPokemonIds = matchingPokemonIds {
                    filtered = filtered.filter { finalPokemonIds.contains($0.id) }

                    // 合致した技を記録
                    for (pokemonId, learnMethods) in pokemonLearnMethodsMap where finalPokemonIds.contains(pokemonId) {
                        var matchInfo = matchInfoMap[pokemonId] ?? PokemonMatchInfo.empty
                        matchInfo = PokemonMatchInfo(
                            matchedAbilities: matchInfo.matchedAbilities,
                            matchedMoves: (matchInfo.matchedMoves + learnMethods).uniqueByMoveId()
                        )
                        matchInfoMap[pokemonId] = matchInfo
                    }
                }
            } catch {
                // エラー時は技メタデータフィルターをスキップ
            }
            isFiltering = false
        }

        // ソート適用
        var sorted = sortPokemonUseCase.execute(
            pokemonList: filtered,
            sortOption: currentSortOption
        )

        // 図鑑番号ソートの場合、選択された図鑑の番号でソート
        if case .pokedexNumber(let ascending) = currentSortOption, selectedPokedex != .national {
            sorted = sorted.sorted { pokemon1, pokemon2 in
                let num1 = pokemon1.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
                let num2 = pokemon2.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
                return ascending ? num1 < num2 : num1 > num2
            }
        }

        // 合致情報と一緒にラップ
        filteredPokemons = sorted.map { pokemon in
            let matchInfo = matchInfoMap[pokemon.id] ?? .empty
            return PokemonWithMatchInfo(pokemon: pokemon, matchInfo: matchInfo)
        }
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
        abilityMetadataFilters.removeAll()
        selectedMoveCategories.removeAll()
        selectedMoves.removeAll()
        evolutionFilterMode = .all
        statFilterConditions.removeAll()
        moveMetadataFilters.removeAll()
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

    /// 技がメタデータフィルター条件に合致するかチェック
    /// - Parameters:
    ///   - move: チェック対象の技
    ///   - filter: フィルター条件
    /// - Returns: 条件に合致する場合はtrue
    private func matchesMoveMetadata(move: MoveEntity, filter: MoveMetadataFilter) -> Bool {
        // タイプフィルター
        if !filter.types.isEmpty {
            if !filter.types.contains(move.type.name) {
                return false
            }
        }

        // 分類フィルター（物理/特殊/変化）
        if !filter.damageClasses.isEmpty && !filter.damageClasses.contains(move.damageClass) {
            return false
        }

        // 威力条件
        if let powerCondition = filter.powerCondition {
            guard powerCondition.matches(move.power) else {
                return false
            }
        }

        // 命中率条件
        if let accuracyCondition = filter.accuracyCondition {
            guard accuracyCondition.matches(move.accuracy) else {
                return false
            }
        }

        // PP条件
        if let ppCondition = filter.ppCondition {
            guard ppCondition.matches(move.pp) else {
                return false
            }
        }

        // 優先度フィルター
        if let priority = filter.priority {
            guard move.priority == priority else {
                return false
            }
        }

        // 対象フィルター
        if !filter.targets.isEmpty && !filter.targets.contains(move.target) {
            return false
        }

        // メタデータが必要な条件
        guard let meta = move.meta else {
            // メタデータがない場合、メタデータ関連の条件があればfalse
            if !filter.ailments.isEmpty || filter.hasDrain ||
               filter.hasHealing || !filter.statChanges.isEmpty {
                return false
            }
            // メタデータ不要な条件のみならtrue（ここまで到達していれば他の条件は満たしている）
            return filter.categories.isEmpty || !Set(move.categories).isDisjoint(with: filter.categories)
        }

        // 状態異常フィルター
        if !filter.ailments.isEmpty {
            let matchesAilment = filter.ailments.contains { ailment in
                meta.ailment == ailment.apiName && meta.ailmentChance > 0
            }
            if !matchesAilment {
                return false
            }
        }

        // HP吸収
        if filter.hasDrain && meta.drain <= 0 {
            return false
        }

        // HP回復
        if filter.hasHealing && meta.healing <= 0 {
            return false
        }

        // 能力変化フィルター（全ての条件を満たす必要がある - AND検索）
        if !filter.statChanges.isEmpty {
            let matchesAllStatChanges = filter.statChanges.allSatisfy { statChangeFilter in
                let (stat, change, isUser) = statChangeFilter.statChangeInfo

                // 技のtargetから自分への技かどうかを判定
                // user, ally, selected-pokemon, user-or-ally など、自分や味方を対象とする技を判定
                let selfTargets = ["user", "ally", "selected-pokemon", "user-or-ally", "user-and-allies", "all-allies"]
                let targetIsUser = selfTargets.contains(move.target)

                // isUserとtargetIsUserが一致する必要がある
                if isUser != targetIsUser {
                    return false
                }

                // stat/changeの一致を確認（changeの符号が正しいか確認）
                let hasMatchingStatChange = meta.statChanges.contains { statChange in
                    let statMatches = statChange.stat == stat
                    let changeMatches = (change > 0 && statChange.change > 0) || (change < 0 && statChange.change < 0)
                    return statMatches && changeMatches
                }

                return hasMatchingStatChange
            }
            if !matchesAllStatChanges {
                return false
            }
        }

        // 技カテゴリーフィルター
        if !filter.categories.isEmpty {
            let hasMatchingCategory = !Set(move.categories).isDisjoint(with: filter.categories)
            if !hasMatchingCategory {
                return false
            }
        }

        return true
    }
}
