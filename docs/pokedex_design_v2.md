# Pokedex-SwiftUI 設計書 v2.0

**作成日:** 2025-10-05  
**バージョン:** 2.0.0  
**対象:** 機能拡張・改善フェーズ

---

## 📝 改訂履歴

| バージョン | 日付 | 変更内容 |
|----------|------|---------|
| 2.0.0 | 2025-10-05 | 初版作成。バージョングループ別表示、全ポケモン対応、フィルター・ソート機能拡張の設計 |

---

## 🎯 概要

本設計書は、[requirements_v2.md](./requirements_v2.md)で定義された要件に基づき、Clean Architecture + MVVM パターンを維持しながら機能拡張を実現するための技術設計を記述します。

---

## 🏗️ アーキテクチャ概要

既存のClean Architecture構成を維持しつつ、以下の層で拡張を行います:

```
Presentation Layer (SwiftUI Views + ViewModels)
    ↓↑ 新機能: バージョングループ選択、ソート、フィルター拡張
Domain Layer (Entities + UseCases + Protocols)
    ↓↑ 新機能: 世代対応、技・特性フィルター
Data Layer (Repositories + API Clients + Cache)
    ↓↑ 新機能: バージョングループ別データ取得、Kingfisher統合
External Services (PokéAPI)
```

---

## 📦 Domain層の設計

### 1. Entity拡張

#### 1.1 PokemonListItemEntity の拡張

**現状:**
```swift
struct PokemonListItemEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let spriteUrl: String
}
```

**v2.0 拡張:**
```swift
struct PokemonListItemEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let spriteUrl: String
    
    // v2.0 追加項目
    let abilities: [AbilityInfo]      // 特性情報
    let baseStats: BaseStats           // 種族値
    let generation: Int                // 初登場世代
}
```

#### 1.2 新しいEntity: AbilityInfo

```swift
struct AbilityInfo: Equatable {
    let name: String
    let isHidden: Bool
}
```

**用途:**
- 通常特性と隠れ特性を区別
- 表示形式: `特性: [通常] [隠れ]`

#### 1.3 新しいEntity: BaseStats

```swift
struct BaseStats: Equatable {
    let hp: Int
    let attack: Int
    let defense: Int
    let specialAttack: Int
    let specialDefense: Int
    let speed: Int
    
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }
    
    // 表示用フォーマット: "45-49-49-65-65-45 (318)"
    var displayString: String {
        "\(hp)-\(attack)-\(defense)-\(specialAttack)-\(specialDefense)-\(speed) (\(total))"
    }
}
```

#### 1.4 新しいEntity: VersionGroup (実装済み)

```swift
struct VersionGroup: Identifiable, Equatable {
    let id: String                           // "red-blue", "scarlet-violet", "national"
    let name: String                         // "赤・緑・青"
    let generation: Int                      // 世代番号 (1-9)
    let pokedexNames: [String]?              // ["kanto"], nilは全国図鑑

    static let nationalDex = VersionGroup(
        id: "national",
        name: "全国図鑑",
        generation: 9,
        pokedexNames: nil
    )
}
```

**バージョングループデータ:**
- 静的に定義された22個のバージョングループ
- `VersionGroup.allVersionGroups` で全リストを取得

**実装例 (実装済み):**
```swift
// VersionGroup.swift で静的に定義
static let allVersionGroups: [VersionGroup] = [
    .nationalDex,
    .redBlue,
    .yellow,
    .goldSilver,
    // ... 全22個
]
```

#### 1.5 新しいEntity: MoveEntity

```swift
struct MoveEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let type: PokemonType
    let generation: Int  // この技が登場した世代
}
```

#### 1.6 新しいEntity: MoveLearnMethod

```swift
enum MoveLearnMethodType: Equatable {
    case levelUp(level: Int)
    case machine(number: String)  // "TM15", "TR03" など
    case egg
    case tutor
    case evolution
    case form  // フォルムチェンジ時
}

struct MoveLearnMethod: Equatable {
    let move: MoveEntity
    let method: MoveLearnMethodType
    let generation: Int  // この方法でこの技を習得できる世代
}
```

#### 1.7 新しいEnum: SortOption

```swift
enum SortOption: Equatable {
    case pokedexNumber
    case name(ascending: Bool)
    case totalStats(ascending: Bool)
    case hp(ascending: Bool)
    case attack(ascending: Bool)
    case defense(ascending: Bool)
    case specialAttack(ascending: Bool)
    case specialDefense(ascending: Bool)
    case speed(ascending: Bool)
    
    var displayName: String {
        switch self {
        case .pokedexNumber:
            return "図鑑番号"
        case .name(let ascending):
            return "名前\(ascending ? "↑" : "↓")"
        case .totalStats(let ascending):
            return "種族値合計\(ascending ? "↑" : "↓")"
        case .hp(let ascending):
            return "HP\(ascending ? "↑" : "↓")"
        case .attack(let ascending):
            return "攻撃\(ascending ? "↑" : "↓")"
        case .defense(let ascending):
            return "防御\(ascending ? "↑" : "↓")"
        case .specialAttack(let ascending):
            return "特攻\(ascending ? "↑" : "↓")"
        case .specialDefense(let ascending):
            return "特防\(ascending ? "↑" : "↓")"
        case .speed(let ascending):
            return "素早さ\(ascending ? "↑" : "↓")"
        }
    }
}
```

#### 1.8 SearchFilterEntity の拡張

**現状:**
```swift
struct SearchFilterEntity {
    var searchText: String
    var selectedTypes: Set<PokemonType>
}
```

**v2.0 拡張:**
```swift
struct SearchFilterEntity {
    var searchText: String
    var selectedTypes: Set<PokemonType>
    
    // v2.0 追加
    var selectedAbilities: Set<String>
    var selectedMoves: [MoveEntity]
    
    var hasActiveFilter: Bool {
        !searchText.isEmpty || 
        !selectedTypes.isEmpty || 
        !selectedAbilities.isEmpty ||
        !selectedMoves.isEmpty
    }
}
```

---

### 2. UseCase拡張・新規作成

#### 2.1 FetchPokemonListUseCase (実装済み)

**インターフェース:**
```swift
protocol FetchPokemonListUseCaseProtocol {
    func execute() async throws -> [Pokemon]
}
```

**実装:**
```swift
final class FetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Pokemon] {
        // リポジトリから全ポケモンリストを取得
        return try await repository.fetchPokemonList(
            limit: 151,
            offset: 0,
            progressHandler: nil
        )
    }
}
```

#### 2.2 新しいUseCase: SortPokemonUseCase

```swift
protocol SortPokemonUseCase {
    func execute(
        pokemonList: [PokemonListItemEntity],
        sortOption: SortOption
    ) -> [PokemonListItemEntity]
}

final class DefaultSortPokemonUseCase: SortPokemonUseCase {
    func execute(
        pokemonList: [PokemonListItemEntity],
        sortOption: SortOption
    ) -> [PokemonListItemEntity] {
        
        switch sortOption {
        case .pokedexNumber:
            return pokemonList.sorted { $0.id < $1.id }
            
        case .name(let ascending):
            return pokemonList.sorted { 
                ascending ? $0.name < $1.name : $0.name > $1.name 
            }
            
        case .totalStats(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.total < $1.baseStats.total
                    : $0.baseStats.total > $1.baseStats.total
            }
            
        case .hp(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.hp < $1.baseStats.hp
                    : $0.baseStats.hp > $1.baseStats.hp
            }
            
        case .attack(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.attack < $1.baseStats.attack
                    : $0.baseStats.attack > $1.baseStats.attack
            }
            
        case .defense(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.defense < $1.baseStats.defense
                    : $0.baseStats.defense > $1.baseStats.defense
            }
            
        case .specialAttack(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.specialAttack < $1.baseStats.specialAttack
                    : $0.baseStats.specialAttack > $1.baseStats.specialAttack
            }
            
        case .specialDefense(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.specialDefense < $1.baseStats.specialDefense
                    : $0.baseStats.specialDefense > $1.baseStats.specialDefense
            }
            
        case .speed(let ascending):
            return pokemonList.sorted {
                ascending 
                    ? $0.baseStats.speed < $1.baseStats.speed
                    : $0.baseStats.speed > $1.baseStats.speed
            }
        }
    }
}
```

#### 2.3 新しいUseCase: FilterPokemonByAbilityUseCase

```swift
protocol FilterPokemonByAbilityUseCase {
    func execute(
        pokemonList: [PokemonListItemEntity],
        selectedAbilities: Set<String>
    ) -> [PokemonListItemEntity]
}

final class DefaultFilterPokemonByAbilityUseCase: FilterPokemonByAbilityUseCase {
    func execute(
        pokemonList: [PokemonListItemEntity],
        selectedAbilities: Set<String>
    ) -> [PokemonListItemEntity] {
        
        guard !selectedAbilities.isEmpty else {
            return pokemonList
        }
        
        return pokemonList.filter { pokemon in
            // 通常特性・隠れ特性の両方をチェック
            pokemon.abilities.contains { ability in
                selectedAbilities.contains(ability.name)
            }
        }
    }
}
```

#### 2.4 新しいUseCase: FilterPokemonByMovesUseCase

