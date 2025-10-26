# Pokedex-SwiftUI 設計書 v3.0

## 1. 概要

### 1.1 目的
Pokedex-SwiftUI v3.0の詳細画面拡充機能について、Clean Architecture + MVVMパターンに基づいた実装設計を定義する。

### 1.2 対象バージョン
- バージョン: v3.0
- ベースバージョン: v2.0

### 1.3 設計原則
- Clean Architectureの層分離を維持
- 既存のアーキテクチャパターンに準拠
- テスタビリティを確保
- 拡張性と保守性を重視

---

## 2. アーキテクチャ概要

### 2.1 レイヤー構成

```
Presentation Layer (SwiftUI Views + ViewModels)
    ↓↑
Domain Layer (Entities + UseCases + Protocols)
    ↓↑
Data Layer (Repositories + API Clients + Cache)
    ↓↑
External Services (PokéAPI v2)
```

### 2.2 依存関係の方向
- Presentation → Domain
- Domain ← Data
- Data → External Services
- Domain層は他の層に依存しない（Dependency Inversion）

---

## 3. Domain層の設計

### 3.1 新規Entity

#### 3.1.1 PokemonForm
```swift
struct PokemonForm: Equatable, Identifiable {
    let id: Int
    let name: String
    let pokemonId: Int
    let formName: String  // "normal", "alola", "galar", "mega-x", etc.
    let types: [PokemonType]
    let sprites: PokemonSprites
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let isDefault: Bool
    let isMega: Bool
    let isRegional: Bool
    let versionGroup: String?
}
```

#### 3.1.2 TypeMatchup
```swift
struct TypeMatchup: Equatable {
    let offensive: OffensiveMatchup
    let defensive: DefensiveMatchup
    
    struct OffensiveMatchup: Equatable {
        let superEffective: [PokemonType]  // 2x
    }
    
    struct DefensiveMatchup: Equatable {
        let quadrupleWeak: [PokemonType]    // 4x
        let doubleWeak: [PokemonType]       // 2x
        let doubleResist: [PokemonType]     // 1/2x
        let quadrupleResist: [PokemonType]  // 1/4x
        let immune: [PokemonType]           // 0x
    }
}
```

#### 3.1.3 CalculatedStats
```swift
struct CalculatedStats: Equatable {
    let level: Int = 50
    let patterns: [StatsPattern]
    
    struct StatsPattern: Equatable, Identifiable {
        let id: String  // "ideal", "max", "neutral", "min", "hindered"
        let displayName: String  // "理想", "252", "無振り", "最低", "下降"
        let hp: Int
        let attack: Int
        let defense: Int
        let specialAttack: Int
        let specialDefense: Int
        let speed: Int
        
        let config: PatternConfig
        
        struct PatternConfig: Equatable {
            let iv: Int  // 0 or 31
            let ev: Int  // 0 or 252
            let nature: NatureModifier
            
            enum NatureModifier: Equatable {
                case boosted    // 1.1x
                case neutral    // 1.0x
                case hindered   // 0.9x
            }
        }
    }
}
```

#### 3.1.4 EvolutionNode
```swift
struct EvolutionNode: Equatable, Identifiable {
    let id: Int
    let speciesId: Int
    let name: String
    let imageUrl: String?
    let types: [PokemonType]
    let evolvesTo: [EvolutionEdge]
    let evolvesFrom: EvolutionEdge?
    
    struct EvolutionEdge: Equatable {
        let target: Int  // species ID
        let trigger: EvolutionTrigger
        let conditions: [EvolutionCondition]
    }
    
    enum EvolutionTrigger: String, Equatable {
        case levelUp = "level-up"
        case trade = "trade"
        case useItem = "use-item"
        case shed = "shed"
        case other
    }
    
    struct EvolutionCondition: Equatable {
        let type: ConditionType
        let value: String?
        
        enum ConditionType: String, Equatable {
            case minLevel = "min_level"
            case item = "item"
            case heldItem = "held_item"
            case timeOfDay = "time_of_day"
            case location = "location"
            case minHappiness = "min_happiness"
            case minBeauty = "min_beauty"
            case minAffection = "min_affection"
            case knownMove = "known_move"
            case knownMoveType = "known_move_type"
            case partySpecies = "party_species"
            case partyType = "party_type"
            case relativePhysicalStats = "relative_physical_stats"
            case tradeSpecies = "trade_species"
            case needsOverworldRain = "needs_overworld_rain"
            case turnUpsideDown = "turn_upside_down"
        }
    }
}

struct EvolutionChain: Equatable {
    let id: Int
    let rootNode: EvolutionNode
    
    // ツリー構造を平坦化したノードリスト（表示用）
    var allNodes: [EvolutionNode] {
        flattenTree(node: rootNode)
    }
    
    private func flattenTree(node: EvolutionNode) -> [EvolutionNode] {
        var result = [node]
        for edge in node.evolvesTo {
            // 再帰的に子ノードを取得
            // 実装時に詳細化
        }
        return result
    }
}
```

#### 3.1.5 PokemonLocation
```swift
struct PokemonLocation: Equatable {
    let locationName: String
    let versionDetails: [LocationVersionDetail]
    
    struct LocationVersionDetail: Equatable {
        let version: String
        let encounterDetails: [EncounterDetail]
    }
    
    struct EncounterDetail: Equatable {
        let minLevel: Int
        let maxLevel: Int
        let method: String  // "walk", "surf", "old-rod", etc.
        let chance: Int     // percentage
    }
}
```

#### 3.1.6 AbilityDetail
```swift
struct AbilityDetail: Equatable, Identifiable {
    let id: Int
    let name: String
    let effect: String          // 対戦向け説明（英語）
    let flavorText: String?     // ゲーム内説明（日本語、将来対応）
    let isHidden: Bool
}
```

#### 3.1.7 MoveDetail (既存の拡張)
```swift
// 既存のMoveEntityを拡張
struct MoveEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let type: PokemonType
    let power: Int?
    let accuracy: Int?
    let pp: Int?
    let damageClass: String
    let effect: String?  // 新規追加: 説明文（effectテキスト）

    var displayPower: String {
        power.map(String.init) ?? "-"
    }

    var displayAccuracy: String {
        accuracy.map(String.init) ?? "-"
    }

    var displayPP: String {
        pp.map(String.init) ?? "-"
    }

    var categoryIcon: String {
        switch damageClass {
        case "physical": return "💥"  // 物理
        case "special": return "✨"   // 特殊
        case "status": return "🔄"    // 変化
        default: return ""
        }
    }

    var displayEffect: String {
        effect ?? "説明なし"
    }
}
```

#### 3.1.8 PokemonFlavorText
```swift
struct PokemonFlavorText: Equatable {
    let text: String
    let language: String
    let versionGroup: String
}
```

### 3.2 新規UseCase

