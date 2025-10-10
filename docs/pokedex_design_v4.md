# Pokédex SwiftUI - 設計書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-10

---

## 📋 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [Phase 1: SwiftData永続化](#phase-1-swiftdata永続化)
3. [Phase 2: プリバンドルデータベース](#phase-2-プリバンドルデータベース)
4. [Phase 3: 技フィルターの高速化](#phase-3-技フィルターの高速化)
5. [Phase 4: 日本語対応](#phase-4-日本語対応)
6. [Phase 5: バージョン固有データ対応](#phase-5-バージョン固有データ対応)
7. [Phase 6: モジュール化](#phase-6-モジュール化)
8. [データフロー](#データフロー)
9. [エラーハンドリング](#エラーハンドリング)

---

## アーキテクチャ概要

### 全体構成（v4.0: SwiftData + プリバンドルDB）

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
│  │  - FetchPokemonListUseCase                       │  │
│  │  - FilterPokemonByMovesUseCase                   │  │
│  │  - etc.                                          │  │
│  └──────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────┐  │
│  │              Entities (既存)                      │  │
│  │  - Pokemon, PokemonType, PokemonStat             │  │
│  │  - Move, Ability, etc.                           │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                           │
┌─────────────────────────────────────────────────────────┐
│                         Data                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  │
│  │ Pokemon      │  │ Move         │  │   Type       │  │
│  │ Repository   │  │ Repository   │  │ Repository   │  │
│  └──────────────┘  └──────────────┘  └──────────────┘  │
│         │                  │                 │           │
│  ┌──────┴──────────────────┴─────────────────┴──────┐  │
│  │              SwiftData (新規)                     │  │
│  │  ┌────────────────┐  ┌────────────────┐          │  │
│  │  │ PokemonModel   │  │  MoveModel     │          │  │
│  │  │  + Mapper      │  │   + Mapper     │          │  │
│  │  └────────────────┘  └────────────────┘          │  │
│  │                                                    │  │
│  │  ┌────────────────────────────────────┐          │  │
│  │  │  ModelContainer                    │          │  │
│  │  │   - 永続化先: Documents/           │          │  │
│  │  │   - プリバンドル: Resources/       │          │  │
│  │  └────────────────────────────────────┘          │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │            PokemonAPIClient (既存)                │  │
│  │  - 初回データ取得（Phase 1）                      │  │
│  │  - 差分更新（Phase 2）                            │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### v4.0の設計方針

1. **SwiftData中心の永続化**: インメモリキャッシュを廃止し、全てSwiftDataで永続化
2. **プリバンドルDB**: 初回起動から全データ利用可能
3. **シンプルな構成**: 複雑なバックグラウンド取得ロジックを削除し、順次取得に統一
4. **モジュール化準備**: UIKit版を見据えたData/Domain層の分離

### 新規追加コンポーネント

| コンポーネント | 責務 | Phase |
|--------------|------|-------|
| PokemonModel | SwiftDataモデル（永続化） | 1 |
| PokemonModelMapper | Domain ↔ SwiftData変換 | 1 |
| MoveModel | 技データのSwiftDataモデル | 3 |
| GenerateDatabaseScript | プリバンドルDB生成ツール | 2 |
| SettingsViewModel | キャッシュ管理UI | 1 |
| LocalizationManager | 日本語対応 | 4 |
| PokemonVersionVariant | バージョン固有データ | 5 |
| PokedexCore Package | モジュール化 | 6 |

---

## Phase 1: SwiftData永続化

### 目標

- 取得したポケモンデータをディスクに永続化
- アプリ再起動後もデータを保持
- 2回目以降の起動を1秒以内に短縮

### 1.1 SwiftDataモデル設計

**設計方針**:
1. Domain層のPokemonエンティティと1:1対応するSwiftDataモデルを作成
2. リレーションシップを活用して正規化
3. `@Attribute(.unique)`で一意制約を設定
4. `@Relationship(deleteRule: .cascade)`で親子関係を管理

**PokemonModel**:

```swift
@Model
final class PokemonModel {
    // MARK: - Properties

    @Attribute(.unique) var id: Int           // 主キー
    var speciesId: Int                        // 種族ID
    var name: String                          // 英語名
    var height: Int                           // 身長（デシメートル）
    var weight: Int                           // 体重（ヘクトグラム）

    // リレーションシップ（1:N）
    @Relationship(deleteRule: .cascade) var types: [PokemonTypeModel]
    @Relationship(deleteRule: .cascade) var stats: [PokemonStatModel]
    @Relationship(deleteRule: .cascade) var abilities: [PokemonAbilityModel]
    @Relationship(deleteRule: .cascade) var sprites: PokemonSpriteModel?

    // 簡略化されたデータ
    var moveIds: [Int]                        // 技ID一覧（詳細は別途取得）
    var availableGenerations: [Int]           // 登場可能世代
    var fetchedAt: Date                       // キャッシュ日時

    init(id: Int, speciesId: Int, name: String, height: Int, weight: Int,
         types: [PokemonTypeModel] = [], stats: [PokemonStatModel] = [],
         abilities: [PokemonAbilityModel] = [], sprites: PokemonSpriteModel? = nil,
         moveIds: [Int] = [], availableGenerations: [Int] = [],
         fetchedAt: Date = Date()) {
        self.id = id
        self.speciesId = speciesId
        self.name = name
        self.height = height
        self.weight = weight
        self.types = types
        self.stats = stats
        self.abilities = abilities
        self.sprites = sprites
        self.moveIds = moveIds
        self.availableGenerations = availableGenerations
        self.fetchedAt = fetchedAt
    }
}
```

**関連モデル**:

```swift
@Model
final class PokemonTypeModel {
    var slot: Int                             // タイプスロット（1 or 2）
    var name: String                          // タイプ名
    var pokemon: PokemonModel?                // 親ポケモン

    init(slot: Int, name: String) {
        self.slot = slot
        self.name = name
    }
}

@Model
final class PokemonStatModel {
    var name: String                          // ステータス名
    var baseStat: Int                         // 種族値
    var pokemon: PokemonModel?                // 親ポケモン

    init(name: String, baseStat: Int) {
        self.name = name
        self.baseStat = baseStat
    }
}

@Model
final class PokemonAbilityModel {
    var name: String                          // 特性名
    var isHidden: Bool                        // 隠れ特性フラグ
    var pokemon: PokemonModel?                // 親ポケモン

    init(name: String, isHidden: Bool) {
        self.name = name
        self.isHidden = isHidden
    }
}

@Model
final class PokemonSpriteModel {
    var frontDefault: String?                 // デフォルト画像URL
    var frontShiny: String?                   // 色違い画像URL
    var homeFrontDefault: String?             // Home画像URL
    var homeFrontShiny: String?               // Home色違い画像URL
    var pokemon: PokemonModel?                // 親ポケモン

    init(frontDefault: String? = nil, frontShiny: String? = nil,
         homeFrontDefault: String? = nil, homeFrontShiny: String? = nil) {
        self.frontDefault = frontDefault
        self.frontShiny = frontShiny
        self.homeFrontDefault = homeFrontDefault
        self.homeFrontShiny = homeFrontShiny
    }
}
```

**ER図**:

```
PokemonModel (1) ──┬── (N) PokemonTypeModel
                   ├── (N) PokemonStatModel
                   ├── (N) PokemonAbilityModel
                   └── (1) PokemonSpriteModel
```

### 1.2 PokemonModelMapper

**責務**:
- Domain層の`Pokemon`とData層の`PokemonModel`の相互変換
- データ損失なく双方向変換を保証

**クラス設計**:

```swift
enum PokemonModelMapper {
    // MARK: - Domain → SwiftData

    static func toModel(_ pokemon: Pokemon) -> PokemonModel {
        // タイプ変換
        let types = pokemon.types.map { type in
            PokemonTypeModel(slot: type.slot, name: type.name)
        }

        // ステータス変換
        let stats = pokemon.stats.map { stat in
            PokemonStatModel(name: stat.name, baseStat: stat.baseStat)
        }

        // 特性変換
        let abilities = pokemon.abilities.map { ability in
            PokemonAbilityModel(name: ability.name, isHidden: ability.isHidden)
        }

        // 画像URL変換
        let sprites = PokemonSpriteModel(
            frontDefault: pokemon.sprites.frontDefault,
            frontShiny: pokemon.sprites.frontShiny,
            homeFrontDefault: pokemon.sprites.other?.home?.frontDefault,
            homeFrontShiny: pokemon.sprites.other?.home?.frontShiny
        )

        // 技ID抽出
        let moveIds = pokemon.moves.map { $0.id }

        return PokemonModel(
            id: pokemon.id,
            speciesId: pokemon.speciesId,
            name: pokemon.name,
            height: pokemon.height,
            weight: pokemon.weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moveIds: moveIds,
            availableGenerations: pokemon.availableGenerations
        )
    }

    // MARK: - SwiftData → Domain

    static func toDomain(_ model: PokemonModel) -> Pokemon {
        // タイプ変換
        let types = model.types.map { typeModel in
            PokemonType(slot: typeModel.slot, name: typeModel.name)
        }

        // ステータス変換
        let stats = model.stats.map { statModel in
            PokemonStat(name: statModel.name, baseStat: statModel.baseStat)
        }

        // 特性変換
        let abilities = model.abilities.map { abilityModel in
            PokemonAbility(name: abilityModel.name, isHidden: abilityModel.isHidden)
        }

        // 画像URL変換
        let sprites = PokemonSprites(
            frontDefault: model.sprites?.frontDefault,
            frontShiny: model.sprites?.frontShiny,
            other: PokemonSprites.OtherSprites(
                home: PokemonSprites.OtherSprites.HomeSprites(
                    frontDefault: model.sprites?.homeFrontDefault,
                    frontShiny: model.sprites?.homeFrontShiny
                )
            )
        )

        // 技情報は空配列（詳細は必要時に別途取得）
        let moves: [PokemonMove] = []

        return Pokemon(
            id: model.id,
            speciesId: model.speciesId,
            name: model.name,
            height: model.height,
            weight: model.weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moves,
            availableGenerations: model.availableGenerations
        )
    }
}
```

### 1.3 PokemonRepository の SwiftData 対応

**変更前（v3.0 - インメモリキャッシュ）**:

```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient = PokemonAPIClient()

    // 問題: アプリ再起動で消失
    private var cache: [Int: Pokemon] = [:]
    private var versionGroupCaches: [String: [Pokemon]] = [:]

    func fetchPokemonList(versionGroup: VersionGroup,
                         progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // キャッシュチェック
        if let cached = versionGroupCaches[versionGroup.id] {
            return cached
        }

        // API取得
        let pokemons = try await apiClient.fetchPokemonList(...)

        // メモリに保存（再起動で消える）
        versionGroupCaches[versionGroup.id] = pokemons

        return pokemons
    }
}
```

**変更後（v4.0 - SwiftData）**:

```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient = PokemonAPIClient()
    private let modelContext: ModelContext  // ← 追加

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchPokemonList(versionGroup: VersionGroup,
                         progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // 1. SwiftDataから取得を試みる
        let descriptor = FetchDescriptor<PokemonModel>(
            sortBy: [SortDescriptor(\.id)]
        )
        let cachedModels = try modelContext.fetch(descriptor)

        if !cachedModels.isEmpty {
            // キャッシュあり → Domainエンティティに変換して返す
            return cachedModels.map { PokemonModelMapper.toDomain($0) }
        }

        // 2. キャッシュなし → APIから取得
        let pokemons = try await apiClient.fetchPokemonList(
            idRange: versionGroup.idRange,
            progressHandler: progressHandler
        )

        // 3. SwiftDataに保存（ディスク永続化）
        for pokemon in pokemons {
            let model = PokemonModelMapper.toModel(pokemon)
            modelContext.insert(model)
        }
        try modelContext.save()

        return pokemons
    }

    func clearCache() {
        do {
            // SwiftDataの全データ削除
            try modelContext.delete(model: PokemonModel.self)
            try modelContext.save()
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}
```

### 1.4 ModelContainer セットアップ

**PokedexApp.swift**:

```swift
import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: PokemonModel.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: false)
            )
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)  // ← 追加
        }
    }
}
```

**DIContainer.swift**:

```swift
final class DIContainer: ObservableObject {
    static let shared = DIContainer()

    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Repositories
    private lazy var pokemonRepository: PokemonRepositoryProtocol = {
        guard let modelContext = modelContext else {
            fatalError("ModelContext not set")
        }
        return PokemonRepository(modelContext: modelContext)
    }()
}
```

**ContentView.swift**:

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        PokemonListView()
            .onAppear {
                // ModelContextをDIContainerに注入
                DIContainer.shared.setModelContext(modelContext)
            }
    }
}
```

### 1.5 データフロー

**初回起動（キャッシュなし）**:

```
User: アプリ起動
    ↓
PokemonListView
    ↓
PokemonListViewModel.loadPokemons()
    ↓
PokemonRepository.fetchPokemonList()
    ├→ 1. SwiftData確認 → 空
    ├→ 2. PokéAPI取得（60-90秒）
    │     - 順次取得（50ms間隔）
    │     - 進捗通知
    ├→ 3. PokemonModelMapper.toModel()
    ├→ 4. modelContext.insert()
    └→ 5. modelContext.save() → ディスクに永続化
    ↓
User: ポケモンリスト表示（60-90秒後）
```

**2回目以降（キャッシュあり）**:

```
User: アプリ起動
    ↓
PokemonListView
    ↓
PokemonListViewModel.loadPokemons()
    ↓
PokemonRepository.fetchPokemonList()
    ├→ 1. SwiftData確認 → あり！
    ├→ 2. PokemonModelMapper.toDomain()
    └→ 3. 即座に返却（1秒以内）
    ↓
User: ポケモンリスト表示（1秒以内）
```

---

## Phase 2: プリバンドルデータベース

### 目標

- 全1025匹のデータを事前に生成してアプリに同梱
- 初回起動から1秒以内でデータ表示
- 完全オフライン対応

### 2.1 データ生成スクリプト

**GenerateDatabase.swift** (Tools target):

```swift
import Foundation
import SwiftData

@main
struct GenerateDatabase {
    static func main() async throws {
        print("🚀 Generating preloaded database...")

        // 出力先: Resources/PreloadedData/Pokedex.sqlite
        let outputURL = URL(fileURLWithPath: "Resources/PreloadedData/Pokedex.sqlite")

        // ModelContainer作成
        let container = try ModelContainer(
            for: PokemonModel.self,
            configurations: ModelConfiguration(url: outputURL)
        )
        let context = ModelContext(container)

        // 全ポケモン取得（1025匹）
        let apiClient = PokemonAPIClient()
        var fetchedCount = 0

        for id in 1...1025 {
            do {
                let pokemon = try await apiClient.fetchPokemon(id)
                let model = PokemonModelMapper.toModel(pokemon)
                context.insert(model)

                fetchedCount += 1
                if fetchedCount % 10 == 0 {
                    print("Fetched: \(fetchedCount)/1025")
                    try context.save()
                }

                // API負荷軽減
                try await Task.sleep(nanoseconds: 50_000_000)
            } catch {
                print("⚠️ Failed to fetch Pokemon #\(id): \(error)")
            }
        }

        // 最終保存
        try context.save()
        print("✅ Database generation completed: \(fetchedCount) Pokemon")
        print("📦 File size: \(try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] ?? 0) bytes")
    }
}
```

### 2.2 プリバンドルDBの組み込み

**ディレクトリ構成**:
```
Pokedex/
├── Resources/
│   └── PreloadedData/
│       └── Pokedex.sqlite  // 生成したDBファイル（約15-20MB）
```

**PokemonRepository の拡張**:

```swift
extension PokemonRepository {
    func fetchPokemonList(versionGroup: VersionGroup,
                         progressHandler: ((Double) -> Void)?) async throws -> [Pokemon] {
        // 1. SwiftDataから取得を試みる
        let descriptor = FetchDescriptor<PokemonModel>(sortBy: [SortDescriptor(\.id)])
        let cachedModels = try modelContext.fetch(descriptor)

        if !cachedModels.isEmpty {
            return cachedModels.map { PokemonModelMapper.toDomain($0) }
        }

        // 2. プリバンドルDBをコピー（初回のみ）
        if await copyPreloadedDatabaseIfNeeded() {
            // コピー成功 → 再読み込み
            let models = try modelContext.fetch(descriptor)
            if !models.isEmpty {
                return models.map { PokemonModelMapper.toDomain($0) }
            }
        }

        // 3. フォールバック: APIから取得
        let pokemons = try await apiClient.fetchPokemonList(
            idRange: versionGroup.idRange,
            progressHandler: progressHandler
        )

        for pokemon in pokemons {
            modelContext.insert(PokemonModelMapper.toModel(pokemon))
        }
        try modelContext.save()

        return pokemons
    }

    private func copyPreloadedDatabaseIfNeeded() async -> Bool {
        let fileManager = FileManager.default

        // ドキュメントディレクトリのDB
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return false
        }
        let targetURL = documentsURL.appendingPathComponent("Pokedex.sqlite")

        // 既にコピー済み
        if fileManager.fileExists(atPath: targetURL.path) {
            return false
        }

        // バンドルからコピー
        guard let bundleURL = Bundle.main.url(
            forResource: "Pokedex",
            withExtension: "sqlite",
            subdirectory: "PreloadedData"
        ) else {
            print("⚠️ Preloaded database not found in bundle")
            return false
        }

        do {
            try fileManager.copyItem(at: bundleURL, to: targetURL)
            print("✅ Preloaded database copied")
            return true
        } catch {
            print("⚠️ Failed to copy preloaded database: \(error)")
            return false
        }
    }
}
```

### 2.3 差分更新

**アプリバージョンアップ時の処理**:

```swift
extension PokemonRepository {
    func updateDatabaseIfNeeded() async throws {
        // 1. PokéAPIから最新のポケモン総数を取得
        let latestCount = try await apiClient.fetchTotalPokemonCount()

        // 2. SwiftDataの最大IDを確認
        let descriptor = FetchDescriptor<PokemonModel>(
            sortBy: [SortDescriptor(\.id, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        let maxModel = try modelContext.fetch(descriptor).first
        let currentMaxId = maxModel?.id ?? 0

        // 3. 差分がある場合のみ取得
        guard latestCount > currentMaxId else {
            print("Database is up to date")
            return
        }

        print("Updating database: \(currentMaxId + 1)...\(latestCount)")

        // 4. 新しいポケモンのみ取得
        for id in (currentMaxId + 1)...latestCount {
            do {
                let pokemon = try await apiClient.fetchPokemon(id)
                let model = PokemonModelMapper.toModel(pokemon)
                modelContext.insert(model)

                if id % 10 == 0 {
                    try modelContext.save()
                }

                try await Task.sleep(nanoseconds: 50_000_000)
            } catch {
                print("⚠️ Failed to fetch Pokemon #\(id): \(error)")
            }
        }

        try modelContext.save()
        print("✅ Database updated: \(latestCount - currentMaxId) new Pokemon")
    }
}
```

---

## Phase 3以降

**Phase 3: 技フィルターの高速化** - MoveModelの定義、技データの永続化、FilterPokemonByMovesUseCaseの改良

**Phase 4: 日本語対応** - Entityに日本語名フィールド追加、LocalizationManager実装

**Phase 5: バージョン固有データ対応** - PokemonVersionVariantモデル追加、地方図鑑対応

**Phase 6: モジュール化** - PokedexCoreパッケージ作成、Domain/Data/Presentation層の分離

詳細は `docs/pokedex_prompts_v4.md` および `docs/pokedex_requirements_v4.md` を参照してください。

---

## データフロー（Phase 2完了後）

**初回起動**:

```
User: アプリ起動
    ↓
PokemonRepository.fetchPokemonList()
    ├→ 1. SwiftData確認 → 空
    ├→ 2. プリバンドルDB確認 → あり！
    ├→ 3. Documents/にコピー
    ├→ 4. SwiftDataから読み込み
    └→ 5. Domain変換して返却（1秒以内）
    ↓
User: ポケモンリスト表示（1秒以内）
```

**2回目以降**:

```
User: アプリ起動
    ↓
PokemonRepository.fetchPokemonList()
    ├→ 1. SwiftData確認 → あり！
    └→ 2. Domain変換して返却（1秒以内）
    ↓
User: ポケモンリスト表示（1秒以内）
```

---

## エラーハンドリング

### SwiftDataエラー

| エラー | 原因 | 対処 |
|--------|------|------|
| ModelContainer初期化失敗 | スキーマ不整合 | アプリ再インストール推奨 |
| fetch失敗 | データ破損 | キャッシュクリア → 再取得 |
| save失敗 | ディスク容量不足 | ユーザーに通知 |

### プリバンドルDBエラー

| エラー | 原因 | 対処 |
|--------|------|------|
| バンドルにDBなし | ビルド設定ミス | APIからフォールバック取得 |
| コピー失敗 | 権限エラー | APIからフォールバック取得 |

---

## 変更履歴

| 日付 | バージョン | 変更内容 |
|------|-----------|---------|
| 2025-10-09 | 1.0 | 初版作成 |
| 2025-10-10 | 2.0 | Phase 1をSwiftData永続化に変更、Phase 2をプリバンドルDBに変更、Phase 3以降を簡略化 |
