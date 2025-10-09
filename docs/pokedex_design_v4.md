# Pokédex SwiftUI - 設計書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-09

---

## 📋 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [Phase 1: バックグラウンド段階的読み込み](#phase-1-バックグラウンド段階的読み込み)
3. [Phase 2: 永続的キャッシュの導入](#phase-2-永続的キャッシュの導入)
4. [Phase 3: 技フィルターの高速化](#phase-3-技フィルターの高速化)
5. [Phase 4: 適応的並列度制御](#phase-4-適応的並列度制御)
6. [データフロー](#データフロー)
7. [エラーハンドリング](#エラーハンドリング)

---

## アーキテクチャ概要

### 全体構成（v4.0拡張版）

```
┌─────────────────────────────────────────────────────────┐
│                      Presentation                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ PokemonList  │  │ PokemonDetail│  │   Settings   │  │
│  │  ViewModel   │  │   ViewModel  │  │   ViewModel  │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                        Domain                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │              UseCases (既存)                      │  │
│  ├──────────────────────────────────────────────────┤  │
│  │         BackgroundFetchService (新規)            │  │
│  │         ProgressTracker (新規)                   │  │
│  │         PriorityQueue (新規)                     │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                         Data                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Pokemon      │  │ Move         │  │   Type       │  │
│  │ Repository   │  │ Repository   │  │ Repository   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│           │                 │                 │          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ PokemonData  │  │ MoveData     │  │ Cache        │  │
│  │ Store (新規) │  │ Store (新規) │  │ Manager      │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│           │                 │                            │
│  ┌──────────────────────────────────────────────────┐  │
│  │              SwiftData (新規)                     │  │
│  │  ┌────────────────┐  ┌────────────────┐          │  │
│  │  │ PokemonData    │  │  MoveData      │          │  │
│  │  │    Model       │  │   Model        │          │  │
│  │  └────────────────┘  └────────────────┘          │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │            PokemonAPIClient (既存)                │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 新規追加コンポーネント

| コンポーネント | 責務 | Phase |
|--------------|------|-------|
| BackgroundFetchService | バックグラウンド取得の制御 | 1 |
| ProgressTracker | 進捗管理・通知 | 1 |
| PriorityQueue | 取得優先度の管理 | 1 |
| PokemonDataStore | SwiftDataへのCRUD操作 | 2 |
| MoveDataStore | 技データのCRUD操作 | 3 |
| CacheManager | キャッシュ全体の管理 | 2 |
| SettingsViewModel | 設定画面のロジック | 2 |
| AdaptiveFetchStrategy | 並列度の動的制御 | 4 |

---

## Phase 1: バックグラウンド段階的読み込み

### 1.1 BackgroundFetchService

**責務**:
- バックグラウンドでのポケモンデータ取得
- 優先度に基づいた取得順序の制御
- 進捗通知

**クラス設計**:

```swift
@MainActor
final class BackgroundFetchService: ObservableObject {
    // MARK: - Dependencies
    private let pokemonRepository: PokemonRepositoryProtocol
    private let progressTracker: ProgressTracker
    private let priorityQueue: PriorityQueue

    // MARK: - Published State
    @Published private(set) var isLoading = false
    @Published private(set) var currentPhase: FetchPhase = .idle

    // MARK: - Public Methods

    /// 段階的取得を開始
    /// - Parameter progressHandler: 進捗コールバック
    func startIncrementalFetch(progressHandler: ((FetchProgress) -> Void)?) async throws

    /// 特定の世代を優先取得
    /// - Parameter generation: 世代番号（1-9）
    func prioritizeFetch(generation: Int) async throws

    /// バックグラウンド取得をキャンセル
    func cancel()

    // MARK: - Private Methods

    /// 第1世代を取得
    private func fetchGeneration1() async throws -> [Pokemon]

    /// 残りの世代を順次取得
    private func fetchRemainingGenerations() async throws

    /// 取得失敗時のリトライ
    private func retryFetch(id: Int, maxAttempts: Int) async throws -> Pokemon?
}

enum FetchPhase {
    case idle
    case fetchingGeneration1
    case fetchingRemaining(currentGen: Int)
    case completed
    case failed(Error)
}

struct FetchProgress {
    let totalCount: Int
    let fetchedCount: Int
    let currentGeneration: Int
    let successCount: Int
    let failedCount: Int

    var percentage: Double {
        Double(fetchedCount) / Double(totalCount)
    }
}
```

**取得ロジック**:

```swift
func startIncrementalFetch(progressHandler: ((FetchProgress) -> Void)?) async throws {
    isLoading = true
    currentPhase = .fetchingGeneration1

    // Phase 1: 第1世代（1-151）を優先取得
    let gen1Pokemon = try await fetchGeneration1()
    progressTracker.update(fetchedCount: gen1Pokemon.count, generation: 1)
    progressHandler?(progressTracker.currentProgress)

    // Phase 2: 残りをバックグラウンドで取得
    currentPhase = .fetchingRemaining(currentGen: 2)

    Task.detached { [weak self] in
        await self?.fetchRemainingGenerations()
    }
}

private func fetchGeneration1() async throws -> [Pokemon] {
    var pokemons: [Pokemon] = []

    // 順次取得（確実性優先）
    for id in 1...151 {
        if let pokemon = try await retryFetch(id: id, maxAttempts: 3) {
            pokemons.append(pokemon)
        }

        // 10匹ごとに進捗通知
        if id % 10 == 0 {
            await MainActor.run {
                progressTracker.update(fetchedCount: pokemons.count, generation: 1)
            }
        }

        // API負荷軽減のため50ms待機
        try await Task.sleep(nanoseconds: 50_000_000)
    }

    return pokemons
}

private func fetchRemainingGenerations() async throws {
    let generations = [
        2: 152...251,   // 第2世代
        3: 252...386,   // 第3世代
        4: 387...493,   // 第4世代
        5: 494...649,   // 第5世代
        6: 650...721,   // 第6世代
        7: 722...809,   // 第7世代
        8: 810...905,   // 第8世代
        9: 906...1025   // 第9世代
    ]

    for (gen, range) in generations.sorted(by: { $0.key < $1.key }) {
        await MainActor.run {
            currentPhase = .fetchingRemaining(currentGen: gen)
        }

        for id in range {
            // 優先度キューをチェック（ユーザーが特定の世代を見ようとしている場合）
            if let priorityId = await priorityQueue.dequeue() {
                _ = try await retryFetch(id: priorityId, maxAttempts: 3)
            }

            _ = try await retryFetch(id: id, maxAttempts: 3)

            await MainActor.run {
                progressTracker.increment(generation: gen)
            }

            try await Task.sleep(nanoseconds: 50_000_000)
        }
    }

    await MainActor.run {
        currentPhase = .completed
        isLoading = false
    }
}
```

### 1.2 ProgressTracker

**責務**:
- 取得進捗の追跡
- 進捗情報の提供
- 通知の管理

**クラス設計**:

```swift
@MainActor
final class ProgressTracker: ObservableObject {
    // MARK: - Published State
    @Published private(set) var currentProgress: FetchProgress

    // MARK: - Private State
    private var successCount = 0
    private var failedCount = 0
    private var fetchedByGeneration: [Int: Int] = [:]

    // MARK: - Constants
    private let totalCount = 1025

    init() {
        currentProgress = FetchProgress(
            totalCount: totalCount,
            fetchedCount: 0,
            currentGeneration: 1,
            successCount: 0,
            failedCount: 0
        )
    }

    // MARK: - Public Methods

    func update(fetchedCount: Int, generation: Int) {
        successCount = fetchedCount
        fetchedByGeneration[generation] = fetchedCount
        updateProgress(generation: generation)
    }

    func increment(generation: Int) {
        successCount += 1
        fetchedByGeneration[generation, default: 0] += 1
        updateProgress(generation: generation)
    }

    func recordFailure(generation: Int) {
        failedCount += 1
        updateProgress(generation: generation)
    }

    func reset() {
        successCount = 0
        failedCount = 0
        fetchedByGeneration.removeAll()
        updateProgress(generation: 1)
    }

    // MARK: - Private Methods

    private func updateProgress(generation: Int) {
        currentProgress = FetchProgress(
            totalCount: totalCount,
            fetchedCount: successCount,
            currentGeneration: generation,
            successCount: successCount,
            failedCount: failedCount
        )
    }
}
```

### 1.3 PriorityQueue

**責務**:
- ユーザーの閲覧意図に基づいた優先取得
- 取得順序の動的変更

**クラス設計**:

```swift
actor PriorityQueue {
    private var queue: [Int] = []

    /// 優先度の高いIDをキューに追加
    func enqueue(_ id: Int) {
        // すでにキューにある場合は先頭に移動
        if let index = queue.firstIndex(of: id) {
            queue.remove(at: index)
        }
        queue.insert(id, at: 0)
    }

    /// 優先度の高いIDを取得
    func dequeue() -> Int? {
        guard !queue.isEmpty else { return nil }
        return queue.removeFirst()
    }

    /// 世代全体を優先キューに追加
    func enqueueGeneration(_ generation: Int) {
        let ranges: [Int: ClosedRange<Int>] = [
            1: 1...151,
            2: 152...251,
            3: 252...386,
            4: 387...493,
            5: 494...649,
            6: 650...721,
            7: 722...809,
            8: 810...905,
            9: 906...1025
        ]

        guard let range = ranges[generation] else { return }

        for id in range {
            queue.append(id)
        }
    }

    func clear() {
        queue.removeAll()
    }
}
```

### 1.4 進捗表示UI

**ProgressBannerView**:

```swift
struct ProgressBannerView: View {
    @ObservedObject var progressTracker: ProgressTracker
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 0) {
            // コンパクト表示
            HStack {
                Image(systemName: "arrow.down.circle")
                    .foregroundColor(.blue)

                Text("ポケモンデータを取得中...")
                    .font(.subheadline)

                Spacer()

                Text("\(progressTracker.currentProgress.fetchedCount)/\(progressTracker.currentProgress.totalCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button {
                    withAnimation {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))

            // プログレスバー
            ProgressView(value: progressTracker.currentProgress.percentage)
                .padding(.horizontal)

            // 詳細表示（展開時）
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("第\(progressTracker.currentProgress.currentGeneration)世代を取得中")
                            .font(.caption)
                        Spacer()
                        Text("\(Int(progressTracker.currentProgress.percentage * 100))%")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Label("\(progressTracker.currentProgress.successCount)", systemImage: "checkmark.circle.fill")
                            .foregroundColor(.green)

                        if progressTracker.currentProgress.failedCount > 0 {
                            Label("\(progressTracker.currentProgress.failedCount)", systemImage: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                    .font(.caption2)
                }
                .padding()
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
}
```

---

## Phase 2: 永続的キャッシュの導入

### 2.1 SwiftDataモデル定義

**PokemonDataModel**:

```swift
import SwiftData

@Model
final class PokemonDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var speciesId: Int

    // 基本情報
    var types: [String]
    var height: Int
    var weight: Int

    // 画像URL
    var frontDefaultSprite: String?
    var frontShinySprite: String?
    var homeSprite: String?

    // 種族値
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    // 特性
    @Relationship(deleteRule: .cascade) var abilities: [AbilityDataModel]

    // 技（IDのみ保存、詳細はMoveDataModelから取得）
    var moveIds: [Int]

    // フォーム情報
    @Relationship(deleteRule: .cascade) var forms: [PokemonFormDataModel]

    // キャッシュメタデータ
    var lastUpdated: Date
    var cacheVersion: Int
    var isCached: Bool

    init(id: Int, name: String, speciesId: Int, types: [String],
         height: Int, weight: Int, hp: Int, attack: Int, defense: Int,
         specialAttack: Int, specialDefense: Int, speed: Int,
         abilities: [AbilityDataModel], moveIds: [Int], forms: [PokemonFormDataModel]) {
        self.id = id
        self.name = name
        self.speciesId = speciesId
        self.types = types
        self.height = height
        self.weight = weight
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
        self.abilities = abilities
        self.moveIds = moveIds
        self.forms = forms
        self.lastUpdated = Date()
        self.cacheVersion = 1
        self.isCached = true
    }
}

@Model
final class AbilityDataModel {
    var name: String
    var isHidden: Bool

    init(name: String, isHidden: Bool) {
        self.name = name
        self.isHidden = isHidden
    }
}

@Model
final class PokemonFormDataModel {
    var id: Int
    var name: String
    var formName: String
    var types: [String]
    var isMega: Bool
    var isRegional: Bool
    var isDefault: Bool

    init(id: Int, name: String, formName: String, types: [String],
         isMega: Bool, isRegional: Bool, isDefault: Bool) {
        self.id = id
        self.name = name
        self.formName = formName
        self.types = types
        self.isMega = isMega
        self.isRegional = isRegional
        self.isDefault = isDefault
    }
}
```

**MoveDataModel** (Phase 3用):

```swift
@Model
final class MoveDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var type: String
    var damageClass: String
    var power: Int?
    var accuracy: Int?
    var pp: Int
    var priority: Int
    var effectChance: Int?

    // 習得可能なポケモン（ポケモンID:習得方法のマッピング）
    var learnablePokemon: [Int: [String]] // [pokemonId: [learnMethods]]

    // キャッシュメタデータ
    var lastUpdated: Date
    var cacheVersion: Int

    init(id: Int, name: String, type: String, damageClass: String,
         power: Int?, accuracy: Int?, pp: Int, priority: Int, effectChance: Int?,
         learnablePokemon: [Int: [String]]) {
        self.id = id
        self.name = name
        self.type = type
        self.damageClass = damageClass
        self.power = power
        self.accuracy = accuracy
        self.pp = pp
        self.priority = priority
        self.effectChance = effectChance
        self.learnablePokemon = learnablePokemon
        self.lastUpdated = Date()
        self.cacheVersion = 1
    }
}
```

### 2.2 PokemonDataStore

**責務**:
- SwiftDataへのCRUD操作
- Entityとの相互変換
- クエリの実行

**クラス設計**:

```swift
@MainActor
final class PokemonDataStore {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext

    init() throws {
        let schema = Schema([
            PokemonDataModel.self,
            MoveDataModel.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = ModelContext(modelContainer)
    }

    // MARK: - Create

    func save(_ pokemon: Pokemon) throws {
        let dataModel = PokemonDataModel(
            id: pokemon.id,
            name: pokemon.name,
            speciesId: pokemon.speciesId,
            types: pokemon.types.map { $0.name },
            height: pokemon.height,
            weight: pokemon.weight,
            hp: pokemon.stats.first(where: { $0.name == "hp" })?.baseStat ?? 0,
            attack: pokemon.stats.first(where: { $0.name == "attack" })?.baseStat ?? 0,
            defense: pokemon.stats.first(where: { $0.name == "defense" })?.baseStat ?? 0,
            specialAttack: pokemon.stats.first(where: { $0.name == "special-attack" })?.baseStat ?? 0,
            specialDefense: pokemon.stats.first(where: { $0.name == "special-defense" })?.baseStat ?? 0,
            speed: pokemon.stats.first(where: { $0.name == "speed" })?.baseStat ?? 0,
            abilities: pokemon.abilities.map { AbilityDataModel(name: $0.name, isHidden: $0.isHidden) },
            moveIds: pokemon.moves.map { $0.id },
            forms: [] // フォームは別途保存
        )

        modelContext.insert(dataModel)
        try modelContext.save()
    }

    func saveAll(_ pokemons: [Pokemon]) throws {
        for pokemon in pokemons {
            try save(pokemon)
        }
    }

    // MARK: - Read

    func fetch(id: Int) throws -> Pokemon? {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            predicate: #Predicate { $0.id == id }
        )

        guard let dataModel = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return mapToPokemon(dataModel)
    }

    func fetchAll() throws -> [Pokemon] {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            sortBy: [SortDescriptor(\.id)]
        )

        let dataModels = try modelContext.fetch(descriptor)
        return dataModels.map { mapToPokemon($0) }
    }

    func fetchRange(_ range: ClosedRange<Int>) throws -> [Pokemon] {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            predicate: #Predicate { pokemon in
                pokemon.id >= range.lowerBound && pokemon.id <= range.upperBound
            },
            sortBy: [SortDescriptor(\.id)]
        )

        let dataModels = try modelContext.fetch(descriptor)
        return dataModels.map { mapToPokemon($0) }
    }

    // MARK: - Update

    func update(_ pokemon: Pokemon) throws {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            predicate: #Predicate { $0.id == pokemon.id }
        )

        guard let existing = try modelContext.fetch(descriptor).first else {
            // 存在しない場合は新規作成
            try save(pokemon)
            return
        }

        // 更新
        existing.name = pokemon.name
        existing.types = pokemon.types.map { $0.name }
        existing.lastUpdated = Date()

        try modelContext.save()
    }

    // MARK: - Delete

    func delete(id: Int) throws {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            predicate: #Predicate { $0.id == id }
        )

        guard let dataModel = try modelContext.fetch(descriptor).first else {
            return
        }

        modelContext.delete(dataModel)
        try modelContext.save()
    }

    func deleteAll() throws {
        try modelContext.delete(model: PokemonDataModel.self)
        try modelContext.save()
    }

    // MARK: - Query

    func count() throws -> Int {
        let descriptor = FetchDescriptor<PokemonDataModel>()
        return try modelContext.fetchCount(descriptor)
    }

    func isCached(id: Int) throws -> Bool {
        let descriptor = FetchDescriptor<PokemonDataModel>(
            predicate: #Predicate { $0.id == id }
        )
        return try modelContext.fetchCount(descriptor) > 0
    }

    func getCacheSize() -> Int64 {
        // SwiftDataのストレージサイズを取得
        // TODO: 実装
        return 0
    }

    // MARK: - Mapping

    private func mapToPokemon(_ dataModel: PokemonDataModel) -> Pokemon {
        Pokemon(
            id: dataModel.id,
            name: dataModel.name,
            speciesId: dataModel.speciesId,
            types: dataModel.types.enumerated().map { PokemonType(slot: $0.offset + 1, name: $0.element) },
            sprites: PokemonSprites(
                frontDefault: dataModel.frontDefaultSprite,
                frontShiny: dataModel.frontShinySprite,
                other: dataModel.homeSprite.map { homeUrl in
                    PokemonSprites.OtherSprites(
                        home: PokemonSprites.OtherSprites.HomeSprites(
                            frontDefault: homeUrl,
                            frontShiny: nil
                        )
                    )
                }
            ),
            stats: [
                PokemonStat(name: "hp", baseStat: dataModel.hp),
                PokemonStat(name: "attack", baseStat: dataModel.attack),
                PokemonStat(name: "defense", baseStat: dataModel.defense),
                PokemonStat(name: "special-attack", baseStat: dataModel.specialAttack),
                PokemonStat(name: "special-defense", baseStat: dataModel.specialDefense),
                PokemonStat(name: "speed", baseStat: dataModel.speed)
            ],
            abilities: dataModel.abilities.map { PokemonAbility(name: $0.name, isHidden: $0.isHidden) },
            moves: [], // 技はMoveRepositoryから別途取得
            height: dataModel.height,
            weight: dataModel.weight
        )
    }
}
```

### 2.3 CacheManager

**責務**:
- キャッシュ全体の管理
- キャッシュのクリア
- キャッシュ状態の確認

**クラス設計**:

```swift
@MainActor
final class CacheManager: ObservableObject {
    private let pokemonDataStore: PokemonDataStore
    private let moveDataStore: MoveDataStore

    @Published private(set) var cacheStatus: CacheStatus

    struct CacheStatus {
        let pokemonCount: Int
        let moveCount: Int
        let totalSize: Int64
        let lastUpdated: Date?
    }

    init(pokemonDataStore: PokemonDataStore, moveDataStore: MoveDataStore) {
        self.pokemonDataStore = pokemonDataStore
        self.moveDataStore = moveDataStore
        self.cacheStatus = CacheStatus(
            pokemonCount: 0,
            moveCount: 0,
            totalSize: 0,
            lastUpdated: nil
        )
    }

    // MARK: - Public Methods

    func updateStatus() async throws {
        let pokemonCount = try pokemonDataStore.count()
        let moveCount = try moveDataStore.count()
        let totalSize = pokemonDataStore.getCacheSize() + moveDataStore.getCacheSize()

        cacheStatus = CacheStatus(
            pokemonCount: pokemonCount,
            moveCount: moveCount,
            totalSize: totalSize,
            lastUpdated: Date()
        )
    }

    func clearAll() async throws {
        try pokemonDataStore.deleteAll()
        try moveDataStore.deleteAll()
        try await updateStatus()
    }

    func clearPokemonCache() async throws {
        try pokemonDataStore.deleteAll()
        try await updateStatus()
    }

    func clearMoveCache() async throws {
        try moveDataStore.deleteAll()
        try await updateStatus()
    }

    var formattedSize: String {
        ByteCountFormatter.string(fromByteCount: cacheStatus.totalSize, countStyle: .file)
    }
}
```

### 2.4 SettingsView

**設定画面UI**:

```swift
struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel
    @State private var showClearConfirmation = false

    var body: some View {
        NavigationView {
            List {
                Section("キャッシュ情報") {
                    HStack {
                        Text("ポケモンデータ")
                        Spacer()
                        Text("\(viewModel.cacheStatus.pokemonCount)匹")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("技データ")
                        Spacer()
                        Text("\(viewModel.cacheStatus.moveCount)件")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("キャッシュサイズ")
                        Spacer()
                        Text(viewModel.formattedSize)
                            .foregroundColor(.secondary)
                    }

                    if let lastUpdated = viewModel.cacheStatus.lastUpdated {
                        HStack {
                            Text("最終更新")
                            Spacer()
                            Text(lastUpdated, style: .relative)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button(role: .destructive) {
                        showClearConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("キャッシュをクリア")
                        }
                    }
                } footer: {
                    Text("キャッシュをクリアすると、次回起動時に再度データを取得します。")
                }
            }
            .navigationTitle("設定")
            .task {
                await viewModel.loadCacheStatus()
            }
            .confirmationDialog(
                "キャッシュをクリアしますか？",
                isPresented: $showClearConfirmation,
                titleVisibility: .visible
            ) {
                Button("クリア", role: .destructive) {
                    Task {
                        await viewModel.clearCache()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            }
        }
    }
}

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var cacheStatus: CacheManager.CacheStatus

    private let cacheManager: CacheManager

    var formattedSize: String {
        cacheManager.formattedSize
    }

    init(cacheManager: CacheManager) {
        self.cacheManager = cacheManager
        self.cacheStatus = cacheManager.cacheStatus
    }

    func loadCacheStatus() async {
        do {
            try await cacheManager.updateStatus()
            cacheStatus = cacheManager.cacheStatus
        } catch {
            print("Failed to load cache status: \(error)")
        }
    }

    func clearCache() async {
        do {
            try await cacheManager.clearAll()
            cacheStatus = cacheManager.cacheStatus
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}
```

---

## Phase 3: 技フィルターの高速化

### 3.1 MoveDataStore

**責務**:
- 技データのCRUD操作
- 習得可能ポケモンの検索
- インデックス最適化

**クラス設計**:

```swift
@MainActor
final class MoveDataStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Create/Update

    func save(_ move: MoveEntity) throws {
        let dataModel = MoveDataModel(
            id: move.id,
            name: move.name,
            type: move.type,
            damageClass: move.damageClass,
            power: move.power,
            accuracy: move.accuracy,
            pp: move.pp,
            priority: move.priority,
            effectChance: move.effectChance,
            learnablePokemon: [:] // 別途更新
        )

        modelContext.insert(dataModel)
        try modelContext.save()
    }

    func updateLearnablePokemon(moveId: Int, pokemonId: Int, learnMethods: [String]) throws {
        let descriptor = FetchDescriptor<MoveDataModel>(
            predicate: #Predicate { $0.id == moveId }
        )

        guard let move = try modelContext.fetch(descriptor).first else { return }

        move.learnablePokemon[pokemonId] = learnMethods
        move.lastUpdated = Date()
        try modelContext.save()
    }

    // MARK: - Read

    func fetch(id: Int) throws -> MoveEntity? {
        let descriptor = FetchDescriptor<MoveDataModel>(
            predicate: #Predicate { $0.id == id }
        )

        guard let dataModel = try modelContext.fetch(descriptor).first else {
            return nil
        }

        return mapToMoveEntity(dataModel)
    }

    func fetchAll() throws -> [MoveEntity] {
        let descriptor = FetchDescriptor<MoveDataModel>(
            sortBy: [SortDescriptor(\.id)]
        )

        return try modelContext.fetch(descriptor).map { mapToMoveEntity($0) }
    }

    // MARK: - Query (技フィルター用)

    /// 指定された技を習得可能なポケモンIDを検索
    func findPokemonLearningMove(moveId: Int) throws -> [Int] {
        let descriptor = FetchDescriptor<MoveDataModel>(
            predicate: #Predicate { $0.id == moveId }
        )

        guard let move = try modelContext.fetch(descriptor).first else {
            return []
        }

        return Array(move.learnablePokemon.keys)
    }

    /// 複数の技を全て習得可能なポケモンIDを検索
    func findPokemonLearningAllMoves(moveIds: [Int]) throws -> [Int] {
        guard !moveIds.isEmpty else { return [] }

        var pokemonSets: [Set<Int>] = []

        for moveId in moveIds {
            let pokemonIds = try findPokemonLearningMove(moveId: moveId)
            pokemonSets.append(Set(pokemonIds))
        }

        // 積集合を取得（全ての技を習得できるポケモン）
        guard let first = pokemonSets.first else { return [] }
        let result = pokemonSets.dropFirst().reduce(first) { $0.intersection($1) }

        return Array(result).sorted()
    }

    // MARK: - Delete

    func deleteAll() throws {
        try modelContext.delete(model: MoveDataModel.self)
        try modelContext.save()
    }

    func count() throws -> Int {
        let descriptor = FetchDescriptor<MoveDataModel>()
        return try modelContext.fetchCount(descriptor)
    }

    func getCacheSize() -> Int64 {
        // TODO: 実装
        return 0
    }

    // MARK: - Mapping

    private func mapToMoveEntity(_ dataModel: MoveDataModel) -> MoveEntity {
        MoveEntity(
            id: dataModel.id,
            name: dataModel.name,
            type: dataModel.type,
            damageClass: dataModel.damageClass,
            power: dataModel.power,
            accuracy: dataModel.accuracy,
            pp: dataModel.pp,
            priority: dataModel.priority,
            effectChance: dataModel.effectChance,
            effect: nil // 必要に応じてAPI取得
        )
    }
}
```

### 3.2 FilterPokemonByMovesUseCase（改良版）

**改良内容**:
- DBから高速検索
- API呼び出しを最小化

```swift
final class FilterPokemonByMovesUseCase: FilterPokemonByMovesUseCaseProtocol {
    private let moveDataStore: MoveDataStore
    private let pokemonDataStore: PokemonDataStore

    init(moveDataStore: MoveDataStore, pokemonDataStore: PokemonDataStore) {
        self.moveDataStore = moveDataStore
        self.pokemonDataStore = pokemonDataStore
    }

    func execute(
        pokemonList: [PokemonListItem],
        selectedMoves: [MoveEntity],
        versionGroup: String?
    ) async throws -> [PokemonListItem] {

        // Phase 1: DBから習得可能ポケモンを高速検索
        let moveIds = selectedMoves.map { $0.id }
        let learnablePokemonIds = try moveDataStore.findPokemonLearningAllMoves(moveIds: moveIds)

        // Phase 2: ポケモンリストをフィルタリング
        let filtered = pokemonList.filter { learnablePokemonIds.contains($0.id) }

        // Phase 3: 習得方法の詳細をDBから取得
        var result: [PokemonListItem] = []

        for pokemon in filtered {
            var learnMethods: [String: [MoveLearnMethod]] = [:]

            for move in selectedMoves {
                if let methods = try getMoveLearnMethods(
                    pokemonId: pokemon.id,
                    moveId: move.id,
                    versionGroup: versionGroup
                ) {
                    learnMethods[move.name] = methods
                }
            }

            // 全ての技の習得方法が取得できた場合のみ追加
            if learnMethods.count == selectedMoves.count {
                result.append(pokemon)
            }
        }

        return result.sorted { $0.id < $1.id }
    }

    private func getMoveLearnMethods(
        pokemonId: Int,
        moveId: Int,
        versionGroup: String?
    ) throws -> [MoveLearnMethod]? {

        // DBから取得
        guard let move = try moveDataStore.fetch(id: moveId) else { return nil }
        guard let methodNames = move.learnablePokemon[pokemonId] else { return nil }

        // 習得方法をパース
        return methodNames.compactMap { methodName in
            if methodName.starts(with: "level-") {
                if let level = Int(methodName.replacingOccurrences(of: "level-", with: "")) {
                    return MoveLearnMethod.levelUp(level: level)
                }
            } else if methodName == "machine" {
                return MoveLearnMethod.machine(number: nil) // 番号は別途取得
            } else if methodName == "egg" {
                return MoveLearnMethod.egg
            } else if methodName == "tutor" {
                return MoveLearnMethod.tutor
            }
            return nil
        }
    }
}
```

---

## Phase 4: 適応的並列度制御

### 4.1 AdaptiveFetchStrategy

**責務**:
- ネットワーク状況の監視
- バッチサイズの動的調整
- エラー率のモニタリング

**クラス設計**:

```swift
actor AdaptiveFetchStrategy {
    // MARK: - State

    private var currentBatchSize: Int = 3
    private var recentResults: [(success: Bool, duration: TimeInterval)] = []
    private let maxHistorySize = 10

    // MARK: - Constants

    private let minBatchSize = 1
    private let maxBatchSize = 5
    private let successThresholdForIncrease = 0.95  // 95%成功率で並列度UP
    private let successThresholdForDecrease = 0.80  // 80%未満で並列度DOWN

    // MARK: - Public Methods

    func getBatchSize() -> Int {
        currentBatchSize
    }

    func recordResult(success: Bool, duration: TimeInterval) {
        recentResults.append((success, duration))

        // 履歴サイズ制限
        if recentResults.count > maxHistorySize {
            recentResults.removeFirst()
        }

        // バッチサイズを調整
        adjustBatchSize()
    }

    func reset() {
        currentBatchSize = 3
        recentResults.removeAll()
    }

    // MARK: - Private Methods

    private func adjustBatchSize() {
        guard recentResults.count >= 5 else { return }

        let successRate = calculateSuccessRate()
        let avgDuration = calculateAverageDuration()

        if successRate >= successThresholdForIncrease && avgDuration < 2.0 {
            // 成功率が高く、レスポンスも速い → 並列度UP
            increaseBatchSize()
        } else if successRate < successThresholdForDecrease || avgDuration > 5.0 {
            // 成功率が低い、またはレスポンスが遅い → 並列度DOWN
            decreaseBatchSize()
        }
    }

    private func calculateSuccessRate() -> Double {
        let successCount = recentResults.filter { $0.success }.count
        return Double(successCount) / Double(recentResults.count)
    }

    private func calculateAverageDuration() -> TimeInterval {
        let total = recentResults.map { $0.duration }.reduce(0, +)
        return total / Double(recentResults.count)
    }

    private func increaseBatchSize() {
        if currentBatchSize < maxBatchSize {
            currentBatchSize += 1
            print("📈 Batch size increased to \(currentBatchSize)")
        }
    }

    private func decreaseBatchSize() {
        if currentBatchSize > minBatchSize {
            currentBatchSize -= 1
            print("📉 Batch size decreased to \(currentBatchSize)")
        }
    }
}
```

### 4.2 PokemonAPIClient（拡張）

**適応的戦略の適用**:

```swift
func fetchPokemonList(
    idRange: ClosedRange<Int>,
    progressHandler: ((Double) -> Void)?
) async throws -> [Pokemon] {

    let strategy = AdaptiveFetchStrategy()
    let totalCount = idRange.count
    var pokemons: [Pokemon] = []
    var currentIndex = idRange.lowerBound

    while currentIndex <= idRange.upperBound {
        let batchSize = await strategy.getBatchSize()
        let batchEnd = min(currentIndex + batchSize - 1, idRange.upperBound)
        let batchRange = currentIndex...batchEnd

        let startTime = Date()

        // バッチ取得
        let batch = try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            for id in batchRange {
                group.addTask {
                    do {
                        return try await self.fetchPokemon(id)
                    } catch {
                        return nil
                    }
                }
            }

            var results: [Pokemon] = []
            for try await pokemon in group {
                if let pokemon = pokemon {
                    results.append(pokemon)
                }
            }
            return results
        }

        let duration = Date().timeIntervalSince(startTime)
        let success = batch.count == batchRange.count

        // 戦略に結果を記録
        await strategy.recordResult(success: success, duration: duration)

        pokemons.append(contentsOf: batch)
        currentIndex = batchEnd + 1

        // 進捗通知
        let progress = Double(pokemons.count) / Double(totalCount)
        progressHandler?(progress)

        // 次のバッチまで待機
        try await Task.sleep(nanoseconds: 50_000_000)
    }

    return pokemons.sorted { $0.id < $1.id }
}
```

---

## データフロー

### v4.0のデータフロー図

```
┌─────────────────────────────────────────────────────────┐
│                   User Action                            │
│           (アプリ起動 / 技フィルター実行)                  │
└─────────────────────────────────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│              PokemonListViewModel                        │
│   ┌─────────────────────────────────────────────────┐  │
│   │ 1. キャッシュチェック (PokemonDataStore)         │  │
│   │ 2. キャッシュヒット → 即座に表示                 │  │
│   │ 3. キャッシュミス → BackgroundFetchService起動   │  │
│   └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              │                       │
              ↓                       ↓
    ┌──────────────────┐    ┌──────────────────┐
    │ PokemonDataStore │    │ BackgroundFetch  │
    │   (SwiftData)    │    │     Service      │
    └──────────────────┘    └──────────────────┘
              │                       │
              │                       ↓
              │            ┌──────────────────┐
              │            │ PokemonRepository│
              │            └──────────────────┘
              │                       │
              │                       ↓
              │            ┌──────────────────┐
              │            │ PokemonAPIClient │
              │            └──────────────────┘
              │                       │
              │                       ↓
              │            ┌──────────────────┐
              │            │    PokéAPI       │
              │            └──────────────────┘
              │                       │
              │◄──────────────────────┘
              │   (取得後DBに保存)
              ↓
    ┌──────────────────┐
    │   UI Update      │
    │  (リスト表示)     │
    └──────────────────┘
```

### 技フィルターのデータフロー

```
┌─────────────────────────────────────────────────────────┐
│                  User Action                             │
│              (技フィルター実行)                           │
└─────────────────────────────────────────────────────────┘
                          │
                          ↓
┌─────────────────────────────────────────────────────────┐
│         FilterPokemonByMovesUseCase                      │
│   ┌─────────────────────────────────────────────────┐  │
│   │ 1. MoveDataStoreからインデックス検索              │  │
│   │ 2. 習得可能ポケモンIDを即座に取得                │  │
│   │ 3. ポケモンリストをフィルタリング                 │  │
│   └─────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                          │
                          ↓
              ┌──────────────────┐
              │  MoveDataStore   │
              │   (SwiftData)    │
              │  - インデックス   │
              │  - 高速検索       │
              └──────────────────┘
                          │
                          ↓
              ┌──────────────────┐
              │   結果を返す      │
              │  (3秒以内)        │
              └──────────────────┘
```

---

## エラーハンドリング

### エラー分類と対応

| エラータイプ | 対応 | リトライ | ユーザー通知 |
|------------|------|---------|------------|
| ネットワークエラー | 3回リトライ | ○ | 失敗時のみ |
| タイムアウト | 指数バックオフでリトライ | ○ | 失敗時のみ |
| キャッシュ読み込み失敗 | APIから取得 | × | なし |
| キャッシュ書き込み失敗 | ログ記録のみ | × | なし |
| DB破損 | キャッシュクリア提案 | × | ○ |

### エラー通知UI

```swift
struct ErrorBannerView: View {
    let error: PokemonError
    let retryAction: (() -> Void)?

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)

            VStack(alignment: .leading) {
                Text(error.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(error.message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let retryAction = retryAction {
                Button("再試行") {
                    retryAction()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding()
    }
}
```

---

## テスト戦略

### Phase 1: バックグラウンド段階的読み込み

**BackgroundFetchServiceTests**
- 優先度キューの動作確認
- 進捗通知の正確性
- キャンセル処理
- エラーハンドリング

**ProgressTrackerTests**
- 進捗計算の精度
- 状態遷移の検証
- 通知タイミング

### Phase 2: 永続的キャッシュ

**PokemonDataStoreTests**
- SwiftDataへの保存/読み込み
- キャッシュ有効期限チェック
- 差分更新ロジック
- データマイグレーション

**CacheManagerTests**
- キャッシュクリア処理
- バージョン管理
- 容量管理

### Phase 3: 技フィルター高速化

**MoveDataStoreTests**
- インデックス検索の性能
- 技メタデータフィルタリング
- learnablePokemonマッピング精度

### Phase 4: 適応的並列度制御（オプション）

**AdaptiveFetchStrategyTests**
- ネットワーク状態検出
- 並列度の動的調整
- タイムアウト回避

### テストカバレッジ目標

| 層 | v4.0目標 |
|----|---------|
| Domain層 | 90%+ |
| Data層 | 85%+ |
| Presentation層 | 80%+ |
| **全体** | **85%+** |

---

## まとめ

### v4.0で追加される主要コンポーネント

1. **BackgroundFetchService**: 段階的バックグラウンド取得
2. **ProgressTracker**: 進捗管理
3. **PriorityQueue**: 優先度管理
4. **PokemonDataStore**: SwiftData永続化
5. **MoveDataStore**: 技データ永続化
6. **CacheManager**: キャッシュ管理
7. **SettingsViewModel**: 設定画面
8. **AdaptiveFetchStrategy**: 適応的並列制御

### 期待される効果

| 項目 | v3.0 | v4.0 | 改善率 |
|------|------|------|--------|
| 初回起動 | 60-90秒 | 8-12秒 | 85%削減 |
| 2回目起動 | 60-90秒 | 1秒以内 | 98%削減 |
| 技フィルター | 80秒 | 3秒以内 | 96%削減 |
| ユーザー満足度 | 低 | 高 | - |

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 担当 |
|------|-----------|---------|------|
| 2025-10-09 | 1.0 | 初版作成 | Claude |
