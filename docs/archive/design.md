# 設計書 - Pokédex SwiftUI

## 📐 アーキテクチャ概要

このプロジェクトは**Clean Architecture + MVVM**を採用しています。

### アーキテクチャの目的

- **保守性**: 変更が特定の層に限定され、影響範囲が明確
- **テスタビリティ**: ビジネスロジックを独立してテスト可能
- **再利用性**: Domain層は将来のUIKit版でも再利用可能
- **理解しやすさ**: 責務が明確に分離されている

---

## 🏗️ レイヤー構成

```
┌─────────────────────────────────────┐
│         Presentation Layer          │
│      (SwiftUI Views + ViewModels)   │
│   - ユーザーインターフェース          │
│   - ユーザー操作の受付               │
│   - 画面表示のロジック               │
└─────────────────────────────────────┘
                 ↓↑
┌─────────────────────────────────────┐
│          Domain Layer               │
│    (Entities + UseCases + Protocols)│
│   - ビジネスロジック                 │
│   - データ構造の定義                 │
│   - アプリの中核ルール               │
└─────────────────────────────────────┘
                 ↓↑
┌─────────────────────────────────────┐
│           Data Layer                │
│    (Repositories + API Clients)     │
│   - データの取得・保存               │
│   - 外部APIとの通信                 │
│   - データの変換                    │
└─────────────────────────────────────┘
                 ↓↑
┌─────────────────────────────────────┐
│         External Services           │
│          (PokéAPI)                  │
└─────────────────────────────────────┘
```

### 依存関係のルール

- **Presentation → Domain**: ViewModelがUseCaseを使用
- **Domain → Data**: UseCaseがRepositoryプロトコルを使用
- **Data → Domain**: RepositoryがプロトコルとEntityを実装
- **逆方向の依存は禁止**: 下位レイヤーが上位レイヤーを知らない

---

## 📂 フォルダ構成

```
PokedexApp/
├── PokedexApp.swift                 # アプリエントリーポイント
│
├── Domain/                          # ビジネスロジック層
│   ├── Entities/                    # データ構造
│   │   ├── Pokemon.swift
│   │   ├── PokemonType.swift
│   │   ├── PokemonStat.swift
│   │   ├── PokemonAbility.swift
│   │   ├── PokemonSprites.swift
│   │   └── EvolutionChain.swift
│   │
│   ├── UseCases/                    # ビジネスロジック
│   │   ├── FetchPokemonListUseCase.swift
│   │   ├── FetchPokemonDetailUseCase.swift
│   │   ├── SearchPokemonUseCase.swift
│   │   └── FilterPokemonUseCase.swift
│   │
│   └── Interfaces/                  # プロトコル定義
│       └── PokemonRepositoryProtocol.swift
│
├── Data/                            # データアクセス層
│   ├── Repositories/
│   │   └── PokemonRepository.swift  # Repositoryの実装
│   │
│   ├── Network/
│   │   └── PokemonAPIClient.swift   # API通信ラッパー
│   │
│   └── DTOs/                        # データ変換
│       └── PokemonMapper.swift      # API DTO → Entity
│
├── Presentation/                    # UI層
│   ├── PokemonList/
│   │   ├── PokemonListView.swift
│   │   ├── PokemonListViewModel.swift
│   │   └── Components/
│   │       └── PokemonRow.swift
│   │
│   ├── PokemonDetail/
│   │   ├── PokemonDetailView.swift
│   │   ├── PokemonDetailViewModel.swift
│   │   └── Components/
│   │       ├── PokemonHeaderView.swift
│   │       ├── PokemonStatsView.swift
│   │       ├── PokemonAbilitiesView.swift
│   │       ├── EvolutionChainView.swift
│   │       └── PokemonMovesView.swift
│   │
│   ├── Search/
│   │   ├── SearchFilterView.swift
│   │   └── SearchFilterViewModel.swift
│   │
│   └── Common/                      # 共通UI部品
│       ├── AsyncImageView.swift
│       ├── LoadingView.swift
│       ├── ErrorView.swift
│       └── TypeBadge.swift
│
├── Application/                     # アプリ設定
│   ├── DIContainer.swift            # 依存性注入
│   └── AppCoordinator.swift         # ナビゲーション管理
│
└── Resources/
    └── Assets.xcassets
```

---

