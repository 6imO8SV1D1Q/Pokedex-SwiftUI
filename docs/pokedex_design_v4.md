# Pokédex SwiftUI - 設計書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-11

---

## 📋 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [Phase 1: SwiftData永続化](#phase-1-swiftdata永続化)
3. [Phase 2: プリバンドルデータベース](#phase-2-プリバンドルデータベース)
4. [Phase 3: 技・特性データモデル](#phase-3-技特性データモデル)
5. [Phase 4以降](#phase-4以降)
6. [データフロー](#データフロー-phase-2完了後)
7. [エラーハンドリング](#エラーハンドリング)

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
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int           // Pokemon ID (主キー)
    var nationalDexNumber: Int                // 全国図鑑番号
    var name: String                          // 英語名
    var nameJa: String                        // 日本語名
    var genus: String                         // 分類（英語）
    var genusJa: String                       // 分類（日本語）

    var height: Int                           // 身長（デシメートル）
    var weight: Int                           // 体重（ヘクトグラム）
    var category: String                      // 区分: normal/legendary/mythical

    // MARK: - Game Data

    var types: [String]                       // タイプ配列 ["electric"]
    var eggGroups: [String]                   // タマゴグループ
    var genderRate: Int                       // 性別比（-1=性別なし、0=オスのみ、8=メスのみ）

    // MARK: - Abilities

    var primaryAbilities: [Int]               // 通常特性IDリスト
    var hiddenAbility: Int?                   // 隠れ特性ID（nullable）

    // MARK: - Stats

    @Relationship(deleteRule: .cascade) var baseStats: PokemonBaseStatsModel?

    // MARK: - Sprites

    @Relationship(deleteRule: .cascade) var sprites: PokemonSpriteModel?

    // MARK: - Moves

    @Relationship(deleteRule: .cascade) var moves: [PokemonLearnedMoveModel]

    // MARK: - Evolution

    @Relationship(deleteRule: .cascade) var evolutionChain: PokemonEvolutionModel?

    // MARK: - Varieties & Pokedex

    var varieties: [Int]                      // 関連フォームID配列
    var pokedexNumbers: [String: Int]         // 地方図鑑番号辞書 {"paldea": 25}

    // MARK: - Cache

    var fetchedAt: Date                       // キャッシュ日時

    init(id: Int, nationalDexNumber: Int, name: String, nameJa: String,
         genus: String, genusJa: String, height: Int, weight: Int,
         category: String, types: [String], eggGroups: [String], genderRate: Int,
         primaryAbilities: [Int], hiddenAbility: Int? = nil,
         baseStats: PokemonBaseStatsModel? = nil, sprites: PokemonSpriteModel? = nil,
         moves: [PokemonLearnedMoveModel] = [], evolutionChain: PokemonEvolutionModel? = nil,
         varieties: [Int] = [], pokedexNumbers: [String: Int] = [:],
         fetchedAt: Date = Date()) {
        self.id = id
        self.nationalDexNumber = nationalDexNumber
        self.name = name
        self.nameJa = nameJa
        self.genus = genus
        self.genusJa = genusJa
        self.height = height
        self.weight = weight
        self.category = category
        self.types = types
        self.eggGroups = eggGroups
        self.genderRate = genderRate
        self.primaryAbilities = primaryAbilities
        self.hiddenAbility = hiddenAbility
        self.baseStats = baseStats
        self.sprites = sprites
        self.moves = moves
        self.evolutionChain = evolutionChain
        self.varieties = varieties
        self.pokedexNumbers = pokedexNumbers
        self.fetchedAt = fetchedAt
    }
}
```

**関連モデル**:

```swift
@Model
final class PokemonBaseStatsModel {
    var hp: Int                               // HP種族値
    var attack: Int                           // 攻撃種族値
    var defense: Int                          // 防御種族値
    var spAttack: Int                         // 特攻種族値
    var spDefense: Int                        // 特防種族値
    var speed: Int                            // 素早さ種族値
    var total: Int                            // 合計種族値
    var pokemon: PokemonModel?                // 親ポケモン

    init(hp: Int, attack: Int, defense: Int, spAttack: Int,
         spDefense: Int, speed: Int, total: Int) {
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.spAttack = spAttack
        self.spDefense = spDefense
        self.speed = speed
        self.total = total
    }
}

@Model
final class PokemonSpriteModel {
    var normal: String                        // 通常画像URL
    var shiny: String                         // 色違い画像URL
    var pokemon: PokemonModel?                // 親ポケモン

    init(normal: String, shiny: String) {
        self.normal = normal
        self.shiny = shiny
    }
}

@Model
final class PokemonLearnedMoveModel {
    var moveId: Int                           // 技ID
    var learnMethod: String                   // 習得方法: level-up/machine/egg/tutor
    var level: Int?                           // 習得レベル（level-upの場合）
    var machineNumber: String?                // わざマシン番号（machineの場合、例: "TM126"）
    var pokemon: PokemonModel?                // 親ポケモン

    init(moveId: Int, learnMethod: String, level: Int? = nil, machineNumber: String? = nil) {
        self.moveId = moveId
        self.learnMethod = learnMethod
        self.level = level
        self.machineNumber = machineNumber
    }
}

@Model
final class PokemonEvolutionModel {
    var chainId: Int                          // 進化チェーンID
    var evolutionStage: Int                   // 進化段階（1=初期、2=第1進化、3=第2進化）
    var evolvesFrom: Int?                     // 進化前のポケモンID
    var evolvesTo: [Int]                      // 進化先のポケモンID配列
    var canUseEviolite: Bool                  // しんかのきせき適用可能フラグ
    var pokemon: PokemonModel?                // 親ポケモン

    init(chainId: Int, evolutionStage: Int, evolvesFrom: Int? = nil,
         evolvesTo: [Int] = [], canUseEviolite: Bool) {
        self.chainId = chainId
        self.evolutionStage = evolutionStage
        self.evolvesFrom = evolvesFrom
        self.evolvesTo = evolvesTo
        self.canUseEviolite = canUseEviolite
    }
}
```

**ER図**:

```
PokemonModel (1) ──┬── (1) PokemonBaseStatsModel
                   ├── (1) PokemonSpriteModel
                   ├── (N) PokemonLearnedMoveModel
                   └── (1) PokemonEvolutionModel
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
                     PokemonBaseStatsModel.self,
                     PokemonSpriteModel.self,
                     PokemonLearnedMoveModel.self,
                     PokemonEvolutionModel.self,
                     MoveModel.self,
                     MoveMetaModel.self,
                     AbilityModel.self,
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

### 2.1 データ生成アプローチ

**アプローチ: JSON → SwiftData初回読み込み**

Phase 2では、SQLiteデータベースを直接生成する代わりに、以下のアプローチを採用:

1. **JSON生成ツール** (`GenerateScarletVioletData.swift`):
   - PokéAPIから全データ取得
   - JSON形式で保存 (`scarlet_violet.json`)
   - 出力先: `Resources/PreloadedData/scarlet_violet.json`

2. **初回起動時の読み込み**:
   - JSONファイルをバンドルから読み込み
   - SwiftDataモデルに変換して永続化
   - 2回目以降はSwiftDataから直接読み込み

**メリット**:
- JSONは人間が読みやすく、デバッグが容易
- バージョン管理が容易
- データ更新時の差分確認が簡単
- SwiftDataスキーマ変更に強い（再生成が不要）

**GenerateScarletVioletData.swift** の概要:

```swift
#!/usr/bin/env swift

import Foundation

// データ構造定義
struct GameData: Codable {
    let dataVersion: String
    let lastUpdated: String
    let versionGroup: String
    let versionGroupId: Int
    let generation: Int
    var pokemon: [PokemonData]
    let moves: [MoveData]
    let abilities: [AbilityData]
}

struct PokemonData: Codable {
    let id: Int
    let nationalDexNumber: Int
    let name: String
    let nameJa: String
    let genus: String
    let genusJa: String
    let sprites: SpriteData
    let types: [String]
    let abilities: AbilitySet
    let baseStats: BaseStats
    var moves: [LearnedMove]
    let eggGroups: [String]
    let genderRate: Int
    let height: Int
    let weight: Int
    let evolutionChain: EvolutionInfo
    let varieties: [Int]
    let pokedexNumbers: [String: Int]
    let category: String
}

// PokéAPIから全データ取得してJSONに保存
// 詳細: Tools/GenerateScarletVioletData.swift
```

**実行方法**:

```bash
swift Tools/GenerateScarletVioletData.swift
```

**出力**:
- `Resources/PreloadedData/scarlet_violet.json` (約7.4 MB)
- 866ポケモン、680技、269特性
- 日本語翻訳完備

### 2.2 JSONファイルの組み込み

**ディレクトリ構成**:
```
Pokedex/
├── Resources/
│   └── PreloadedData/
│       └── scarlet_violet.json  // 生成したJSONファイル（約7.4 MB）
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
            // キャッシュあり → Domainに変換して返す
            return cachedModels.map { PokemonModelMapper.toDomain($0) }
        }

        // 2. プリバンドルJSONから読み込み（初回のみ）
        if let jsonData = loadPreloadedJSON() {
            let decoder = JSONDecoder()
            let gameData = try decoder.decode(GameData.self, from: jsonData)

            // SwiftDataに保存
            for pokemonData in gameData.pokemon {
                let model = PokemonModelMapper.fromJSON(pokemonData)
                modelContext.insert(model)
            }

            // 技データも保存
            for moveData in gameData.moves {
                let model = MoveModelMapper.fromJSON(moveData)
                modelContext.insert(model)
            }

            // 特性データも保存
            for abilityData in gameData.abilities {
                let model = AbilityModelMapper.fromJSON(abilityData)
                modelContext.insert(model)
            }

            try modelContext.save()

            // 再読み込み
            let models = try modelContext.fetch(descriptor)
            return models.map { PokemonModelMapper.toDomain($0) }
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

    private func loadPreloadedJSON() -> Data? {
        guard let bundleURL = Bundle.main.url(
            forResource: "scarlet_violet",
            withExtension: "json",
            subdirectory: "PreloadedData"
        ) else {
            print("⚠️ Preloaded JSON not found in bundle")
            return nil
        }

        do {
            let data = try Data(contentsOf: bundleURL)
            print("✅ Preloaded JSON loaded (\(data.count / 1024 / 1024) MB)")
            return data
        } catch {
            print("⚠️ Failed to load preloaded JSON: \(error)")
            return nil
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

## Phase 3: 技・特性データモデル

### 目標

- 技データ・特性データを永続化
- 日本語対応完了
- 技フィルターの高速化

### 3.1 MoveModel

```swift
@Model
final class MoveModel {
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int           // 技ID（主キー）
    var name: String                          // 英語名
    var nameJa: String                        // 日本語名

    // MARK: - Type & Category

    var type: String                          // タイプ
    var damageClass: String                   // 分類: physical/special/status

    // MARK: - Stats

    var power: Int?                           // 威力（nullable）
    var accuracy: Int?                        // 命中率（nullable）
    var pp: Int                               // PP
    var priority: Int                         // 優先度

    // MARK: - Effect

    var effectChance: Int?                    // 追加効果発動率
    var effect: String                        // 効果説明（英語）
    var effectJa: String                      // 効果説明（日本語）

    // MARK: - Meta

    @Relationship(deleteRule: .cascade) var meta: MoveMetaModel?

    init(id: Int, name: String, nameJa: String, type: String, damageClass: String,
         power: Int? = nil, accuracy: Int? = nil, pp: Int, priority: Int,
         effectChance: Int? = nil, effect: String, effectJa: String,
         meta: MoveMetaModel? = nil) {
        self.id = id
        self.name = name
        self.nameJa = nameJa
        self.type = type
        self.damageClass = damageClass
        self.power = power
        self.accuracy = accuracy
        self.pp = pp
        self.priority = priority
        self.effectChance = effectChance
        self.effect = effect
        self.effectJa = effectJa
        self.meta = meta
    }
}

@Model
final class MoveMetaModel {
    var ailment: String                       // 状態異常種類
    var ailmentChance: Int                    // 状態異常発動率
    var category: String                      // カテゴリ
    var critRate: Int                         // 急所ランク
    var drain: Int                            // HP吸収率
    var flinchChance: Int                     // ひるみ確率
    var healing: Int                          // HP回復率
    var statChance: Int                       // 能力変化確率
    var statChanges: [MoveStatChange]         // 能力変化リスト
    var move: MoveModel?                      // 親技

    init(ailment: String, ailmentChance: Int, category: String, critRate: Int,
         drain: Int, flinchChance: Int, healing: Int, statChance: Int,
         statChanges: [MoveStatChange] = []) {
        self.ailment = ailment
        self.ailmentChance = ailmentChance
        self.category = category
        self.critRate = critRate
        self.drain = drain
        self.flinchChance = flinchChance
        self.healing = healing
        self.statChance = statChance
        self.statChanges = statChanges
    }
}

struct MoveStatChange: Codable {
    var stat: String                          // 能力名
    var change: Int                           // 変化量

    init(stat: String, change: Int) {
        self.stat = stat
        self.change = change
    }
}
```

### 3.2 AbilityModel

```swift
@Model
final class AbilityModel {
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int           // 特性ID（主キー）
    var name: String                          // 英語名
    var nameJa: String                        // 日本語名

    // MARK: - Effect

    var effect: String                        // 効果説明（英語）
    var effectJa: String                      // 効果説明（日本語）

    init(id: Int, name: String, nameJa: String, effect: String, effectJa: String) {
        self.id = id
        self.name = name
        self.nameJa = nameJa
        self.effect = effect
        self.effectJa = effectJa
    }
}
```

---

## Phase 4以降

**Phase 4: バージョン固有データ対応** - PokemonVersionVariantモデル追加、地方図鑑対応

**Phase 5: モジュール化** - PokedexCoreパッケージ作成、Domain/Data/Presentation層の分離

**Phase 6: UI/UX改善** - アニメーション、詳細画面拡充

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
| 2025-10-11 | 3.0 | JSONベースのアプローチに変更、全モデルをJSONデータ構造に合わせて更新、日本語フィールド追加、技・特性モデル追加 |
