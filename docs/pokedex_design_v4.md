# Pokédex SwiftUI - 設計書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-01-13

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

### v4.0の設計方針（実装完了）

1. **SwiftData中心の永続化**: インメモリキャッシュを廃止し、全てSwiftDataで永続化 ✅
2. **プリバンドルJSON**: 初回起動から全データ利用可能（約7.4MB） ✅
3. **埋め込みモデル**: `@Relationship`を避け、`Codable` structで埋め込み（18秒 → 1秒以内） ✅
4. **図鑑データ永続化**: PokedexModelでAPI呼び出しを削減 ✅
5. **スキーマバージョン管理**: 自動マイグレーション機能（`v4.1-embedded`） ✅

### 新規追加コンポーネント

| コンポーネント | 責務 | Phase | 状態 |
|--------------|------|-------|------|
| PokemonModel | SwiftDataモデル（埋め込み型） | 1 | ✅ |
| PokemonModelMapper | Domain ↔ SwiftData変換 | 1 | ✅ |
| PokedexModel | 図鑑データのSwiftDataモデル | 2 | ✅ |
| MoveModel | 技データのSwiftDataモデル | 3 | ✅ |
| AbilityModel | 特性データのSwiftDataモデル | 3 | ✅ |
| GenerateScarletVioletData | プリバンドルJSON生成ツール | 2 | ✅ |
| PreloadedDataLoader | JSON読み込み処理 | 2 | ✅ |
| LocalizationManager | 日本語対応 | 3 | ✅ |
| SettingsView | 言語設定UI | 3 | ✅ |
| FilterMode | OR/AND切り替えenum | 4 | ✅ |
| PokedexType | 図鑑区分enum | 4 | ✅ |

---

## Phase 1: SwiftData永続化 ✅ 完了

### 目標

- 取得したポケモンデータをディスクに永続化 ✅
- アプリ再起動後もデータを保持 ✅
- 2回目以降の起動を1秒以内に短縮 ✅
- **追加達成**: データ変換時間を18秒から1秒以内に短縮 ✅

### 1.1 SwiftDataモデル設計（埋め込み型）

**設計方針の変更**:
1. Domain層のPokemonエンティティと1:1対応するSwiftDataモデルを作成 ✅
2. ~~リレーションシップを活用して正規化~~ → **埋め込み型に変更**
3. `@Attribute(.unique)`で一意制約を設定 ✅
4. ~~`@Relationship(deleteRule: .cascade)`で親子関係を管理~~ → **`Codable` structで埋め込み**

**変更理由**:
- `@Relationship`による遅延ロードで86,600+の技習得データ取得に18秒かかっていた
- `Codable` structで直接埋め込むことで、遅延ロードを回避
- 結果: データ変換時間が18秒から1秒以内に改善

**PokemonModel（埋め込み型）**:

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

    // MARK: - Embedded Models (Codable struct - @Relationshipなし)

    var baseStats: PokemonBaseStatsModel?     // 種族値（埋め込み）
    var sprites: PokemonSpriteModel?          // 画像URL（埋め込み）
    var moves: [PokemonLearnedMoveModel]      // 技習得情報（埋め込み、86,600+レコード）
    var evolutionChain: PokemonEvolutionModel? // 進化情報（埋め込み）

    // MARK: - Varieties & Pokedex

    var varieties: [Int]                      // 関連フォームID配列
    var pokedexNumbers: [String: Int]         // 地方図鑑番号辞書 {"paldea": 25}

    // MARK: - Cache

    var fetchedAt: Date                       // キャッシュ日時
}
```

**埋め込みモデル（Codable struct）**:

```swift
// 種族値（埋め込み型）
struct PokemonBaseStatsModel: Codable {
    var hp: Int                               // HP種族値
    var attack: Int                           // 攻撃種族値
    var defense: Int                          // 防御種族値
    var spAttack: Int                         // 特攻種族値
    var spDefense: Int                        // 特防種族値
    var speed: Int                            // 素早さ種族値
    var total: Int                            // 合計種族値
}

// 画像URL（埋め込み型）
struct PokemonSpriteModel: Codable {
    var normal: String                        // 通常画像URL
    var shiny: String                         // 色違い画像URL
}

// 技習得情報（埋め込み型）
// 重要: これを@Relationshipにすると18秒のボトルネックになる
struct PokemonLearnedMoveModel: Codable {
    var pokemonId: Int                        // ポケモンID
    var moveId: Int                           // 技ID
    var learnMethod: String                   // 習得方法: level-up/machine/egg/tutor
    var level: Int?                           // 習得レベル（level-upの場合）
    var machineNumber: String?                // わざマシン番号（machineの場合、例: "TM126"）
}

// 進化情報（埋め込み型）
struct PokemonEvolutionModel: Codable {
    var chainId: Int                          // 進化チェーンID
    var evolutionStage: Int                   // 進化段階（1=初期、2=第1進化、3=第2進化）
    var evolvesFrom: Int?                     // 進化前のポケモンID
    var evolvesTo: [Int]                      // 進化先のポケモンID配列
    var canUseEviolite: Bool                  // しんかのきせき適用可能フラグ
}
```

**データ構造**:

```
PokemonModel (1つのモデル内に全データ埋め込み)
├── baseStats: PokemonBaseStatsModel? (struct、埋め込み)
├── sprites: PokemonSpriteModel? (struct、埋め込み)
├── moves: [PokemonLearnedMoveModel] (struct配列、埋め込み、100件/匹)
└── evolutionChain: PokemonEvolutionModel? (struct、埋め込み)
```

**パフォーマンス比較**:

| 項目 | @Relationship | 埋め込み型 |
|------|--------------|----------|
| データ取得 | 遅延ロード（86,600+クエリ） | 一括取得 |
| 変換時間 | 18秒 | 1秒以内 |
| 構造 | 正規化（5テーブル） | 非正規化（1テーブル） |
| クエリ | 複数JOINが必要 | 単一SELECT |

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

### 1.4 ModelContainer セットアップと自動マイグレーション

**PokedexApp.swift**（実装版）:

```swift
import SwiftUI
import SwiftData

