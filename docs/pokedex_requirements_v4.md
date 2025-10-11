# Pokédex SwiftUI - 要件定義書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-10

---

## 📋 目次

1. [概要](#概要)
2. [背景と目的](#背景と目的)
3. [機能要件](#機能要件)
4. [非機能要件](#非機能要件)
5. [技術要件](#技術要件)
6. [実装フェーズ](#実装フェーズ)

---

## 概要

### バージョン4.0のテーマ
**「パフォーマンス最適化 - 快適な図鑑体験の実現」**

v3.0で詳細画面の機能を大幅に拡充したが、初回起動時のデータ取得に60-90秒かかり、ユーザー体験を損なっている。v4.0では、確実性を保ちつつ、パフォーマンスを大幅に改善する。

### 主な改善目標

| 項目 | v3.0（現状） | v4.0 Phase 1 | v4.0 Phase 2 |
|------|-------------|-------------|-------------|
| 初回起動時間 | 60-90秒 | 60-90秒 | **1秒以内** |
| 2回目以降起動 | 60-90秒 | **1秒以内** | **1秒以内** |
| 技フィルター | 数十秒 | **3秒以内** | **3秒以内** |
| オフライン対応 | ❌ | ⚠️（2回目以降） | ✅（初回から） |

---

## 背景と目的

### v3.0の課題

1. **初回起動が遅い**
   - 全ポケモン（1025匹）を順次取得するため60-90秒かかる
   - ユーザーは画面が表示されるまで何もできない

2. **2回目以降も遅い**
   - メモリキャッシュのみのため、アプリ再起動で全データ消失
   - 91%まで取得しても再起動すると1%からやり直し
   - 毎回60-90秒待たされる

3. **技フィルターが遅い**
   - 現在の実装（FilterPokemonByMovesUseCase.swift:72-77）:
     ```swift
     for pokemon in pokemonList {  // バージョン選択時のポケモン全て
         let learnMethods = try await moveRepository.fetchLearnMethods(
             pokemonId: pokemon.id,  // 各ポケモンごとにAPI呼び出し
             moveIds: selectedMoves.map { $0.id },
             versionGroup: versionGroup
         )
     }
     ```
   - 各ポケモンの技習得方法を取得するため、選択中のポケモン全てに対してAPI呼び出し
   - ポケモン数 × 約0.1秒/匹 = 数十秒かかる
   - フィルター結果が表示されるまで実用的でない

### v4.0の解決策

**Phase 1: SwiftData永続化**
1. **2回目以降の即時起動**
   - 取得したデータをディスクに永続化
   - アプリ再起動でも1秒以内で表示
   - オフライン閲覧に対応（2回目以降）

**Phase 2: プリバンドルデータベース**
2. **初回起動の高速化**
   - アプリに全データを同梱
   - 初回起動から1秒以内で表示
   - 完全オフライン対応（初回から）

**Phase 3: 技フィルターの高速化**
3. **技検索の実用化**
   - 技データをSwiftDataで永続化
   - 3秒以内で検索結果表示

---

## 機能要件

### Phase 1: SwiftData永続化（高優先度・1-2日）

#### FR-4.1.1 ポケモンデータの永続化

**要件**:
- 取得したポケモンデータをSwiftDataでディスクに保存
- アプリ再起動後もデータを保持
- 2回目以降の起動を1秒以内に短縮

**SwiftDataモデル**:
- PokemonModel: ポケモン基本情報
- PokemonTypeModel: タイプ情報
- PokemonStatModel: 種族値
- PokemonAbilityModel: 特性
- PokemonSpriteModel: 画像URL

**受入基準**:
- [ ] 初回起動: API から全データ取得・SwiftData に保存（60-90秒）
- [ ] 2回目起動: SwiftData から読み込み・1秒以内に表示
- [ ] オフライン: 機内モードでも2回目以降は全機能動作
- [ ] データ整合性: 保存・読み込みでデータ欠損なし

#### FR-4.1.2 キャッシュ管理

**要件**:
- 設定画面からキャッシュをクリア可能
- キャッシュサイズを表示
- キャッシュの最終更新日時を表示

**受入基準**:
- [ ] 設定画面に「キャッシュをクリア」ボタン
- [ ] クリア前に確認ダイアログを表示
- [ ] クリア後、次回起動時に再取得

---

### Phase 2: プリバンドルデータベース（中優先度・2-3日）

#### FR-4.2.1 データベース生成とバンドル

**要件**:
- 全ポケモン（1025匹）のデータをSwiftDataで事前生成
- 生成したデータベース（.sqlite）をアプリに同梱
- 初回起動時にバンドルDBをDocumentsディレクトリにコピー
- 初回から1秒以内で全データを表示可能

**データ生成スクリプト**:
- Scripts/GenerateDatabase.swift を作成
- PokéAPIから全1025匹を取得（約1-2時間）
- SwiftDataで保存（Pokedex.sqlite、約15-20MB）

**受入基準**:
- [ ] 初回起動が1秒以内
- [ ] アプリサイズ増加が20MB以下
- [ ] 完全オフライン動作（初回から）
- [ ] データの正確性検証

#### FR-4.2.2 差分更新

**要件**:
- アプリバージョンアップ時に新ポケモンのみ追加取得
- 既存ポケモンは再取得しない（データ変更がないため）
- バックグラウンドで差分取得（ユーザー操作を妨げない）

**差分更新ロジック**:
1. 起動時にPokéAPIの最新ポケモン数を取得
2. SwiftDataの最大IDと比較
3. 不足分のみ追加取得
4. 例: DB に 1025 匹、API に 1030 匹 → 1026-1030 のみ取得

**受入基準**:
- [ ] 新ポケモン追加時に差分のみ取得
- [ ] バックグラウンド取得中も既存データ閲覧可能
- [ ] 設定画面から手動で全データ再取得可能

---

### Phase 3: 技フィルターの高速化（高優先度）

#### FR-4.3.1 技習得データの事前キャッシュ

**要件**:
- バックグラウンドで全ポケモンの技データを取得
- SwiftDataに永続化
- 技フィルター時はDBから高速検索

**受入基準**:
- [ ] 技フィルターが3秒以内に完了
- [ ] オフラインでも技フィルターが動作
- [ ] データの正確性が保たれている

#### FR-4.3.2 クライアント側フィルタリング

**要件**:
- `Pokemon.moves`を活用して事前絞り込み
- API呼び出しを最小限に抑える
- インデックスによる高速検索

**受入基準**:
- [ ] DB検索が1秒以内に完了
- [ ] フィルター結果が正確
- [ ] 複数技の組み合わせ検索も高速

#### FR-4.3.3 技データの優先取得

**要件**:
- ユーザーが技フィルターを開いた時点で優先取得
- 「技データを準備中...」と表示
- 取得完了後に即座にフィルター可能

**受入基準**:
- [ ] 技フィルター画面を開いた時点で取得開始
- [ ] 進捗を表示
- [ ] 取得完了後はオフラインでも動作

---

## 非機能要件

### NFR-4.1 パフォーマンス

| 項目 | Phase 1 | Phase 2 | 測定方法 |
|------|---------|---------|---------|
| 初回起動時間 | 60-90秒 | **1秒以内** | 起動からポケモンリスト表示まで |
| 2回目以降起動 | **1秒以内** | **1秒以内** | SwiftDataから読み込み時間 |
| 技フィルター | **3秒以内** | **3秒以内** | フィルター開始から結果表示まで |
| スクロール性能 | 60fps維持 | 60fps維持 | Instruments Time Profilerで測定 |

### NFR-4.2 信頼性

| 項目 | 要件 |
|------|------|
| データ整合性 | 取得失敗時も部分的に動作 |
| オフライン対応 | キャッシュがあれば全機能動作 |
| エラー回復 | 取得失敗時は自動リトライ（最大3回） |

### NFR-4.3 ユーザビリティ

| 項目 | 要件 |
|------|------|
| 進捗表示 | バックグラウンド取得中は進捗を表示 |
| 操作可能性 | 取得中もアプリ操作可能 |
| フィードバック | 取得完了時に通知（オプション） |

### NFR-4.4 保守性

| 項目 | 要件 |
|------|------|
| ログ出力 | 取得状況・エラーをログに記録 |
| デバッグモード | 開発者向けに詳細情報を表示 |
| キャッシュ管理 | 設定画面から手動でクリア可能 |

---

## 技術要件

### TR-4.1 使用技術

| カテゴリ | 技術 | 用途 |
|---------|------|------|
| 永続化 | SwiftData | ポケモンデータのローカル保存 |
| 並行処理 | Swift Concurrency | バックグラウンド取得 |
| UI | SwiftUI | 進捗表示・設定画面 |
| ネットワーク | URLSession | API通信 |

### TR-4.2 データモデル

#### PokemonDataModel (SwiftData)

```swift
@Model
final class PokemonDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var types: [String]
    var sprites: SpritesData
    var stats: [StatData]
    var abilities: [AbilityData]
    var moves: [MoveData]
    var lastUpdated: Date

    // フォーム情報
    var forms: [PokemonFormData]

    // キャッシュメタデータ
    var isCached: Bool
    var cacheVersion: Int
}
```

#### MoveDataModel (SwiftData)

```swift
@Model
final class MoveDataModel {
    @Attribute(.unique) var id: Int
    var name: String
    var type: String
    var power: Int?
    var accuracy: Int?
    var pp: Int
    var damageClass: String
    var learnablePokemon: [Int] // Pokemon IDs
    var lastUpdated: Date
}
```

### TR-4.3 アーキテクチャ拡張

**新規追加コンポーネント**:

1. **DataStore層**
   - `PokemonDataStore`: SwiftData操作
   - `MoveDataStore`: 技データ操作
   - `CacheManager`: キャッシュ管理

2. **BackgroundTask層**
   - `BackgroundFetchService`: バックグラウンド取得
   - `ProgressTracker`: 進捗管理
   - `PriorityQueue`: 取得優先度管理

3. **Settings層**
   - `SettingsView`: キャッシュ管理UI
   - `SettingsViewModel`: 設定ロジック

---

### Phase 5: 日本語対応（中優先度）

#### FR-4.5.1 日本語名称の取得と表示

**現状の問題**:
- ポケモン名、タイプ名、技名、特性名などが全て英語表示
- 日本語ユーザーにとって分かりにくい
- 例：「pikachu」「electric」「thunderbolt」

**要件**:
- PokéAPIの`names`フィールドから日本語名を取得
- 全ての名称を日本語で表示
  - ポケモン名：「pikachu」→「ピカチュウ」
  - タイプ名：「electric」→「でんき」
  - 技名：「thunderbolt」→「10まんボルト」
  - 特性名：「static」→「せいでんき」
  - 分類：「mouse pokemon」→「ねずみポケモン」

**受入基準**:
- [ ] ポケモン名が日本語で表示される
- [ ] タイプ名が日本語で表示される
- [ ] 技名が日本語で表示される
- [ ] 特性名が日本語で表示される
- [ ] 進化条件が日本語で表示される

#### FR-4.5.2 言語設定

**要件**:
- 設定画面から言語を切り替え可能
- 英語/日本語の2言語対応
- デフォルトは端末の言語設定に従う

**受入基準**:
- [ ] 設定画面に言語切り替え機能
- [ ] 切り替え後、即座に全画面が更新される
- [ ] 設定が永続化される

#### FR-4.5.3 データベース設計

**要件**:
- SwiftDataモデルに日本語名フィールドを追加
- 英語名も保持（APIとの整合性のため）

**データモデル拡張**:
```swift
@Model
final class PokemonDataModel {
    var name: String        // 英語名（API互換用）
    var nameJa: String?     // 日本語名
    var genus: String?      // 分類（英語）
    var genusJa: String?    // 分類（日本語）
    // ...
}

@Model
final class MoveDataModel {
    var name: String        // 英語名
    var nameJa: String?     // 日本語名
    // ...
}
```

**受入基準**:
- [ ] 日本語名がDBに保存される
- [ ] 英語名も保持される
- [ ] 言語切り替え時にDBから適切な名前を取得

---

## 実装フェーズ

**詳細な実装手順は `docs/pokedex_prompts_v4.md` を参照してください。**

### Phase 1: SwiftData永続化（高優先度・1-2日）

**目標**: 2回目以降の起動を1秒以内に

**実装内容**:
1. SwiftDataモデル定義（PokemonModel, TypeModel, StatModel等）
2. PokemonModelMapper作成（Domain ↔ SwiftData変換）
3. PokemonRepositoryのSwiftData対応
4. ModelContainerのセットアップ

**成果物**:
- [ ] PokemonModel.swift（新規）
- [ ] PokemonModelMapper.swift（新規）
- [ ] PokemonRepository.swift（SwiftData対応に修正）
- [ ] PokedexApp.swift（ModelContainer追加）

**テスト**:
- [ ] 初回起動: 60-90秒でデータ取得・保存
- [ ] 2回目起動: 1秒以内にリスト表示
- [ ] オフライン: 機内モードでも動作

---

### Phase 2: プリバンドルデータベース（中優先度・2-3日）

**目標**: 初回起動も1秒以内に

**実装内容**:
1. データ生成スクリプト作成（全1025匹を取得してDB化）
2. プリバンドルDBの組み込み（Resources/PreloadedData/）
3. 初回起動時のDB自動コピー処理
4. 差分更新ロジック

**成果物**:
- [ ] Scripts/GenerateDatabase.swift（新規）
- [ ] Resources/PreloadedData/Pokedex.sqlite（約15-20MB）
- [ ] PokemonRepository.swift（プリバンドルDB対応）

**テスト**:
- [ ] 初回起動: 1秒以内にリスト表示
- [ ] アプリサイズ増加: 20MB以下
- [ ] 差分更新動作確認

---

### Phase 3: 技フィルターの高速化（高優先度・2-3日）

**目標**: 技検索を3秒以内に

**実装内容**:
1. MoveModelの定義
2. 技データの事前取得・永続化
3. FilterPokemonByMovesUseCaseの改良（DB検索ベース）

**成果物**:
- [ ] MoveModel.swift（新規）
- [ ] MoveDataStore.swift（新規）
- [ ] FilterPokemonByMovesUseCase（改良）

**テスト**:
- [ ] 技フィルター: 3秒以内
- [ ] オフライン動作確認
- [ ] 精度検証

---

### Phase 4: 日本語対応（中優先度・2-3日）

**実装内容**:
1. Entityに日本語名フィールド追加
2. Mapperで日本語名を抽出
3. DataModelに日本語名フィールド追加
4. 言語設定の実装
5. 表示ロジックの更新

**成果物**:
- [ ] Pokemon+Localization.swift（拡張）
- [ ] LocalizationManager.swift（新規）
- [ ] PokemonDataModel（拡張：nameJa, genusJa）
- [ ] MoveDataModel（拡張：nameJa）
- [ ] TypeEntity（拡張：nameJa）
- [ ] AbilityEntity（拡張：nameJa）
- [ ] SettingsView（言語切り替え）

**マッピング例**:
```swift
// PokemonSpeciesMapper.swift
func map(from species: PKMPokemonSpecies) -> PokemonSpecies {
    let nameJa = species.names?.first(where: { $0.language?.name == "ja" })?.name
    let genusJa = species.genera?.first(where: { $0.language?.name == "ja" })?.genus

    return PokemonSpecies(
        name: species.name ?? "",
        nameJa: nameJa,
        genus: genus,
        genusJa: genusJa,
        // ...
    )
}
```

**テスト**:
- [ ] 全ての名称が日本語で表示される
- [ ] 英語/日本語切り替えが動作する
- [ ] 日本語データがDBに保存される

---

### Phase 5: UI/UX改善（低優先度・1-2日）

**目標**: フィルター機能の使いやすさ向上

**実装内容**:
1. 特性フィルターに検索機能追加
2. 技フィルターの高度な絞り込み機能

**詳細**: `FR-4.6.1`, `FR-4.6.2` を参照

---

### Phase 6: バージョン固有データ対応（低優先度・3-4日）

**目標**: ゲームバージョンごとに正確なデータを表示

**背景**:
- ポケモンのタイプ・特性はゲームバージョンによって異なる場合がある
- 例: フェアリータイプは第6世代から登場
- 地方図鑑（カントー、ジョウト等）にも対応したい

**実装内容**:
1. PokemonVersionVariantモデル追加
2. PokedexModelの追加（地方図鑑情報）
3. バージョン別データの取得・保存
4. UI上でバージョン選択機能

**成果物**:
- [ ] PokemonVersionVariant.swift（新規）
- [ ] PokedexModel.swift（新規）
- [ ] PokemonRepository（バージョン固有データ対応）

**テスト**:
- [ ] バージョン選択でタイプが正しく変わる
- [ ] 地方図鑑が選択可能
- [ ] データの正確性検証

---

### Phase 7: モジュール化（低優先度・3-4日）

**目標**: UIKit版を見据えたアーキテクチャ

**背景**:
- 将来的にUIKit版も作成予定
- Data層・Domain層・ViewModel層は共通化可能
- View層のみSwiftUI/UIKitで個別実装

**実装内容**:
1. PokedexCoreパッケージ作成
2. Domain/Data/Presentationの分離
3. Package.swift設定
4. SwiftUI版からの参照確認

**モジュール構成**:
```
PokedexCore (Swift Package)
├── Domain          # Entity, UseCase, Protocol
├── Data            # Repository, API, SwiftData
└── Presentation    # ViewModel（共通）

Pokedex-SwiftUI (App)
└── Views           # SwiftUI View

Pokedex-UIKit (Future App)
└── ViewControllers # UIKit ViewController
```

**成果物**:
- [ ] PokedexCore Package（新規）
- [ ] Domain Target（分離）
- [ ] Data Target（分離）
- [ ] Presentation Target（分離）

**テスト**:
- [ ] PokedexCoreが独立してビルド可能
- [ ] SwiftUI版が正常動作
- [ ] UIKit版の基盤準備完了

---

## 成功基準

### 定量的基準

| 指標 | v3.0（現状） | Phase 1 | Phase 2 | 必達 |
|------|-------------|---------|---------|------|
| 初回起動時間 | 60-90秒 | 60-90秒 | **1秒以内** | 3秒以内 |
| 2回目起動 | 60-90秒 | **1秒以内** | **1秒以内** | 3秒以内 |
| 技フィルター | 80秒 | **3秒以内** | **3秒以内** | 5秒以内 |
| アプリサイズ | 5MB | 5MB | **25MB** | 50MB以内 |
| オフライン対応 | ❌ | ⚠️（2回目以降） | ✅（初回から） | - |

### 定性的基準

- [ ] ユーザーが「速くなった」と体感できる
- [ ] オフラインでも快適に使える
- [ ] 技フィルターが実用的になる
- [ ] エラーが発生しても部分的に動作する

---

## リスクと対策

### リスク1: SwiftDataの学習コスト

**対策**:
- 小規模な機能から段階的に導入
- 公式ドキュメント・サンプルコードを活用
- 必要に応じてCore Dataも検討

### リスク2: データ移行の複雑性

**対策**:
- 初回はキャッシュなしで動作（既存の動作）
- 段階的にキャッシュを構築
- 移行失敗時はキャッシュをクリア

### リスク3: ディスク容量の圧迫

**対策**:
- キャッシュサイズを50MB以下に抑える
- 不要な画像データは保存しない
- 設定画面からクリア可能に

---

## 変更履歴

| 日付 | バージョン | 変更内容 | 担当 |
|------|-----------|---------|------|
| 2025-10-09 | 1.0 | 初版作成 | Claude |
| 2025-10-10 | 2.0 | Phase 1をSwiftData永続化に変更、Phase 2をプリバンドルDBに変更、Phase 4削除、Phase 6-7追加 | Claude |
