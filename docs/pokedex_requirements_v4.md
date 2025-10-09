# Pokédex SwiftUI - 要件定義書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-09

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

| 項目 | v3.0（現状） | v4.0（目標） |
|------|-------------|-------------|
| 初回起動時間 | 60-90秒 | 8-12秒 |
| 2回目以降起動 | 60-90秒 | 1秒以内 |
| 技フィルター | 数十秒 | 3秒以内 |

---

## 背景と目的

### v3.0の課題

1. **初回起動が遅い**
   - 全ポケモン（1025匹）を順次取得するため60-90秒かかる
   - ユーザーは画面が表示されるまで何もできない

2. **2回目以降も遅い**
   - メモリキャッシュのみのため、アプリ再起動で全データ再取得
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

### v4.0の目的

1. **初回起動の高速化**
   - ユーザーが即座にポケモンを閲覧できるようにする
   - バックグラウンドで残りのデータを取得

2. **2回目以降の即時起動**
   - 永続キャッシュにより1秒以内で起動
   - オフライン閲覧にも対応

3. **技フィルターの高速化**
   - 事前キャッシュにより3秒以内で結果表示
   - 実用的な検索体験を提供

---

## 機能要件

### Phase 1: バックグラウンド段階的読み込み（高優先度）

#### FR-4.1.1 初回起動時の段階的読み込み

**要件**:
- **全国図鑑モード**:
  - 起動時は第1世代（1-151）のみを取得して即座に表示
  - 残り（152-1025）はバックグラウンドで取得
- **バージョングループ選択時**:
  - そのバージョンに登場するポケモンのみを優先取得
  - PokéAPIの`pokedex`エンドポイントから取得したIDリストに基づく
  - 取得完了後、残りをバックグラウンドで取得（全国図鑑用）
- 取得中もユーザーはアプリを操作可能

**受入基準**:
- [ ] 全国図鑑：起動後8-12秒以内に第1世代が表示される
- [ ] 赤・緑：起動後8-12秒以内に全ポケモンが表示される
- [ ] スカーレット・バイオレット：登録数に応じた時間内に全ポケモンが表示される
- [ ] バックグラウンド取得中もスクロール・検索が可能
- [ ] バックグラウンド取得が完了したら自動的にリストが更新される
- [ ] 取得失敗時は取得済みデータのみで動作継続

#### FR-4.1.2 進捗表示

**要件**:
- バックグラウンド取得の進捗をユーザーに表示
- 「ポケモンデータを取得中... (152/1025)」のような形式
- プログレスバーで進捗を可視化

**受入基準**:
- [ ] 画面上部または下部に進捗表示
- [ ] リアルタイムで進捗が更新される
- [ ] 完了時に自動的に非表示になる
- [ ] タップして詳細（成功/失敗数）を確認可能

#### FR-4.1.3 取得順序の最適化

**要件**:
- 第1世代（1-151）を優先取得
- その後、人気の高い世代から順次取得
  - 第2世代（152-251）
  - 第3世代（252-386）
  - ...

**受入基準**:
- [ ] 第1世代が最初に完了する
- [ ] 世代ごとに段階的に表示される
- [ ] ユーザーが特定の世代を見ようとした場合、その世代を優先取得

---

### Phase 2: 永続的キャッシュの導入（中優先度）

#### FR-4.2.1 SwiftDataによる永続化

**要件**:
- ポケモンデータをSwiftDataで永続化
- アプリ再起動後もデータを保持
- 初回同期後は即座に表示

**受入基準**:
- [ ] 2回目以降の起動が1秒以内
- [ ] オフラインでも全ポケモンを閲覧可能
- [ ] データの整合性が保たれている

#### FR-4.2.2 データ更新戦略

**PokéAPIのデータ更新頻度**:
- ポケモン基本データ：ほぼ変更なし（新世代リリース時のみ）
- 技データ：年に数回（新技追加、効果変更）
- フォームデータ：まれに追加（イベント限定フォームなど）

**キャッシュ有効期限**:
- **ポケモンデータ**: 30日間有効
  - 理由：基本データはほぼ変更されない
  - 新世代リリース時は手動更新推奨
- **技データ**: 7日間有効
  - 理由：技の効果変更などが稀に発生
- **バージョン情報**: キャッシュに保存
  - データ構造変更時に自動クリア

**更新ロジック**:
1. **起動時チェック**:
   - キャッシュバージョンをチェック
   - 不一致なら全クリア→再取得
   - 一致なら有効期限をチェック

2. **有効期限チェック**:
   - 期限内：DBから即座に読み込み
   - 期限切れ：バックグラウンドで差分更新
     - 最大IDをチェック（例：1025）
     - DBの最大IDより大きいIDがあれば追加取得
     - 既存データは更新しない（変更がないため）