@main
struct PokedexApp: App {
    let modelContainer: ModelContainer

    init() {
        // スキーマ定義（埋め込みモデルのstructは含まない）
        let schema = Schema([
            PokemonModel.self,      // メインモデルのみ
            MoveModel.self,
            MoveMetaModel.self,
            AbilityModel.self,
            PokedexModel.self       // 図鑑データ
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            // 通常の初期化
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // マイグレーション失敗時の自動クリーンアップ
            print("⚠️ ModelContainer initialization failed: \(error)")
            print("🔄 Deleting old store and retrying...")

            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-shm"))
            try? FileManager.default.removeItem(at: storeURL.deletingPathExtension().appendingPathExtension("store-wal"))

            // 再試行
            do {
                modelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                print("✅ ModelContainer recreated successfully")
            } catch {
                fatalError("Failed to initialize ModelContainer: \(error)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
                .environmentObject(LocalizationManager.shared)
        }
    }
}
```

**スキーマバージョン管理**:

```swift
// PokemonRepository.swift
let currentSchemaVersion = "v4.1-embedded"
let savedSchemaVersion = UserDefaults.standard.string(forKey: "swiftdata_schema_version")
let isSchemaChanged = savedSchemaVersion != currentSchemaVersion

if isSchemaChanged {
    print("📦 Schema changed: \(savedSchemaVersion ?? "nil") → \(currentSchemaVersion)")
    // スキーマ変更を記録
    UserDefaults.standard.set(currentSchemaVersion, forKey: "swiftdata_schema_version")
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
    ├→ 2. プリバンドルJSON読み込み（scarlet_violet.json）
    │     - 866ポケモン、680技、269特性、3図鑑
    │     - PreloadedDataLoader.loadPreloadedDataIfNeeded()
    ├→ 3. SwiftDataに保存（進捗表示付き）
    │     ├→ 0%: JSONパース開始
    │     ├→ 10%: ポケモンデータ保存開始
    │     ├→ 45%: 図鑑データ保存完了
    │     ├→ 80%: 技・特性データ保存完了
    │     └→ 100%: 完了
    ├→ 4. PokemonModelMapper.toDomain()（1秒以内）
    └→ 5. 即座に返却
    ↓
User: ポケモンリスト表示（1秒以内）
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
    ├→ 2. PokemonModelMapper.toDomain()（1秒以内、埋め込み型で高速）
    └→ 3. 即座に返却
    ↓
User: ポケモンリスト表示（1秒以内）
```

---

## Phase 2: プリバンドルJSON ✅ 完了

### 目標

- Scarlet/Violet対象の866ポケモンのデータを事前生成してアプリに同梱 ✅
- 初回起動から1秒以内でデータ表示 ✅
- 完全オフライン対応 ✅
- **追加達成**: 図鑑データの永続化でAPI呼び出しを削減 ✅

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

### 2.3 PokedexModelの追加

**目的**: 図鑑データ（paldea, kitakami, blueberry）をSwiftDataで永続化し、API呼び出しを削減

**PokedexModel**:

```swift
@Model
final class PokedexModel {
    @Attribute(.unique) var name: String      // 図鑑名（paldea, kitakami, blueberry）
    var speciesIds: [Int]                     // 含まれるポケモンのspecies ID配列

    init(name: String, speciesIds: [Int]) {
        self.name = name
        self.speciesIds = speciesIds
    }
}
```

**データ生成ツール**:

```python
# Tools/add_pokedex_data.py
import json
import requests

POKEDEX_NAMES = ["paldea", "kitakami", "blueberry"]

def fetch_pokedex(pokedex_name):
    url = f"https://pokeapi.co/api/v2/pokedex/{pokedex_name}"
    response = requests.get(url)
    data = response.json()

    species_ids = [int(entry["pokemon_species"]["url"].rstrip("/").split("/")[-1])
                   for entry in data["pokemon_entries"]]

    return {
        "name": pokedex_name,
        "speciesIds": sorted(species_ids)
    }

# JSONに追加
pokedexes = [fetch_pokedex(name) for name in POKEDEX_NAMES]
data["pokedexes"] = pokedexes
```

**実行結果**:

```json
{
  "pokedexes": [
    {
      "name": "paldea",
      "speciesIds": [1, 2, 3, ..., 1010]  // 400種
    },
    {
      "name": "kitakami",
      "speciesIds": [10, 16, 19, ..., 1017]  // 200種
    },
    {
      "name": "blueberry",
      "speciesIds": [1, 4, 7, ..., 1025]  // 243種
    }
  ]
}
```

**PokemonRepositoryでの利用**:

```swift
// 図鑑データをSwiftDataから取得
for pokedexName in pokedexNames {
    let pokedexDescriptor = FetchDescriptor<PokedexModel>(
        predicate: #Predicate { $0.name == pokedexName }
    )

    if let pokedex = try modelContext.fetch(pokedexDescriptor).first {
        print("✅ [SwiftData Pokedex] Hit: \(pokedexName) (\(pokedex.speciesIds.count) species)")
        speciesIds.formUnion(pokedex.speciesIds)
    }
}

// API呼び出しが不要になった
```

**効果**:
- API呼び出し削減: 起動時3回 → 0回
- オフライン対応: バージョングループ切り替えもオフラインで動作

---

## Phase 3: 技・特性データモデルと日本語対応 ✅ 完了

### 目標

- 技データ・特性データを永続化 ✅
- 日本語対応完了 ✅
- 技フィルターの高速化 ✅
- 技カテゴリーフィルター実装（43種類） ✅

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

### 3.3 LocalizationManager（日本語対応）

**目的**: ポケモン名、タイプ名、技名、特性名の言語切り替え機能

**LocalizationManager.swift**:

```swift
@MainActor
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguage: AppLanguage = .japanese

    // ポケモンの表示名を取得
    func displayName(for pokemon: Pokemon) -> String {
        switch currentLanguage {
        case .japanese:
            return pokemon.nameJa.isEmpty ? pokemon.name : pokemon.nameJa
        case .english:
            return pokemon.name
        }
    }

    // タイプの表示名を取得
    func displayName(for type: PokemonType) -> String {
        switch currentLanguage {
        case .japanese:
            return TypeNames.japanese[type.name] ?? type.name
        case .english:
            return TypeNames.english[type.name] ?? type.name
        }
    }

    // 技の表示名を取得
    func displayName(for move: MoveEntity) -> String {
        switch currentLanguage {
        case .japanese:
            return move.nameJa.isEmpty ? move.name : move.nameJa
        case .english:
            return move.name
        }
    }

    // 特性の表示名を取得
    func displayName(for ability: PokemonAbility) -> String {
        switch currentLanguage {
        case .japanese:
            return ability.nameJa.isEmpty ? ability.name : ability.name
        case .english:
            return ability.name
        }
    }
}

enum AppLanguage: String, CaseIterable, Identifiable, Codable {
    case japanese = "ja"
    case english = "en"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .japanese: return "日本語"
        case .english: return "English"
        }
    }
}
```

**SettingsView.swift**:

```swift
struct SettingsView: View {
    @EnvironmentObject private var localizationManager: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("言語", selection: $localizationManager.currentLanguage) {
                        ForEach(AppLanguage.allCases) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("表示設定")
                } footer: {
                    Text("アプリの表示言語を変更できます。タイプ名などが選択した言語で表示されます。")
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
}
```

---

## Phase 4: 高度なフィルタリング機能

### 目標

- タイプ/特性/技フィルターのOR/AND切り替え ✅
- 技のメタデータによる絞り込み
- 特性のメタデータによる絞り込み
- ポケモン区分フィルター（一般/準伝説/伝説/幻）
- 進化のきせきフィルター
- 最終進化フィルター
- 実数値絞り込みフィルター
- Chip UIでフィルター条件を可視化
- 図鑑区分セレクター ✅
- 表示形式の統一（グリッド表示削除） ✅
- ポケモン件数表示 ✅

### 4.0 基本フィルターのOR/AND切り替え ✅

**設計方針**:
- タイプ、特性、技の各フィルターにOR/AND検索モードを追加
- SearchFilterViewにSegmented Controlを配置
- ViewModelで検索ロジックを切り替え

**実装状況**: ✅ 完了

```swift
/// フィルターの検索モード
enum FilterMode {
    case or   // いずれかに該当（現在のタイプ・特性）
    case and  // 全てに該当（現在の技名）
}

// PokemonListViewModelに追加
@Published var typeFilterMode: FilterMode = .or
@Published var abilityFilterMode: FilterMode = .or
@Published var moveFilterMode: FilterMode = .and
```

**検索ロジックの変更**:

```swift
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

// 特性フィルター（FilterPokemonByAbilityUseCaseを拡張）
func execute(
    pokemonList: [Pokemon],
    selectedAbilities: Set<String>,
    mode: FilterMode
) -> [Pokemon] {
    guard !selectedAbilities.isEmpty else {
        return pokemonList
    }

    return pokemonList.filter { pokemon in
        if mode == .or {
            // OR: いずれかの特性を持つ
            pokemon.abilities.contains { selectedAbilities.contains($0.name) }
        } else {
            // AND: 全ての特性を持つ
            selectedAbilities.allSatisfy { selectedAbility in
                pokemon.abilities.contains { $0.name == selectedAbility }
            }
        }
    }
}

// 技フィルター（FilterPokemonByMovesUseCaseを拡張）
func execute(
    pokemonList: [Pokemon],
    selectedMoves: [MoveEntity],
    versionGroup: String,
    mode: FilterMode
) async throws -> [(pokemon: Pokemon, learnMethods: [MoveLearnMethod])] {
    // ... 既存のbulkLearnMethods取得 ...

    if mode == .and {
        // AND: 全ての技を覚えられる（既存ロジック）
        if learnMethods.count == selectedMoves.count {
            results.append((pokemon, learnMethods))
        }
    } else {
        // OR: いずれかの技を覚えられる
        if !learnMethods.isEmpty {
            results.append((pokemon, learnMethods))
        }
    }
}
```

**UI実装（SearchFilterView）**:

```swift
Section("タイプ") {
    Picker("検索モード", selection: $viewModel.typeFilterMode) {
        Text("OR（いずれか）").tag(FilterMode.or)
        Text("AND（全て）").tag(FilterMode.and)
    }
    .pickerStyle(.segmented)

    // 既存のタイプ選択UI
}

Section("特性") {
    Picker("検索モード", selection: $viewModel.abilityFilterMode) {
        Text("OR（いずれか）").tag(FilterMode.or)
        Text("AND（全て）").tag(FilterMode.and)
    }
    .pickerStyle(.segmented)

    // 既存の特性選択UI
}

Section("技") {
    Picker("検索モード", selection: $viewModel.moveFilterMode) {
        Text("OR（いずれか）").tag(FilterMode.or)
        Text("AND（全て）").tag(FilterMode.and)
    }
    .pickerStyle(.segmented)

    // 既存の技選択UI
}
```

### 4.1 MoveFilterCondition（技のメタデータ条件）

**設計方針**:
- MoveModelとMoveMetaModelの全フィールドを条件として利用可能
- 複数条件のAND検索（1つの技で全ての条件を満たす）

```swift
/// 技のフィルター条件
struct MoveFilterCondition {
    // 基本情報
    var types: Set<String>               // タイプ（複数選択可、OR）
    var damageClasses: Set<String>       // physical/special/status
    var powerRange: ClosedRange<Int>?    // 威力範囲（0-250）
    var accuracyRange: ClosedRange<Int>? // 命中率範囲（50-100、nilは必中）
    var ppRange: ClosedRange<Int>?       // PP範囲（5-40）
    var priorityRange: ClosedRange<Int>? // 優先度範囲（-7〜+5）
    var targets: Set<String>             // 技範囲（単体/全体/自分/味方など）

