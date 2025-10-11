# Pokédex SwiftUI - 実装プロンプト v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-10
**最終更新**: 2025-10-10

---

## 📝 実装メモ（2025-10-10）

### 決定事項

1. **実装方針**: Phase 1とPhase 2を統合し、最初からプリバンドルDB方式で実装
   - 理由: 初回起動から爆速にする
   - 段階的検証: 151匹で動作確認 → 1025匹全て

2. **検証ステップ**:
   - Step 1: SwiftDataモデル・Mapper実装
   - Step 2: 第1世代（151匹）でプリバンドルDB生成（約8分）
   - Step 3: 動作確認（初回起動・2回目起動・オフライン）
   - Step 4: 問題なければ全1025匹のDB生成（約1-2時間）

3. **オフライン対応の理解**:
   - プリバンドルDB方式 → 初回からオフラインOK
   - API取得方式 → 初回のみオンライン必須、2回目以降オフラインOK

4. **UIKit対応**:
   - 将来的にUIKit版も作成予定
   - Data層・Domain層・ViewModel層は共通化
   - View層のみSwiftUI/UIKitで個別実装

### 既に作成済み

- ✅ `Data/Persistence/PokemonModel.swift` - SwiftDataモデル定義
- ✅ `Data/Persistence/PokemonModelMapper.swift` - Domain ↔ SwiftData変換
- ✅ `docs/pokedex_prompts_v4.md` - 実装プロンプト

### 次回タスク

1. 要件定義書の更新（改定案を反映）
2. 設計書の改定
3. PokemonRepositoryをSwiftData対応に変更
4. ModelContainerセットアップ（PokedexApp.swift）
5. 第1世代（151匹）プリバンドルDB生成
6. 動作確認
7. 全1025匹プリバンドルDB生成

---

## 📋 目次