#### 3.2.1 FetchPokemonFormsUseCase
```swift
protocol FetchPokemonFormsUseCaseProtocol {
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonForm]
}

final class FetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonForm] {
        let forms = try await repository.fetchPokemonForms(pokemonId: pokemonId)
        
        // バージョングループでフィルタリング
        if let versionGroup = versionGroup {
            return forms.filter { form in
                // メガシンカなどはバージョンに応じてフィルタ
                filterByVersionGroup(form: form, versionGroup: versionGroup)
            }
        }
        
        return forms
    }
    
    private func filterByVersionGroup(form: PokemonForm, versionGroup: String) -> Bool {
        // バージョングループによるフィルタリングロジック
        // 例: X-Yでのみメガシンカが存在
        // 実装時に詳細化
        return true
    }
}
```

#### 3.2.2 CalculateStatsUseCase
```swift
protocol CalculateStatsUseCaseProtocol {
    func execute(baseStats: [PokemonStat]) -> CalculatedStats
}

final class CalculateStatsUseCase: CalculateStatsUseCaseProtocol {
    func execute(baseStats: [PokemonStat]) -> CalculatedStats {
        let patterns: [CalculatedStats.StatsPattern] = [
            calculatePattern(
                id: "ideal",
                displayName: "理想",
                baseStats: baseStats,
                config: .init(iv: 31, ev: 252, nature: .boosted)
            ),
            calculatePattern(
                id: "max",
                displayName: "252",
                baseStats: baseStats,
                config: .init(iv: 31, ev: 252, nature: .neutral)
            ),
            calculatePattern(
                id: "neutral",
                displayName: "無振り",
                baseStats: baseStats,
                config: .init(iv: 31, ev: 0, nature: .neutral)
            ),
            calculatePattern(
                id: "min",
                displayName: "最低",
                baseStats: baseStats,
                config: .init(iv: 0, ev: 0, nature: .neutral)
            ),
            calculatePattern(
                id: "hindered",
                displayName: "下降",
                baseStats: baseStats,
                config: .init(iv: 0, ev: 0, nature: .hindered)
            )
        ]
        
        return CalculatedStats(patterns: patterns)
    }
    
    private func calculatePattern(
        id: String,
        displayName: String,
        baseStats: [PokemonStat],
        config: CalculatedStats.StatsPattern.PatternConfig
    ) -> CalculatedStats.StatsPattern {
        let level = 50
        
        // 実数値計算式
        // HP: floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + level + 10
        // その他: floor((floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + 5) * nature)
        
        let hp = calculateHP(
            base: baseStats.first { $0.name == "hp" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level
        )
        
        let attack = calculateStat(
            base: baseStats.first { $0.name == "attack" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level,
            nature: config.nature
        )
        
        let defense = calculateStat(
            base: baseStats.first { $0.name == "defense" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level,
            nature: config.nature
        )
        
        let specialAttack = calculateStat(
            base: baseStats.first { $0.name == "special-attack" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level,
            nature: config.nature
        )
        
        let specialDefense = calculateStat(
            base: baseStats.first { $0.name == "special-defense" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level,
            nature: config.nature
        )
        
        let speed = calculateStat(
            base: baseStats.first { $0.name == "speed" }?.baseStat ?? 0,
            iv: config.iv,
            ev: config.ev,
            level: level,
            nature: config.nature
        )
        
        return CalculatedStats.StatsPattern(
            id: id,
            displayName: displayName,
            hp: hp,
            attack: attack,
            defense: defense,
            specialAttack: specialAttack,
            specialDefense: specialDefense,
            speed: speed,
            config: config
        )
    }
    
    private func calculateHP(base: Int, iv: Int, ev: Int, level: Int) -> Int {
        let value = ((base * 2 + iv + ev / 4) * level) / 100 + level + 10
        return value
    }
    
    private func calculateStat(
        base: Int,
        iv: Int,
        ev: Int,
        level: Int,
        nature: CalculatedStats.StatsPattern.PatternConfig.NatureModifier
    ) -> Int {
        let baseStat = ((base * 2 + iv + ev / 4) * level) / 100 + 5
        
        let natureMultiplier: Double = switch nature {
        case .boosted: 1.1
        case .neutral: 1.0
        case .hindered: 0.9
        }
        
        return Int(Double(baseStat) * natureMultiplier)
    }
}
```

#### 3.2.3 FetchTypeMatchupUseCase
```swift
protocol FetchTypeMatchupUseCaseProtocol {
    func execute(types: [PokemonType]) async throws -> TypeMatchup
}

final class FetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol {
    private let repository: TypeRepositoryProtocol
    
    init(repository: TypeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(types: [PokemonType]) async throws -> TypeMatchup {
        // 各タイプの相性情報を取得
        let typeDetails = try await withThrowingTaskGroup(of: TypeDetail.self) { group in
            for type in types {
                group.addTask {
                    try await self.repository.fetchTypeDetail(type: type)
                }
            }
            
            var results: [TypeDetail] = []
            for try await detail in group {
                results.append(detail)
            }
            return results
        }
        
        // 攻撃面: このポケモンの技が効果ばつぐん
        let offensive = calculateOffensiveMatchup(typeDetails: typeDetails)
        
        // 防御面: このポケモンが受けるダメージ
        let defensive = calculateDefensiveMatchup(types: types, typeDetails: typeDetails)
        
        return TypeMatchup(offensive: offensive, defensive: defensive)
    }
    
    private func calculateOffensiveMatchup(
        typeDetails: [TypeDetail]
    ) -> TypeMatchup.OffensiveMatchup {
        // 各タイプの damageRelations.doubleDamageTo を集約
        var superEffective: Set<PokemonType> = []
        
        for detail in typeDetails {
            for type in detail.damageRelations.doubleDamageTo {
                superEffective.insert(type)
            }
        }
        
        return TypeMatchup.OffensiveMatchup(
            superEffective: Array(superEffective).sorted(by: { $0.rawValue < $1.rawValue })
        )
    }
    
    private func calculateDefensiveMatchup(
        types: [PokemonType],
        typeDetails: [TypeDetail]
    ) -> TypeMatchup.DefensiveMatchup {
        // 全タイプに対する倍率を計算
        var multipliers: [PokemonType: Double] = [:]
        
        for attackType in PokemonType.allCases {
            var multiplier = 1.0
            
            for defenseType in types {
                let typeDetail = typeDetails.first { $0.type == defenseType }
                
                if typeDetail?.damageRelations.noDamageFrom.contains(attackType) == true {
                    multiplier *= 0.0
                } else if typeDetail?.damageRelations.halfDamageFrom.contains(attackType) == true {
                    multiplier *= 0.5
                } else if typeDetail?.damageRelations.doubleDamageFrom.contains(attackType) == true {
                    multiplier *= 2.0
                }
            }
            
            multipliers[attackType] = multiplier
        }
        
        // 倍率ごとに分類
        let quadrupleWeak = multipliers.filter { $0.value == 4.0 }.map { $0.key }.sorted(by: { $0.rawValue < $1.rawValue })
        let doubleWeak = multipliers.filter { $0.value == 2.0 }.map { $0.key }.sorted(by: { $0.rawValue < $1.rawValue })
        let doubleResist = multipliers.filter { $0.value == 0.5 }.map { $0.key }.sorted(by: { $0.rawValue < $1.rawValue })
        let quadrupleResist = multipliers.filter { $0.value == 0.25 }.map { $0.key }.sorted(by: { $0.rawValue < $1.rawValue })
        let immune = multipliers.filter { $0.value == 0.0 }.map { $0.key }.sorted(by: { $0.rawValue < $1.rawValue })
        
        return TypeMatchup.DefensiveMatchup(
            quadrupleWeak: quadrupleWeak,
            doubleWeak: doubleWeak,
            doubleResist: doubleResist,
            quadrupleResist: quadrupleResist,
            immune: immune
        )
    }
}
```