## 🎯 主要コンポーネント設計

### Domain Layer

#### Entities

##### Pokemon.swift
```swift
struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let height: Int              // デシメートル単位
    let weight: Int              // ヘクトグラム単位
    let types: [PokemonType]
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let sprites: PokemonSprites
    let species: PokemonSpecies? // 進化チェーン取得用
    
    // 計算プロパティ
    var heightInMeters: Double {
        Double(height) / 10.0
    }
    
    var weightInKilograms: Double {
        Double(weight) / 10.0
    }
}
```

##### PokemonType.swift
```swift
struct PokemonType: Codable {
    let slot: Int
    let name: String
    
    // タイプ別の色
    var color: Color {
        switch name.lowercased() {
        case "normal": return .gray
        case "fire": return .red
        case "water": return .blue
        case "grass": return .green
        case "electric": return .yellow
        // ... 他のタイプ
        default: return .gray
        }
    }
}
```

##### PokemonStat.swift
```swift
struct PokemonStat: Codable, Identifiable {
    let id = UUID()
    let name: String
    let baseStat: Int
    
    // 日本語表示名
    var displayName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "こうげき"
        case "defense": return "ぼうぎょ"
        case "special-attack": return "とくこう"
        case "special-defense": return "とくぼう"
        case "speed": return "すばやさ"
        default: return name
        }
    }
}
```

#### UseCases

##### FetchPokemonListUseCase.swift
```swift
protocol FetchPokemonListUseCaseProtocol {
    func execute(limit: Int, offset: Int) async throws -> [Pokemon]
}

final class FetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(limit: Int = 151, offset: Int = 0) async throws -> [Pokemon] {
        return try await repository.fetchPokemonList(limit: limit, offset: offset)
    }
}
```

##### FetchPokemonDetailUseCase.swift
```swift
protocol FetchPokemonDetailUseCaseProtocol {
    func execute(id: Int) async throws -> Pokemon
    func execute(name: String) async throws -> Pokemon
}

final class FetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol
    
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> Pokemon {
        return try await repository.fetchPokemonDetail(id: id)
    }
    
    func execute(name: String) async throws -> Pokemon {
        return try await repository.fetchPokemonDetail(name: name)
    }
}
```

#### Interfaces

##### PokemonRepositoryProtocol.swift
```swift
protocol PokemonRepositoryProtocol {
    func fetchPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonDetail(name: String) async throws -> Pokemon
    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain
    func fetchPokemonMoves(id: Int, generation: Int) async throws -> [Move]
}
```

---

### Data Layer

#### Repositories

##### PokemonRepository.swift
```swift
final class PokemonRepository: PokemonRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private var cache: [Int: Pokemon] = [:]
    
    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }
    
    func fetchPokemonList(limit: Int, offset: Int) async throws -> [Pokemon] {
        // API呼び出し + キャッシュ処理
    }
    
    func fetchPokemonDetail(id: Int) async throws -> Pokemon {
        // キャッシュチェック → API呼び出し
        if let cached = cache[id] {
            return cached
        }
        
        let pokemon = try await apiClient.fetchPokemon(id)
        cache[id] = pokemon
        return pokemon
    }
}
```

#### Network

##### PokemonAPIClient.swift
```swift
final class PokemonAPIClient {
    private let pokemonAPI = PokemonAPI()
    
    func fetchPokemon(_ id: Int) async throws -> Pokemon {
        let pkm = try await pokemonAPI.pokemonService.fetchPokemon(id)
        return PokemonMapper.map(from: pkm)
    }
    
    func fetchPokemonList(limit: Int) async throws -> [Pokemon] {
        let pagedObject = try await pokemonAPI.pokemonService.fetchPokemonList(
            paginationState: .initial(pageLimit: limit)
        )
        
        // 並列取得でパフォーマンス向上
        return try await withThrowingTaskGroup(of: Pokemon?.self) { group in
            for resource in pagedObject.results ?? [] {
                group.addTask {
                    try await self.pokemonAPI.resourceService.fetch(resource)
                        .map { PokemonMapper.map(from: $0) }
                }
            }
            
            var results: [Pokemon] = []
            for try await pokemon in group {
                if let pokemon = pokemon {
                    results.append(pokemon)
                }
            }
            return results.sorted { $0.id < $1.id }
        }
    }
}
```