1. [概要](#概要)
2. [Phase 1: SwiftData永続化](#phase-1-swiftdata永続化)
3. [Phase 2: プリバンドルデータベース](#phase-2-プリバンドルデータベース)
4. [Phase 3: バージョン固有データ対応](#phase-3-バージョン固有データ対応)
5. [Phase 4: モジュール化](#phase-4-モジュール化)

---

## 概要

### v4.0の実装方針

**背景**:
- v3.0で全ポケモン（1025匹）を順次取得すると60-90秒かかる
- インメモリキャッシュのため、アプリ再起動で毎回再取得
- 91%まで取得しても再起動で1%に戻る

**解決策**:
1. **SwiftData永続化** - 取得したデータをディスクに保存
2. **プリバンドルDB** - 初回から全データを即座に使用可能（将来的）
3. **バージョン固有データ対応** - ゲームによって異なるタイプ・特性に対応
4. **モジュール化** - UIKit版を見据えたアーキテクチャ

**実装の優先順位**:
1. Phase 1（高優先度）: SwiftData永続化 → 2回目以降が即時起動
2. Phase 2（中優先度）: プリバンドルDB → 初回起動も即座に
3. Phase 3（低優先度）: バージョン固有データ対応 → データの正確性向上
4. Phase 4（低優先度）: モジュール化 → UIKit版の準備

---

## Phase 1: SwiftData永続化

### 目標

- 取得したポケモンデータをSwiftDataで永続化
- 2回目以降の起動を1秒以内に短縮
- オフライン閲覧を可能にする

### 実装手順

#### ステップ1-1: SwiftDataモデルの定義

**ファイル**: `Data/Persistence/PokemonModel.swift`

```swift
import Foundation
import SwiftData

/// SwiftData用のPokemonモデル
@Model
final class PokemonModel {
    @Attribute(.unique) var id: Int
    var speciesId: Int
    var name: String
    var height: Int
    var weight: Int

    @Relationship(deleteRule: .cascade) var types: [PokemonTypeModel]
    @Relationship(deleteRule: .cascade) var stats: [PokemonStatModel]
    @Relationship(deleteRule: .cascade) var abilities: [PokemonAbilityModel]
    @Relationship(deleteRule: .cascade) var sprites: PokemonSpriteModel?

    var moveIds: [Int]
    var availableGenerations: [Int]
    var fetchedAt: Date

    init(
        id: Int,
        speciesId: Int,
        name: String,
        height: Int,
        weight: Int,
        types: [PokemonTypeModel] = [],
        stats: [PokemonStatModel] = [],
        abilities: [PokemonAbilityModel] = [],
        sprites: PokemonSpriteModel? = nil,
        moveIds: [Int] = [],
        availableGenerations: [Int] = [],
        fetchedAt: Date = Date()
    ) {
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

@Model
final class PokemonTypeModel {
    var slot: Int
    var name: String
    var pokemon: PokemonModel?

    init(slot: Int, name: String) {
        self.slot = slot
        self.name = name
    }
}

@Model
final class PokemonStatModel {
    var name: String
    var baseStat: Int
    var pokemon: PokemonModel?

    init(name: String, baseStat: Int) {
        self.name = name
        self.baseStat = baseStat
    }
}

@Model
final class PokemonAbilityModel {
    var name: String
    var isHidden: Bool
    var pokemon: PokemonModel?

    init(name: String, isHidden: Bool) {
        self.name = name
        self.isHidden = isHidden
    }
}

@Model
final class PokemonSpriteModel {
    var frontDefault: String?
    var frontShiny: String?
    var homeFrontDefault: String?
    var homeFrontShiny: String?
    var pokemon: PokemonModel?

    init(
        frontDefault: String? = nil,
        frontShiny: String? = nil,
        homeFrontDefault: String? = nil,
        homeFrontShiny: String? = nil
    ) {
        self.frontDefault = frontDefault
        self.frontShiny = frontShiny
        self.homeFrontDefault = homeFrontDefault
        self.homeFrontShiny = homeFrontShiny
    }
}
```

**チェックリスト**:
- [ ] PokemonModel.swiftを作成
- [ ] 全ての@Modelクラスに@Attribute(.unique)を適切に設定
- [ ] @Relationship(deleteRule: .cascade)を設定（親削除時に子も削除）
- [ ] ビルドが通ることを確認

#### ステップ1-2: Mapper作成（Domain ↔ SwiftData変換）

**ファイル**: `Data/Persistence/PokemonModelMapper.swift`

```swift
import Foundation

enum PokemonModelMapper {
    // MARK: - Domain → SwiftData

    static func toModel(_ pokemon: Pokemon) -> PokemonModel {
        let types = pokemon.types.map { type in
            PokemonTypeModel(slot: type.slot, name: type.name)
        }

        let stats = pokemon.stats.map { stat in
            PokemonStatModel(name: stat.name, baseStat: stat.baseStat)
        }

        let abilities = pokemon.abilities.map { ability in
            PokemonAbilityModel(name: ability.name, isHidden: ability.isHidden)
        }

        let sprites = PokemonSpriteModel(
            frontDefault: pokemon.sprites.frontDefault,
            frontShiny: pokemon.sprites.frontShiny,
            homeFrontDefault: pokemon.sprites.other?.home?.frontDefault,
            homeFrontShiny: pokemon.sprites.other?.home?.frontShiny
        )

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
        let types = model.types.map { typeModel in
            PokemonType(slot: typeModel.slot, name: typeModel.name)
        }

        let stats = model.stats.map { statModel in
            PokemonStat(name: statModel.name, baseStat: statModel.baseStat)
        }

        let abilities = model.abilities.map { abilityModel in
            PokemonAbility(name: abilityModel.name, isHidden: abilityModel.isHidden)
        }

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

        // 技情報は簡略化（必要に応じて別途取得）
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

**チェックリスト**:
- [ ] PokemonModelMapper.swiftを作成
- [ ] toModel()の実装
- [ ] toDomain()の実装
- [ ] ビルドが通ることを確認

#### ステップ1-3: ModelContainerのセットアップ

**ファイル**: `PokedexApp.swift`（既存ファイルの修正）

```swift
import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    // ModelContainerを追加
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

**チェックリスト**:
- [ ] PokedexApp.swiftにModelContainerを追加
- [ ] .modelContainer()モディファイアを設定
- [ ] ビルドが通ることを確認

#### ステップ1-4: PokemonRepositoryのSwiftData対応

**ファイル**: `Data/Repositories/PokemonRepository.swift`（既存ファイルの修正）

**変更前**:
```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient = PokemonAPIClient()

    // インメモリキャッシュ（問題の原因）
    private var cache: [Int: Pokemon] = [:]
    private var versionGroupCaches: [String: [Pokemon]] = [:]
    // ...
}
```

**変更後**:
```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient = PokemonAPIClient()
    private let modelContext: ModelContext  // ← 追加

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchPokemonList(
        versionGroup: VersionGroup,
        progressHandler: ((Double) -> Void)?
    ) async throws -> [Pokemon] {
        // 1. SwiftDataから取得を試みる
        let descriptor = FetchDescriptor<PokemonModel>(
            sortBy: [SortDescriptor(\.id)]
        )

        let cachedModels = try modelContext.fetch(descriptor)

        if !cachedModels.isEmpty {
            // キャッシュがあれば返す
            return cachedModels.map { PokemonModelMapper.toDomain($0) }
        }

        // 2. キャッシュがなければAPIから取得
        let pokemons = try await apiClient.fetchPokemonList(
            idRange: versionGroup.idRange,
            progressHandler: progressHandler
        )

        // 3. SwiftDataに保存
        for pokemon in pokemons {
            let model = PokemonModelMapper.toModel(pokemon)
            modelContext.insert(model)
        }

        try modelContext.save()

        return pokemons
    }

    func clearCache() {
        // SwiftDataの全データを削除
        do {
            try modelContext.delete(model: PokemonModel.self)
            try modelContext.save()
        } catch {
            print("Failed to clear cache: \(error)")
        }
    }
}
```

**チェックリスト**:
- [ ] PokemonRepositoryにmodelContextを追加
- [ ] fetchPokemonList()をSwiftData対応に変更
- [ ] clearCache()をSwiftData対応に変更
- [ ] ビルドが通ることを確認

#### ステップ1-5: DIContainerの更新

**ファイル**: `Application/DIContainer.swift`（既存ファイルの修正）

```swift
final class DIContainer: ObservableObject {
    static let shared = DIContainer()

    // ModelContextを保持
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Repositories
    private lazy var pokemonRepository: PokemonRepositoryProtocol = {
        guard let modelContext = modelContext else {
            fatalError("ModelContext not set. Call setModelContext() first.")
        }
        return PokemonRepository(modelContext: modelContext)
    }()

    // ...（他のコードは既存のまま）
}
```

**ファイル**: `ContentView.swift`（既存ファイルの修正）

```swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        PokemonListView()
            .onAppear {
                DIContainer.shared.setModelContext(modelContext)
            }
    }
}
```

**チェックリスト**:
- [ ] DIContainerにmodelContext設定機能を追加
- [ ] ContentView.swiftでmodelContextを渡す
- [ ] ビルドが通ることを確認

#### ステップ1-6: 動作確認

**確認項目**:
1. **初回起動**:
   - [ ] 全ポケモンを取得（60-90秒かかるがOK）
   - [ ] 進捗が表示される
   - [ ] ポケモンリストが表示される

2. **2回目起動**:
   - [ ] 1秒以内にポケモンリストが表示される
   - [ ] 以前と同じポケモンが表示される

3. **キャッシュクリア**:
   - [ ] clearCache()で全データが削除される
   - [ ] 再起動後、再度取得が必要になる

4. **オフライン**:
   - [ ] 機内モードでもポケモンリストが表示される
   - [ ] 詳細画面も表示される

---

## Phase 2: プリバンドルデータベース

### 目標

- 初回起動から全データを即座に使用可能に
- アプリサイズ増加を抑える（目標: 20MB以下）
- データ更新時の差分取得

### 実装手順

#### ステップ2-1: データ生成スクリプト作成

**ファイル**: `Scripts/GenerateDatabase.swift`（新規）

```swift
import Foundation
import SwiftData

/// プリバンドル用のデータベースを生成するスクリプト
@main
struct GenerateDatabase {
    static func main() async throws {
        print("🚀 Generating preloaded database...")

        // 1. ModelContainerを作成
        let container = try ModelContainer(
            for: PokemonModel.self,
            configurations: ModelConfiguration(
                url: URL(fileURLWithPath: "Resources/PreloadedData/Pokedex.sqlite")
            )
        )

        let context = ModelContext(container)

        // 2. 全ポケモンを取得
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

        // 3. 最終保存
        try context.save()
        print("✅ Database generation completed: \(fetchedCount) Pokemon")
    }
}
```

**実行方法**:
```bash
# Package.swiftにToolsターゲット追加後
swift run GenerateDatabase
```

**チェックリスト**:
- [ ] Scripts/GenerateDatabase.swiftを作成
- [ ] Package.swiftにToolsターゲットを追加
- [ ] スクリプトを実行してPokedex.sqliteを生成
- [ ] ファイルサイズが20MB以下であることを確認

#### ステップ2-2: プリバンドルDBの組み込み

**ディレクトリ構成**:
```
Pokedex/
├── Resources/
│   └── PreloadedData/
│       └── Pokedex.sqlite  ← 生成したファイルを配置
```

**ファイル**: `Data/Repositories/PokemonRepository.swift`（修正）

```swift
func fetchPokemonList(
    versionGroup: VersionGroup,
    progressHandler: ((Double) -> Void)?
) async throws -> [Pokemon] {
    // 1. SwiftDataから取得を試みる
    let descriptor = FetchDescriptor<PokemonModel>(
        sortBy: [SortDescriptor(\.id)]
    )

    let cachedModels = try modelContext.fetch(descriptor)

    if !cachedModels.isEmpty {
        return cachedModels.map { PokemonModelMapper.toDomain($0) }
    }

    // 2. プリバンドルDBをコピー（初回のみ）
    if await copyPreloadedDatabaseIfNeeded() {
        // コピー成功したら再読み込み
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
        let model = PokemonModelMapper.toModel(pokemon)
        modelContext.insert(model)
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

    // 既にコピー済みならスキップ
    if fileManager.fileExists(atPath: targetURL.path) {
        return false
    }

    // バンドルからコピー
    guard let bundleURL = Bundle.main.url(forResource: "Pokedex", withExtension: "sqlite", subdirectory: "PreloadedData") else {
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
```

**チェックリスト**:
- [ ] Resources/PreloadedData/にPokedex.sqliteを配置
- [ ] Xcodeプロジェクトにファイルを追加（ターゲットに含める）
- [ ] copyPreloadedDatabaseIfNeeded()を実装
- [ ] ビルドサイズが適切か確認（+20MB程度）

#### ステップ2-3: 動作確認

**確認項目**:
1. **初回起動（プリバンドルDB有効）**:
   - [ ] 1秒以内にポケモンリストが表示される
   - [ ] 全1025匹が表示される
   - [ ] API呼び出しが発生していない

2. **差分更新**:
   - [ ] バージョンアップ時に新ポケモンのみ取得
   - [ ] 既存ポケモンは再取得しない

---

## Phase 3: バージョン固有データ対応

### 目標

- ゲームによって異なるタイプ・特性に対応
- 地方図鑑（カントー、ジョウト、ガラル、パルデアなど）に対応
- 正確なポケモンデータを提供

### 実装手順

#### ステップ3-1: スキーマ拡張

**ファイル**: `Data/Persistence/PokemonModel.swift`（拡張）

```swift
@Model
final class PokemonModel {
    @Attribute(.unique) var id: Int
    var speciesId: Int
    var name: String
    var height: Int
    var weight: Int

    // 全国図鑑用（デフォルト）
    @Relationship(deleteRule: .cascade) var types: [PokemonTypeModel]
    @Relationship(deleteRule: .cascade) var stats: [PokemonStatModel]
    @Relationship(deleteRule: .cascade) var abilities: [PokemonAbilityModel]
    @Relationship(deleteRule: .cascade) var sprites: PokemonSpriteModel?

    // バージョン固有データ（新規）
    @Relationship(deleteRule: .cascade) var variants: [PokemonVersionVariant]

    var moveIds: [Int]
    var availableGenerations: [Int]
    var fetchedAt: Date

    // ...
}

@Model
final class PokemonVersionVariant {
    var versionGroupId: String  // "red-blue", "gold-silver", "scarlet-violet"

    // バージョン固有のタイプ
    @Relationship(deleteRule: .cascade) var types: [PokemonTypeModel]

    // バージョン固有の特性
    @Relationship(deleteRule: .cascade) var abilities: [PokemonAbilityModel]

    // バージョン固有のスプライト
    var spriteUrl: String?
    var shinyUrl: String?

    // 所属する図鑑エントリー
    @Relationship(deleteRule: .cascade) var pokedexEntries: [PokedexEntryModel]

    var pokemon: PokemonModel?

    init(versionGroupId: String) {
        self.versionGroupId = versionGroupId
    }
}

@Model
final class PokedexModel {
    @Attribute(.unique) var id: String  // "national", "kanto", "johto"
    var name: String
    var region: String?
    var versionGroupIds: [String]

    @Relationship(deleteRule: .cascade) var entries: [PokedexEntryModel]

    init(id: String, name: String, region: String?, versionGroupIds: [String]) {
        self.id = id
        self.name = name
        self.region = region
        self.versionGroupIds = versionGroupIds
    }
}

@Model
final class PokedexEntryModel {
    var entryNumber: Int
    var pokedex: PokedexModel?
    var variant: PokemonVersionVariant?

    init(entryNumber: Int) {
        self.entryNumber = entryNumber
    }
}
```

**チェックリスト**:
- [ ] PokemonVersionVariantモデルを追加
- [ ] PokedexModelを追加
- [ ] PokedexEntryModelを追加
- [ ] PokemonModelにvariantsリレーションを追加

#### ステップ3-2: マイグレーション設定

```swift
enum PokemonSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [PokemonModel.self, /* ... */]
    }
}

enum PokemonSchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    static var models: [any PersistentModel.Type] {
        [PokemonModel.self, PokemonVersionVariant.self, PokedexModel.self, /* ... */]
    }
}

enum PokemonMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [PokemonSchemaV1.self, PokemonSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }

    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: PokemonSchemaV1.self,
        toVersion: PokemonSchemaV2.self
    )
}
```

**チェックリスト**:
- [ ] スキーマバージョニング設定
- [ ] マイグレーションプラン定義
- [ ] 既存データの移行確認

---

## Phase 4: モジュール化

### 目標

- Data層とDomain層をSwift Packageとして分離
- SwiftUI版とUIKit版で共有可能にする
- Presentation層のみをアプリ固有にする

### モジュール構成

```
PokedexCore/
├── Package.swift
├── Sources/
│   ├── Domain/
│   │   ├── Entities/
│   │   ├── UseCases/
│   │   └── Protocols/
│   ├── Data/
│   │   ├── Repositories/
│   │   ├── Network/
│   │   ├── Persistence/
│   │   └── DTOs/
│   └── Presentation/
│       └── ViewModels/
└── Tests/

Pokedex-SwiftUI/
├── Views/
│   ├── PokemonListView.swift
│   ├── PokemonDetailView.swift
│   └── Components/
└── App/
    └── PokedexApp.swift

Pokedex-UIKit/  (将来)
├── ViewControllers/
│   ├── PokemonListViewController.swift
│   └── PokemonDetailViewController.swift
└── App/
    └── AppDelegate.swift
```

### Package.swift設定

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PokedexCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Data", targets: ["Data"]),
        .library(name: "Presentation", targets: ["Presentation"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kinkofer/PokemonAPI.git", from: "6.0.0"),
    ],
    targets: [
        .target(name: "Domain", dependencies: []),
        .target(name: "Data", dependencies: ["Domain", "PokemonAPI"]),
        .target(name: "Presentation", dependencies: ["Domain", "Data"]),

        .testTarget(name: "DomainTests", dependencies: ["Domain"]),
        .testTarget(name: "DataTests", dependencies: ["Data"]),
    ]
)
```

**チェックリスト**:
- [ ] PokedexCoreパッケージを作成
- [ ] Domain/Data/Presentationを分離
- [ ] SwiftUI/UIKit両方から参照可能にする

---

## テスト戦略

### Phase 1: SwiftData永続化のテスト

```swift
final class PokemonRepositoryTests: XCTestCase {
    var repository: PokemonRepository!
    var modelContext: ModelContext!

    override func setUp() async throws {
        // インメモリコンテナでテスト
        let container = try ModelContainer(
            for: PokemonModel.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        modelContext = ModelContext(container)
        repository = PokemonRepository(modelContext: modelContext)
    }

    func test_fetchPokemonList_cachesData() async throws {
        // 1回目: APIから取得
        let pokemons1 = try await repository.fetchPokemonList(
            versionGroup: .nationalDex,
            progressHandler: nil
        )

        XCTAssertFalse(pokemons1.isEmpty)

        // 2回目: キャッシュから取得
        let pokemons2 = try await repository.fetchPokemonList(
            versionGroup: .nationalDex,
            progressHandler: nil
        )

        XCTAssertEqual(pokemons1.count, pokemons2.count)
    }

    func test_clearCache_removesAllData() throws {
        // データを挿入
        let model = PokemonModel(id: 1, speciesId: 1, name: "bulbasaur", height: 7, weight: 69)
        modelContext.insert(model)
        try modelContext.save()

        // クリア
        repository.clearCache()

        // 確認
        let descriptor = FetchDescriptor<PokemonModel>()
        let models = try modelContext.fetch(descriptor)
        XCTAssertTrue(models.isEmpty)
    }
}
```

---

## トラブルシューティング

### 問題1: ビルドエラー "Cannot find type 'PokemonModel'"

**原因**: SwiftDataモデルがターゲットに含まれていない

**解決策**:
1. Xcodeで該当ファイルを選択
2. File Inspector → Target Membership を確認
3. アプリターゲットにチェックを入れる

### 問題2: "Failed to initialize ModelContainer"

**原因**: スキーマ定義にエラーがある

**解決策**:
1. @Modelマクロが全てのクラスに付いているか確認
2. @Relationship の親子関係が正しいか確認
3. クリーンビルド（Cmd+Shift+K）

### 問題3: データが永続化されない

**原因**: modelContext.save()を忘れている

**解決策**:
```swift
modelContext.insert(model)
try modelContext.save()  // ← 必須
```

### 問題4: プリバンドルDBが読み込まれない

**原因**: ファイルがバンドルに含まれていない

**解決策**:
1. Xcodeでファイルを選択
2. File Inspector → Target Membership を確認
3. Build Phases → Copy Bundle Resources に含まれているか確認

---

## 成功基準

### Phase 1完了時

- [ ] 2回目以降の起動が1秒以内
- [ ] オフラインでもポケモンリスト表示
- [ ] キャッシュクリアが動作
- [ ] 全テストが通過

### Phase 2完了時

- [ ] 初回起動が1秒以内
- [ ] アプリサイズ増加が20MB以下
- [ ] 差分更新が動作

### Phase 3完了時

- [ ] バージョン固有タイプが正しく表示
- [ ] 地方図鑑が正しく表示
- [ ] マイグレーションが正常動作

### Phase 4完了時

- [ ] PokedexCoreパッケージが独立動作
- [ ] SwiftUI版が正常動作
- [ ] UIKit版の準備完了

---

## 参考リンク

- [SwiftData公式ドキュメント](https://developer.apple.com/documentation/swiftdata)
- [SwiftData Migration Guide](https://developer.apple.com/documentation/swiftdata/migrating-your-app-to-swiftdata)
- [PokéAPI Documentation](https://pokeapi.co/docs/v2)