```swift
protocol FilterPokemonByMovesUseCase {
    func execute(
        pokemonList: [PokemonListItemEntity],
        selectedMoves: [MoveEntity],
        generation: Int
    ) async throws -> [(pokemon: PokemonListItemEntity, learnMethods: [MoveLearnMethod])]
}

final class DefaultFilterPokemonByMovesUseCase: FilterPokemonByMovesUseCase {
    private let moveRepository: MoveRepository
    
    init(moveRepository: MoveRepository) {
        self.moveRepository = moveRepository
    }
    
    func execute(
        pokemonList: [PokemonListItemEntity],
        selectedMoves: [MoveEntity],
        generation: Int
    ) async throws -> [(pokemon: PokemonListItemEntity, learnMethods: [MoveLearnMethod])] {
        
        guard !selectedMoves.isEmpty else {
            return pokemonList.map { ($0, []) }
        }
        
        var results: [(PokemonListItemEntity, [MoveLearnMethod])] = []
        
        for pokemon in pokemonList {
            // このポケモンが選択された技をすべて習得できるか確認
            let learnMethods = try await moveRepository.fetchLearnMethods(
                pokemonId: pokemon.id,
                moveIds: selectedMoves.map { $0.id },
                generation: generation
            )
            
            // すべての技を習得できる場合のみ結果に含める
            if learnMethods.count == selectedMoves.count {
                results.append((pokemon, learnMethods))
            }
        }
        
        return results
    }
}
```

#### 2.5 新しいUseCase: FetchAllAbilitiesUseCase

```swift
protocol FetchAllAbilitiesUseCase {
    func execute(generation: Int?) async throws -> [String]
}

final class DefaultFetchAllAbilitiesUseCase: FetchAllAbilitiesUseCase {
    private let abilityRepository: AbilityRepository
    
    init(abilityRepository: AbilityRepository) {
        self.abilityRepository = abilityRepository
    }
    
    func execute(generation: Int?) async throws -> [String] {
        return try await abilityRepository.fetchAllAbilities(generation: generation)
    }
}
```

#### 2.6 新しいUseCase: FetchAllMovesUseCase

```swift
protocol FetchAllMovesUseCase {
    func execute(generation: Int?) async throws -> [MoveEntity]
}

final class DefaultFetchAllMovesUseCase: FetchAllMovesUseCase {
    private let moveRepository: MoveRepository
    
    init(moveRepository: MoveRepository) {
        self.moveRepository = moveRepository
    }
    
    func execute(generation: Int?) async throws -> [MoveEntity] {
        return try await moveRepository.fetchAllMoves(generation: generation)
    }
}
```

#### 2.7 新しいUseCase: FetchVersionGroupsUseCase (実装済み)

```swift
protocol FetchVersionGroupsUseCaseProtocol {
    func execute() -> [VersionGroup]
}

final class FetchVersionGroupsUseCase: FetchVersionGroupsUseCaseProtocol {
    func execute() -> [VersionGroup] {
        return VersionGroup.allVersionGroups
    }
}
```

---

## 💾 Data層の設計

### 1. Repository拡張

#### 1.1 PokemonRepository の拡張

**インターフェース:**
```swift
protocol PokemonRepository {
    // v1.0 既存
    func fetchPokemonList() async throws -> [PokemonListItemEntity]
    func fetchPokemonDetail(id: Int) async throws -> PokemonDetailEntity
    
    // v2.0 追加
    func fetchPokemonList(
        idRange: ClosedRange<Int>,
        generation: Int,
        progressHandler: ((Double) -> Void)?
    ) async throws -> [PokemonListItemEntity]
}
```

**実装例:**
```swift
final class DefaultPokemonRepository: PokemonRepository {
    private let apiClient: PokemonAPIClient
    private let cache: PokemonCache
    
    func fetchPokemonList(
        idRange: ClosedRange<Int>,
        generation: Int,
        progressHandler: ((Double) -> Void)? = nil
    ) async throws -> [PokemonListItemEntity] {
        
        // キャッシュキー: "pokemon_list_gen\(generation)_\(idRange.lowerBound)-\(idRange.upperBound)"
        let cacheKey = "pokemon_list_gen\(generation)_\(idRange.lowerBound)-\(idRange.upperBound)"
        
        if let cached = cache.getPokemonList(key: cacheKey) {
            return cached
        }
        
        // 並列取得
        let totalCount = idRange.count
        var fetchedPokemon: [PokemonListItemEntity] = []
        
        // バッチサイズ: 50件ずつ
        let batchSize = 50
        
        for batchStart in stride(from: idRange.lowerBound, through: idRange.upperBound, by: batchSize) {
            let batchEnd = min(batchStart + batchSize - 1, idRange.upperBound)
            let batchRange = batchStart...batchEnd
            
            // TaskGroupで並列取得
            let batch = try await withThrowingTaskGroup(of: PokemonListItemEntity?.self) { group in
                for id in batchRange {
                    group.addTask {
                        try await self.fetchPokemonListItem(id: id, generation: generation)
                    }
                }
                
                var results: [PokemonListItemEntity] = []
                for try await pokemon in group {
                    if let pokemon = pokemon {
                        results.append(pokemon)
                    }
                }
                return results
            }
            
            fetchedPokemon.append(contentsOf: batch)
            
            // 進捗通知
            let progress = Double(fetchedPokemon.count) / Double(totalCount)
            progressHandler?(progress)
        }
        
        // ソート(ID順)
        let sortedPokemon = fetchedPokemon.sorted { $0.id < $1.id }
        
        // キャッシュに保存
        cache.setPokemonList(key: cacheKey, pokemonList: sortedPokemon)
        
        return sortedPokemon
    }
    
    private func fetchPokemonListItem(id: Int, generation: Int) async throws -> PokemonListItemEntity? {
        // PokéAPIからポケモン情報を取得
        let dto = try await apiClient.fetchPokemon(id: id)
        
        // バージョングループ別のタイプ・特性を取得
        let typesForVersionGroup = try await fetchTypesForVersionGroup(pokemonId: id, generation: generation)
        let abilitiesForVersionGroup = try await fetchAbilitiesForVersionGroup(pokemonId: id, generation: generation)
        
        // DTOからEntityに変換
        return PokemonListItemEntity(
            id: dto.id,
            name: dto.name,
            types: typesForVersionGroup,
            spriteUrl: dto.sprites.frontDefault,
            abilities: abilitiesForVersionGroup,
            baseStats: BaseStats(
                hp: dto.stats.first { $0.stat.name == "hp" }?.baseStat ?? 0,
                attack: dto.stats.first { $0.stat.name == "attack" }?.baseStat ?? 0,
                defense: dto.stats.first { $0.stat.name == "defense" }?.baseStat ?? 0,
                specialAttack: dto.stats.first { $0.stat.name == "special-attack" }?.baseStat ?? 0,
                specialDefense: dto.stats.first { $0.stat.name == "special-defense" }?.baseStat ?? 0,
                speed: dto.stats.first { $0.stat.name == "speed" }?.baseStat ?? 0
            ),
            generation: dto.generation
        )
    }
    
    private func fetchTypesForVersionGroup(pokemonId: Int, generation: Int) async throws -> [PokemonType] {
        // pokemon-species APIからバージョングループ別のタイプ情報を取得
        // 実装詳細はPokéAPI仕様に依存
        // 必要に応じて別のエンドポイントを使用
        
        // 簡易実装例: 最新のタイプを返す(詳細は要調査)
        let dto = try await apiClient.fetchPokemon(id: pokemonId)
        return dto.types.map { PokemonType(rawValue: $0.type.name) ?? .normal }
    }
    
    private func fetchAbilitiesForVersionGroup(pokemonId: Int, generation: Int) async throws -> [AbilityInfo] {
        let dto = try await apiClient.fetchPokemon(id: pokemonId)
        
        // バージョングループ別のフィルタリング
        // 第1-2世代: 特性なし
        if generation <= 2 {
            return []
        }
        
        // 第3-4世代: 隠れ特性なし
        let abilities = dto.abilities.map { abilityDTO in
            AbilityInfo(
                name: abilityDTO.ability.name,
                isHidden: abilityDTO.isHidden
            )
        }
        
        if generation <= 4 {
            return abilities.filter { !$0.isHidden }
        }
        
        return abilities
    }
}
```

#### 1.2 新しいRepository: AbilityRepository

```swift
protocol AbilityRepository {
    func fetchAllAbilities(generation: Int?) async throws -> [String]
}

final class DefaultAbilityRepository: AbilityRepository {
    private let apiClient: PokemonAPIClient
    private let cache: AbilityCache
    
    func fetchAllAbilities(generation: Int?) async throws -> [String] {
        let cacheKey = "abilities_gen\(generation ?? 0)"
        
        if let cached = cache.getAbilities(key: cacheKey) {
            return cached
        }
        
        // PokéAPI: /api/v2/ability?limit=1000
        let abilities = try await apiClient.fetchAllAbilities()
        
        // 世代フィルタリング(必要に応じて)
        let filteredAbilities: [String]
        if let generation = generation {
            filteredAbilities = abilities.filter { ability in
                // 特性の登場バージョングループをチェック(APIから取得)
                ability.generation <= generation
            }.map { $0.name }
        } else {
            filteredAbilities = abilities.map { $0.name }
        }
        
        cache.setAbilities(key: cacheKey, abilities: filteredAbilities)
        
        return filteredAbilities.sorted()
    }
}
```