---

### Presentation Layer

#### ViewModels

##### PokemonListViewModel.swift
```swift
@MainActor
final class PokemonListViewModel: ObservableObject {
    // Published プロパティ
    @Published var pokemons: [Pokemon] = []
    @Published var filteredPokemons: [Pokemon] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // フィルター状態
    @Published var searchText = ""
    @Published var selectedTypes: Set<String> = []
    
    // Dependencies
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol
    private let searchPokemonUseCase: SearchPokemonUseCaseProtocol
    
    init(
        fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol,
        searchPokemonUseCase: SearchPokemonUseCaseProtocol
    ) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
        self.searchPokemonUseCase = searchPokemonUseCase
    }
    
    func loadPokemons() async {
        isLoading = true
        errorMessage = nil
        
        do {
            pokemons = try await fetchPokemonListUseCase.execute(limit: 151)
            applyFilters()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func applyFilters() {
        filteredPokemons = pokemons.filter { pokemon in
            let matchesSearch = searchText.isEmpty || 
                pokemon.name.localizedCaseInsensitiveContains(searchText)
            
            let matchesType = selectedTypes.isEmpty || 
                pokemon.types.contains { selectedTypes.contains($0.name) }
            
            return matchesSearch && matchesType
        }
    }
}
```

##### PokemonDetailViewModel.swift
```swift
@MainActor
final class PokemonDetailViewModel: ObservableObject {
    @Published var pokemon: Pokemon
    @Published var isShiny = false
    @Published var selectedGeneration = 1
    @Published var moves: [Move] = []
    @Published var evolutionChain: EvolutionChain?
    @Published var isLoading = false
    
    private let fetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol
    
    init(
        pokemon: Pokemon,
        fetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol
    ) {
        self.pokemon = pokemon
        self.fetchPokemonDetailUseCase = fetchPokemonDetailUseCase
    }
    
    func loadDetails() async {
        // 詳細情報、進化チェーン、技などを取得
    }
    
    func toggleShiny() {
        isShiny.toggle()
    }
}
```

#### Views

##### PokemonListView.swift
```swift
struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @State private var showingFilter = false
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading {
                    LoadingView()
                } else if let error = viewModel.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.loadPokemons() }
                    }
                } else {
                    pokemonList
                }
            }
            .navigationTitle("Pokédex")
            .searchable(text: $viewModel.searchText)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingFilter = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showingFilter) {
                SearchFilterView(viewModel: viewModel)
            }
            .task {
                await viewModel.loadPokemons()
            }
        }
    }
    
    private var pokemonList: some View {
        List(viewModel.filteredPokemons) { pokemon in
            NavigationLink(value: pokemon) {
                PokemonRow(pokemon: pokemon)
            }
        }
        .navigationDestination(for: Pokemon.self) { pokemon in
            PokemonDetailView(pokemon: pokemon)
        }
    }
}
```

---

## 🔄 データフロー

### ポケモンリスト取得の流れ

```
1. PokemonListView
   └─ .task { await viewModel.loadPokemons() }
      │
2. PokemonListViewModel
   └─ fetchPokemonListUseCase.execute(limit: 151)
      │
3. FetchPokemonListUseCase
   └─ repository.fetchPokemonList(limit: 151, offset: 0)
      │
4. PokemonRepository
   ├─ キャッシュチェック
   └─ apiClient.fetchPokemonList(limit: 151)
      │
5. PokemonAPIClient
   ├─ pokemonAPI.pokemonService.fetchPokemonList()
   └─ 並列でポケモン詳細を取得
      │
6. PokéAPI (外部)
   └─ HTTPレスポンス
      │
7. PokemonMapper
   └─ PKMPokemon → Pokemon (Entityに変換)
      │
8. Repository → UseCase → ViewModel
   └─ @Published var pokemons が更新される
      │
9. SwiftUI
   └─ 自動的にViewが再描画
```

---

## 🧩 依存性注入(DI)

### DIContainer.swift