3. **手動更新**:
   - 設定画面から「データを更新」ボタン
   - 全データを再取得（キャッシュは保持）
   - 更新中は進捗表示

**受入基準**:
- [ ] 30日以内の起動はDB読み込みのみ（1秒以内）
- [ ] 30日経過後は差分のみ更新（バックグラウンド）
- [ ] 更新中も既存データは閲覧可能
- [ ] データバージョン不一致時は自動クリア
- [ ] 設定画面から手動更新可能

#### FR-4.2.3 キャッシュ管理

**要件**:
- 設定画面からキャッシュをクリア可能
- キャッシュサイズを表示
- キャッシュの最終更新日時を表示

**受入基準**:
- [ ] 設定画面に「キャッシュをクリア」ボタン
- [ ] クリア前に確認ダイアログを表示
- [ ] クリア後は自動的に再取得開始

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

### Phase 4: 適応的並列度制御（低優先度）

#### FR-4.4.1 動的バッチサイズ調整

**要件**:
- ネットワーク状況に応じてバッチサイズを動的調整
- 成功率が高い場合は並列度を上げる
- タイムアウトが多い場合は並列度を下げる

**受入基準**:
- [ ] WiFi環境では高速化
- [ ] 低速環境でもタイムアウトなし
- [ ] 自動的に最適化される

#### FR-4.4.2 エラー率モニタリング

**要件**:
- 直近10件のリクエスト成功率を監視
- 成功率80%未満なら並列度を下げる
- 成功率95%以上なら並列度を上げる

**受入基準**:
- [ ] エラー率に応じて自動調整
- [ ] 設定画面で現在の並列度を確認可能
- [ ] ログで調整履歴を確認可能

---

## 非機能要件

### NFR-4.1 パフォーマンス

| 項目 | 要件 | 測定方法 |
|------|------|---------|
| 初回起動時間 | 8-12秒以内 | 起動からポケモンリスト表示まで |
| 2回目以降起動 | 1秒以内 | キャッシュ有効時の起動時間 |
| 技フィルター | 3秒以内 | フィルター開始から結果表示まで |
| スクロール性能 | 60fps維持 | Instruments Time Profilerで測定 |

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

### Phase 1: バックグラウンド段階的読み込み（1-2日）

**実装内容**:
1. BackgroundFetchServiceの実装
2. ProgressTrackerの実装
3. PokemonListViewModelの拡張
4. 進捗表示UIの追加

**成果物**:
- [ ] BackgroundFetchService.swift
- [ ] ProgressTracker.swift
- [ ] PokemonListViewModel（拡張）
- [ ] ProgressView.swift

**テスト**:
- [ ] 初回起動が8-12秒以内
- [ ] バックグラウンド取得中も操作可能
- [ ] 進捗表示が正確

---

### Phase 2: 永続的キャッシュの導入（2-3日）

**実装内容**:
1. SwiftDataモデル定義
2. PokemonDataStoreの実装
3. PokemonRepositoryの拡張（DB連携）
4. 差分更新ロジックの実装
5. 設定画面の追加

**成果物**:
- [ ] PokemonDataModel.swift
- [ ] PokemonDataStore.swift
- [ ] PokemonRepository（拡張）
- [ ] SettingsView.swift
- [ ] CacheManager.swift

**テスト**:
- [ ] 2回目以降の起動が1秒以内
- [ ] オフライン動作確認
- [ ] キャッシュクリアが動作

---

### Phase 3: 技フィルターの高速化（2-3日）

**実装内容**:
1. MoveDataModelの定義
2. MoveDataStoreの実装
3. 技データの事前取得ロジック
4. FilterPokemonByMovesUseCaseの改良
5. インデックス最適化

**成果物**:
- [ ] MoveDataModel.swift
- [ ] MoveDataStore.swift
- [ ] FilterPokemonByMovesUseCase（改良）
- [ ] MoveIndexer.swift

**テスト**:
- [ ] 技フィルターが3秒以内
- [ ] オフラインでも動作
- [ ] 結果が正確

---

### Phase 4: 適応的並列度制御（2-3日、オプション）

**実装内容**:
1. AdaptiveFetchStrategyの実装
2. NetworkQualityDetectorの実装
3. ErrorRateMonitorの実装
4. PokemonAPIClientの拡張

**成果物**:
- [ ] AdaptiveFetchStrategy.swift
- [ ] NetworkQualityDetector.swift
- [ ] ErrorRateMonitor.swift

**テスト**:
- [ ] WiFi環境で高速化
- [ ] 低速環境でもタイムアウトなし
- [ ] 自動調整が機能

---

### Phase 5: 日本語対応（2-3日）

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