#### 3.2.4 FetchEvolutionChainUseCaseの拡張
```swift
// 既存のUseCaseを拡張
protocol FetchEvolutionChainUseCaseProtocol {
    func execute(speciesId: Int) async throws -> EvolutionChain
}

final class FetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(speciesId: Int) async throws -> EvolutionChain {
        // PokéAPIから進化チェーン情報を取得
        let chainData = try await repository.fetchEvolutionChain(speciesId: speciesId)
        
        // ツリー構造に変換
        let rootNode = try await buildEvolutionNode(from: chainData.chain)
        
        return EvolutionChain(id: chainData.id, rootNode: rootNode)
    }
    
    private func buildEvolutionNode(from chain: EvolutionChainLink) async throws -> EvolutionNode {
        // 再帰的にノードを構築
        // 実装時に詳細化
        fatalError("Not implemented")
    }
}
```

#### 3.2.5 FetchPokemonLocationsUseCase
```swift
protocol FetchPokemonLocationsUseCaseProtocol {
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonLocation]
}

final class FetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonLocation] {
        let locations = try await repository.fetchPokemonLocations(pokemonId: pokemonId)
        
        // バージョングループでフィルタリング
        if let versionGroup = versionGroup {
            return locations.map { location in
                let filteredVersions = location.versionDetails.filter { detail in
                    belongsToVersionGroup(version: detail.version, versionGroup: versionGroup)
                }
                return PokemonLocation(
                    locationName: location.locationName,
                    versionDetails: filteredVersions
                )
            }.filter { !$0.versionDetails.isEmpty }
        }
        
        return locations
    }
    
    private func belongsToVersionGroup(version: String, versionGroup: String) -> Bool {
        // バージョンとバージョングループのマッピング
        // 実装時に詳細化
        return true
    }
}
```

#### 3.2.6 FetchAbilityDetailUseCase
```swift
protocol FetchAbilityDetailUseCaseProtocol {
    func execute(abilityId: Int) async throws -> AbilityDetail
}

final class FetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol {
    private let repository: AbilityRepositoryProtocol
    
    init(repository: AbilityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(abilityId: Int) async throws -> AbilityDetail {
        return try await repository.fetchAbilityDetail(abilityId: abilityId)
    }
}
```

#### 3.2.7 FetchFlavorTextUseCase
```swift
protocol FetchFlavorTextUseCaseProtocol {
    func execute(speciesId: Int, versionGroup: String?) async throws -> PokemonFlavorText?
}

final class FetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(speciesId: Int, versionGroup: String?) async throws -> PokemonFlavorText? {
        let species = try await repository.fetchPokemonSpecies(speciesId: speciesId)
        
        // バージョングループに対応するフレーバーテキストを取得
        if let versionGroup = versionGroup {
            return species.flavorTexts.first { text in
                text.versionGroup == versionGroup && text.language == "ja"
            }
        }
        
        // 最新のフレーバーテキストを取得
        return species.flavorTexts.first { $0.language == "ja" }
    }
}
```

### 3.3 Repository Protocol の拡張

#### 3.3.1 PokemonRepositoryProtocol
```swift
protocol PokemonRepositoryProtocol {
    // 既存メソッド
    func fetchPokemonList(versionGroup: String?, limit: Int, offset: Int) async throws -> [PokemonListItem]
    func fetchPokemonDetail(id: Int, versionGroup: String?) async throws -> Pokemon
    func fetchPokemonSpecies(speciesId: Int) async throws -> PokemonSpecies
    func fetchEvolutionChain(speciesId: Int) async throws -> EvolutionChainData
    
    // 新規メソッド
    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm]
    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation]
}
```

#### 3.3.2 TypeRepositoryProtocol（新規）
```swift
protocol TypeRepositoryProtocol {
    func fetchTypeDetail(type: PokemonType) async throws -> TypeDetail
}

struct TypeDetail: Equatable {
    let type: PokemonType
    let damageRelations: DamageRelations
    
    struct DamageRelations: Equatable {
        let doubleDamageTo: [PokemonType]
        let halfDamageTo: [PokemonType]
        let noDamageTo: [PokemonType]
        let doubleDamageFrom: [PokemonType]
        let halfDamageFrom: [PokemonType]
        let noDamageFrom: [PokemonType]
    }
}
```

#### 3.3.3 AbilityRepositoryProtocol（新規）
```swift
protocol AbilityRepositoryProtocol {
    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail
}
```

---

## 4. Data層の設計

### 4.1 Repository実装

#### 4.1.1 PokemonRepositoryの拡張
```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: PokemonAPIClientProtocol
    private let formCache: FormCacheProtocol
    private let locationCache: LocationCacheProtocol
    
    // 新規メソッドの実装
    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        // キャッシュチェック
        if let cached = await formCache.get(pokemonId: pokemonId) {
            return cached
        }
        
        // APIから取得
        let forms = try await apiClient.fetchPokemonForms(pokemonId: pokemonId)
        
        // キャッシュに保存
        await formCache.set(pokemonId: pokemonId, forms: forms)
        
        return forms
    }
    
    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation] {
        // キャッシュチェック
        if let cached = await locationCache.get(pokemonId: pokemonId) {
            return cached
        }
        
        // APIから取得
        let locations = try await apiClient.fetchPokemonLocations(pokemonId: pokemonId)
        
        // キャッシュに保存
        await locationCache.set(pokemonId: pokemonId, locations: locations)
        
        return locations
    }
}
```

#### 4.1.2 TypeRepository（新規）
```swift
final class TypeRepository: TypeRepositoryProtocol {
    private let apiClient: PokemonAPIClientProtocol
    private let cache: TypeCacheProtocol
    
    func fetchTypeDetail(type: PokemonType) async throws -> TypeDetail {
        // キャッシュチェック
        if let cached = await cache.get(type: type) {
            return cached
        }
        
        // APIから取得
        let detail = try await apiClient.fetchTypeDetail(type: type)
        
        // キャッシュに保存
        await cache.set(type: type, detail: detail)
        
        return detail
    }
}
```

#### 4.1.3 AbilityRepository（新規）
```swift
final class AbilityRepository: AbilityRepositoryProtocol {
    private let apiClient: PokemonAPIClientProtocol
    private let cache: AbilityCacheProtocol
    
    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail {
        // キャッシュチェック
        if let cached = await cache.get(abilityId: abilityId) {
            return cached
        }
        
        // APIから取得
        let detail = try await apiClient.fetchAbilityDetail(abilityId: abilityId)
        
        // キャッシュに保存
        await cache.set(abilityId: abilityId, detail: detail)
        
        return detail
    }
}
```