```swift
final class DIContainer: ObservableObject {
    // Singletonインスタンス
    static let shared = DIContainer()
    
    // Repositories
    private lazy var pokemonRepository: PokemonRepositoryProtocol = {
        PokemonRepository()
    }()
    
    // UseCases
    func makeFetchPokemonListUseCase() -> FetchPokemonListUseCaseProtocol {
        FetchPokemonListUseCase(repository: pokemonRepository)
    }
    
    func makeFetchPokemonDetailUseCase() -> FetchPokemonDetailUseCaseProtocol {
        FetchPokemonDetailUseCase(repository: pokemonRepository)
    }
    
    // ViewModels
    func makePokemonListViewModel() -> PokemonListViewModel {
        PokemonListViewModel(
            fetchPokemonListUseCase: makeFetchPokemonListUseCase(),
            searchPokemonUseCase: makeSearchPokemonUseCase()
        )
    }
}
```

### アプリエントリーポイント

```swift
@main
struct PokedexApp: App {
    @StateObject private var container = DIContainer.shared
    
    var body: some Scene {
        WindowGroup {
            PokemonListView(
                viewModel: container.makePokemonListViewModel()
            )
            .environmentObject(container)
        }
    }
}
```

---

## 🎨 UI設計の原則

### SwiftUIのベストプラクティス

1. **ViewとViewModelの分離**
   - ViewはUIの構造のみ
   - ビジネスロジックはViewModelに

2. **再利用可能なコンポーネント**
   - TypeBadge, PokemonRow など小さく分割

3. **Lazy Loading**
   - List, LazyVStack, LazyHStack を活用

4. **State管理**
   - @State: View内のローカル状態
   - @StateObject: ViewModelの所有
   - @ObservedObject: 親から渡されたViewModel
   - @EnvironmentObject: DIコンテナなど

---

## 🧪 テスト戦略

### テスト対象

#### Domain層(優先度: 高)
- UseCaseのユニットテスト
- Entityのロジックテスト

#### Presentation層(優先度: 中)
- ViewModelのユニットテスト
- モックRepositoryを使用

#### Data層(優先度: 低)
- 今回は最小限

### テストの例

```swift
final class FetchPokemonListUseCaseTests: XCTestCase {
    func testExecute_Success() async throws {
        // Given
        let mockRepository = MockPokemonRepository()
        let useCase = FetchPokemonListUseCase(repository: mockRepository)
        
        // When
        let pokemons = try await useCase.execute(limit: 10)
        
        // Then
        XCTAssertEqual(pokemons.count, 10)
        XCTAssertEqual(pokemons.first?.name, "bulbasaur")
    }
}
```

---

## 📊 パフォーマンス最適化

### API呼び出しの最適化

1. **並列リクエスト**
   - TaskGroupで複数のポケモンを同時取得
   - 最大5個までに制限

2. **メモリキャッシュ**
   - Repository内でDictionaryでキャッシュ
   - 同じポケモンは再取得しない

3. **画像キャッシュ**
   - AsyncImageまたはKingfisher使用

### UI描画の最適化

1. **Lazy表示**
   - List, LazyVStack使用
   - 画面外の要素は描画しない

2. **画像の遅延読み込み**
   - AsyncImageで自動管理

---

## 🔒 エラーハンドリング

### エラーの種類

```swift
enum PokemonError: LocalizedError {
    case networkError(Error)
    case notFound
    case invalidData
    case timeout
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "通信エラー: \(error.localizedDescription)"
        case .notFound:
            return "ポケモンが見つかりませんでした"
        case .invalidData:
            return "データの形式が正しくありません"
        case .timeout:
            return "通信がタイムアウトしました"
        }
    }
}
```

### エラー表示

- Alertでユーザーに通知
- リトライボタンを提供
- エラーメッセージは分かりやすく

---

## 📱 画面遷移設計

### NavigationStackの構造

```
NavigationStack
├─ PokemonListView
│  └─ navigationDestination(for: Pokemon.self)
│     └─ PokemonDetailView
│        └─ navigationDestination(for: Pokemon.self)
│           └─ PokemonDetailView (進化先)
│
└─ .sheet(isPresented: $showingFilter)
   └─ SearchFilterView
```

---

## ✅ まとめ

この設計により以下を実現:

- ✅ **保守性**: レイヤーが明確に分離
- ✅ **テスタビリティ**: Mockを使った単体テスト可能
- ✅ **拡張性**: 新機能追加が容易
- ✅ **可読性**: コードの役割が明確
- ✅ **再利用性**: Domain層は他のUIでも使用可能

---

**作成日**: 2025-10-04  
**バージョン**: 1.0.0