    // 効果（MoveMetaModel）
    var ailments: Set<String>            // まひ、やけど、どく等（OR）
    var categories: Set<String>          // 43種類のカテゴリー（OR）

    // 能力変化（AND条件：全て満たす技を探す）
    var statChanges: [StatChangeCondition]

    // その他
    var hasCritRateBoost: Bool?          // 急所率アップ
    var hasDrain: Bool?                  // HP吸収
    var hasHealing: Bool?                // HP回復
    var hasFlinch: Bool?                 // ひるみ
}

/// 能力変化条件
struct StatChangeCondition {
    var stat: String                     // "attack", "defense", "special-attack"等
    var changeAmount: Int?               // +1, +2, -1, -2等（nilは任意）
}

/// 技範囲（target）
enum MoveTarget: String, CaseIterable {
    case specificMove = "specific-move"              // 単体対象（相手1体）
    case selectedPokemon = "selected-pokemon"        // 選択した対象1体
    case allOtherPokemon = "all-other-pokemon"       // 自分以外の全て
    case allOpponents = "all-opponents"              // 相手全体
    case user = "user"                               // 自分
    case userOrAlly = "user-or-ally"                 // 自分または味方
    case ally = "ally"                               // 味方
    case allAllies = "all-allies"                    // 味方全体
    case allPokemon = "all-pokemon"                  // 全員（フィールド全体）
    case userAndAllies = "user-and-allies"           // 自分と味方全体
    case entireField = "entire-field"                // フィールド全体