### 4.2 API Client の拡張

#### 4.2.1 PokemonAPIClientProtocol
```swift
protocol PokemonAPIClientProtocol {
    // 既存メソッド
    func fetchPokemonList(limit: Int, offset: Int) async throws -> PokemonListResponse
    func fetchPokemonDetail(id: Int) async throws -> PokemonDTO
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpeciesDTO
    func fetchEvolutionChain(id: Int) async throws -> EvolutionChainDTO
    
    // 新規メソッド
    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonFormDTO]
    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocationDTO]
    func fetchTypeDetail(type: PokemonType) async throws -> TypeDetailDTO
    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetailDTO
}
```

#### 4.2.2 PokéAPI エンドポイント
```swift
enum PokemonAPIEndpoint {
    case pokemonList(limit: Int, offset: Int)
    case pokemonDetail(id: Int)
    case pokemonSpecies(id: Int)
    case evolutionChain(id: Int)
    case pokemonForms(pokemonId: Int)       // 新規
    case pokemonLocations(pokemonId: Int)   // 新規
    case typeDetail(typeId: Int)            // 新規
    case abilityDetail(abilityId: Int)      // 新規
    
    var url: URL {
        let baseURL = "https://pokeapi.co/api/v2"
        
        switch self {
        case .pokemonList(let limit, let offset):
            return URL(string: "\(baseURL)/pokemon?limit=\(limit)&offset=\(offset)")!
        case .pokemonDetail(let id):
            return URL(string: "\(baseURL)/pokemon/\(id)")!
        case .pokemonSpecies(let id):
            return URL(string: "\(baseURL)/pokemon-species/\(id)")!
        case .evolutionChain(let id):
            return URL(string: "\(baseURL)/evolution-chain/\(id)")!
        case .pokemonForms(let pokemonId):
            return URL(string: "\(baseURL)/pokemon/\(pokemonId)")!  // forms情報は/pokemonに含まれる
        case .pokemonLocations(let pokemonId):
            return URL(string: "\(baseURL)/pokemon/\(pokemonId)/encounters")!
        case .typeDetail(let typeId):
            return URL(string: "\(baseURL)/type/\(typeId)")!
        case .abilityDetail(let abilityId):
            return URL(string: "\(baseURL)/ability/\(abilityId)")!
        }
    }
}
```

### 4.3 DTO（Data Transfer Object）

#### 4.3.1 PokemonFormDTO
```swift
struct PokemonFormDTO: Codable {
    let id: Int
    let name: String
    let formName: String
    let types: [TypeSlotDTO]
    let sprites: SpritesDTO
    let stats: [StatDTO]
    let abilities: [AbilitySlotDTO]
    let isDefault: Bool
    let isMega: Bool
    let versionGroup: VersionGroupDTO?
    
    // 実装時に詳細化
}
```

#### 4.3.2 TypeDetailDTO
```swift
struct TypeDetailDTO: Codable {
    let id: Int
    let name: String
    let damageRelations: DamageRelationsDTO
    
    struct DamageRelationsDTO: Codable {
        let doubleDamageTo: [TypeReferenceDTO]
        let halfDamageTo: [TypeReferenceDTO]
        let noDamageTo: [TypeReferenceDTO]
        let doubleDamageFrom: [TypeReferenceDTO]
        let halfDamageFrom: [TypeReferenceDTO]
        let noDamageFrom: [TypeReferenceDTO]
    }
    
    struct TypeReferenceDTO: Codable {
        let name: String
        let url: String
    }
}
```

#### 4.3.3 AbilityDetailDTO
```swift
struct AbilityDetailDTO: Codable {
    let id: Int
    let name: String
    let effectEntries: [EffectEntryDTO]
    let flavorTextEntries: [FlavorTextEntryDTO]
    
    struct EffectEntryDTO: Codable {
        let effect: String
        let language: LanguageDTO
    }
    
    struct FlavorTextEntryDTO: Codable {
        let flavorText: String
        let language: LanguageDTO
        let versionGroup: VersionGroupDTO
    }
    
    struct LanguageDTO: Codable {
        let name: String
    }
    
    struct VersionGroupDTO: Codable {
        let name: String
    }
}
```

#### 4.3.4 PokemonLocationDTO
```swift
struct PokemonLocationDTO: Codable {
    let locationArea: LocationAreaDTO
    let versionDetails: [VersionDetailDTO]
    
    struct LocationAreaDTO: Codable {
        let name: String
        let url: String
    }
    
    struct VersionDetailDTO: Codable {
        let version: VersionDTO
        let maxChance: Int
        let encounterDetails: [EncounterDetailDTO]
    }
    
    struct VersionDTO: Codable {
        let name: String
        let url: String
    }
    
    struct EncounterDetailDTO: Codable {
        let minLevel: Int
        let maxLevel: Int
        let method: MethodDTO
        let chance: Int
    }
    
    struct MethodDTO: Codable {
        let name: String
        let url: String
    }
}
```

### 4.4 Cache層

#### 4.4.1 FormCache
```swift
protocol FormCacheProtocol: Actor {
    func get(pokemonId: Int) -> [PokemonForm]?
    func set(pokemonId: Int, forms: [PokemonForm])
    func clear()
}

actor FormCache: FormCacheProtocol {
    private var cache: [Int: [PokemonForm]] = [:]
    
    func get(pokemonId: Int) -> [PokemonForm]? {
        return cache[pokemonId]
    }
    
    func set(pokemonId: Int, forms: [PokemonForm]) {
        cache[pokemonId] = forms
    }
    
    func clear() {
        cache.removeAll()
    }
}
```

#### 4.4.2 TypeCache
```swift
protocol TypeCacheProtocol: Actor {
    func get(type: PokemonType) -> TypeDetail?
    func set(type: PokemonType, detail: TypeDetail)
    func clear()
}

actor TypeCache: TypeCacheProtocol {
    private var cache: [PokemonType: TypeDetail] = [:]
    
    func get(type: PokemonType) -> TypeDetail? {
        return cache[type]
    }
    
    func set(type: PokemonType, detail: TypeDetail) {
        cache[type] = detail
    }
    
    func clear() {
        cache.removeAll()
    }
}
```

#### 4.4.3 AbilityCache
```swift
protocol AbilityCacheProtocol: Actor {
    func get(abilityId: Int) -> AbilityDetail?
    func set(abilityId: Int, detail: AbilityDetail)
    func clear()
}

actor AbilityCache: AbilityCacheProtocol {
    private var cache: [Int: AbilityDetail] = [:]
    
    func get(abilityId: Int) -> AbilityDetail? {
        return cache[abilityId]
    }
    
    func set(abilityId: Int, detail: AbilityDetail) {
        cache[abilityId] = detail
    }
    
    func clear() {
        cache.removeAll()
    }
}
```