#### 1.3 新しいRepository: MoveRepository

```swift
protocol MoveRepository {
    func fetchAllMoves(generation: Int?) async throws -> [MoveEntity]
    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        generation: Int
    ) async throws -> [MoveLearnMethod]
}

final class DefaultMoveRepository: MoveRepository {
    private let apiClient: PokemonAPIClient
    private let cache: MoveCache
    
    func fetchAllMoves(generation: Int?) async throws -> [MoveEntity] {
        let cacheKey = "moves_gen\(generation ?? 0)"
        
        if let cached = cache.getMoves(key: cacheKey) {
            return cached
        }
        
        // PokéAPI: /api/v2/move?limit=1000
        let moves = try await apiClient.fetchAllMoves()
        
        let filteredMoves: [MoveEntity]
        if let generation = generation {
            filteredMoves = moves.filter { $0.generation <= generation }
        } else {
            filteredMoves = moves
        }
        
        cache.setMoves(key: cacheKey, moves: filteredMoves)
        
        return filteredMoves.sorted { $0.name < $1.name }
    }
    
    func fetchLearnMethods(
        pokemonId: Int,
        moveIds: [Int],
        generation: Int
    ) async throws -> [MoveLearnMethod] {
        
        // PokéAPI: /api/v2/pokemon/{id}
        let pokemonDTO = try await apiClient.fetchPokemon(id: pokemonId)
        
        var learnMethods: [MoveLearnMethod] = []
        
        for moveId in moveIds {
            // このポケモンがこの技を習得できるか確認
            if let moveData = pokemonDTO.moves.first(where: { $0.move.id == moveId }) {
                // バージョングループ別の習得方法を取得
                for versionGroupDetail in moveData.versionGroupDetails {
                    if versionGroupDetail.generation == generation {
                        let method = parseLearnMethod(
                            methodName: versionGroupDetail.moveLearnMethod.name,
                            level: versionGroupDetail.levelLearnedAt
                        )
                        
                        let move = MoveEntity(
                            id: moveId,
                            name: moveData.move.name,
                            type: .normal,  // 必要に応じてAPIから取得
                            generation: generation
                        )
                        
                        learnMethods.append(MoveLearnMethod(
                            move: move,
                            method: method,
                            generation: generation
                        ))
                        break
                    }
                }
            }
        }
        
        return learnMethods
    }
    
    private func parseLearnMethod(methodName: String, level: Int?) -> MoveLearnMethodType {
        switch methodName {
        case "level-up":
            return .levelUp(level: level ?? 1)
        case "machine":
            return .machine(number: "TM??")  // TM番号は別途取得が必要
        case "egg":
            return .egg
        case "tutor":
            return .tutor
        default:
            return .tutor
        }
    }
}
```

#### 1.4 新しいRepository: VersionGroupRepository

```swift
protocol VersionGroupRepository {
    func fetchAllVersionGroups() async throws -> [VersionGroupEntity]
    func fetchTotalPokemonCount() async throws -> Int
}

final class DefaultVersionGroupRepository: VersionGroupRepository {
    private let apiClient: PokemonAPIClient
    private let cache: VersionGroupCache
    
    init(apiClient: PokemonAPIClient, cache: VersionGroupCache) {
        self.apiClient = apiClient
        self.cache = cache
    }
    
    func fetchAllVersionGroups() async throws -> [VersionGroupEntity] {
        let cacheKey = "all_generations"
        
        if let cached = cache.getVersionGroups(key: cacheKey) {
            return cached
        }
        
        // 最新の総ポケモン数を取得
        let totalCount = try await fetchTotalPokemonCount()
        
        var generations: [VersionGroupEntity] = []
        
        // 全国図鑑
        generations.append(VersionGroupEntity(
            id: 0,
            name: "全国図鑑",
            pokemonSpeciesRange: 1...totalCount
        ))
        
        // 各バージョングループを取得(最大10世代まで試行)
        for genId in 1...10 {
            do {
                let genData = try await apiClient.fetchVersionGroup(id: genId)
                
                // pokemon_speciesからIDを抽出して範囲を決定
                let speciesIds = genData.pokemonSpecies
                    .compactMap { Int($0.url.split(separator: "/").last ?? "") }
                    .sorted()
                
                guard let minId = speciesIds.first, let maxId = speciesIds.last else {
                    continue
                }
                
                generations.append(VersionGroupEntity(
                    id: genId,
                    name: "第\(genId)世代",
                    pokemonSpeciesRange: minId...maxId
                ))
            } catch {
                // バージョングループが存在しない場合はループ終了
                break
            }
        }
        
        cache.setVersionGroups(key: cacheKey, generations: generations)
        
        return generations
    }
    
    func fetchTotalPokemonCount() async throws -> Int {
        let cacheKey = "total_pokemon_count"
        
        if let cached = cache.getTotalCount(key: cacheKey) {
            return cached
        }
        
        // PokéAPI: /api/v2/pokemon-species?limit=0
        // レスポンスのcountフィールドが総数
        let response = try await apiClient.fetchPokemonSpeciesCount()
        let totalCount = response.count
        
        cache.setTotalCount(key: cacheKey, count: totalCount)
        
        return totalCount
    }
}
```

### 2. キャッシュ戦略

#### 2.1 画像キャッシュ(Kingfisher)

**設定:**
```swift
// AppDelegate または @main App で設定

import Kingfisher

func configureKingfisher() {
    // メモリキャッシュ設定
    ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024  // 100MB
    ImageCache.default.memoryStorage.config.countLimit = 150  // 最大150枚
    
    // ディスクキャッシュ設定
    ImageCache.default.diskStorage.config.sizeLimit = 500 * 1024 * 1024  // 500MB
    ImageCache.default.diskStorage.config.expiration = .days(7)  // 7日間保持
    
    // ダウンロードタイムアウト
    KingfisherManager.shared.downloader.downloadTimeout = 15.0
}
```

**使用例(View層):**
```swift
import Kingfisher

struct PokemonRow: View {
    let pokemon: PokemonListItemEntity
    
    var body: some View {
        HStack {
            KFImage(URL(string: pokemon.spriteUrl))
                .placeholder {
                    ProgressView()
                }
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.25)
                .resizable()
                .frame(width: 60, height: 60)
            
            // 残りのUI
        }
    }
}
```

#### 2.2 データキャッシュ(メモリ)

**実装例:**
```swift
final class PokemonCache {
    private var cache: [String: [PokemonListItemEntity]] = [:]
    private let queue = DispatchQueue(label: "com.pokedex.cache", attributes: .concurrent)
    
    func getPokemonList(key: String) -> [PokemonListItemEntity]? {
        queue.sync {
            cache[key]
        }
    }
    
    func setPokemonList(key: String, pokemonList: [PokemonListItemEntity]) {
        queue.async(flags: .barrier) {
            self.cache[key] = pokemonList
        }
    }
    
    func clear() {
        queue.async(flags: .barrier) {
            self.cache.removeAll()
        }
    }
}
```

**キャッシュキー設計:**
- ポケモンリスト: `"pokemon_list_gen{世代}_{開始ID}-{終了ID}"`
- 特性リスト: `"abilities_gen{世代}"`
- 技リスト: `"moves_gen{世代}"`

---

## 🎨 Presentation層の設計

### 1. ViewModel拡張

#### 1.1 PokemonListViewModel (実装済み)

```swift
@MainActor
final class PokemonListViewModel: ObservableObject {
    // Published Properties
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var filteredPokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published private(set) var loadingProgress: Double = 0.0
    @Published var errorMessage: String?
    @Published var showError = false

    // Filter Properties
    @Published var searchText = ""
    @Published var selectedTypes: Set<String> = []
    @Published var selectedAbilities: Set<String> = []

    // v2.0 実装済み
    @Published var selectedVersionGroup: VersionGroup = .nationalDex
    @Published var currentSortOption: SortOption = .pokedexNumber
    @Published var displayMode: DisplayMode = .list

    private(set) var allVersionGroups: [VersionGroup] = []
    
    // UseCases
    private let fetchPokemonListUseCase: FetchPokemonListUseCase
    private let sortPokemonUseCase: SortPokemonUseCase
    private let fetchVersionGroupsUseCase: FetchVersionGroupsUseCase
    
    // フィルター済みポケモンリスト
    private var unfilteredPokemonList: [PokemonListItemEntity] = []
    
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCase,
        sortPokemonUseCase: SortPokemonUseCase,
        fetchVersionGroupsUseCase: FetchVersionGroupsUseCase
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.sortPokemonUseCase = sortPokemonUseCase
        self.fetchVersionGroupsUseCase = fetchVersionGroupsUseCase
    }
    
    func loadVersionGroups() async {
        isLoadingVersionGroups = true
        
        do {
            allVersionGroups = try await fetchVersionGroupsUseCase.execute()
            
            // 全国図鑑がデフォルトで選択されている
            if let nationalDex = allVersionGroups.first(where: { $0.id == 0 }) {
                selectedVersionGroup = nationalDex
            }
        } catch {
            print("Error loading generations: \(error)")
            // フォールバック: 最低限の世代データを用意
            allVersionGroups = [.nationalDex]
        }
        
        isLoadingVersionGroups = false
    }
    
    func loadPokemon() async {
        isLoading = true
        loadingProgress = 0.0
        
        do {
            unfilteredPokemonList = try await fetchPokemonListUseCase.execute(
                generation: selectedVersionGroup,
                progressHandler: { [weak self] progress in
                    Task { @MainActor in
                        self?.loadingProgress = progress
                    }
                }
            )
            
            applySortAndFilter()
            
        } catch {
            // エラーハンドリング
            print("Error loading pokemon: \(error)")
        }
        
        isLoading = false
    }
    
    func changeVersionGroup(_ generation: VersionGroupEntity) async {
        selectedVersionGroup = generation
        await loadPokemon()
    }
    
    func changeSortOption(_ option: SortOption) {
        currentSortOption = option
        applySortAndFilter()
    }
    
    func selectPokemon(_ pokemon: PokemonListItemEntity) {
        selectedPokemonId = pokemon.id
    }
    
    func applyFilter(_ filter: SearchFilterEntity) {
        // SearchViewModelと連携してフィルター適用
        // 実装は SearchViewModel に委譲
    }
    
    private func applySortAndFilter() {
        // ソート適用
        pokemonList = sortPokemonUseCase.execute(
            pokemonList: unfilteredPokemonList,
            sortOption: currentSortOption
        )
    }
}
```