    var displayName: String {
        switch self {
        case .specificMove, .selectedPokemon:
            return "単体"
        case .allOpponents:
            return "相手全体"
        case .allOtherPokemon:
            return "自分以外全員"
        case .user:
            return "自分"
        case .userOrAlly:
            return "自分または味方"
        case .ally:
            return "味方単体"
        case .allAllies:
            return "味方全体"
        case .allPokemon:
            return "全員"
        case .userAndAllies:
            return "自分と味方"
        case .entireField:
            return "フィールド"
        }
    }
}
```

### 4.2 AbilityCategory（特性のメタデータ）

**設計方針**（検討中）:
- AbilityModelに `categories: [String]` フィールドを追加
- 自動判定 or 手動分類

```swift
/// 特性のカテゴリー
enum AbilityCategory: String, CaseIterable {
    case weather = "weather"                // 天候変化
    case terrain = "terrain"                // フィールド変化
    case statBoost = "stat-boost"           // 能力上昇
    case statDrop = "stat-drop"             // 能力下降
    case typeChange = "type-change"         // タイプ変更
    case immunity = "immunity"              // 無効化
    case statusEffect = "status-effect"     // 状態異常付与
    case statusCure = "status-cure"         // 状態異常回復
    case healing = "healing"                // HP回復
    case damageBoost = "damage-boost"       // 技威力上昇
    case damageReduction = "damage-reduction" // ダメージ軽減
    case priority = "priority"              // 優先度変化
    case accuracy = "accuracy"              // 命中率変化
    case other = "other"                    // その他

    var displayName: String {
        switch self {
        case .weather: return "天候変化"
        case .terrain: return "フィールド変化"
        case .statBoost: return "能力上昇"
        case .statDrop: return "能力下降"
        case .typeChange: return "タイプ変更"
        case .immunity: return "無効化"
        case .statusEffect: return "状態異常付与"
        case .statusCure: return "状態異常回復"
        case .healing: return "HP回復"
        case .damageBoost: return "技威力上昇"
        case .damageReduction: return "ダメージ軽減"
        case .priority: return "優先度変化"
        case .accuracy: return "命中率変化"
        case .other: return "その他"
        }
    }
}
```

### 4.2.1 AbilityDetailFilterView（特性の詳細フィルター画面）

**画面構成**:

```swift
NavigationStack {
    Form {
        // 特性名検索（既存）
        Section("特性名で検索") {
            TextField("特性名を入力", text: $searchText)
            // 選択済み特性を表示（Chip UI）
            FlowLayout {
                ForEach(selectedAbilities, id: \.self) { ability in
                    AbilityChip(name: ability) {
                        // 削除
                        selectedAbilities.remove(ability)
                    }
                }
            }
        }

        // OR/AND切り替え
        Section {
            Picker("検索モード", selection: $abilityFilterMode) {
                Text("OR（いずれか）").tag(FilterMode.or)
                Text("AND（全て）").tag(FilterMode.and)
            }
            .pickerStyle(.segmented)
        } header: {
            Text("検索モード")
        } footer: {
            Text(abilityFilterMode == .or
                ? "選択した特性のいずれかを持つポケモンを表示"
                : "選択した特性を全て持つポケモンを表示")
        }

        // 効果カテゴリーフィルター
        Section("効果で絞り込む") {
            ForEach(AbilityCategory.allCases, id: \.self) { category in
                Button(action: {
                    selectedAbilityCategories.toggle(category)
                }) {
                    HStack {
                        Text(category.displayName)
                        Spacer()
                        if selectedAbilityCategories.contains(category) {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        }
    }
    .navigationTitle("特性の詳細フィルター")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("キャンセル") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("適用") { applyFilter() }
        }
    }
}
```

### 4.3 MoveDetailFilterView（技の詳細フィルター画面）

**画面構成**:

```
NavigationStack {
    Form {
        // 技名検索（既存）
        Section("技名で検索") {
            TextField("技名を入力", text: $searchText)
            // 選択済み技を表示（Chip UI）
            FlowLayout {
                ForEach(selectedMoves) { move in
                    MoveChip(move: move) {
                        // 削除
                    }
                }
            }
        }

        // 基本情報フィルター
        Section("基本情報") {
            // タイプ選択（複数）
            MultiSelectPicker("タイプ", selection: $selectedTypes) {
                ForEach(allTypes) { type in
                    TypeBadge(type)
                }
            }

            // 分類選択
            Picker("分類", selection: $selectedDamageClasses) {
                Text("物理").tag("physical")
                Text("特殊").tag("special")
                Text("変化").tag("status")
            }

            // 威力範囲
            HStack {
                TextField("最小", value: $minPower, format: .number)
                Text("〜")
                TextField("最大", value: $maxPower, format: .number)
            }
        }

        // 効果フィルター
        Section("効果") {
            // 状態異常
            MultiSelectPicker("状態異常", selection: $selectedAilments) {
                Text("まひ").tag("paralysis")
                Text("やけど").tag("burn")
                // ...
            }

            // 能力変化
            Section("能力変化") {
                ForEach($statChangeConditions) { $condition in
                    HStack {
                        Picker("能力", selection: $condition.stat) {
                            Text("攻撃").tag("attack")
                            Text("防御").tag("defense")
                            Text("特攻").tag("special-attack")
                            Text("特防").tag("special-defense")
                            Text("素早さ").tag("speed")
                        }

                        Picker("変化量", selection: $condition.changeAmount) {
                            Text("任意").tag(nil as Int?)
                            Text("+1").tag(1)
                            Text("+2").tag(2)
                            Text("-1").tag(-1)
                            Text("-2").tag(-2)
                        }

                        Button(action: { removeStatChange(condition) }) {
                            Image(systemName: "minus.circle.fill")
                        }
                    }
                }
                Button("能力変化を追加") {
                    addStatChange()
                }
            }
        }
    }
    .navigationTitle("技の詳細フィルター")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("キャンセル") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("適用") { applyFilter() }
        }
    }
}
```

### 4.4 FilterConditionChipView（選択条件の表示）

**Chip UI実装**:

```swift
struct FilterConditionChipView: View {
    let condition: FilterCondition
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(condition.displayText)
                .font(.caption)
                .foregroundColor(.white)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(condition.categoryColor)
        .cornerRadius(8)
    }
}

enum FilterCondition {
    case moveName(MoveEntity)
    case moveMetadata(String)  // "特攻上昇 AND 特防上昇"
    case abilityName(AbilityEntity)
    case abilityCategory(AbilityCategory)
    case pokemonCategory(PokemonCategory)
    case canUseEviolite
    case isFinalEvolution
    case statFilter(StatFilterCondition)