### Phase 6: UI/UX改善（1-2日）

#### FR-4.6.1 特性フィルターの改善

**現状の問題**:
- 全特性（約300個）をリスト表示
- スクロールして探すのが困難
- 選びたい特性を見つけにくい

**要件**:
- 検索フィールドを追加
- 前方一致で絞り込み
- 検索結果のみを表示
- リアルタイムで絞り込み

**UI設計**:
```swift
Section("特性") {
    // 検索フィールド
    TextField("特性名で検索", text: $abilitySearchText)
        .textFieldStyle(.roundedBorder)

    // 選択中の特性
    if !selectedAbilities.isEmpty {
        ForEach(Array(selectedAbilities), id: \.self) { ability in
            abilityChip(ability)
        }
    }

    // 検索結果（前方一致）
    ForEach(filteredAbilities, id: \.self) { ability in
        abilitySelectionButton(ability)
    }
    .onChange(of: abilitySearchText) { _, newValue in
        filterAbilities(query: newValue)
    }
}
```

**絞り込みロジック**:
```swift
var filteredAbilities: [String] {
    guard !abilitySearchText.isEmpty else {
        return [] // 検索テキストが空なら結果なし（全表示しない）
    }

    return allAbilities
        .filter { $0.localizedStandardContains(abilitySearchText) } // 前方一致
        .sorted()
        .prefix(20) // 最大20件
}
```

**受入基準**:
- [ ] 検索フィールドが表示される
- [ ] 入力に応じてリアルタイムで絞り込まれる
- [ ] 前方一致で検索できる
- [ ] 選択中の特性が上部に表示される
- [ ] 最大20件まで表示

#### FR-4.6.2 技フィルターの高度な絞り込み

**現状の問題**:
- 技名でしか検索できない
- 「でんきタイプの威力100以上の技を覚えるポケモン」のような検索ができない

**要件**:
1. **技名検索**（特性と同様）
   - 前方一致で絞り込み
   - 最大20件表示

2. **技のメタデータで絞り込み**
   - タイプ：18タイプから選択
   - ダメージクラス：物理/特殊/変化
   - 威力：範囲指定（例：80-120）
   - 命中率：範囲指定（例：90-100）
   - PP：範囲指定

**UI設計**:
```swift
Section("技フィルター") {
    // 技名検索
    TextField("技名で検索", text: $moveSearchText)

    // メタデータ絞り込み
    Picker("タイプ", selection: $selectedMoveType) {
        Text("全て").tag(nil as String?)
        ForEach(allTypes, id: \.self) { type in
            Text(type).tag(type as String?)
        }
    }

    Picker("分類", selection: $selectedDamageClass) {
        Text("全て").tag(nil as String?)
        Text("物理").tag("physical" as String?)
        Text("特殊").tag("special" as String?)
        Text("変化").tag("status" as String?)
    }

    // 威力範囲
    HStack {
        Text("威力")
        Slider(value: $minPower, in: 0...200)
        Text("\(Int(minPower))+")
    }

    // 選択中の技
    ForEach(selectedMoves, id: \.id) { move in
        moveChip(move)
    }

    // 検索結果
    ForEach(filteredMoves, id: \.id) { move in
        moveRow(move)
    }
}
```

**絞り込みロジック**:
```swift
var filteredMoves: [MoveEntity] {
    var results = allMoves

    // 技名検索
    if !moveSearchText.isEmpty {
        results = results.filter {
            $0.name.localizedStandardContains(moveSearchText)
        }
    }

    // タイプ絞り込み
    if let type = selectedMoveType {
        results = results.filter { $0.type == type }
    }

    // ダメージクラス絞り込み
    if let damageClass = selectedDamageClass {
        results = results.filter { $0.damageClass == damageClass }
    }

    // 威力絞り込み
    if minPower > 0 {
        results = results.filter { ($0.power ?? 0) >= Int(minPower) }
    }

    return results.sorted { $0.name < $1.name }.prefix(20)
}
```

**受入基準**:
- [ ] 技名で検索できる
- [ ] タイプで絞り込める
- [ ] ダメージクラスで絞り込める
- [ ] 威力で絞り込める
- [ ] 複数条件の組み合わせが動作する
- [ ] 絞り込んだ技を覚えるポケモンを検索できる

---

## 成功基準

### 定量的基準

| 指標 | 現状 | 目標 | 必達 |
|------|------|------|------|
| 初回起動時間 | 60-90秒 | 8-12秒 | 15秒以内 |
| 2回目起動 | 60-90秒 | 1秒 | 3秒以内 |
| 技フィルター | 80秒 | 3秒 | 5秒以内 |
| キャッシュサイズ | - | 50MB以下 | 100MB以下 |

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