#### 1.2 SearchViewModel の拡張

```swift
@MainActor
final class SearchViewModel: ObservableObject {
    // 既存
    @Published var searchText = ""
    @Published var selectedTypes: Set<PokemonType> = []
    
    // v2.0 追加
    @Published var selectedAbilities: Set<String> = []
    @Published var selectedMoves: [MoveEntity] = []
    @Published private(set) var availableAbilities: [String] = []
    @Published private(set) var availableMoves: [MoveEntity] = []
    @Published private(set) var isLoadingAbilities = false
    @Published private(set) var isLoadingMoves = false
    
    // 世代情報(PokemonListViewModelから受け取る)
    var currentVersionGroup: VersionGroupEntity = .nationalDex
    
    // UseCases
    private let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCase
    private let fetchAllMovesUseCase: FetchAllMovesUseCase
    private let filterByAbilityUseCase: FilterPokemonByAbilityUseCase
    private let filterByMovesUseCase: FilterPokemonByMovesUseCase
    
    init(
        fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCase,
        fetchAllMovesUseCase: FetchAllMovesUseCase,
        filterByAbilityUseCase: FilterPokemonByAbilityUseCase,
        filterByMovesUseCase: FilterPokemonByMovesUseCase
    ) {
        self.fetchAllAbilitiesUseCase = fetchAllAbilitiesUseCase
        self.fetchAllMovesUseCase = fetchAllMovesUseCase
        self.filterByAbilityUseCase = filterByAbilityUseCase
        self.filterByMovesUseCase = filterByMovesUseCase
    }
    
    func loadAbilities() async {
        // 第1-2バージョングループは特性なし
        guard currentVersionGroup.id >= 3 || currentVersionGroup.id == 0 else {
            availableAbilities = []
            return
        }
        
        isLoadingAbilities = true
        
        do {
            let generation = currentVersionGroup.id == 0 ? 9 : currentVersionGroup.id
            availableAbilities = try await fetchAllAbilitiesUseCase.execute(generation: generation)
        } catch {
            print("Error loading abilities: \(error)")
        }
        
        isLoadingAbilities = false
    }
    
    func loadMoves() async {
        // 技フィルターはバージョングループ選択時のみ有効
        guard currentVersionGroup.id != 0 else {
            availableMoves = []
            return
        }
        
        isLoadingMoves = true
        
        do {
            availableMoves = try await fetchAllMovesUseCase.execute(generation: currentVersionGroup.id)
        } catch {
            print("Error loading moves: \(error)")
        }
        
        isLoadingMoves = false
    }
    
    func toggleAbility(_ ability: String) {
        if selectedAbilities.contains(ability) {
            selectedAbilities.remove(ability)
        } else {
            selectedAbilities.insert(ability)
        }
    }
    
    func addMove(_ move: MoveEntity) {
        guard selectedMoves.count < 4 else { return }
        selectedMoves.append(move)
    }
    
    func removeMove(_ move: MoveEntity) {
        selectedMoves.removeAll { $0.id == move.id }
    }
    
    func clearFilter() {
        searchText = ""
        selectedTypes.removeAll()
        selectedAbilities.removeAll()
        selectedMoves.removeAll()
    }
    
    func onVersionGroupChanged(_ generation: VersionGroupEntity) {
        currentVersionGroup = generation
        
        // 世代変更時、フィルターをクリア
        selectedAbilities.removeAll()
        selectedMoves.removeAll()
        
        // 新しいバージョングループの特性・技を読み込む
        Task {
            await loadAbilities()
            await loadMoves()
        }
    }
    
    var isAbilityFilterEnabled: Bool {
        // 全国図鑑または第3世代以降
        currentVersionGroup.id == 0 || currentVersionGroup.id >= 3
    }
    
    var isMoveFilterEnabled: Bool {
        // バージョングループ選択時のみ有効
        currentVersionGroup.id != 0
    }
}
```

### 2. View設計

#### 2.1 PokemonRow の拡張

```swift
struct PokemonRow: View {
    let pokemon: PokemonListItemEntity
    let displayMode: DisplayMode
    
    var body: some View {
        if displayMode == .list {
            listLayout
        } else {
            gridLayout
        }
    }
    
    private var listLayout: some View {
        HStack(alignment: .top, spacing: 12) {
            // スプライト画像
            KFImage(URL(string: pokemon.spriteUrl))
                .placeholder { ProgressView() }
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.25)
                .resizable()
                .frame(width: 60, height: 60)
            
            VStack(alignment: .leading, spacing: 4) {
                // 名前 + 図鑑番号
                HStack {
                    Text(pokemon.name)
                        .font(.headline)
                    Text("#\(String(format: "%03d", pokemon.id))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // タイプ
                HStack(spacing: 4) {
                    ForEach(pokemon.types, id: \.self) { type in
                        TypeBadge(type: type)
                    }
                }
                
                // 特性
                AbilityView(abilities: pokemon.abilities)
                
                // 種族値
                BaseStatsView(baseStats: pokemon.baseStats, compact: true)
            }
        }
        .padding(.vertical, 8)
    }
    
    private var gridLayout: some View {
        VStack(spacing: 4) {
            // スプライト画像
            KFImage(URL(string: pokemon.spriteUrl))
                .placeholder { ProgressView() }
                .retry(maxCount: 3, interval: .seconds(2))
                .fade(duration: 0.25)
                .resizable()
                .frame(width: 80, height: 80)
            
            // 名前
            Text(pokemon.name)
                .font(.caption)
                .lineLimit(1)
            
            // タイプ
            HStack(spacing: 2) {
                ForEach(pokemon.types, id: \.self) { type in
                    TypeBadge(type: type, compact: true)
                }
            }
            
            // 特性(改行)
            AbilityView(abilities: pokemon.abilities, compact: true)
            
            // 種族値(2行)
            BaseStatsView(baseStats: pokemon.baseStats, compact: true, multiLine: true)
        }
        .padding(8)
    }
}
```

#### 2.2 新しいView: AbilityView

```swift
struct AbilityView: View {
    let abilities: [AbilityInfo]
    var compact: Bool = false
    
    var body: some View {
        if abilities.isEmpty {
            Text("特性: -")
                .font(compact ? .caption2 : .caption)
                .foregroundColor(.secondary)
        } else {
            let normalAbilities = abilities.filter { !$0.isHidden }
            let hiddenAbilities = abilities.filter { $0.isHidden }
            
            let displayText = formatAbilities(normal: normalAbilities, hidden: hiddenAbilities)
            
            Text("特性: \(displayText)")
                .font(compact ? .caption2 : .caption)
                .foregroundColor(.secondary)
                .lineLimit(compact ? 2 : 1)
        }
    }
    
    private func formatAbilities(normal: [AbilityInfo], hidden: [AbilityInfo]) -> String {
        var parts: [String] = []
        
        // 通常特性
        if !normal.isEmpty {
            let normalNames = normal.map { $0.name }.joined(separator: "/")
            parts.append(normalNames)
        }
        
        // 隠れ特性
        if !hidden.isEmpty {
            let hiddenNames = hidden.map { $0.name }.joined(separator: "/")
            parts.append(hiddenNames)
        }
        
        return parts.joined(separator: " ")
    }
}
```

#### 2.3 新しいView: BaseStatsView

```swift
struct BaseStatsView: View {
    let baseStats: BaseStats
    var compact: Bool = false
    var multiLine: Bool = false
    
    var body: some View {
        if multiLine {
            VStack(alignment: .leading, spacing: 2) {
                Text("\(baseStats.hp)-\(baseStats.attack)-\(baseStats.defense)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("\(baseStats.specialAttack)-\(baseStats.specialDefense)-\(baseStats.speed)(\(baseStats.total))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        } else {
            Text(baseStats.displayString)
                .font(compact ? .caption2 : .caption)
                .foregroundColor(.secondary)
        }
    }
}
```

