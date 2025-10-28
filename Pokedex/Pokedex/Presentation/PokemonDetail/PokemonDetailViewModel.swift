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

    /// 進化チェーン（ツリー構造）
    @Published var evolutionChainEntity: EvolutionChainEntity?

    /// 選択された技の習得方法
    @Published var selectedLearnMethod = "all"

    // MARK: - v3.0 新規プロパティ

    /// 利用可能なフォーム一覧
    @Published var availableForms: [PokemonForm] = []

    /// 選択中のフォーム
    @Published var selectedForm: PokemonForm?

    /// 進化チェーンの各ノードのリージョンフォームバリエーション（speciesId: フォーム）
    @Published var evolutionFormVariants: [Int: PokemonForm] = [:]

    /// タイプ相性
    @Published var typeMatchup: TypeMatchup?

    /// 計算された実数値
    @Published var calculatedStats: CalculatedStats?

    /// 出現場所
    @Published var locations: [PokemonLocation] = []

    /// 特性詳細（特性名 -> 詳細情報）
    @Published var abilityDetails: [String: AbilityDetail] = [:]

    /// 技詳細（技名 -> 詳細情報）
    @Published var moveDetails: [String: MoveEntity] = [:]

    /// 図鑑テキスト
    @Published var flavorText: PokemonFlavorText?

    /// ポケモン種族情報（性別比・たまごグループなど）
    @Published var pokemonSpecies: PokemonSpecies?

    /// セクションの展開状態
    @Published var isSectionExpanded: [String: Bool] = [:]

    // MARK: - ライバル除外フィルター

    /// 選択されたライバルのID
    @Published var selectedRivals: Set<Int> = []

    /// ライバル除外フィルターのON/OFF
    @Published var excludeRivalMoves: Bool = false

    /// ライバルの技データ（ライバルID -> 技リスト）
    @Published var rivalMoves: [Int: [PokemonMove]] = [:]

    /// 全ポケモンリスト（ライバル選択用）
    @Published var allPokemon: [PokemonWithMatchInfo] = []

    /// 現在の言語設定（LocalizationManagerから）
    @Published var currentLanguage: AppLanguage = .japanese

    // MARK: - Private Properties

    /// LocalizationManager
    private var localizationManager: LocalizationManager

    /// Combine subscriptions
    private var cancellables = Set<AnyCancellable>()

    /// 進化チェーン取得UseCase
    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol

    /// v3.0 UseCases
    private let fetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol
    private let fetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol
    private let calculateStatsUseCase: CalculateStatsUseCaseProtocol
    private let fetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol
    private let fetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol
    private let fetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol
    private let moveRepository: MoveRepositoryProtocol
    private let pokemonRepository: PokemonRepositoryProtocol

    /// バージョングループ
    private let versionGroup: String?

    /// 最大再試行回数
    private let maxRetries = 3

    /// タイムアウト時間（秒）
    private let timeoutSeconds: UInt64 = 10

    // MARK: - Computed Properties

    /// 表示する画像URL
    var displayImageURL: String? {
        // selectedFormがある場合はそのスプライトを使用
        let sprites = selectedForm?.sprites ?? pokemon.sprites

        if isShiny {
            return sprites.shinyImageURL ?? sprites.other?.home?.frontDefault ?? sprites.frontDefault
        } else {
            return sprites.other?.home?.frontDefault ?? sprites.frontDefault
        }
    }

    /// 表示するタイプ
    var displayTypes: [PokemonType] {
        return selectedForm?.types ?? pokemon.types
    }

    /// 表示する特性
    var displayAbilities: [PokemonAbility] {
        return selectedForm?.abilities ?? pokemon.abilities
    }

    /// 表示する種族値
    var displayStats: [PokemonStat] {
        return selectedForm?.stats ?? pokemon.stats
    }

    /// ライバル除外フィルター適用後の技リスト
    var filteredMovesByRival: [PokemonMove] {
        guard excludeRivalMoves && !selectedRivals.isEmpty else {
            return pokemon.moves
        }

        // 選択されているライバルの技の名前セット（selectedRivalsでフィルタ）
        let rivalMoveNames = Set(
            selectedRivals.compactMap { rivalMoves[$0] }
                .flatMap { $0.map { $0.name } }
        )

        // デバッグログ
        print("🔍 [Rival Filter Debug]")
        print("  Current Pokemon: \(pokemon.name) (ID: \(pokemon.id))")
        print("  Selected Rivals: \(selectedRivals.count) - \(selectedRivals)")
        print("  Loaded Rival Data (total): \(rivalMoves.count) - \(rivalMoves.keys)")
        print("  Used Rival Data (filtered): \(selectedRivals.filter { rivalMoves[$0] != nil }.count)")
        print("  Total Moves (Pokemon): \(pokemon.moves.count)")
        print("  Total Moves (Selected Rivals combined): \(rivalMoveNames.count)")

        // 技名の比較（1匹だけ選択時のみ）
        if selectedRivals.count == 1, let rivalId = selectedRivals.first, rivalMoves[rivalId] != nil {
            let pokemonMoveNames = Set(pokemon.moves.map { $0.name })
            let rivalOnlyMoves = rivalMoveNames.subtracting(pokemonMoveNames)
            let pokemonOnlyMoves = pokemonMoveNames.subtracting(rivalMoveNames)
            print("  🎯 Rival-only moves: \(rivalOnlyMoves.count) - \(Array(rivalOnlyMoves).prefix(5))")
            print("  🎯 Pokemon-only moves: \(pokemonOnlyMoves.count) - \(Array(pokemonOnlyMoves).prefix(5))")
        }

        // ライバルが覚えない技のみ返す
        let filtered = pokemon.moves.filter { !rivalMoveNames.contains($0.name) }
        print("  Filtered Moves (result): \(filtered.count)")

        return filtered
    }

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameters:
    ///   - pokemon: ポケモンデータ
    ///   - allPokemon: 全ポケモンリスト（ライバル選択用、省略可能）
    ///   - versionGroup: バージョングループ
    ///   - fetchEvolutionChainUseCase: 進化チェーン取得UseCase（省略時はDIContainerから取得）
    ///   - fetchPokemonFormsUseCase: フォーム取得UseCase（省略時はDIContainerから取得）
    ///   - fetchTypeMatchupUseCase: タイプ相性取得UseCase（省略時はDIContainerから取得）
    ///   - calculateStatsUseCase: 実数値計算UseCase（省略時はDIContainerから取得）
    ///   - fetchPokemonLocationsUseCase: 出現場所取得UseCase（省略時はDIContainerから取得）
    ///   - fetchAbilityDetailUseCase: 特性詳細取得UseCase（省略時はDIContainerから取得）
    ///   - fetchFlavorTextUseCase: 図鑑テキスト取得UseCase（省略時はDIContainerから取得）
    ///   - moveRepository: 技リポジトリ（省略時はDIContainerから取得）
    ///   - pokemonRepository: ポケモンリポジトリ（省略時はDIContainerから取得）
    init(
        pokemon: Pokemon,
        allPokemon: [PokemonWithMatchInfo] = [],
        versionGroup: String? = nil,
        localizationManager: LocalizationManager? = nil,
        fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol? = nil,
        fetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol? = nil,
        fetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol? = nil,
        calculateStatsUseCase: CalculateStatsUseCaseProtocol? = nil,
        fetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol? = nil,
        fetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol? = nil,
        fetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol? = nil,
        moveRepository: MoveRepositoryProtocol? = nil,
        pokemonRepository: PokemonRepositoryProtocol? = nil
    ) {
        self.pokemon = pokemon
        self.allPokemon = allPokemon
        self.versionGroup = versionGroup
        self.localizationManager = localizationManager ?? .shared
        self.fetchEvolutionChainUseCase = fetchEvolutionChainUseCase ?? DIContainer.shared.makeFetchEvolutionChainUseCase()
        self.fetchPokemonFormsUseCase = fetchPokemonFormsUseCase ?? DIContainer.shared.makeFetchPokemonFormsUseCase()
        self.fetchTypeMatchupUseCase = fetchTypeMatchupUseCase ?? DIContainer.shared.makeFetchTypeMatchupUseCase()
        self.calculateStatsUseCase = calculateStatsUseCase ?? DIContainer.shared.makeCalculateStatsUseCase()
        self.fetchPokemonLocationsUseCase = fetchPokemonLocationsUseCase ?? DIContainer.shared.makeFetchPokemonLocationsUseCase()
        self.fetchAbilityDetailUseCase = fetchAbilityDetailUseCase ?? DIContainer.shared.makeFetchAbilityDetailUseCase()
        self.fetchFlavorTextUseCase = fetchFlavorTextUseCase ?? DIContainer.shared.makeFetchFlavorTextUseCase()
        self.moveRepository = moveRepository ?? DIContainer.shared.makeMoveRepository()
        self.pokemonRepository = pokemonRepository ?? DIContainer.shared.makePokemonRepository()

        // 初期言語を設定
        self.currentLanguage = self.localizationManager.currentLanguage

        // LocalizationManagerの言語変更を監視
        self.localizationManager.$currentLanguage
            .sink { [weak self] newLanguage in
                self?.currentLanguage = newLanguage
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods

    /// 色違い表示を切り替え
    func toggleShiny() {
        isShiny.toggle()
    }


    // MARK: - v3.0 新規メソッド

    /// ポケモン詳細データをすべて読み込む
    /// - Parameter id: ポケモンID
    func loadPokemonDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            // 並列でデータ取得（speciesIdを使用）
            let speciesId = pokemon.speciesId
            let preferredVersion = AppSettings.shared.preferredVersion.rawValue
            async let formsTask = fetchPokemonFormsUseCase.execute(pokemonId: speciesId, versionGroup: versionGroup)
            async let locationsTask = fetchPokemonLocationsUseCase.execute(pokemonId: speciesId, versionGroup: versionGroup)
            async let flavorTextTask = fetchFlavorTextUseCase.execute(speciesId: speciesId, versionGroup: versionGroup, preferredVersion: preferredVersion, preferredLanguage: localizationManager.currentLanguage.rawValue)
            async let speciesTask = pokemonRepository.fetchPokemonSpecies(id: speciesId)
            async let evolutionChainTask = fetchEvolutionChainUseCase.executeV3(pokemonId: speciesId)

            // 結果を待機
            availableForms = try await formsTask
            locations = try await locationsTask
            flavorText = try await flavorTextTask
            pokemonSpecies = try await speciesTask
            evolutionChainEntity = try await evolutionChainTask

            // 現在のpokemon.idに一致するフォームを選択、なければデフォルトフォーム
            selectedForm = availableForms.first(where: { $0.pokemonId == pokemon.id }) ??
                          availableForms.first(where: { $0.isDefault }) ??
                          availableForms.first

            // フォーム依存データを読み込む
            await loadFormDependentData()

            // 技詳細を読み込む
            await loadMoveDetails(moves: pokemon.moves)

            isLoading = false
        } catch {
            isLoading = false
            handleError(error)
        }
    }

    /// フォームを選択
    /// - Parameter form: 選択するフォーム
    func selectForm(_ form: PokemonForm) async {
        selectedForm = form
        await loadFormDependentData()
    }

    /// フォーム依存のデータを読み込む
    func loadFormDependentData() async {
        guard let form = selectedForm else { return }

        do {
            // タイプ相性を取得
            typeMatchup = try await fetchTypeMatchupUseCase.execute(types: form.types)

            // 実数値を計算
            calculatedStats = calculateStatsUseCase.execute(baseStats: form.stats)

            // 特性詳細を取得
            await loadAbilityDetails(abilities: form.abilities)

            // speciesIdが異なる場合は、speciesと進化チェーンを再取得
            if form.speciesId != pokemon.speciesId {
                let preferredVersion = AppSettings.shared.preferredVersion.rawValue
                async let speciesTask = pokemonRepository.fetchPokemonSpecies(id: form.speciesId)
                async let flavorTextTask = fetchFlavorTextUseCase.execute(speciesId: form.speciesId, versionGroup: versionGroup, preferredVersion: preferredVersion, preferredLanguage: localizationManager.currentLanguage.rawValue)
                async let evolutionChainTask = fetchEvolutionChainUseCase.executeV3(pokemonId: form.speciesId)

                pokemonSpecies = try await speciesTask
                flavorText = try await flavorTextTask
                evolutionChainEntity = try await evolutionChainTask
            }

            // リージョンフォームの場合、進化チェーンの各ノードのリージョンフォームを取得
            await loadEvolutionFormVariants(for: form.formName)
        } catch {
            handleError(error)
        }
    }

    /// 進化チェーンの各ノードのリージョンフォームバリエーションを取得
    private func loadEvolutionFormVariants(for formName: String) async {
        // 通常フォームの場合はクリア
        guard formName != "normal" else {
            evolutionFormVariants = [:]
            return
        }

        guard let chain = evolutionChainEntity else { return }

        // 進化チェーンの全speciesIdを収集
        var speciesIds = Set<Int>()
        collectSpeciesIds(from: chain.rootNode, into: &speciesIds)

        // 各speciesIdに対して、同じformNameのフォームを並列取得
        await withTaskGroup(of: (Int, PokemonForm)?.self) { group in
            for speciesId in speciesIds {
                group.addTask {
                    do {
                        let forms = try await self.fetchPokemonFormsUseCase.execute(pokemonId: speciesId, versionGroup: self.versionGroup)
                        // 同じformNameのフォームを探す
                        if let regionalForm = forms.first(where: { $0.formName == formName }) {
                            return (speciesId, regionalForm)
                        }
                    } catch {
                        // エラーは無視（そのポケモンにリージョンフォームがない場合）
                    }
                    return nil
                }
            }

            for await result in group {
                if let (speciesId, form) = result {
                    evolutionFormVariants[speciesId] = form
                }
            }
        }
    }

    /// 進化チェーンから全speciesIdを再帰的に収集
    private func collectSpeciesIds(from node: EvolutionNode, into set: inout Set<Int>) {
        set.insert(node.speciesId)
        for edge in node.evolvesTo {
            if let targetNode = evolutionChainEntity?.nodeMap[edge.target] {
                collectSpeciesIds(from: targetNode, into: &set)
            }
        }
    }

    /// 特性詳細を並列で読み込む
    /// - Parameter abilities: 特性のリスト
    func loadAbilityDetails(abilities: [PokemonAbility]) async {
        await withTaskGroup(of: (String, AbilityDetail)?.self) { group in
            for ability in abilities {
                group.addTask {
                    do {
                        // 特性名から詳細を取得
                        let detail = try await self.fetchAbilityDetailUseCase.execute(abilityName: ability.name)
                        return (ability.name, detail)
                    } catch {
                        // エラーの場合はnilを返す（個別の特性取得失敗は無視）
                        print("Failed to fetch ability detail for \(ability.name): \(error)")
                        return nil
                    }
                }
            }

            for await result in group {
                if let (name, detail) = result {
                    abilityDetails[name] = detail
                }
            }
        }
    }

    /// 技詳細を並列で読み込む
    /// - Parameter moves: 技のリスト
    func loadMoveDetails(moves: [PokemonMove]) async {
        await withTaskGroup(of: (String, MoveEntity)?.self) { group in
            for move in moves {
                group.addTask {
                    do {
                        // 技IDから詳細を取得（バージョングループを渡してマシン番号も取得）
                        let detail = try await self.moveRepository.fetchMoveDetail(moveId: move.id, versionGroup: self.versionGroup)
                        return (move.name, detail)
                    } catch {
                        // エラーの場合はnilを返す（個別の技取得失敗は無視）
                        print("Failed to fetch move detail for \(move.name): \(error)")
                        return nil
                    }
                }
            }

            for await result in group {
                if let (name, detail) = result {
                    moveDetails[name] = detail
                }
            }
        }
    }

    /// セクションの展開/折りたたみを切り替え
    /// - Parameter sectionId: セクションID
    func toggleSection(_ sectionId: String) {
        isSectionExpanded[sectionId, default: false].toggle()
    }

    // MARK: - Private Methods

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

    // MARK: - Rival Filter Methods

    /// ライバルの技データを読み込む
    func loadRivalMoves() async {
        guard !selectedRivals.isEmpty else {
            rivalMoves.removeAll()
            return
        }

        await withTaskGroup(of: (Int, [PokemonMove]?).self) { group in
            for rivalId in selectedRivals {
                // すでに取得済みの場合はスキップ
                if rivalMoves[rivalId] != nil {
                    continue
                }

                group.addTask { [weak self] in
                    guard let self = self else { return (rivalId, nil) }

                    do {
                        let rivalPokemon = try await self.pokemonRepository.fetchPokemonDetail(id: rivalId)
                        return (rivalId, rivalPokemon.moves)
                    } catch {
                        print("Failed to load moves for rival \(rivalId): \(error)")
                        return (rivalId, nil)
                    }
                }
            }

            for await (rivalId, moves) in group {
                if let moves = moves {
                    await MainActor.run {
                        self.rivalMoves[rivalId] = moves
                    }
                }
            }
        }
    }

    /// ライバル除外フィルターを切り替え
    func toggleRivalFilter() {
        excludeRivalMoves.toggle()
        // データロードはライバル選択後に行う（onChange(of: selectedRivals)で実行）
    }
}