    var displayText: String {
        switch self {
        case .moveName(let move):
            return move.nameJa
        case .moveMetadata(let description):
            return description
        case .abilityName(let ability):
            return ability.nameJa ?? ability.name
        case .abilityCategory(let category):
            return category.displayName
        case .pokemonCategory(let category):
            return category.displayName
        case .canUseEviolite:
            return "進化のきせき適用可"
        case .isFinalEvolution:
            return "最終進化のみ"
        case .statFilter(let condition):
            return condition.displayText
        }
    }

    var categoryColor: Color {
        switch self {
        case .moveName, .moveMetadata:
            return .blue
        case .abilityName, .abilityCategory:
            return .green
        case .pokemonCategory:
            return .purple
        case .canUseEviolite, .isFinalEvolution:
            return .orange
        case .statFilter:
            return .red
        }
    }
}
```

### 4.5 最終進化フィルター

**設計方針**:
- PokemonEvolutionModel.evolvesToで最終進化を判定
- SearchFilterViewにトグルを追加

```swift
// PokemonListViewModelに追加
@Published var filterFinalEvolutionOnly: Bool = false

// フィルタリングロジック
func applyFiltersAsync() async {
    var filtered = pokemons.filter { pokemon in
        // 既存のフィルター条件...

        // 最終進化フィルター
        let matchesFinalEvolution = !filterFinalEvolutionOnly ||
            pokemon.evolution?.evolvesTo.isEmpty == true

        return matchesSearch && matchesType && matchesFinalEvolution
    }
    // ...
}
```

**UI実装（SearchFilterView）**:

```swift
Section("進化段階") {
    Toggle("最終進化のみ", isOn: $viewModel.filterFinalEvolutionOnly)
    Toggle("進化のきせき適用可", isOn: $viewModel.filterEvioliteOnly)
}
```

**注意事項**:
- Pokemonエンティティに進化情報（evolution）を追加する必要がある
- または、別途進化情報を取得して判定する

### 4.6 StatFilterCondition（実数値フィルター）

**設計方針**:
- 既存の`CalculateStatsUseCase`を利用
- レベル50固定、個体値31
- ユーザーが実数値を直接入力（努力値・性格補正は自分で計算）
- StatDetailFilterView（専用画面）で条件を設定

```swift
/// 実数値フィルター条件
struct StatFilterCondition {
    var stat: StatType                   // HP/攻撃/防御/特攻/特防/素早さ
    var comparison: ComparisonType       // 以上/以下/範囲
    var minValue: Int?                   // 最小値
    var maxValue: Int?                   // 最大値（範囲指定の場合）
}

enum StatType: String, CaseIterable {
    case hp = "hp"
    case attack = "attack"
    case defense = "defense"
    case specialAttack = "special-attack"
    case specialDefense = "special-defense"
    case speed = "speed"

    var displayName: String {
        switch self {
        case .hp: return "HP"
        case .attack: return "こうげき"
        case .defense: return "ぼうぎょ"
        case .specialAttack: return "とくこう"
        case .specialDefense: return "とくぼう"
        case .speed: return "すばやさ"
        }
    }
}

enum ComparisonType: String, CaseIterable {
    case greaterThanOrEqual = ">="
    case lessThanOrEqual = "<="
    case range = "range"