#### 2.4 新しいView: VersionGroupSelectorView

```swift
struct VersionGroupSelectorView: View {
    @Binding var selectedVersionGroup: VersionGroupEntity
    let generations: [VersionGroupEntity]
    let onVersionGroupChange: (VersionGroupEntity) -> Void
    
    var body: some View {
        Menu {
            ForEach(generations) { generation in
                Button(action: {
                    selectedVersionGroup = generation
                    onVersionGroupChange(generation)
                }) {
                    HStack {
                        Text(generation.name)
                        if generation.id == selectedVersionGroup.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack {
                Text(selectedVersionGroup.name)
                Image(systemName: "chevron.down")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.secondary.opacity(0.2))
            .cornerRadius(8)
        }
    }
}
```

#### 2.5 新しいView: SortOptionView

```swift
struct SortOptionView: View {
    @Binding var currentSortOption: SortOption
    let onSortChange: (SortOption) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section("全国図鑑No") {
                    sortButton(.pokedexNumber)
                    sortButton(.name(ascending: true))
                    sortButton(.name(ascending: false))
                }
                
                Section("種族値") {
                    sortButton(.totalStats(ascending: false))
                    sortButton(.totalStats(ascending: true))
                    sortButton(.hp(ascending: false))
                    sortButton(.attack(ascending: false))
                    sortButton(.defense(ascending: false))
                    sortButton(.specialAttack(ascending: false))
                    sortButton(.specialDefense(ascending: false))
                    sortButton(.speed(ascending: false))
                }
            }
            .navigationTitle("並び替え")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sortButton(_ option: SortOption) -> some View {
        Button(action: {
            currentSortOption = option
            onSortChange(option)
            dismiss()
        }) {
            HStack {
                Text(option.displayName)
                Spacer()
                if currentSortOption == option {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}
```

#### 2.6 新しいView: AbilityFilterView

```swift
struct AbilityFilterView: View {
    @Binding var selectedAbilities: Set<String>
    let availableAbilities: [String]
    let isEnabled: Bool
    @State private var searchText = ""
    
    var filteredAbilities: [String] {
        if searchText.isEmpty {
            return availableAbilities
        }
        return availableAbilities.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("特性フィルター")
                .font(.headline)
            
            if !isEnabled {
                Text("全国図鑑モードでは利用可能です。第1-2バージョングループでは特性システムが存在しません。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            } else {
                // 検索フィールド
                TextField("特性を検索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 選択済みタグ
                if !selectedAbilities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(Array(selectedAbilities), id: \.self) { ability in
                                TagView(text: ability) {
                                    selectedAbilities.remove(ability)
                                }
                            }
                        }
                    }
                }
                
                // 特性リスト
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredAbilities, id: \.self) { ability in
                            Button(action: {
                                toggleAbility(ability)
                            }) {
                                HStack {
                                    Text(ability)
                                    Spacer()
                                    if selectedAbilities.contains(ability) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private func toggleAbility(_ ability: String) {
        if selectedAbilities.contains(ability) {
            selectedAbilities.remove(ability)
        } else {
            selectedAbilities.insert(ability)
        }
    }
}
```

#### 2.7 新しいView: MoveFilterView

```swift
struct MoveFilterView: View {
    @Binding var selectedMoves: [MoveEntity]
    let availableMoves: [MoveEntity]
    let isEnabled: Bool
    @State private var searchText = ""
    
    var filteredMoves: [MoveEntity] {
        if searchText.isEmpty {
            return availableMoves
        }
        return availableMoves.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("技フィルター")
                .font(.headline)
            
            if !isEnabled {
                Text("技フィルターはバージョングループを選択した場合のみ利用可能です。")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
            } else {
                // 検索フィールド
                TextField("技を検索", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // 選択済みタグ
                if !selectedMoves.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(selectedMoves) { move in
                                TagView(text: move.name) {
                                    selectedMoves.removeAll { $0.id == move.id }
                                }
                            }
                        }
                    }
                }
                
                Text("最大4つまで選択可能 (\(selectedMoves.count)/4)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // 技リスト
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 4) {
                        ForEach(filteredMoves) { move in
                            Button(action: {
                                addMove(move)
                            }) {
                                HStack {
                                    Text(move.name)
                                    Spacer()
                                    if selectedMoves.contains(where: { $0.id == move.id }) {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .disabled(selectedMoves.count >= 4 && !selectedMoves.contains(where: { $0.id == move.id }))
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private func addMove(_ move: MoveEntity) {
        if let index = selectedMoves.firstIndex(where: { $0.id == move.id }) {
            selectedMoves.remove(at: index)
        } else if selectedMoves.count < 4 {
            selectedMoves.append(move)
        }
    }
}
```

#### 2.8 新しいView: LoadingProgressView

```swift
struct LoadingProgressView: View {
    let progress: Double
    let current: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
            
            Text("ポケモンを読み込み中... \(current)/\(total)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}
```

#### 2.9 PokemonListView の拡張

```swift
struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @State private var showingSortOptions = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // ツールバー: バージョングループ選択・ソート・表示切り替え
                HStack {
                    VersionGroupSelectorView(
                        selectedVersionGroup: $viewModel.selectedVersionGroup,
                        generations: viewModel.allVersionGroups,
                        onVersionGroupChange: { generation in
                            Task {
                                await viewModel.changeVersionGroup(generation)
                                searchViewModel.onVersionGroupChanged(generation)
                            }
                        }
                    )
                    
                    Spacer()
                    
                    Button(action: {
                        showingSortOptions = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(viewModel.currentSortOption.displayName)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Button(action: {
                        viewModel.displayMode = viewModel.displayMode == .list ? .grid : .list
                    }) {
                        Image(systemName: viewModel.displayMode == .list ? "square.grid.2x2" : "list.bullet")
                    }
                }
                .padding()
                
                // ポケモンリスト
                if viewModel.isLoading {
                    Spacer()
                    LoadingProgressView(
                        progress: viewModel.loadingProgress,
                        current: Int(viewModel.loadingProgress * Double(viewModel.selectedVersionGroup.pokemonSpeciesRange.count)),
                        total: viewModel.selectedVersionGroup.pokemonSpeciesRange.count
                    )
                    Spacer()
                } else {
                    ScrollViewReader { proxy in
                        if viewModel.displayMode == .list {
                            List(viewModel.pokemonList) { pokemon in
                                NavigationLink(value: pokemon.id) {
                                    PokemonRow(pokemon: pokemon, displayMode: .list)
                                }
                                .id(pokemon.id)
                            }
                            .listStyle(.plain)
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 16) {
                                    ForEach(viewModel.pokemonList) { pokemon in
                                        NavigationLink(value: pokemon.id) {
                                            PokemonRow(pokemon: pokemon, displayMode: .grid)
                                        }
                                        .id(pokemon.id)
                                    }
                                }
                                .padding()
                            }
                        }
                        .onChange(of: viewModel.selectedPokemonId) { _, newValue in
                            if let id = newValue {
                                withAnimation {
                                    proxy.scrollTo(id, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("ポケモン図鑑")
            .navigationDestination(for: Int.self) { pokemonId in
                PokemonDetailView(pokemonId: pokemonId)
                    .onDisappear {
                        // 詳細画面から戻る際、選択したポケモンのIDを保持
                        viewModel.selectPokemon(
                            viewModel.pokemonList.first { $0.id == pokemonId }!
                        )
                    }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SearchView(viewModel: searchViewModel)) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
            .sheet(isPresented: $showingSortOptions) {
                SortOptionView(
                    currentSortOption: $viewModel.currentSortOption,
                    onSortChange: { option in
                        viewModel.changeSortOption(option)
                    }
                )
            }
            .task {
                await viewModel.loadPokemon()
            }
        }
    }
}
```

---

## 🧪 テスト戦略

### 1. ユニットテスト

#### 1.1 Domain層のテスト

**SortPokemonUseCaseTests:**
```swift
final class SortPokemonUseCaseTests: XCTestCase {
    var sut: SortPokemonUseCase!
    var mockPokemonList: [PokemonListItemEntity]!
    
    override func setUp() {
        super.setUp()
        sut = DefaultSortPokemonUseCase()
        mockPokemonList = createMockPokemonList()
    }
    
    func test_sortByPokedexNumber() {
        // Given
        let shuffled = mockPokemonList.shuffled()
        
        // When
        let result = sut.execute(pokemonList: shuffled, sortOption: .pokedexNumber)
        
        // Then
        XCTAssertEqual(result.first?.id, 1)
        XCTAssertEqual(result.last?.id, 151)
    }
    
    func test_sortByTotalStats_descending() {
        // When
        let result = sut.execute(pokemonList: mockPokemonList, sortOption: .totalStats(ascending: false))
        
        // Then
        XCTAssertGreaterThanOrEqual(result.first!.baseStats.total, result.last!.baseStats.total)
    }
    
    // 他のソートオプションのテスト...
}
```

