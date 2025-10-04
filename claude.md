# Claude Code 開発ガイド

このファイルはClaude Codeがプロジェクト開発を支援する際の指針を示します。

## 📋 プロジェクト概要

- **プロジェクト名**: Pokédex SwiftUI
- **目的**: ポケモンファン向けの図鑑アプリ
- **アーキテクチャ**: Clean Architecture + MVVM
- **UI**: SwiftUI
- **最低iOS**: iOS 17.0+

## 🏗️ アーキテクチャルール

### レイヤー構成

```
Presentation (SwiftUI Views + ViewModels)
    ↓
Domain (Entities + UseCases + Protocols)
    ↓
Data (Repositories + API Clients)
```

### 依存関係の原則

1. **上位レイヤーは下位レイヤーに依存できる**
   - Presentation → Domain → Data

2. **下位レイヤーは上位レイヤーに依存してはいけない**
   - Data層はDomain層のプロトコルを実装するのみ

3. **Domain層は外部依存を持たない**
   - SwiftUI、PokemonAPIライブラリへの直接依存禁止
   - プロトコルを通じた抽象化

## 📂 ファイル配置ルール

### Domain層

```
Pokedex/Pokedex/Domain/
├── Entities/          # データ構造（struct、enum）
├── UseCases/          # ビジネスロジック（final class）
└── Interfaces/        # プロトコル定義
```

- **Entities**: `struct`で定義、`Identifiable`, `Codable`準拠
- **UseCases**: `final class`で定義、プロトコルとペアで作成
- **Interfaces**: Repositoryのプロトコルのみ

### Data層

```
Pokedex/Pokedex/Data/
├── Repositories/      # Repository実装
├── Network/           # API通信
└── DTOs/              # データ変換
```

- **Repositories**: Domainのプロトコルを実装
- **Network**: PokemonAPIライブラリのラッパー
- **DTOs**: APIレスポンス → Entity変換

### Presentation層

```
Pokedex/Pokedex/Presentation/
├── 機能名/
│   ├── XXXView.swift
│   ├── XXXViewModel.swift
│   └── Components/
└── Common/            # 共通コンポーネント
```

- **View**: SwiftUI View、UIロジックのみ
- **ViewModel**: `@MainActor`, `ObservableObject`準拠
- **Components**: 再利用可能な小さなView

## 🎯 コーディング規約

### 命名規則

- **ファイル名**: PascalCase、用途が明確に
  - 例: `Pokemon.swift`, `FetchPokemonListUseCase.swift`
  
- **クラス/構造体**: PascalCase
  - 例: `PokemonListViewModel`, `Pokemon`

- **変数/関数**: camelCase
  - 例: `fetchPokemons()`, `isLoading`

- **定数**: camelCase
  - 例: `maxRetryCount`, `defaultPageLimit`

### SwiftUIスタイル

```swift
// ✅ Good
struct PokemonListView: View {
    @StateObject private var viewModel: PokemonListViewModel
    @State private var showingFilter = false
    
    var body: some View {
        content
    }
    
    // 複雑なViewは分割
    private var content: some View {
        List(viewModel.pokemons) { pokemon in
            PokemonRow(pokemon: pokemon)
        }
    }
}

// ❌ Bad: bodyが長すぎる
struct PokemonListView: View {
    var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                List(viewModel.pokemons) { pokemon in
                    // 50行以上のコード...
                }
            }
        }
    }
}
```

### ViewModelスタイル

```swift
// ✅ Good
@MainActor
final class PokemonListViewModel: ObservableObject {
    // Published properties
    @Published private(set) var pokemons: [Pokemon] = []
    @Published private(set) var isLoading = false
    @Published var searchText = ""
    
    // Dependencies
    private let fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol
    
    // Initialization
    init(fetchPokemonListUseCase: FetchPokemonListUseCaseProtocol) {
        self.fetchPokemonListUseCase = fetchPokemonListUseCase
    }
    
    // Public methods
    func loadPokemons() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            pokemons = try await fetchPokemonListUseCase.execute()
        } catch {
            // エラーハンドリング
        }
    }
}
```

## 🚫 禁止事項

### 絶対にやってはいけないこと

1. **Domain層に外部ライブラリの型を使う**
   ```swift
   // ❌ Bad
   import PokemonAPI
   struct Pokemon {
       let pkm: PKMPokemon  // PokemonAPIの型を直接使用
   }
   
   // ✅ Good
   struct Pokemon {
       let id: Int
       let name: String
       // 独自の型を定義
   }
   ```

2. **ViewModelにUI要素を含める**
   ```swift
   // ❌ Bad
   @Published var alertTitle: String = ""
   @Published var showAlert: Bool = false
   
   // ✅ Good
   @Published var errorMessage: String?
   // Viewでerrorがnilでなければアラート表示
   ```

3. **Viewにビジネスロジックを書く**
   ```swift
   // ❌ Bad
   var body: some View {
       List {
           ForEach(pokemons.filter { pokemon in
               searchText.isEmpty || pokemon.name.contains(searchText)
           }) { pokemon in
               // ...
           }
       }
   }
   
   // ✅ Good
   // ViewModelでフィルタリング
   var body: some View {
       List(viewModel.filteredPokemons) { pokemon in
           // ...
       }
   }
   ```

4. **グローバル変数の使用**
   ```swift
   // ❌ Bad
   var globalPokemons: [Pokemon] = []
   
   // ✅ Good
   // ViewModelやRepositoryで管理
   ```