#### 4.4.4 LocationCache
```swift
protocol LocationCacheProtocol: Actor {
    func get(pokemonId: Int) -> [PokemonLocation]?
    func set(pokemonId: Int, locations: [PokemonLocation])
    func clear()
}

actor LocationCache: LocationCacheProtocol {
    private var cache: [Int: [PokemonLocation]] = [:]
    
    func get(pokemonId: Int) -> [PokemonLocation]? {
        return cache[pokemonId]
    }
    
    func set(pokemonId: Int, locations: [PokemonLocation]) {
        cache[pokemonId] = locations
    }
    
    func clear() {
        cache.removeAll()
    }
}
```

---

## 5. Presentation層の設計

### 5.1 PokemonDetailViewModel の拡張

```swift
@MainActor
final class PokemonDetailViewModel: ObservableObject {
    // 既存プロパティ
    @Published var pokemon: Pokemon?
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isShiny = false
    
    // 新規プロパティ
    @Published var availableForms: [PokemonForm] = []
    @Published var selectedForm: PokemonForm?
    @Published var typeMatchup: TypeMatchup?
    @Published var calculatedStats: CalculatedStats?
    @Published var evolutionChain: EvolutionChain?
    @Published var locations: [PokemonLocation] = []
    @Published var abilityDetails: [Int: AbilityDetail] = [:]
    @Published var flavorText: PokemonFlavorText?
    
    // セクションの展開状態
    @Published var isSectionExpanded: [String: Bool] = [
        "forms": true,
        "typeMatchup": true,
        "flavorText": true,
        "evolution": true,
        "locations": true,
        "baseStats": true,
        "calculatedStats": true,
        "abilities": true,
        "moves": true
    ]
    
    private let fetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol
    private let fetchPokemonFormsUseCase: FetchPokemonFormsUseCaseProtocol
    private let fetchTypeMatchupUseCase: FetchTypeMatchupUseCaseProtocol
    private let calculateStatsUseCase: CalculateStatsUseCaseProtocol
    private let fetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol
    private let fetchPokemonLocationsUseCase: FetchPokemonLocationsUseCaseProtocol
    private let fetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol
    private let fetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol
    
    private let versionGroup: String?
    
    // init, メソッドの実装は実装時に詳細化
}
```

### 5.2 View Components概要

#### 5.2.1 PokemonDetailView
- 全セクションを統合する親View
- ScrollViewで縦スクロール
- 10個のセクションを順番に配置

#### 5.2.2 PokemonFormSelectorSection
- ドロップダウンでフォーム選択
- 選択中のフォームにチェックマーク

#### 5.2.3 TypeMatchupView
- 攻撃面・防御面の相性表示
- 倍率ごとに色分け

#### 5.2.4 EvolutionChainView
- 横方向のツリー表示
- ノードカード、進化矢印

#### 5.2.5 CalculatedStatsView
- 5パターンの実数値を表形式で表示

#### 5.2.6 AbilitiesView
- 通常特性・隠れ特性を分けて表示
- 特性の説明文も表示

#### 5.2.7 MovesView
- 習得方法別にセクション分け
- 技の詳細情報を一覧表示（名前、タイプ、分類、威力、命中率、PP、説明文）
- 説明文はPokéAPIのeffectテキストを使用

#### 5.2.8 共通コンポーネント
- ExpandableSection: 折りたたみ可能なセクション
- FlowLayout: タイプバッジの横並び表示用

---

## 6. DIContainer の更新

### 6.1 新規依存関係の登録

```swift
final class DIContainer {
    static let shared = DIContainer()
    
    // 既存キャッシュ
    private let pokemonCache: PokemonCacheProtocol
    private let moveCache: MoveCacheProtocol
    
    // 新規キャッシュ
    private let formCache: FormCacheProtocol
    private let typeCache: TypeCacheProtocol
    private let abilityCache: AbilityCacheProtocol
    private let locationCache: LocationCacheProtocol
    
    // APIクライアント
    private let apiClient: PokemonAPIClientProtocol
    
    // 既存リポジトリ
    private let pokemonRepository: PokemonRepositoryProtocol
    private let moveRepository: MoveRepositoryProtocol
    
    // 新規リポジトリ
    private let typeRepository: TypeRepositoryProtocol
    private let abilityRepository: AbilityRepositoryProtocol
    
    // 初期化、ファクトリメソッドの実装は実装時に詳細化
}
```

---

## 7. テスト設計

### 7.1 テスト戦略

#### 7.1.1 テストレベル
1. **ユニットテスト**: 個別のクラス・メソッドをテスト
2. **統合テスト**: 複数のコンポーネント間の連携をテスト
3. **パフォーマンステスト**: 処理速度とメモリ使用量を検証

#### 7.1.2 テストカバレッジ目標
- Domain層: 90%以上
- Presentation層: 85%以上
- Data層: 80%以上
- 全体: 80%以上

#### 7.1.3 テストの原則
- 各テストは独立して実行可能
- テストデータは明示的に定義
- Mockオブジェクトを活用
- Given-When-Thenパターンに従う

### 7.2 ユニットテスト

#### 7.2.1 Domain層のテスト

**CalculateStatsUseCaseTests**
```swift
final class CalculateStatsUseCaseTests: XCTestCase {
    var sut: CalculateStatsUseCase!
    
    override func setUp() {
        super.setUp()
        sut = CalculateStatsUseCase()
    }
    
    // テストケース
    func testCalculateStats_理想個体() {
        // Given: フシギダネの種族値
        let baseStats = [
            PokemonStat(name: "hp", baseStat: 45),
            PokemonStat(name: "attack", baseStat: 49),
            PokemonStat(name: "defense", baseStat: 49),
            PokemonStat(name: "special-attack", baseStat: 65),
            PokemonStat(name: "special-defense", baseStat: 65),
            PokemonStat(name: "speed", baseStat: 45)
        ]
        
        // When
        let result = sut.execute(baseStats: baseStats)
        
        // Then
        let ideal = result.patterns.first { $0.id == "ideal" }
        XCTAssertNotNil(ideal)
        XCTAssertEqual(ideal?.hp, 150)  // 計算式で検証
        XCTAssertEqual(ideal?.attack, 112)
        // ... 他のステータスも検証
    }
    
    func testCalculateStats_252振り()
    func testCalculateStats_無振り()
    func testCalculateStats_最低()
    func testCalculateStats_下降()
    func testCalculateStats_全パターン数()
    func testCalculateHP_正しい計算式()
    func testCalculateStat_性格補正上昇()
    func testCalculateStat_性格補正下降()
}
```