**FilterPokemonByAbilityUseCaseTests:**
```swift
final class FilterPokemonByAbilityUseCaseTests: XCTestCase {
    var sut: FilterPokemonByAbilityUseCase!
    
    override func setUp() {
        super.setUp()
        sut = DefaultFilterPokemonByAbilityUseCase()
    }
    
    func test_filterByAbility() {
        // Given
        let pokemon1 = createMockPokemon(id: 1, abilities: [
            AbilityInfo(name: "しんりょく", isHidden: false),
            AbilityInfo(name: "ようりょくそ", isHidden: true)
        ])
        let pokemon2 = createMockPokemon(id: 2, abilities: [
            AbilityInfo(name: "もうか", isHidden: false)
        ])
        let pokemonList = [pokemon1, pokemon2]
        
        // When
        let result = sut.execute(pokemonList: pokemonList, selectedAbilities: ["しんりょく"])
        
        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, 1)
    }
    
    func test_filterByHiddenAbility() {
        // Given
        let pokemon1 = createMockPokemon(id: 1, abilities: [
            AbilityInfo(name: "しんりょく", isHidden: false),
            AbilityInfo(name: "ようりょくそ", isHidden: true)
        ])
        let pokemonList = [pokemon1]
        
        // When
        let result = sut.execute(pokemonList: pokemonList, selectedAbilities: ["ようりょくそ"])
        
        // Then
        XCTAssertEqual(result.count, 1)
    }
}
```

#### 1.2 Presentation層のテスト

**PokemonListViewModelTests:**
```swift
@MainActor
final class PokemonListViewModelTests: XCTestCase {
    var sut: PokemonListViewModel!
    var mockFetchUseCase: MockFetchPokemonListUseCase!
    var mockSortUseCase: MockSortPokemonUseCase!
    
    override func setUp() async throws {
        mockFetchUseCase = MockFetchPokemonListUseCase()
        mockSortUseCase = MockSortPokemonUseCase()
        sut = PokemonListViewModel(
            fetchPokemonListUseCase: mockFetchUseCase,
            sortPokemonUseCase: mockSortUseCase
        )
    }
    
    func test_loadPokemon_shouldFetchFromUseCase() async {
        // Given
        mockFetchUseCase.pokemonList = createMockPokemonList()
        
        // When
        await sut.loadPokemon()
        
        // Then
        XCTAssertEqual(sut.pokemonList.count, 151)
        XCTAssertTrue(mockFetchUseCase.executeCalled)
    }
    
    func test_changeVersionGroup_shouldReloadPokemon() async {
        // Given
        let generation2 = VersionGroupEntity(id: 2, name: "第2世代", pokemonSpeciesRange: 1...251)
        
        // When
        await sut.changeVersionGroup(generation2)
        
        // Then
        XCTAssertEqual(sut.selectedVersionGroup.id, 2)
        XCTAssertTrue(mockFetchUseCase.executeCalled)
    }
    
    func test_changeSortOption_shouldReorderList() {
        // Given
        sut.pokemonList = createMockPokemonList()
        
        // When
        sut.changeSortOption(.totalStats(ascending: false))
        
        // Then
        XCTAssertEqual(sut.currentSortOption, .totalStats(ascending: false))
        XCTAssertTrue(mockSortUseCase.executeCalled)
    }
}
```

### 2. 統合テスト

**PokéAPI統合テスト(Mockサーバー使用):**
```swift
final class PokemonRepositoryIntegrationTests: XCTestCase {
    var sut: PokemonRepository!
    var mockAPIClient: MockPokemonAPIClient!
    var cache: PokemonCache!
    
    override func setUp() {
        super.setUp()
        mockAPIClient = MockPokemonAPIClient()
        cache = PokemonCache()
        sut = DefaultPokemonRepository(apiClient: mockAPIClient, cache: cache)
    }
    
    func test_fetchPokemonList_shouldReturnCorrectVersionGroup() async throws {
        // Given
        mockAPIClient.setupMockResponses()
        
        // When
        let result = try await sut.fetchPokemonList(
            idRange: 1...151,
            generation: 1,
            progressHandler: nil
        )
        
        // Then
        XCTAssertEqual(result.count, 151)
        XCTAssertNotNil(result.first?.abilities)
        XCTAssertNotNil(result.first?.baseStats)
    }
    
    func test_fetchPokemonList_shouldReportProgress() async throws {
        // Given
        var progressReports: [Double] = []
        
        // When
        _ = try await sut.fetchPokemonList(
            idRange: 1...10,
            generation: 1,
            progressHandler: { progress in
                progressReports.append(progress)
            }
        )
        
        // Then
        XCTAssertFalse(progressReports.isEmpty)
        XCTAssertEqual(progressReports.last, 1.0, accuracy: 0.01)
    }
}
```

### 3. UIテスト

**スクロール位置保持のテスト:**
```swift
final class PokemonListUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    func test_scrollPosition_shouldBePreservedAfterDetailNavigation() {
        // Given: 30番目のポケモンまでスクロール
        let pokemonList = app.collectionViews.firstMatch
        let targetPokemon = pokemonList.cells.element(boundBy: 30)
        targetPokemon.tap()
        
        // When: 詳細画面に遷移して戻る
        app.navigationBars.buttons.element(boundBy: 0).tap()
        
        // Then: 30番目のポケモンが画面内に表示されている
        XCTAssertTrue(targetPokemon.isHittable)
    }
}
```

---

## 🔄 データフロー

### 1. ポケモンリスト取得フロー

```
ユーザー操作: バージョングループ選択
    ↓
PokemonListViewModel.changeVersionGroup()
    ↓
FetchPokemonListUseCase.execute(generation: ...)
    ↓
PokemonRepository.fetchPokemonList(idRange: ..., generation: ...)
    ↓
キャッシュチェック → あればキャッシュから返却
    ↓ (キャッシュなし)
PokemonAPIClient.fetchPokemon() × N (並列)
    ↓
進捗ハンドラーで進捗通知
    ↓
DTOからEntityに変換
    ↓
キャッシュに保存
    ↓
ViewModelに返却
    ↓
SortPokemonUseCase.execute() (ソート適用)
    ↓
@Published pokemonList 更新
    ↓
View再描画
```

### 2. フィルター適用フロー

```
ユーザー操作: 特性選択
    ↓
SearchViewModel.toggleAbility()
    ↓
@Published selectedAbilities 更新
    ↓
PokemonListViewModel.applyFilter()
    ↓
FilterPokemonByAbilityUseCase.execute()
    ↓
フィルター済みリスト生成
    ↓
SortPokemonUseCase.execute() (ソート適用)
    ↓
@Published pokemonList 更新
    ↓
View再描画
```

### 3. バージョングループ切り替えフロー

```
ユーザー操作: バージョングループ切り替え
    ↓
PokemonListViewModel.changeVersionGroup()
    ↓
SearchViewModel.onVersionGroupChanged()
    ↓ (並列実行)
├─ FetchPokemonListUseCase (ポケモンリスト取得)
└─ FetchAllAbilitiesUseCase (特性リスト取得)
   └─ FetchAllMovesUseCase (技リスト取得、バージョングループ選択時のみ)
    ↓
SearchViewModel: フィルタークリア
    ↓
@Published pokemonList, availableAbilities, availableMoves 更新
    ↓
View再描画
```

---

## 📋 PokéAPI エンドポイント設計

### 1. 使用するエンドポイント

| 目的 | エンドポイント | 備考 |
|-----|-------------|------|
| ポケモン基本情報 | `/api/v2/pokemon/{id}` | タイプ、特性、種族値を取得 |
| ポケモン種族情報 | `/api/v2/pokemon-species/{id}` | 世代、進化チェーン情報を取得 |
| **総ポケモン数取得** | `/api/v2/pokemon-species?limit=0` | `count`フィールドが最新の総数 |
| 世代情報 | `/api/v2/generation/{id}` | 世代ごとのポケモンリスト、範囲を取得 |
| 特性リスト | `/api/v2/ability?limit=1000` | 全特性のマスターリスト |
| 技リスト | `/api/v2/move?limit=1000` | 全技のマスターリスト |
| 技詳細 | `/api/v2/move/{id}` | 技のタイプ、世代情報 |

### 2. バージョングループ別データの取得方法

**世代別タイプの取得:**
```swift
// pokemon-species APIを使用
// past_types フィールドに過去のバージョングループでのタイプ情報が含まれる
// 例: サーナイトの場合
// 第5世代まで: タイプ = [psychic]
// 第6世代以降: タイプ = [psychic, fairy]
```

**世代別特性の取得:**
```swift
// pokemon APIのabilitiesフィールド
// 各特性には is_hidden フラグがある
// バージョングループによる特性の変更は pokemon-species の varieties で管理
// 例: ゲンガーの場合、バージョングループによって異なるフォームとして扱われる可能性
```

**技の習得方法:**
```swift
// pokemon APIの moves フィールド
// version_group_details に世代ごとの習得方法が含まれる
// move_learn_method: level-up, machine, egg, tutor など
```

### 3. レスポンスキャッシュ戦略

**キャッシュの優先順位:**
1. メモリキャッシュ(即座に返却)
2. Kingfisherディスクキャッシュ(画像のみ)
3. API取得

**キャッシュの有効期限:**
- ポケモンデータ: セッション中のみ(アプリ終了で削除)
- 画像: 7日間(Kingfisherの設定)

---