    var displayName: String {
        switch self {
        case .greaterThanOrEqual: return "以上"
        case .lessThanOrEqual: return "以下"
        case .range: return "範囲"
        }
    }
}
```

**実装例**:

```swift
// すばやさ180以上の条件
let condition = StatFilterCondition(
    stat: .speed,
    comparison: .greaterThanOrEqual,
    minValue: 180,
    maxValue: nil
)

// フィルタリング処理
func filterByStats(_ pokemons: [Pokemon], condition: StatFilterCondition) -> [Pokemon] {
    return pokemons.filter { pokemon in
        // CalculateStatsUseCaseを使用して最大実数値を計算
        // (Lv50, 個体値31, 努力値252, 性格補正1.1)
        let maxActualStat = calculateStatsUseCase.execute(
            baseStat: pokemon.baseStat(for: condition.stat),
            level: 50,
            iv: 31,
            ev: 252,
            natureModifier: 1.1
        )

        switch condition.comparison {
        case .greaterThanOrEqual:
            return maxActualStat >= condition.minValue!
        case .lessThanOrEqual:
            return maxActualStat <= condition.minValue!
        case .range:
            return maxActualStat >= condition.minValue! && maxActualStat <= condition.maxValue!
        }
    }
}
```

### 4.6.1 StatDetailFilterView（実数値詳細フィルター画面）

**画面構成**:

```swift
NavigationStack {
    Form {
        // 条件追加セクション
        Section {
            Picker("ステータス", selection: $selectedStat) {
                ForEach(StatType.allCases, id: \.self) { stat in
                    Text(stat.displayName).tag(stat)
                }
            }

            Picker("条件", selection: $comparisonType) {
                ForEach(ComparisonType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }

            if comparisonType == .range {
                HStack {
                    TextField("最小値", value: $minValue, format: .number)
                        .keyboardType(.numberPad)
                    Text("〜")
                    TextField("最大値", value: $maxValue, format: .number)
                        .keyboardType(.numberPad)
                }
            } else {
                TextField("値", value: $minValue, format: .number)
                    .keyboardType(.numberPad)
            }

            Button("条件を追加") {
                addCondition()
            }
            .disabled(!canAddCondition)
        } header: {
            Text("条件を追加")
        } footer: {
            Text("レベル50、個体値31での最大実数値（努力値252、性格補正1.1）で判定します")
        }

        // 選択中の条件
        if !statConditions.isEmpty {
            Section("選択中の条件") {
                ForEach(statConditions) { condition in
                    HStack {
                        Text(condition.displayText)
                        Spacer()
                        Button(action: {
                            removeCondition(condition)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
        }
    }
    .navigationTitle("実数値フィルター")
    .toolbar {
        ToolbarItem(placement: .cancellationAction) {
            Button("キャンセル") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("適用") { applyFilter() }
        }
    }
}

// 表示テキスト例
extension StatFilterCondition {
    var displayText: String {
        let statName = stat.displayName
        switch comparison {
        case .greaterThanOrEqual:
            return "\(statName) ≥ \(minValue ?? 0)"
        case .lessThanOrEqual:
            return "\(statName) ≤ \(minValue ?? 0)"
        case .range:
            return "\(statName) \(minValue ?? 0)〜\(maxValue ?? 0)"
        }
    }
}
```

### 4.7 SearchFilterView拡張

**変更箇所**:

```swift
struct SearchFilterView: View {
    // 既存のプロパティ
    @ObservedObject var viewModel: PokemonListViewModel

    // 新規追加
    @State private var selectedCategories: Set<PokemonCategory> = []
    @State private var showMoveDetailFilter: Bool = false
    @State private var showAbilityDetailFilter: Bool = false
    @State private var showStatDetailFilter: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                // 選択中の条件を表示（Chip UI）
                if hasAnyFilter {
                    Section("選択中の条件") {
                        FlowLayout(spacing: 8) {
                            ForEach(allFilterConditions, id: \.self) { condition in
                                FilterConditionChipView(condition: condition) {
                                    removeCondition(condition)
                                }
                            }
                        }

                        Button("全てクリア") {
                            clearAllFilters()
                        }
                        .foregroundColor(.red)
                    }
                }

                // タイプフィルター（OR/AND追加）
                Section("タイプ") {
                    Picker("検索モード", selection: $viewModel.typeFilterMode) {
                        Text("OR（いずれか）").tag(FilterMode.or)
                        Text("AND（全て）").tag(FilterMode.and)
                    }
                    .pickerStyle(.segmented)

                    // 既存のタイプ選択UI
                    // ...
                }

                // 特性フィルター（OR/AND追加）
                Section("特性") {
                    Picker("検索モード", selection: $viewModel.abilityFilterMode) {
                        Text("OR（いずれか）").tag(FilterMode.or)
                        Text("AND（全て）").tag(FilterMode.and)
                    }
                    .pickerStyle(.segmented)

                    // 既存の特性選択UI + 詳細フィルターボタン
                    Button("特性の効果で絞り込む") {
                        showAbilityDetailFilter = true
                    }
                }

                // 技フィルター（OR/AND追加）
                Section("技") {
                    Picker("検索モード", selection: $viewModel.moveFilterMode) {
                        Text("OR（いずれか）").tag(FilterMode.or)
                        Text("AND（全て）").tag(FilterMode.and)
                    }
                    .pickerStyle(.segmented)

                    // 既存の技選択UI + 詳細フィルターボタン
                    Button("技の詳細で絞り込む") {
                        showMoveDetailFilter = true
                    }
                }

                // ポケモン区分フィルター（新規）
                Section("ポケモン区分") {
                    MultiSelectPicker(selection: $selectedCategories) {
                        ForEach(PokemonCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }
                }

                // 進化段階フィルター（新規）
                Section("進化段階") {
                    Toggle("最終進化のみ", isOn: $viewModel.filterFinalEvolutionOnly)
                    Toggle("進化のきせき適用可", isOn: $viewModel.filterEvioliteOnly)
                }

                // 実数値フィルター（専用画面へ遷移）
                Section("実数値") {
                    Button("実数値で絞り込む") {
                        showStatDetailFilter = true
                    }
                }
            }
            .sheet(isPresented: $showMoveDetailFilter) {
                MoveDetailFilterView(...)
            }
            .sheet(isPresented: $showAbilityDetailFilter) {
                AbilityDetailFilterView(...)
            }
            .sheet(isPresented: $showStatDetailFilter) {
                StatDetailFilterView(...)
            }
        }
    }
}
```

---

## Phase 5以降

**Phase 5: バージョン固有データ対応** - PokemonVersionVariantモデル追加、地方図鑑対応

**Phase 6: モジュール化** - PokedexCoreパッケージ作成、Domain/Data/Presentation層の分離

**Phase 7: UI/UX改善** - アニメーション、詳細画面拡充

詳細は `docs/pokedex_prompts_v4.md` および `docs/pokedex_requirements_v4.md` を参照してください。

---

## データフロー（Phase 2完了後）

**バージョングループ切り替え**:

```
User: バージョングループ選択（scarlet-violet）
    ↓
PokemonListViewModel.changeVersionGroup()
    ↓
PokemonRepository.fetchPokemonList()
    ├→ 1. 図鑑データ取得（PokedexModel）
    │     - paldea: 400種
    │     - kitakami: 200種
    │     - blueberry: 243種
    │     - SwiftDataから即座に取得（API不要）
    ├→ 2. 該当ポケモンをSwiftDataから取得
    │     - speciesIds に基づいてフィルタリング
    └→ 3. Domain変換して返却（1秒以内）
    ↓
User: フィルタリングされたリスト表示（1秒以内）
```

**技フィルター**:

```
User: 技フィルター選択（「10まんボルト」「かみなり」）
    ↓
FilterPokemonByMovesUseCase.execute()
    ↓
MoveRepository.fetchBulkLearnMethods()
    ├→ 1. PokemonModelをSwiftDataから取得
    ├→ 2. 埋め込みmoves配列をフィルタリング
    │     - pokemon.moves.filter { moveIds.contains($0.moveId) }
    │     - メモリ内処理のため高速（API不要）
    └→ 3. 結果を返却（3秒以内）
    ↓
User: フィルタリングされたリスト表示（3秒以内）
```

### 4.8 図鑑区分セレクター機能 ✅

**設計方針**:
- ポケモン一覧画面で図鑑区分を切り替えて表示
- 全国図鑑、パルデア図鑑、キタカミ図鑑、ブルーベリー図鑑の4種類
- 各図鑑に登録されているポケモンのみを表示
- 図鑑番号も選択された図鑑の番号で表示

**実装状況**: ✅ 完了

#### Domain層: PokedexType.swift

```swift
/// 図鑑の種類
enum PokedexType: String, CaseIterable, Identifiable, Codable {
    case national    // 全国図鑑
    case paldea      // パルデア図鑑
    case kitakami    // キタカミ図鑑
    case blueberry   // ブルーベリー図鑑

    var id: String { rawValue }

    /// 日本語名
    var nameJa: String {
        switch self {
        case .national: return "全国"
        case .paldea: return "パルデア"
        case .kitakami: return "キタカミ"
        case .blueberry: return "ブルーベリー"
        }
    }

    /// 英語名
    var nameEn: String {
        switch self {
        case .national: return "National"
        case .paldea: return "Paldea"
        case .kitakami: return "Kitakami"
        case .blueberry: return "Blueberry"
        }
    }
}
```

#### Presentation層: LocalizationManager拡張

```swift
extension LocalizationManager {
    /// 図鑑名の表示
    func displayName(for pokedex: PokedexType) -> String {
        switch currentLanguage {
        case .japanese:
            return pokedex.nameJa
        case .english:
            return pokedex.nameEn
        }
    }
}
```

#### ViewModel: PokemonListViewModel拡張

```swift
/// 選択された図鑑区分
@Published var selectedPokedex: PokedexType = .national

/// 図鑑区分を変更
func changePokedex(_ pokedex: PokedexType) {
    selectedPokedex = pokedex

    // 全国図鑑の場合は全ポケモンをロード
    if pokedex == .national {
        if selectedVersionGroup != .nationalDex {
            selectedVersionGroup = .nationalDex
            Task {
                await loadPokemons()
            }
        } else {
            applyFilters()
        }
    } else {
        // 地域図鑑の場合
        if selectedVersionGroup == .nationalDex {
            selectedVersionGroup = .scarletViolet
            Task {
                await loadPokemons()
            }
        } else {
            applyFilters()
        }
    }
}

/// フィルタリング処理（図鑑フィルター追加）
private func applyFiltersAsync() async {
    var filtered = pokemons.filter { pokemon in
        // 図鑑フィルター
        let matchesPokedex: Bool
        if selectedPokedex == .national {
            matchesPokedex = true
        } else {
            matchesPokedex = pokemon.pokedexNumbers?[selectedPokedex.rawValue] != nil
        }

        // ... 他のフィルター条件 ...

        return matchesPokedex && matchesSearch && matchesType
    }

    // 図鑑番号ソート
    if currentSortOption == .pokedexNumber && selectedPokedex != .national {
        sorted = sorted.sorted { pokemon1, pokemon2 in
            let num1 = pokemon1.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
            let num2 = pokemon2.pokedexNumbers?[selectedPokedex.rawValue] ?? Int.max
            return num1 < num2
        }
    }
}
```

#### View: PokemonListView拡張

```swift
VStack(spacing: 0) {
    // 図鑑切り替えSegmented Control
    Picker("図鑑", selection: $viewModel.selectedPokedex) {
        ForEach(PokedexType.allCases) { pokedex in
            Text(localizationManager.displayName(for: pokedex))
                .tag(pokedex)
        }
    }
    .pickerStyle(.segmented)
    .padding(.horizontal, 20)
    .padding(.top, 8)
    .padding(.bottom, 16)
    .background(Color(uiColor: .systemGroupedBackground))
    .onChange(of: viewModel.selectedPokedex) { oldValue, newValue in
        if oldValue != newValue {
            viewModel.changePokedex(newValue)
        }
    }

    contentView
}
```

#### View: PokemonRow拡張（図鑑番号表示）

```swift
struct PokemonRow: View {
    let pokemon: Pokemon
    let selectedPokedex: PokedexType

    private var pokedexNumber: String {
        if selectedPokedex == .national {
            return pokemon.formattedId
        } else {
            if let number = pokemon.pokedexNumbers?[selectedPokedex.rawValue] {
                return String(format: "#%03d", number)
            } else {
                return pokemon.formattedId
            }
        }
    }
}
```

### 4.9 表示形式の統一（グリッド表示削除） ✅

**設計方針**:
- ポケモン一覧の表示形式をリスト表示のみに統一
- グリッド表示機能を削除してUIをシンプルに
- メンテナンスコストの削減

**実装状況**: ✅ 完了

#### 削除されたコンポーネント

- `PokemonGridItem.swift`: グリッド表示用コンポーネント
- `DisplayMode` enum: 表示形式の切り替え用enum
- `toggleDisplayMode()`: 表示形式切り替えメソッド

#### ViewModel: PokemonListViewModel変更

```swift
// 削除
- enum DisplayMode { case list, case grid }
- @Published var displayMode: DisplayMode = .list
- func toggleDisplayMode() { ... }
```

#### View: PokemonListView変更

```swift
// 削除: 表示形式切り替えボタン
- ToolbarItem(placement: .topBarLeading) {
-     Button {
-         viewModel.toggleDisplayMode()
-     } label: {
-         Image(systemName: viewModel.displayMode == .list ? "square.grid.2x2" : "list.bullet")
-     }
- }

// 削除: グリッド表示分岐
- switch viewModel.displayMode {
- case .list:
-     pokemonList
- case .grid:
-     pokemonGrid
- }

// 変更後: リスト表示のみ
pokemonList
```

#### UI調整

```swift
// Picker下の余白: 8px → 16px
.padding(.bottom, 16)

// List上の余白: 8px → 0px
.contentMargins(.top, 0, for: .scrollContent)
```

### 4.10 ポケモン件数表示 ✅

**設計方針**:
- ポケモン一覧画面に取得件数を表示
- フィルター有効時と無効時で表示を切り替え
- ユーザーが現在表示されているポケモンの数を一目で把握できる

**実装状況**: ✅ 完了

#### View: PokemonListView拡張

**配置位置**:
```swift
VStack(spacing: 0) {
    // 図鑑切り替えSegmented Control
    Picker("図鑑", selection: $viewModel.selectedPokedex) {
        // ...
    }

    // ポケモン件数表示（NEW）
    if !viewModel.isLoading {
        pokemonCountView
            .padding(.horizontal, 20)
            .padding(.top, 8)
    }

    contentView
}
```

**pokemonCountView実装**:
```swift
private var pokemonCountView: some View {
    HStack {
        if hasActiveFilters {
            // フィルターがある場合
            Text("絞り込み結果: \(viewModel.filteredPokemons.count)匹")
                .font(.caption)
                .foregroundColor(.primary)
            +
            Text(" / 全\(viewModel.pokemons.count)匹")
                .font(.caption)
                .foregroundColor(.secondary)
        } else {
            // フィルターがない場合
            Text("全\(viewModel.filteredPokemons.count)匹")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        Spacer()
    }
}
```

**hasActiveFilters計算プロパティ**:
```swift
/// フィルターや検索が有効かどうか
private var hasActiveFilters: Bool {
    !viewModel.searchText.isEmpty ||
    !viewModel.selectedTypes.isEmpty ||
    !viewModel.selectedAbilities.isEmpty ||
    !viewModel.selectedMoves.isEmpty ||
    !viewModel.selectedMoveCategories.isEmpty ||
    !viewModel.selectedCategories.isEmpty ||
    viewModel.evolutionFilterMode != .all ||
    !viewModel.statFilterConditions.isEmpty ||
    !viewModel.moveMetadataFilters.isEmpty
}
```

**表示仕様**:

| 状態 | 表示内容 | フォント | 色 |
|------|---------|---------|-----|
| フィルター有効 | "絞り込み結果: 25匹 / 全400匹" | .caption | .primary + .secondary |
| フィルター無効 | "全400匹" | .caption | .secondary |
| ローディング中 | 非表示 | - | - |

**動作**:
1. フィルター条件が1つでも設定されている場合、絞り込み結果と全件数を表示
2. フィルター条件が何もない場合、全件数のみ表示
3. ローディング中は非表示（`if !viewModel.isLoading`で制御）
4. 件数はリアルタイムで更新される（@Publishedプロパティのバインディング）

---

## エラーハンドリング

### SwiftDataエラー

| エラー | 原因 | 対処 | 実装状況 |
|--------|------|------|------|
| ModelContainer初期化失敗 | スキーマ不整合 | 自動クリーンアップ → 再作成 | ✅ 実装済み |
| fetch失敗 | データ破損 | エラー表示 → 再インストール推奨 | ✅ 実装済み |
| save失敗 | ディスク容量不足 | ユーザーに通知 | ✅ 実装済み |

### プリバンドルJSONエラー

| エラー | 原因 | 対処 | 実装状況 |
|--------|------|------|------|
| バンドルにJSONなし | ビルド設定ミス | エラー表示 | ✅ 実装済み |
| JSON解析失敗 | フォーマットエラー | エラー表示 | ✅ 実装済み |

### マイグレーションエラー

| エラー | 原因 | 対処 | 実装状況 |
|--------|------|------|------|
| スキーマバージョン不一致 | @Relationship → 埋め込み型変更 | 自動削除 → 再作成 | ✅ 実装済み |
| データ破損 | 不完全な保存 | 自動削除 → 再作成 | ✅ 実装済み |

---

## 変更履歴

| 日付 | バージョン | 変更内容 |
|------|-----------|---------|
| 2025-10-09 | 1.0 | 初版作成 |
| 2025-10-10 | 2.0 | Phase 1をSwiftData永続化に変更、Phase 2をプリバンドルDBに変更、Phase 3以降を簡略化 |
| 2025-10-11 | 3.0 | JSONベースのアプローチに変更、全モデルをJSONデータ構造に合わせて更新、日本語フィールド追加、技・特性モデル追加 |
| 2025-10-12 | 4.0 | Phase 1-3完了を反映、埋め込みモデル採用、PokedexModel追加、スキーマバージョン管理追加、パフォーマンス実測値更新、LocalizationManager追加 |
| 2025-10-12 | 4.1 | Phase 4追加：高度なフィルタリング機能の設計（MoveFilterCondition、AbilityCategory、Chip UI、MoveDetailFilterView） |
| 2025-10-12 | 4.2 | Phase 4拡張：OR/AND切り替え設計、AbilityDetailFilterView追加、最終進化フィルター追加、StatDetailFilterView設計（UI簡素化・画面分離） |
| 2025-01-13 | 4.3 | Phase 4完了：OR/AND切り替え実装完了（4.0）、図鑑区分セレクター追加（4.8）、グリッド表示削除（4.9）、FilterMode/PokedexType追加 |
| 2025-10-13 | 4.4 | Phase 4拡張：ポケモン件数表示追加（4.10）、hasActiveFiltersロジック実装 |