**FetchTypeMatchupUseCaseTests**
```swift
final class FetchTypeMatchupUseCaseTests: XCTestCase {
    var sut: FetchTypeMatchupUseCase!
    var mockRepository: MockTypeRepository!
    
    override func setUp() {
        super.setUp()
        mockRepository = MockTypeRepository()
        sut = FetchTypeMatchupUseCase(repository: mockRepository)
    }
    
    func testFetchTypeMatchup_単タイプ_ほのお() async throws {
        // Given: ほのおタイプのデータをモック
        mockRepository.typeDetails = [
            .fire: TypeDetail(
                type: .fire,
                damageRelations: DamageRelations(
                    doubleDamageTo: [.grass, .ice, .bug, .steel],
                    halfDamageTo: [.fire, .water, .rock, .dragon],
                    noDamageTo: [],
                    doubleDamageFrom: [.water, .ground, .rock],
                    halfDamageFrom: [.fire, .grass, .ice, .bug, .steel, .fairy],
                    noDamageFrom: []
                )
            )
        ]
        
        // When
        let result = try await sut.execute(types: [.fire])
        
        // Then: 攻撃面
        XCTAssertEqual(result.offensive.superEffective.count, 4)
        XCTAssertTrue(result.offensive.superEffective.contains(.grass))
        XCTAssertTrue(result.offensive.superEffective.contains(.ice))
        
        // Then: 防御面
        XCTAssertEqual(result.defensive.doubleWeak.count, 3)
        XCTAssertTrue(result.defensive.doubleWeak.contains(.water))
        XCTAssertTrue(result.defensive.doubleWeak.contains(.ground))
        XCTAssertTrue(result.defensive.doubleWeak.contains(.rock))
    }
    
    func testFetchTypeMatchup_複合タイプ_4倍弱点() async throws {
        // Given: ほのお・ひこうタイプ（リザードン）
        // いわタイプが4倍弱点になることを検証
        
        // When
        let result = try await sut.execute(types: [.fire, .flying])
        
        // Then
        XCTAssertTrue(result.defensive.quadrupleWeak.contains(.rock))
    }
    
    func testFetchTypeMatchup_複合タイプ_4倍耐性()
    func testOffensiveMatchup_重複除去()
    func testDefensiveMatchup_タイプ番号順ソート()
    func testDefensiveMatchup_無効タイプ()
}
```

**FetchPokemonFormsUseCaseTests**
```swift
final class FetchPokemonFormsUseCaseTests: XCTestCase {
    var sut: FetchPokemonFormsUseCase!
    var mockRepository: MockPokemonRepository!
    
    func testExecute_バージョングループなし_全フォーム取得() async throws {
        // Given
        let allForms = [
            PokemonForm(id: 1, formName: "normal", isMega: false),
            PokemonForm(id: 2, formName: "mega-x", isMega: true),
            PokemonForm(id: 3, formName: "mega-y", isMega: true)
        ]
        mockRepository.formsResult = .success(allForms)
        
        // When
        let result = try await sut.execute(pokemonId: 6, versionGroup: nil)
        
        // Then
        XCTAssertEqual(result.count, 3)
    }
    
    func testExecute_XYバージョン_メガシンカあり() async throws {
        // メガシンカフォームが含まれることを検証
    }
    
    func testExecute_赤緑バージョン_メガシンカなし() async throws {
        // メガシンカフォームが除外されることを検証
    }
}
```

**その他のUseCaseTests**
- FetchEvolutionChainUseCaseTests
- FetchPokemonLocationsUseCaseTests
- FetchAbilityDetailUseCaseTests
- FetchFlavorTextUseCaseTests

#### 7.2.2 Presentation層のテスト

**PokemonDetailViewModelTests**
```swift
@MainActor
final class PokemonDetailViewModelTests: XCTestCase {
    var sut: PokemonDetailViewModel!
    var mockFetchPokemonDetailUseCase: MockFetchPokemonDetailUseCase!
    var mockFetchPokemonFormsUseCase: MockFetchPokemonFormsUseCase!
    var mockFetchTypeMatchupUseCase: MockFetchTypeMatchupUseCase!
    var mockCalculateStatsUseCase: MockCalculateStatsUseCase!
    var mockFetchEvolutionChainUseCase: MockFetchEvolutionChainUseCase!
    var mockFetchPokemonLocationsUseCase: MockFetchPokemonLocationsUseCase!
    var mockFetchAbilityDetailUseCase: MockFetchAbilityDetailUseCase!
    var mockFetchFlavorTextUseCase: MockFetchFlavorTextUseCase!
    
    override func setUp() {
        super.setUp()
        // Mockオブジェクトの初期化
        mockFetchPokemonDetailUseCase = MockFetchPokemonDetailUseCase()
        mockFetchPokemonFormsUseCase = MockFetchPokemonFormsUseCase()
        mockFetchTypeMatchupUseCase = MockFetchTypeMatchupUseCase()
        mockCalculateStatsUseCase = MockCalculateStatsUseCase()
        mockFetchEvolutionChainUseCase = MockFetchEvolutionChainUseCase()
        mockFetchPokemonLocationsUseCase = MockFetchPokemonLocationsUseCase()
        mockFetchAbilityDetailUseCase = MockFetchAbilityDetailUseCase()
        mockFetchFlavorTextUseCase = MockFetchFlavorTextUseCase()
        
        sut = PokemonDetailViewModel(
            fetchPokemonDetailUseCase: mockFetchPokemonDetailUseCase,
            fetchPokemonFormsUseCase: mockFetchPokemonFormsUseCase,
            fetchTypeMatchupUseCase: mockFetchTypeMatchupUseCase,
            calculateStatsUseCase: mockCalculateStatsUseCase,
            fetchEvolutionChainUseCase: mockFetchEvolutionChainUseCase,
            fetchPokemonLocationsUseCase: mockFetchPokemonLocationsUseCase,
            fetchAbilityDetailUseCase: mockFetchAbilityDetailUseCase,
            fetchFlavorTextUseCase: mockFetchFlavorTextUseCase,
            versionGroup: nil
        )
    }
    
    func testLoadPokemonDetail_成功_全データ取得() async {
        // Given
        let pokemon = Pokemon(/* テストデータ */)
        let forms = [PokemonForm(/* テストデータ */)]
        let chain = EvolutionChain(/* テストデータ */)
        
        mockFetchPokemonDetailUseCase.result = .success(pokemon)
        mockFetchPokemonFormsUseCase.result = .success(forms)
        mockFetchEvolutionChainUseCase.result = .success(chain)
        
        // When
        await sut.loadPokemonDetail(id: 1)
        
        // Then
        XCTAssertNotNil(sut.pokemon)
        XCTAssertFalse(sut.availableForms.isEmpty)
        XCTAssertNotNil(sut.selectedForm)
        XCTAssertNotNil(sut.evolutionChain)
        XCTAssertFalse(sut.isLoading)
        XCTAssertNil(sut.error)
    }
    
    func testLoadPokemonDetail_失敗_エラー設定() async {
        // Given
        mockFetchPokemonDetailUseCase.result = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        
        // When
        await sut.loadPokemonDetail(id: 1)
        
        // Then
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testSelectForm_タイプ相性更新() async {
        // Given: 初期データロード
        await setupInitialData()
        let newForm = PokemonForm(/* 異なるタイプのフォーム */)
        mockFetchTypeMatchupUseCase.result = .success(TypeMatchup(/* 新しいタイプ相性 */))
        
        // When
        await sut.selectForm(newForm)
        
        // Then
        XCTAssertEqual(sut.selectedForm?.id, newForm.id)
        XCTAssertNotNil(sut.typeMatchup)
        XCTAssertEqual(mockFetchTypeMatchupUseCase.callCount, 2) // 初回+フォーム切り替え
    }
    
    func testSelectForm_実数値更新() async
    func testSelectForm_特性詳細更新() async
    func testToggleShiny_状態切り替え()
    func testToggleSection_展開状態切り替え()
    func testLoadAbilityDetails_並列取得() async
    func testLoadFormDependentData_複数UseCase並列実行() async
}
```