## 🎨 UI/UXガイドライン

### 1. カラースキーム

**タイプバッジの色:**
既存のタイプカラーを継承し、一貫性を保つ。

### 2. アニメーション

**バージョングループ切り替え時:**
- フェードアウト → ローディング表示 → フェードイン
- アニメーション時間: 0.3秒

**ソート適用時:**
- リスト項目の並び替えアニメーション
- アニメーション時間: 0.25秒

**スクロール位置復帰:**
- スムーズなスクロールアニメーション
- アニメーション時間: 0.5秒

### 3. アクセシビリティ

**VoiceOver対応:**
```swift
// PokemonRowでのアクセシビリティ設定例
var body: some View {
    HStack {
        // ...
    }
    .accessibilityElement(children: .combine)
    .accessibilityLabel("\(pokemon.name)、図鑑番号\(pokemon.id)")
    .accessibilityHint("タップして詳細を表示")
}
```

**Dynamic Type対応:**
- すべてのテキストに`.font()`指定
- 固定サイズを避け、動的なレイアウト

---

## ⚠️ エラーハンドリング

### 1. ネットワークエラー

**リトライ戦略:**
```swift
func fetchWithRetry<T>(
    maxRetries: Int = 3,
    delay: TimeInterval = 2.0,
    operation: () async throws -> T
) async throws -> T {
    var lastError: Error?
    
    for attempt in 1...maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            if attempt < maxRetries {
                try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
            }
        }
    }
    
    throw lastError!
}
```

**ユーザーへの通知:**
- Alertでエラー内容を表示
- リトライボタンを提供
- オフライン時は適切なメッセージ

### 2. データ不整合エラー

**検証:**
```swift
guard pokemon.baseStats.total > 0 else {
    throw DataError.invalidStats
}

guard !pokemon.abilities.isEmpty || pokemon.generation <= 2 else {
    throw DataError.missingAbilities
}
```

### 3. メモリ不足

**大量データ取得時の対策:**
- バッチサイズを動的に調整
- メモリ警告時はキャッシュをクリア
- TaskGroupの並列数を制限

---

## 🚀 パフォーマンス最適化

### 1. 並列処理の最適化

**同時リクエスト数の制限:**
```swift
actor RequestThrottler {
    private var activeRequests = 0
    private let maxConcurrent = 10
    
    func waitForSlot() async {
        while activeRequests >= maxConcurrent {
            await Task.yield()
        }
        activeRequests += 1
    }
    
    func releaseSlot() {
        activeRequests -= 1
    }
}

// 使用例
let throttler = RequestThrottler()

await withThrowingTaskGroup(of: PokemonListItemEntity.self) { group in
    for id in 1...1025 {
        await throttler.waitForSlot()
        
        group.addTask {
            defer { await throttler.releaseSlot() }
            return try await fetchPokemon(id: id)
        }
    }
}
```

### 2. メモリ管理

**大量データの段階的解放:**
```swift
// 不要になったキャッシュを定期的にクリア
func clearOldVersionGroupCache() {
    // 現在選択中のバージョングループ以外のキャッシュを削除
    cache.removeAll { key, _ in
        !key.contains("gen\(selectedVersionGroup.id)")
    }
}
```

### 3. UI最適化

**LazyVStackとLazyVGridの活用:**
- リスト/グリッド表示で遅延読み込み
- 画面外のViewは生成しない

**画像のプリフェッチ:**
```swift
// Kingfisherのプリフェッチ機能
let prefetcher = ImagePrefetcher(urls: upcomingImageURLs)
prefetcher.start()
```

---

## 🔐 セキュリティ考慮事項

### 1. API通信

**HTTPS通信の強制:**
- すべてのPokéAPI通信はHTTPS
- App Transport Securityの設定確認

### 2. データ検証

**入力値の検証:**
```swift
// 世代IDの検証
guard (0...9).contains(generation.id) else {
    throw ValidationError.invalidVersionGroup
}

// ポケモンIDの検証
guard (1...1025).contains(pokemonId) else {
    throw ValidationError.invalidPokemonId
}
```

---

## 📱 デバイス対応

### 1. 画面サイズ対応

**iPhone SE (小画面):**
- グリッド: 2列
- フォントサイズ: 最小限

**iPhone Pro Max (大画面):**
- グリッド: 3〜4列
- より多くの情報を表示

**iPad対応(将来):**
- 現在はiPhone専用だが、将来的にはiPad対応も検討

### 2. iOS バージョン対応

**最低サポートバージョン: iOS 16.0**
- SwiftUIの最新機能を活用
- NavigationStackの使用
- async/awaitの完全サポート

---

## 🔧 DIContainer拡張

### 新しい依存関係の登録

```swift
final class DIContainer {
    // 既存
    let fetchPokemonListUseCase: FetchPokemonListUseCase
    let fetchPokemonDetailUseCase: FetchPokemonDetailUseCase
    
    // v2.0 追加
    let sortPokemonUseCase: SortPokemonUseCase
    let filterByAbilityUseCase: FilterPokemonByAbilityUseCase
    let filterByMovesUseCase: FilterPokemonByMovesUseCase
    let fetchAllAbilitiesUseCase: FetchAllAbilitiesUseCase
    let fetchAllMovesUseCase: FetchAllMovesUseCase
    let fetchVersionGroupsUseCase: FetchVersionGroupsUseCase
    
    // Repositories
    private let pokemonRepository: PokemonRepository
    private let abilityRepository: AbilityRepository
    private let moveRepository: MoveRepository
    private let generationRepository: VersionGroupRepository
    
    // Cache
    private let pokemonCache: PokemonCache
    private let abilityCache: AbilityCache
    private let moveCache: MoveCache
    private let generationCache: VersionGroupCache
    
    init() {
        // Cache初期化
        pokemonCache = PokemonCache()
        abilityCache = AbilityCache()
        moveCache = MoveCache()
        generationCache = VersionGroupCache()
        
        // API Client初期化
        let apiClient = DefaultPokemonAPIClient()
        
        // Repository初期化
        pokemonRepository = DefaultPokemonRepository(
            apiClient: apiClient,
            cache: pokemonCache
        )
        abilityRepository = DefaultAbilityRepository(
            apiClient: apiClient,
            cache: abilityCache
        )
        moveRepository = DefaultMoveRepository(
            apiClient: apiClient,
            cache: moveCache
        )
        generationRepository = DefaultVersionGroupRepository(
            apiClient: apiClient,
            cache: generationCache
        )
        
        // UseCase初期化
        fetchPokemonListUseCase = DefaultFetchPokemonListUseCase(
            repository: pokemonRepository
        )
        fetchPokemonDetailUseCase = DefaultFetchPokemonDetailUseCase(
            repository: pokemonRepository
        )
        sortPokemonUseCase = DefaultSortPokemonUseCase()
        filterByAbilityUseCase = DefaultFilterPokemonByAbilityUseCase()
        filterByMovesUseCase = DefaultFilterPokemonByMovesUseCase(
            moveRepository: moveRepository
        )
        fetchAllAbilitiesUseCase = DefaultFetchAllAbilitiesUseCase(
            abilityRepository: abilityRepository
        )
        fetchAllMovesUseCase = DefaultFetchAllMovesUseCase(
            moveRepository: moveRepository
        )
        fetchVersionGroupsUseCase = DefaultFetchVersionGroupsUseCase(
            generationRepository: generationRepository
        )
        
        // Kingfisher設定
        configureKingfisher()
    }
    
    private func configureKingfisher() {
        ImageCache.default.memoryStorage.config.totalCostLimit = 100 * 1024 * 1024
        ImageCache.default.memoryStorage.config.countLimit = 150
        ImageCache.default.diskStorage.config.sizeLimit = 500 * 1024 * 1024
        ImageCache.default.diskStorage.config.expiration = .days(7)
        KingfisherManager.shared.downloader.downloadTimeout = 15.0
    }
    
    // ViewModelファクトリ
    func makePokemonListViewModel() -> PokemonListViewModel {
        PokemonListViewModel(
            fetchPokemonListUseCase: fetchPokemonListUseCase,
            sortPokemonUseCase: sortPokemonUseCase,
            fetchVersionGroupsUseCase: fetchVersionGroupsUseCase
        )
    }
    
    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            fetchAllAbilitiesUseCase: fetchAllAbilitiesUseCase,
            fetchAllMovesUseCase: fetchAllMovesUseCase,
            filterByAbilityUseCase: filterByAbilityUseCase,
            filterByMovesUseCase: filterByMovesUseCase
        )
    }
}
```

---

## 📚 参考資料・ドキュメント

### 1. PokéAPI公式ドキュメント
- メインドキュメント: https://pokeapi.co/docs/v2
- レスポンスサンプル: https://pokeapi.co/api/v2/pokemon/1

### 2. SwiftUI公式ドキュメント
- NavigationStack: https://developer.apple.com/documentation/swiftui/navigationstack
- ScrollViewReader: https://developer.apple.com/documentation/swiftui/scrollviewreader

### 3. Kingfisher公式ドキュメント
- GitHub: https://github.com/onevcat/Kingfisher
- 使用ガイド: https://github.com/onevcat/Kingfisher/wiki

---

## 🔄 マイグレーション計画