## 📝 コメントルール

### コメントを書くべき箇所

1. **複雑なロジック**
   ```swift
   // ポケモンIDから世代を判定
   // 第1世代: 1-151, 第2世代: 152-251, ...
   func generation(for id: Int) -> Int {
       return (id - 1) / 151 + 1
   }
   ```

2. **外部APIの仕様に依存する部分**
   ```swift
   // PokéAPIは身長をデシメートル単位で返す
   var heightInMeters: Double {
       Double(height) / 10.0
   }
   ```

### コメント不要な箇所

```swift
// ❌ Bad: コード読めば分かる
// ポケモンをロード
func loadPokemons() async {
    // ...
}

// ✅ Good: 説明的な関数名
func loadPokemons() async {
    // ...
}
```

## 🧪 テストに関して

### テスト作成の優先順位

1. **高**: UseCaseのテスト
2. **中**: ViewModelのテスト  
3. **低**: Repositoryのテスト（今回は最小限）

### テストコード例

```swift
final class FetchPokemonListUseCaseTests: XCTestCase {
    func test_正常系_ポケモンリストを取得できる() async throws {
        // Given
        let mockRepo = MockPokemonRepository()
        let useCase = FetchPokemonListUseCase(repository: mockRepo)
        
        // When
        let pokemons = try await useCase.execute(limit: 10)
        
        // Then
        XCTAssertEqual(pokemons.count, 10)
    }
}
```

## 🔧 実装の進め方

### 実装順序

1. **Domain層** (外部依存なし、最初に固める)
   - Entities
   - UseCases + Protocols
   
2. **Data層** (Domainに依存)
   - Repositories
   - API Client
   
3. **Presentation層** (Domain + Dataに依存)
   - ViewModels
   - Views

### 1つの機能を実装する流れ

```
例: ポケモン一覧機能

1. Pokedex/Pokedex/Domain/Entities/Pokemon.swift
2. Pokedex/Pokedex/Domain/Interfaces/PokemonRepositoryProtocol.swift
3. Pokedex/Pokedex/Domain/UseCases/FetchPokemonListUseCase.swift
4. Pokedex/Pokedex/Data/Repositories/PokemonRepository.swift
5. Pokedex/Pokedex/Presentation/PokemonList/PokemonListViewModel.swift
6. Pokedex/Pokedex/Presentation/PokemonList/PokemonListView.swift
7. (オプション) Tests/
```

## 🛡️ エラーハンドリング

### エラー型の定義

```swift
enum PokemonError: LocalizedError {
    case networkError(Error)
    case notFound
    case invalidData
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "通信エラー: \(error.localizedDescription)"
        case .notFound:
            return "ポケモンが見つかりませんでした"
        case .invalidData:
            return "データが不正です"
        }
    }
}
```

### エラーハンドリングパターン

```swift
// ViewModel内
func loadPokemons() async {
    isLoading = true
    errorMessage = nil
    
    do {
        pokemons = try await fetchPokemonListUseCase.execute()
    } catch {
        errorMessage = error.localizedDescription
    }
    
    isLoading = false
}

// View内
.alert("エラー", isPresented: $viewModel.hasError) {
    Button("OK") { }
} message: {
    Text(viewModel.errorMessage ?? "")
}
```

## 📚 使用ライブラリ

### 必須ライブラリ

- **PokemonAPI**: PokéAPI通信
  - `import PokemonAPI`はData層のみ
  - Domain層では使用禁止

- **Kingfisher** (オプション): 画像キャッシュ
  - AsyncImageで十分な場合は不要

### ライブラリ使用ルール

1. Data層でラップして使用
2. Domain層には型を漏らさない
3. 将来ライブラリを変更できるように抽象化

## 🎨 UI実装のガイドライン

### システムカラーを使用

```swift
// ✅ Good
.foregroundColor(.blue)
.background(.gray.opacity(0.2))

// ❌ Bad: ハードコードされた色
.foregroundColor(Color(red: 0.0, green: 0.5, blue: 1.0))
```

### レスポンシブデザイン

```swift
// ✅ Good: ダイナミックタイプ対応
Text(pokemon.name)
    .font(.headline)

// ❌ Bad: 固定サイズ
Text(pokemon.name)
    .font(.system(size: 18))
```

## 📊 パフォーマンス

### API呼び出しの制限

- 並列リクエストは最大5個まで
- 同じデータの重複取得を避ける
- キャッシュを活用

### UI描画の最適化

- Lazy系コンポーネント使用 (List, LazyVStack)
- 不要な再描画を避ける (@State, @Publishedの適切な使用)

## ✅ 質問する前のチェックリスト

実装に迷ったら:

1. **docs/design.md** を確認
2. **docs/requirements.md** を確認
3. **このclaude.md** を確認
4. 似た機能の実装を参考にする

## 🔄 変更管理

### コミットメッセージ

```
feat: ポケモン一覧画面を実装
fix: ポケモン詳細画面のクラッシュを修正
refactor: ViewModelのコードを整理
docs: READMEを更新
test: FetchPokemonListUseCaseのテストを追加
```

## 📞 サポート

質問や不明点があれば:
- docs/design.md の該当セクションを確認
- 既存の類似実装を参照
- このファイルのルールに従っているか確認

---

**最終更新**: 2025-10-04  
**バージョン**: 1.0.0