#### 7.2.3 Data層のテスト

**Cache層のテスト**
```swift
// FormCacheTests
final class FormCacheTests: XCTestCase {
    var sut: FormCache!
    
    override func setUp() async throws {
        sut = FormCache()
    }
    
    func testGet_キャッシュなし_nilを返す() async {
        // When
        let result = await sut.get(pokemonId: 1)
        
        // Then
        XCTAssertNil(result)
    }
    
    func testSetAndGet_正常に保存と取得() async {
        // Given
        let forms = [PokemonForm(id: 1, formName: "normal")]
        
        // When
        await sut.set(pokemonId: 1, forms: forms)
        let result = await sut.get(pokemonId: 1)
        
        // Then
        XCTAssertEqual(result?.count, 1)
        XCTAssertEqual(result?.first?.id, 1)
    }
    
    func testClear_全データ削除() async {
        // Given
        await sut.set(pokemonId: 1, forms: [PokemonForm(id: 1)])
        await sut.set(pokemonId: 2, forms: [PokemonForm(id: 2)])
        
        // When
        await sut.clear()
        
        // Then
        let result1 = await sut.get(pokemonId: 1)
        let result2 = await sut.get(pokemonId: 2)
        XCTAssertNil(result1)
        XCTAssertNil(result2)
    }
    
    func testConcurrentAccess_スレッドセーフ() async {
        // Actorのスレッドセーフ性を検証
    }
}

// TypeCacheTests, AbilityCacheTests, LocationCacheTests も同様の構造
```

**Repository層のテスト**
```swift
final class PokemonRepositoryTests: XCTestCase {
    var sut: PokemonRepository!
    var mockApiClient: MockPokemonAPIClient!
    var mockFormCache: MockFormCache!
    var mockLocationCache: MockLocationCache!
    
    override func setUp() {
        super.setUp()
        mockApiClient = MockPokemonAPIClient()
        mockFormCache = MockFormCache()
        mockLocationCache = MockLocationCache()
        
        sut = PokemonRepository(
            apiClient: mockApiClient,
            formCache: mockFormCache,
            locationCache: mockLocationCache
        )
    }
    
    func testFetchPokemonForms_キャッシュヒット_APIを呼ばない() async throws {
        // Given
        let cachedForms = [PokemonForm(id: 1, formName: "normal")]
        mockFormCache.forms[1] = cachedForms
        
        // When
        let result = try await sut.fetchPokemonForms(pokemonId: 1)
        
        // Then
        XCTAssertEqual(result, cachedForms)
        XCTAssertEqual(mockApiClient.fetchPokemonFormsCallCount, 0)
    }
    
    func testFetchPokemonForms_キャッシュミス_APIを呼ぶ() async throws {
        // Given
        let apiForms = [PokemonForm(id: 1, formName: "normal")]
        mockApiClient.fetchPokemonFormsResult = .success(apiForms)
        
        // When
        let result = try await sut.fetchPokemonForms(pokemonId: 1)
        
        // Then
        XCTAssertEqual(result, apiForms)
        XCTAssertEqual(mockApiClient.fetchPokemonFormsCallCount, 1)
        
        // キャッシュに保存されたか確認
        XCTAssertEqual(mockFormCache.forms[1], apiForms)
    }
    
    func testFetchPokemonForms_APIエラー_エラーをスロー() async {
        // Given
        mockApiClient.fetchPokemonFormsResult = .failure(PokemonError.networkError(URLError(.notConnectedToInternet)))
        
        // When & Then
        do {
            _ = try await sut.fetchPokemonForms(pokemonId: 1)
            XCTFail("エラーがスローされるべき")
        } catch {
            XCTAssertTrue(error is PokemonError)
        }
    }
    
    func testFetchPokemonLocations_成功()
}

// TypeRepositoryTests, AbilityRepositoryTests も同様の構造
```

### 7.3 統合テスト

#### 7.3.1 FormSwitchingIntegrationTests
```swift
@MainActor
final class FormSwitchingIntegrationTests: XCTestCase {
    var container: DIContainer!
    var viewModel: PokemonDetailViewModel!
    
    override func setUp() {
        super.setUp()
        container = DIContainer.shared
    }
    
    func testFormSwitching_通常からメガシンカへ切り替え() async throws {
        // Given: X-Yバージョングループ
        viewModel = container.makePokemonDetailViewModel(versionGroup: "x-y")
        
        // When: リザードンをロード
        await viewModel.loadPokemonDetail(id: 6)
        
        // Then: 通常フォームが選択されている
        XCTAssertNotNil(viewModel.pokemon)
        XCTAssertTrue(viewModel.selectedForm?.isDefault ?? false)
        
        // 通常フォームのタイプ（ほのお・ひこう）
        XCTAssertEqual(viewModel.selectedForm?.types.count, 2)
        XCTAssertTrue(viewModel.selectedForm?.types.contains(.fire) ?? false)
        XCTAssertTrue(viewModel.selectedForm?.types.contains(.flying) ?? false)
        
        // When: メガリザードンXに切り替え
        let megaXForm = viewModel.availableForms.first { 
            $0.isMega && $0.formName.contains("mega-x") 
        }
        XCTAssertNotNil(megaXForm)
        
        await viewModel.selectForm(megaXForm!)
        
        // Then: タイプが変化（ほのお・ドラゴン）
        XCTAssertTrue(viewModel.selectedForm?.types.contains(.fire) ?? false)
        XCTAssertTrue(viewModel.selectedForm?.types.contains(.dragon) ?? false)
        XCTAssertFalse(viewModel.selectedForm?.types.contains(.flying) ?? false)
        
        // タイプ相性が更新されている
        XCTAssertNotNil(viewModel.typeMatchup)
        XCTAssertTrue(viewModel.typeMatchup?.defensive.doubleWeak.contains(.dragon) ?? false)
        
        // 実数値が更新されている
        XCTAssertNotNil(viewModel.calculatedStats)
        
        // 種族値が変化している
        let megaAttack = viewModel.selectedForm?.stats.first { $0.name == "attack" }?.baseStat
        XCTAssertNotNil(megaAttack)
        XCTAssertGreaterThan(megaAttack ?? 0, 84)
    }
}
```

#### 7.3.2 VersionGroupFilteringIntegrationTests
```swift
@MainActor
final class VersionGroupFilteringIntegrationTests: XCTestCase {
    var container: DIContainer!
    
    func testVersionGroupFiltering_赤緑ではメガシンカなし() async throws {
        // Given
        let viewModel = container.makePokemonDetailViewModel(versionGroup: "red-blue")
        
        // When
        await viewModel.loadPokemonDetail(id: 6)
        
        // Then
        let megaForms = viewModel.availableForms.filter { $0.isMega }
        XCTAssertTrue(megaForms.isEmpty)
    }
    
    func testVersionGroupFiltering_XYではメガシンカあり() async throws
}
```