### v1.0 → v2.0 への移行

**データモデルの変更:**
1. `PokemonListItemEntity`の拡張 → 既存コードへの影響なし(後方互換性あり)
2. キャッシュキーの変更 → 既存キャッシュは無効化され、再取得

**破壊的変更:**
- なし(すべて追加機能)

**移行手順:**
1. Domain層の新Entityを追加
2. Data層のRepositoryを拡張
3. Presentation層のViewModelを拡張
4. UIコンポーネントを追加
5. 統合テストで動作確認

---

## 📝 今後の拡張ポイント

### フェーズ5以降の検討事項

**永続化層の追加:**
- CoreDataまたはSwiftDataの導入
- お気に入り機能の実装
- オフライン完全対応

**リージョンフォーム対応:**
- アローラ、ガラル、ヒスイフォームの表示
- フォームごとのタイプ・特性の違い

**メガシンカ・ダイマックス:**
- 特殊形態の表示
- フォルムチェンジ機能

**タイプ相性チェッカー:**
- タイプ相性の表示
- 4倍弱点の警告

**ポケモン比較機能:**
- 複数ポケモンの種族値比較
- グラフ表示

---

## 🎓 チーム開発のためのガイドライン

### 1. コーディング規約

**命名規則:**
- Entity: `PokemonEntity`, `MoveEntity`
- UseCase: `FetchPokemonListUseCase`
- Repository: `PokemonRepository`
- ViewModel: `PokemonListViewModel`

**ファイル配置:**
```
Domain/
  ├─ Entities/
  │   ├─ Pokemon/
  │   │   ├─ PokemonEntity.swift
  │   │   ├─ BaseStats.swift
  │   │   └─ AbilityInfo.swift
  │   └─ Move/
  │       ├─ MoveEntity.swift
  │       └─ MoveLearnMethod.swift
  ├─ UseCases/
  │   ├─ Pokemon/
  │   │   ├─ FetchPokemonListUseCase.swift
  │   │   └─ SortPokemonUseCase.swift
  │   └─ Filter/
  │       ├─ FilterPokemonByAbilityUseCase.swift
  │       └─ FilterPokemonByMovesUseCase.swift
  └─ Interfaces/
      ├─ PokemonRepository.swift
      ├─ AbilityRepository.swift
      └─ MoveRepository.swift
```

### 2. Pull Requestのルール

**PR作成時のチェックリスト:**
- [ ] ユニットテストを追加
- [ ] 既存テストがすべてパス
- [ ] ドキュメントを更新
- [ ] コードレビューを依頼

### 3. コードレビューの観点

- Clean Architectureの原則に従っているか
- 適切なエラーハンドリングがあるか
- パフォーマンスへの考慮があるか
- テストカバレッジは十分か

---

## 🏁 まとめ

本設計書では、requirements_v2.mdで定義された以下の機能を実現するための技術設計を記述しました:

1. ✅ PokemonRow表示拡張(特性・種族値追加)
2. ✅ 特性フィルター機能
3. ✅ 種族値ソート機能
4. ✅ バージョングループ別表示機能
5. ✅ 全ポケモン対応(1025匹)
6. ✅ ローディングUI改善
7. ✅ 技フィルター機能(複数技対応)
8. ✅ スクロール位置保持

Clean Architecture + MVVMパターンを維持しながら、各層での拡張ポイントを明確にし、実装可能な設計としました。

---

**文書管理:**
- ファイル名: `design_v2.md`
- 配置場所: `docs/`
- 関連文書: `requirements_v2.md`, `design.md`, `requirements.md`
---

## 🎉 実装完了機能

### v2.0で実装された機能

以下の機能が設計通りに実装され、テスト済みです：

#### ✅ 1. PokemonRow表示拡張
- 特性表示（通常特性 + 隠れ特性）
- 種族値表示（全ステータス + 合計値）
- バージョングループ別の仕様対応
- 実装ファイル: `Pokedex/Presentation/PokemonList/Components/PokemonRow.swift`

#### ✅ 2. バージョングループ別表示
- 22種類のバージョングループ対応
- 全国図鑑モード
- バージョングループごとのキャッシュ
- 実装ファイル: 
  - `Pokedex/Domain/Entities/VersionGroup.swift`
  - `Pokedex/Domain/UseCases/FetchVersionGroupsUseCase.swift`
  - `Pokedex/Presentation/PokemonList/PokemonListViewModel.swift`

#### ✅ 3. 全ポケモン対応
- 1025匹の全ポケモンに対応
- 並列取得による高速化
- プログレスバー表示
- 実装ファイル:
  - `Pokedex/Domain/UseCases/FetchPokemonListUseCase.swift`
  - `Pokedex/Data/Repositories/PokemonRepository.swift`

#### ✅ 4. 特性フィルター
- 複数特性選択
- バージョングループ連動
- インクリメンタルサーチ
- 実装ファイル:
  - `Pokedex/Domain/UseCases/Filter/FilterPokemonByAbilityUseCase.swift`
  - `Pokedex/Domain/UseCases/FetchAllAbilitiesUseCase.swift`
  - `Pokedex/Data/Repositories/AbilityRepository.swift`

#### ✅ 5. 技フィルター
- 最大4技選択
- 習得方法表示（レベル、TM/TR、タマゴ技など）
- バージョングループ選択時のみ有効
- 実装ファイル:
  - `Pokedex/Domain/UseCases/Filter/FilterPokemonByMovesUseCase.swift`
  - `Pokedex/Domain/UseCases/FetchAllMovesUseCase.swift`
  - `Pokedex/Data/Repositories/MoveRepository.swift`
  - `Pokedex/Data/Cache/MoveCache.swift`

#### ✅ 6. 種族値ソート
- 合計値ソート
- 個別ステータスソート（HP、攻撃、防御、特攻、特防、素早さ）
- 昇順/降順切り替え
- 実装ファイル:
  - `Pokedex/Domain/UseCases/Sort/SortPokemonUseCase.swift`
  - `Pokedex/Domain/Entities/SortOption.swift`

#### ✅ 7. スクロール位置保持
- 詳細画面からの復帰時に元の位置へ
- ScrollViewReaderを使用した実装
- 実装ファイル: `Pokedex/Presentation/PokemonList/PokemonListView.swift`

#### ✅ 8. ローディングUI改善
- プログレスバー表示
- 進捗率表示（例: 450/1025）
- バックグラウンドローディング対応
- 実装ファイル: `Pokedex/Presentation/PokemonList/PokemonListView.swift`

### テスト状況

#### ユニットテスト (85件)
- **Domain層**: 
  - FetchPokemonListUseCaseTests
  - FilterPokemonByMovesUseCaseTests
  - FetchAllMovesUseCaseTests
  - SortPokemonUseCaseTests
  - FilterPokemonByAbilityUseCaseTests
- **Presentation層**:
  - PokemonListViewModelTests
  - PokemonDetailViewModelTests
- **Data層**:
  - MoveCacheTests

#### 統合テスト (20件)
- **VersionGroupIntegrationTests** (5件):
  - バージョングループ切り替え
  - ソートオプション維持
  - キャッシュ効果確認
- **FilterIntegrationTests** (8件):
  - 技・特性・タイプフィルター連携
  - 複数フィルター組み合わせ
- **SortIntegrationTests** (7件):
  - 各種ソートオプション
  - フィルター後のソート維持

#### パフォーマンステスト (8件)
- 初回ロード時間
- バージョングループ切り替え時間
- フィルター処理速度
- ソート処理速度

#### テストカバレッジ
- **Domain層**: 85%以上
- **Data層**: 80%以上
- **Presentation層**: 75%以上

### 既知の制約事項

1. **技フィルター**: 全国図鑑モードでは無効
   - 理由: 技の習得方法がバージョンごとに異なるため
   - 対応: バージョングループ選択時のみフィルター有効

2. **特性フィルター**: 第1〜2世代では無効
   - 理由: 特性システムが未実装の世代
   - 対応: 第3世代以降で自動的に有効化

3. **初回ロード**: 全ポケモン取得のため数秒かかる
   - 理由: 1025匹のポケモンデータを並列取得
   - 対応: プログレスバー表示、2回目以降はキャッシュで高速化

### パフォーマンス特性

- **初回ロード**: 全ポケモンデータ取得のため時間がかかる
- **バージョングループ切り替え**: キャッシュにより2回目以降は高速
- **フィルター処理**: タイプ・特性は即座、技フィルターはAPI呼び出しのため時間がかかる
- **ソート処理**: メモリ上の操作のため高速

### 今後の改善案

1. **オフライン対応強化**
   - CoreDataによる永続化
   - オフライン時のデータ表示

2. **お気に入り機能**
   - UserDefaultsまたはCoreDataで保存
   - お気に入りタブの追加

3. **リージョンフォーム対応**
   - アローラ、ガラル、ヒスイフォームの表示
   - フォーム切り替えUI

4. **UI/UX改善**
   - ダークモード対応
   - アニメーション追加
   - 詳細画面の情報拡充

5. **機能追加**
   - タイプ相性チェッカー
   - ポケモン比較機能
   - チーム編成機能

---

**実装完了日**: 2025-10-05  
**バージョン**: 2.0.0  
**実装者**: Yusuke Abe
