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

    // MARK: - v3.0 新規プロパティ

    /// 利用可能なフォーム一覧
    @Published var availableForms: [PokemonForm] = []

    /// 選択中のフォーム
    @Published var selectedForm: PokemonForm?

    /// タイプ相性
    @Published var typeMatchup: TypeMatchup?

    /// 計算された実数値
    @Published var calculatedStats: CalculatedStats?

    /// 出現場所
    @Published var locations: [PokemonLocation] = []

    /// 特性詳細（特性名 -> 詳細情報）
    @Published var abilityDetails: [String: AbilityDetail] = [:]

    /// 図鑑テキスト
    @Published var flavorText: PokemonFlavorText?

    /// セクションの展開状態
    @Published var isSectionExpanded: [String: Bool] = [:]

    // MARK: - Private Properties

    /// 進化チェーン取得UseCase
    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol

    /// v3.0 UseCases
    private let fetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol
    private let fetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol
    private let calculateStatsUseCase: CalculateStatsUseCaseProtocol
    private let fetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol
    private let fetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol
    private let fetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol

    /// バージョングループ
    private let versionGroup: String?

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
    ///   - versionGroup: バージョングループ
    ///   - fetchEvolutionChainUseCase: 進化チェーン取得UseCase（省略時はDIContainerから取得）
    ///   - fetchPokemonFormsUseCase: フォーム取得UseCase（省略時はDIContainerから取得）
    ///   - fetchTypeMatchupUseCase: タイプ相性取得UseCase（省略時はDIContainerから取得）
    ///   - calculateStatsUseCase: 実数値計算UseCase（省略時はDIContainerから取得）
    ///   - fetchPokemonLocationsUseCase: 出現場所取得UseCase（省略時はDIContainerから取得）
    ///   - fetchAbilityDetailUseCase: 特性詳細取得UseCase（省略時はDIContainerから取得）
    ///   - fetchFlavorTextUseCase: 図鑑テキスト取得UseCase（省略時はDIContainerから取得）
    init(
        pokemon: Pokemon,
        versionGroup: String? = nil,
        fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol? = nil,
        fetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol? = nil,
        fetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol? = nil,
        calculateStatsUseCase: CalculateStatsUseCaseProtocol? = nil,
        fetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol? = nil,
        fetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol? = nil,
        fetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol? = nil
    ) {
        self.pokemon = pokemon
        self.versionGroup = versionGroup
        self.fetchEvolutionChainUseCase = fetchEvolutionChainUseCase ?? DIContainer.shared.makeFetchEvolutionChainUseCase()
        self.fetchPokemonFormsUseCase = fetchPokemonFormsUseCase ?? DIContainer.shared.makeFetchPokemonFormsUseCase()
        self.fetchTypeMatchupUseCase = fetchTypeMatchupUseCase ?? DIContainer.shared.makeFetchTypeMatchupUseCase()
        self.calculateStatsUseCase = calculateStatsUseCase ?? DIContainer.shared.makeCalculateStatsUseCase()
        self.fetchPokemonLocationsUseCase = fetchPokemonLocationsUseCase ?? DIContainer.shared.makeFetchPokemonLocationsUseCase()
        self.fetchAbilityDetailUseCase = fetchAbilityDetailUseCase ?? DIContainer.shared.makeFetchAbilityDetailUseCase()
        self.fetchFlavorTextUseCase = fetchFlavorTextUseCase ?? DIContainer.shared.makeFetchFlavorTextUseCase()
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

    // MARK: - v3.0 新規メソッド

    /// ポケモン詳細データをすべて読み込む
    /// - Parameter id: ポケモンID
    func loadPokemonDetail(id: Int) async {
        isLoading = true
        errorMessage = nil
        showError = false

        do {
            // 並列でデータ取得
            async let formsTask = fetchPokemonFormsUseCase.execute(pokemonId: id, versionGroup: versionGroup)
            async let locationsTask = fetchPokemonLocationsUseCase.execute(pokemonId: id, versionGroup: versionGroup)
            async let flavorTextTask = fetchFlavorTextUseCase.execute(speciesId: id, versionGroup: versionGroup)

            // 結果を待機
            availableForms = try await formsTask
            locations = try await locationsTask
            flavorText = try await flavorTextTask

            // デフォルトフォームを選択
            selectedForm = availableForms.first(where: { $0.isDefault }) ?? availableForms.first

            // フォーム依存データを読み込む
            await loadFormDependentData()

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
        } catch {
            handleError(error)
        }
    }

    /// 特性詳細を並列で読み込む
    /// - Parameter abilities: 特性のリスト
    func loadAbilityDetails(abilities: [PokemonAbility]) async {
        // TODO: PokemonAbilityエンティティに数値IDが含まれていないため、実装保留
        // 解決策:
        // 1. PokemonAbilityにabilityId: Intプロパティを追加する（推奨）
        // 2. または、AbilityRepositoryに名前からID変換メソッドを追加する
        //
        // 実装例（PokemonAbilityにIDがある場合）:
        // await withTaskGroup(of: (String, AbilityDetail)?.self) { group in
        //     for ability in abilities {
        //         group.addTask {
        //             do {
        //                 let detail = try await self.fetchAbilityDetailUseCase.execute(abilityId: ability.abilityId)
        //                 return (ability.name, detail)
        //             } catch {
        //                 return nil
        //             }
        //         }
        //     }
        //     for await result in group {
        //         if let (name, detail) = result {
        //             abilityDetails[name] = detail
        //         }
        //     }
        // }
    }

    /// セクションの展開/折りたたみを切り替え
    /// - Parameter sectionId: セクションID
    func toggleSection(_ sectionId: String) {
        isSectionExpanded[sectionId, default: false].toggle()
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