#### 7.3.3 DataFlowIntegrationTests
```swift
@MainActor
final class DataFlowIntegrationTests: XCTestCase {
    func testDataFlow_ポケモン詳細取得からUI表示まで() async throws {
        // 全体のデータフローを検証
    }
}
```

#### 7.3.4 AbilityLoadingIntegrationTests
```swift
@MainActor
final class AbilityLoadingIntegrationTests: XCTestCase {
    func testAbilityLoading_並列取得() async throws {
        // 特性詳細の並列取得を検証
    }
}
```

### 7.4 パフォーマンステスト

#### 7.4.1 LoadPokemonDetailPerformanceTests
```swift
@MainActor
final class LoadPokemonDetailPerformanceTests: XCTestCase {
    var container: DIContainer!
    var viewModel: PokemonDetailViewModel!
    
    func testLoadPokemonDetail_初回ロード() {
        // 目標: 3秒以内
        measure {
            Task {
                await viewModel.loadPokemonDetail(id: 1)
            }
        }
    }
    
    func testLoadPokemonDetail_キャッシュあり() async {
        // 目標: 1秒以内
    }
    
    func testSelectForm_フォーム切り替え() async {
        // 目標: 0.5秒以内
    }
}
```

#### 7.4.2 CalculateStatsPerformanceTests
```swift
final class CalculateStatsPerformanceTests: XCTestCase {
    func testCalculateStats_単一ポケモン() {
        // 目標: 0.001秒以内
    }
    
    func testCalculateStats_151匹全て() {
        // 目標: 0.2秒以内
    }
}
```

#### 7.4.3 TypeMatchupPerformanceTests
```swift
final class TypeMatchupPerformanceTests: XCTestCase {
    func testFetchTypeMatchup_単タイプ() async {
        // 目標: 0.01秒以内
    }
    
    func testFetchTypeMatchup_複合タイプ() async {
        // 目標: 0.02秒以内
    }
}
```

#### 7.4.4 CachePerformanceTests
```swift
final class CachePerformanceTests: XCTestCase {
    func testFormCache_大量データ保存取得() async {
        // 保存目標: 0.1秒以内
        // 取得目標: 0.05秒以内
    }
}
```

### 7.5 テストデータ

#### 7.5.1 テスト用ポケモンデータ
- フシギダネ（ID: 1）: 基本的な進化チェーンのテスト
- リザードン（ID: 6）: メガシンカのテスト
- イーブイ（ID: 133）: 分岐進化のテスト
- ロトム（ID: 479）: フォルムチェンジのテスト

#### 7.5.2 Mockオブジェクト
```swift
// MockPokemonRepository
final class MockPokemonRepository: PokemonRepositoryProtocol {
    var formsResult: Result<[PokemonForm], Error>!
    var locationsResult: Result<[PokemonLocation], Error>!
    var callCount = 0
    
    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm] {
        callCount += 1
        return try formsResult.get()
    }
}

// MockTypeRepository
// MockAbilityRepository
// など、各Repositoryに対応するMock
```

### 7.6 テスト実行

#### 7.6.1 ローカル実行
```bash
# 全テスト実行
xcodebuild test -scheme Pokedex -destination 'platform=iOS Simulator,name=iPhone 15 Pro'

# 特定のテストクラスのみ実行
xcodebuild test -scheme Pokedex -only-testing:PokedexTests/CalculateStatsUseCaseTests

# カバレッジレポート生成
xcodebuild test -scheme Pokedex -enableCodeCoverage YES
```

#### 7.6.2 CI/CD統合
- GitHub Actionsでプルリクエスト時に自動実行
- カバレッジレポートを自動生成
- カバレッジが80%を下回る場合は警告

---

## 8. エラーハンドリング

### 8.1 エラー定義

```swift
enum PokemonError: LocalizedError {
    case networkError(Error)
    case decodingError(Error)
    case notFound
    case invalidVersionGroup
    case cacheError
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "ネットワークエラー: \(error.localizedDescription)"
        case .decodingError:
            return "データの解析に失敗しました"
        case .notFound:
            return "ポケモンが見つかりませんでした"
        case .invalidVersionGroup:
            return "無効なバージョングループです"
        case .cacheError:
            return "キャッシュエラーが発生しました"
        }
    }
}
```

### 8.2 エラー表示
- ErrorView: エラーメッセージと再試行ボタン
- ViewModelでのエラーハンドリング: try-catchで適切に処理

---

## 9. PokéAPI調査項目

以下の項目について、実装前にPokéAPIの仕様を詳細調査する必要がある：

### 9.1 進化条件の詳細度
- 取得可能な進化トリガーの種類
- 進化条件の詳細情報（レベル、持ち物、時間帯、場所など）
- 条件の組み合わせパターン

### 9.2 フォーム情報の構造
- リージョンフォームの識別方法
- メガシンカの識別方法
- フォルムチェンジの識別方法
- バージョングループごとのフォーム存在判定

### 9.3 特性・技の説明文
- effectテキストの日本語対応状況
- flavorTextとeffectの違い
- 言語コードの仕様

### 9.4 生息地情報
- 出現場所データの構造
- バージョングループとの関連付け
- 出現率・レベル範囲の取得方法

### 9.5 TM/HM/TR番号
- バージョンごとのTM番号管理方法
- HMの世代判定
- TRの存在判定（剣盾以降）

### 9.6 タイプ相性
- タイプ相性データの取得方法
- 複合タイプの計算ロジック
- 世代ごとのタイプ相性の違い

---

## 10. 実装順序

### フェーズ1: データ層の拡充
1. PokéAPI調査
2. Entity実装
3. Repository実装
4. DTO実装とAPI Client拡張
5. Cache実装

### フェーズ2: Domain層の実装
1. CalculateStatsUseCase実装
2. FetchTypeMatchupUseCase実装
3. その他UseCase実装

### フェーズ3: Presentation層の基本機能実装
1. PokemonDetailViewModel拡張
2. フォルム切り替えUI実装
3. 基本情報セクション拡張

### フェーズ4: 高度な表示機能実装
1. タイプ相性表示実装
2. 進化ルート表示実装
3. 図鑑説明と生息地表示実装

### フェーズ5: 実数値と特性表示実装
1. 実数値表示実装
2. 特性表示実装

### フェーズ6: 技一覧表示実装
1. 技一覧表示実装

### フェーズ7: 共通コンポーネントとUI改善
1. 共通コンポーネント実装
2. PokemonDetailView統合

### フェーズ8: DIContainer更新とテスト実装
1. DIContainer更新
2. ユニットテスト実装
3. 統合テストとパフォーマンステスト

### フェーズ9: エラーハンドリングと最終調整
1. エラーハンドリング実装
2. パフォーマンス最適化
3. 最終調整とドキュメント更新

---

**以上**