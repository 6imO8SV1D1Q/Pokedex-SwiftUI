# Pokédex SwiftUI - 要件定義書 v4.0

**プロジェクト名**: Pokédex SwiftUI
**バージョン**: 4.0
**作成日**: 2025-10-09
**最終更新**: 2025-10-12

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

| 項目 | v3.0（現状） | v4.0 実装結果 |
|------|-------------|-------------|
| 初回起動時間 | 60-90秒 | **1秒以内** ✅ |
| 2回目以降起動 | 60-90秒 | **1秒以内** ✅ |
| 技フィルター | 数十秒 | **3秒以内** ✅ |
| データ変換時間 | - | **18秒 → 1秒以内** ✅ |
| オフライン対応 | ❌ | ✅（初回から） |

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

### v4.0の解決策（実装完了）

**Phase 1: SwiftData永続化** ✅
1. **2回目以降の即時起動**
   - 取得したデータをディスクに永続化
   - アプリ再起動でも1秒以内で表示
   - オフライン閲覧に対応（2回目以降）

**Phase 2: プリバンドルJSON** ✅
2. **初回起動の高速化**
   - アプリに全データを同梱（`scarlet_violet.json` 約7.4MB）
   - 初回起動から1秒以内で表示
   - 完全オフライン対応（初回から）

**Phase 3: 技フィルターの高速化** ✅
3. **技検索の実用化**
   - 技・特性データをSwiftDataで永続化
   - 3秒以内で検索結果表示
   - 日本語対応完了

**アーキテクチャ改善**
4. **埋め込みモデルによるパフォーマンス最適化**
   - `@Relationship`から`Codable` structへ変更
   - データ変換時間を18秒から1秒以内に短縮
   - `PokedexModel`追加でAPI呼び出しを削減

---

## 機能要件

### Phase 1: SwiftData永続化（高優先度・1-2日）✅ 完了

#### FR-4.1.1 ポケモンデータの永続化 ✅

**実装内容**:
- ポケモンデータをSwiftDataで永続化
- アプリ再起動後もデータを保持
- 2回目以降の起動を1秒以内に短縮

**SwiftDataモデル（埋め込み型）**:
- `PokemonModel`: ポケモン基本情報
- `PokemonBaseStatsModel`: 種族値（`struct`、埋め込み）
- `PokemonSpriteModel`: 画像URL（`struct`、埋め込み）
- `PokemonLearnedMoveModel`: 技習得情報（`struct`、埋め込み）
- `PokemonEvolutionModel`: 進化情報（`struct`、埋め込み）
- `PokedexModel`: 図鑑データ（API呼び出し削減）

**重要な設計変更**:
- **埋め込みモデル採用**: `@Relationship`から`Codable` structに変更
- **理由**: 遅延ロードによる18秒のボトルネック解消
- **結果**: データ変換が18秒から1秒以内に改善

**受入基準**:
- [x] 初回起動: JSONから全データ読み込み・SwiftData に保存（1秒以内）
- [x] 2回目起動: SwiftData から読み込み・1秒以内に表示
- [x] オフライン: 機内モードでも初回から全機能動作
- [x] データ整合性: 保存・読み込みでデータ欠損なし

#### FR-4.1.2 キャッシュ管理

**実装結果**: ❌ 不要と判断

**理由**:
- 自動マイグレーション機能でスキーマ変更に対応
- データ破損時はアプリ再インストールで解決
- データサイズが小さい（約15-20MB）
- ユーザーが手動で削除する必要性が低い

**代替実装**:
- スキーマバージョン管理（`v4.1-embedded`）
- マイグレーション失敗時の自動クリーンアップ

---

### Phase 2: プリバンドルJSON（中優先度・2-3日）✅ 完了

#### FR-4.2.1 JSONデータ生成とバンドル ✅

**実装内容**:
- Scarlet/Violet対象の866ポケモンのデータを事前生成
- JSON形式で同梱（`scarlet_violet.json` 約7.4MB）
- 初回起動時にJSONを読み込み、SwiftDataに保存
- 初回から1秒以内で全データを表示可能

**データ生成ツール**:
- `Tools/GenerateScarletVioletData.swift` で実装
- PokéAPIから866ポケモン、680技、269特性を取得
- 日本語翻訳も同時取得
- 出力: `Resources/PreloadedData/scarlet_violet.json`

**設計変更の理由**:
- **JSON採用**: SQLiteより人間が読みやすい、デバッグ容易
- **バージョン管理**: Git diffでデータ変更を追跡可能
- **スキーマ変更に強い**: SwiftDataスキーマ変更時も再生成不要

**受入基準**:
- [x] 初回起動が1秒以内
- [x] アプリサイズ増加が10MB以下（実際: 7.4MB）
- [x] 完全オフライン動作（初回から）
- [x] データの正確性検証

#### FR-4.2.2 図鑑データの永続化 ✅

**実装内容**:
- `PokedexModel`を追加（`paldea`, `kitakami`, `blueberry`）
- 図鑑データをJSONに含めて永続化
- API呼び出しを削減（起動時3回 → 0回）

**実装詳細**:
- `Tools/add_pokedex_data.py`: PokéAPIから図鑑データ取得
- JSONに図鑑データを追加（paldea: 400種、kitakami: 200種、blueberry: 243種）
- `PreloadedDataLoader`でSwiftDataに保存

**受入基準**:
- [x] 図鑑データが永続化される
- [x] API呼び出しが削減される
- [x] オフラインでもバージョングループ切り替えが動作

---

### Phase 3: 技・特性データの永続化と日本語対応（高優先度）✅ 完了

#### FR-4.3.1 技・特性データモデルの実装 ✅

**実装内容**:
- `MoveModel`: 技の基本情報（ID、名前、日本語名、タイプ、威力など）
- `MoveMetaModel`: 技の詳細情報（状態異常、急所率、能力変化など）
- `AbilityModel`: 特性の基本情報（ID、名前、日本語名、効果）
- 全データをJSONに含めてプリバンドル

**埋め込みモデル設計**:
- 技習得情報を`PokemonLearnedMoveModel`（`struct`）として埋め込み
- `@Relationship`を使わず、直接配列として保持
- データ変換時間を大幅短縮（18秒 → 1秒以内）

**受入基準**:
- [x] 技フィルターが3秒以内に完了
- [x] オフラインでも技フィルターが動作
- [x] データの正確性が保たれている

#### FR-4.3.2 技カテゴリーフィルターの実装 ✅

**実装内容**:
- 43種類の技カテゴリーに対応
- `SearchFilterView`でカテゴリー選択UI実装
- `MoveRepository.fetchMovesByCategories`で高速検索

**受入基準**:
- [x] DB検索が1秒以内に完了
- [x] フィルター結果が正確
- [x] 複数技の組み合わせ検索も高速

#### FR-4.3.3 日本語対応の完了 ✅

**実装内容**:
- ポケモン名、タイプ名、技名、特性名の日本語対応
- `LocalizationManager`で言語切り替え機能実装
- 設定画面から日本語/英語を切り替え可能

**受入基準**:
- [x] 全ての名称が日本語で表示される
- [x] 英語/日本語切り替えが動作する
- [x] 日本語データがDBに保存される

---

## 非機能要件

### NFR-4.1 パフォーマンス

| 項目 | 目標 | 実測値 | 測定方法 |
|------|---------|---------|---------|
| 初回起動時間 | **1秒以内** | **1秒以内** ✅ | 起動からポケモンリスト表示まで |
| 2回目以降起動 | **1秒以内** | **1秒以内** ✅ | SwiftDataから読み込み時間 |
| データ変換時間 | - | **18秒 → 1秒以内** ✅ | PokemonModelMapper実行時間 |
| 技フィルター | **3秒以内** | **3秒以内** ✅ | フィルター開始から結果表示まで |
| スクロール性能 | 60fps維持 | 60fps維持 ✅ | Instruments Time Profilerで測定 |

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

#### PokemonModel (SwiftData - 埋め込み型)

```swift
@Model
final class PokemonModel {
    @Attribute(.unique) var id: Int
    var nationalDexNumber: Int
    var name: String
    var nameJa: String
    var genus: String
    var genusJa: String
    var height: Int
    var weight: Int
    var category: String
    var types: [String]

    // 埋め込みモデル（Codable struct、@Relationshipなし）
    var baseStats: PokemonBaseStatsModel?
    var sprites: PokemonSpriteModel?
    var moves: [PokemonLearnedMoveModel]  // 直接配列として埋め込み
    var evolutionChain: PokemonEvolutionModel?

    var fetchedAt: Date
}

// 埋め込みモデル（struct）
struct PokemonBaseStatsModel: Codable {
    var hp: Int
    var attack: Int
    var defense: Int
    var spAttack: Int
    var spDefense: Int
    var speed: Int
    var total: Int
}

struct PokemonLearnedMoveModel: Codable {
    var pokemonId: Int
    var moveId: Int
    var learnMethod: String
    var level: Int?
    var machineNumber: String?
}
```

#### MoveModel (SwiftData)

```swift
@Model
final class MoveModel {
    @Attribute(.unique) var id: Int
    var name: String
    var nameJa: String
    var type: String
    var power: Int?
    var accuracy: Int?
    var pp: Int
    var damageClass: String
    var effect: String
    var effectJa: String

    // メタ情報（@Relationshipは使用しない）
    var meta: MoveMetaModel?
}
```

#### PokedexModel (SwiftData)

```swift
@Model
final class PokedexModel {
    @Attribute(.unique) var name: String
    var speciesIds: [Int]
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

### Phase 1: SwiftData永続化（高優先度・1-2日）✅ 完了

**目標**: 2回目以降の起動を1秒以内に

**実装内容**:
1. SwiftDataモデル定義（埋め込み型）
2. PokemonModelMapper作成（Domain ↔ SwiftData変換）
3. PokemonRepositoryのSwiftData対応
4. ModelContainerのセットアップ
5. スキーマバージョン管理（v4.1-embedded）

**成果物**:
- [x] PokemonModel.swift（埋め込み型で実装）
- [x] PokemonModelMapper.swift（変換時間を18秒 → 1秒以内に改善）
- [x] PokemonRepository.swift（SwiftData対応）
- [x] PokedexApp.swift（ModelContainer + 自動マイグレーション）
- [x] PokedexModel.swift（図鑑データ永続化）

**テスト**:
- [x] 初回起動: 1秒以内でJSON読み込み・保存
- [x] 2回目起動: 1秒以内にリスト表示
- [x] オフライン: 機内モードでも動作

---

### Phase 2: プリバンドルJSON（中優先度・2-3日）✅ 完了

**目標**: 初回起動も1秒以内に

**実装内容**:
1. データ生成ツール作成（Scarlet/Violet対象866匹をJSON化）
2. プリバンドルJSONの組み込み（Resources/PreloadedData/）
3. 初回起動時のJSON自動読み込み処理
4. 図鑑データの永続化（PokedexModel）

**成果物**:
- [x] Tools/GenerateScarletVioletData.swift（JSON生成ツール）
- [x] Tools/add_pokedex_data.py（図鑑データ追加ツール）
- [x] Resources/PreloadedData/scarlet_violet.json（約7.4MB）
- [x] PokemonRepository.swift（プリバンドルJSON対応）
- [x] PreloadedDataLoader.swift（JSON読み込み処理）

**テスト**:
- [x] 初回起動: 1秒以内にリスト表示
- [x] アプリサイズ増加: 10MB以下（実際: 7.4MB）
- [x] 図鑑データ永続化確認

---

### Phase 3: 技・特性データの永続化（高優先度・2-3日）✅ 完了

**目標**: 技検索を3秒以内に、日本語対応完了

**実装内容**:
1. MoveModel・AbilityModelの定義
2. 技・特性データの永続化（プリバンドルJSON）
3. FilterPokemonByMovesUseCaseの改良（DB検索ベース）
4. 日本語対応完了（LocalizationManager実装）
5. 技カテゴリーフィルター実装（43種類）

**成果物**:
- [x] MoveModel.swift（技データモデル）
- [x] MoveMetaModel.swift（技メタ情報）
- [x] AbilityModel.swift（特性データモデル）
- [x] MoveRepository.swift（技データ取得）
- [x] FilterPokemonByMovesUseCase（DB検索ベース）
- [x] LocalizationManager.swift（言語切り替え）
- [x] SettingsView.swift（言語設定UI）

**テスト**:
- [x] 技フィルター: 3秒以内
- [x] オフライン動作確認
- [x] 精度検証
- [x] 日本語表示確認

---

### Phase 4: 高度なフィルタリング機能（高優先度・3-4日）

#### FR-4.4.0 基本フィルターの検索ロジック拡張

**要件**:
- タイプ、特性、技のフィルターにOR/AND検索の切り替え機能を追加
- 既存フィルターの使い勝手を向上

**詳細**:

**FR-4.4.0-1: タイプフィルターOR/AND切り替え**
- **現状**: OR検索のみ（選択したタイプのいずれかを持つポケモン）
- **追加**: AND検索（選択したタイプを全て持つポケモン）
- **例**: 「みず AND じめん」→ ヌオー、トリトドンなど

**FR-4.4.0-2: 特性フィルターOR/AND切り替え**
- **現状**: OR検索のみ（選択した特性のいずれかを持つポケモン）
- **追加**: AND検索（複数の特性候補を同時に持つポケモン）
  - 注: ポケモンは最大3つの特性（通常1/通常2/夢特性）を持つ
- **例**: 「いかく AND ほのおのからだ」→ ウインディ（アローラ）など

**FR-4.4.0-3: 技フィルターOR/AND切り替え**
- **現状**: AND検索のみ（選択した技を全て覚えられるポケモン）
- **追加**: OR検索（選択した技のいずれかを覚えられるポケモン）
- **例**: 「かえんほうしゃ OR れいとうビーム」→ 高火力特殊技を持つポケモン

**受入基準**:
- [ ] SearchFilterViewにOR/ANDトグルボタン追加
- [ ] 各フィルターで検索ロジックが切り替わる
- [ ] 現在の検索モードがUIで明確に表示される

#### FR-4.4.1 技のメタデータフィルター

**要件**:
- 技名指定だけでなく、技の効果・特性による絞り込みを可能にする
- 複数のメタデータ条件を組み合わせて、それらを**全て満たす技**を覚えるポケモンを検索
- 技の詳細フィルター画面を新設
- 技名フィルターとメタデータフィルターはOR/AND切り替え可能

**フィルター項目**:

**基本情報:**
- タイプ（18種類）
- 分類（物理/特殊/変化）
- 威力範囲（0-250）
- 命中率範囲（必中/50-100）
- PP範囲（5-40）
- 優先度（-7 〜 +5）
- 技範囲: 単体/全体/自分/味方など

**効果（MoveMetaModel）:**
- 状態異常: まひ、やけど、どく、もうどく、ねむり、こおり、こんらん
- 能力変化（自分）: 攻撃↑、防御↑、特攻↑、特防↑、素早さ↑、命中↑、回避↑
- 能力変化（相手）: 攻撃↓、防御↓、特攻↓、特防↓、素早さ↓、命中↓、回避↓
- その他: 急所率アップ、HP吸収、HP回復、ひるみ
- カテゴリー: 43種類（音系、パンチ系、ダンス系など）

**複合条件の例**:
```
技名指定: 「かえんほうしゃ」
AND
メタデータ条件: 「特攻上昇 AND 特防上昇」を同時に満たす技
→ かえんほうしゃを覚え、かつ特攻と特防を同時に上げられる技（めいそう等）を覚えるポケモン
```

**受入基準**:
- [ ] 技の詳細フィルター画面を新設
- [ ] 全てのメタデータ項目でフィルタリング可能
- [ ] 複数条件のAND検索が動作
- [ ] フィルター結果が3秒以内に表示

#### FR-4.4.2 特性のメタデータフィルター

**要件**:
- 特性名だけでなく、効果による絞り込みを可能にする
- 特性の効果を自動または手動で分類
- 特性詳細フィルター画面を新設
- OR/AND検索の切り替え可能

**分類案**:
- 天候・フィールド: ひでり、あめふらし、グラスメイカーなど
- 能力変化: いかく、ダウンロードなど
- タイプ・相性: へんしょく、もらいびなど
- 攻撃・防御: てつのこぶし、ハードロックなど
- 状態異常: せいでんき、めんえきなど
- 回復: さいせいりょく、ちょすいなど
- その他: はやてのつばさ、ノーガードなど

**実装方法**（検討中）:
- 案1: effectの英語説明文から自動判定
- 案2: 269個の特性を手動分類
- 案3: 半自動（キーワード判定 + 手動確認）

**UI仕様**:
- 特性詳細フィルター画面（AbilityDetailFilterView）を新設
- SearchFilterViewから「特性の効果で絞り込む」ボタンで遷移

**受入基準**:
- [ ] 特性の効果分類データを作成
- [ ] AbilityDetailFilterView実装
- [ ] 効果による絞り込みが動作
- [ ] OR/AND検索が切り替え可能

#### FR-4.4.3 ポケモン区分フィルター

**要件**:
- 一般、準伝説、伝説、幻の4つの区分で絞り込み
- 複数選択可能（OR条件）

**区分定義**:
- 一般: 通常の野生で出現するポケモン
- 準伝説: 固定シンボルで出現する強力なポケモン（三鳥、UBなど）
- 伝説: パッケージ伝説、禁止級
- 幻: 配布限定のポケモン

**受入基準**:
- [ ] 4つの区分で絞り込み可能
- [ ] 複数選択でOR検索
- [ ] SearchFilterViewに追加

#### FR-4.4.4 進化のきせきフィルター

**要件**:
- 「進化のきせき」が適用可能なポケモンのみを表示
- PokemonEvolutionModel.canUseEviolite を利用

**適用条件**:
- 進化前または進化途中のポケモン
- 最終進化形は対象外

**受入基準**:
- [ ] 進化のきせき適用可能ポケモンの絞り込み
- [ ] SearchFilterViewに追加

#### FR-4.4.5 最終進化フィルター

**要件**:
- 最終進化形のポケモンのみを表示
- PokemonEvolutionModel.evolvesTo を利用して判定

**判定条件**:
- `evolvesTo.isEmpty == true` の場合、最終進化形

**使用例**:
- 対戦用ポケモンの絞り込み
- 最終進化形のみの図鑑埋めチェック

**受入基準**:
- [ ] 最終進化形の絞り込み
- [ ] SearchFilterViewに追加
- [ ] 進化段階の情報をPokemonエンティティに追加（必要に応じて）

#### FR-4.4.6 実数値絞り込みフィルター

**要件**:
- ポケモンの実数値（HP、攻撃、防御、特攻、特防、素早さ）で絞り込み
- レベル50での実数値を直接数値入力で指定
- ライバルの明確化に利用
- 実数値詳細フィルター画面（StatDetailFilterView）を新設

**計算の前提条件**:
- レベル: 50固定
- 個体値: 31（最大）
- 努力値・性格補正: ユーザーが自由に計算して実数値を指定

**フィルター例**:
- 「すばやさ180以上」: 最速スカーフ持ちを探す
- 「すばやさ90以下」: トリックルーム要員を探す
- 「HP200以上」: 高耐久ポケモンを探す

**UI仕様**:
```
実数値フィルター（レベル50想定）

  [HP ▼] [以上 ▼] [200____] [追加]
  [すばやさ ▼] [以下 ▼] [90____] [追加]
  [すばやさ ▼] [範囲 ▼] [100____] 〜 [150____] [追加]

  [選択中の条件]
  HP ≥ 200 [x]
  すばやさ ≤ 90 [x]
  すばやさ 100〜150 [x]
```

**検索ロジック**:
- CalculateStatsUseCaseで各ポケモンの最大実数値（Lv50, 個体値31, 努力値252, 性格補正1.1）を計算
- 指定された条件を満たすポケモンのみ表示

**受入基準**:
- [ ] StatDetailFilterView実装
- [ ] 6つのステータスで実数値絞り込み可能
- [ ] 範囲指定（以上/以下/範囲）が可能
- [ ] CalculateStatsUseCaseを利用
- [ ] SearchFilterViewから遷移可能

#### FR-4.4.7 フィルター条件の可視化（Chip UI）

**要件**:
- 現在選択中のフィルター条件を分かりやすく表示
- 既存の技名表示と同様のChip UI（タグUI）スタイルを採用
- 各条件に×ボタンを付けて個別削除可能

**UI仕様**:
```
[選択中の条件]
技名: [かえんほうしゃ] [x]  [なみのり] [x]
効果: [特攻上昇 AND 特防上昇] [x]  [やけど付与] [x]
特性: [天候変化] [x]
区分: [伝説] [x]  [幻] [x]
その他: [進化のきせき適用可] [x]
```

**スタイル案**:
- 四角い枠（角丸）で囲む
- 背景色で分類を区別（技=青、特性=緑、区分=紫など）
- ×ボタンで個別削除
- 「全てクリア」ボタンも配置

**受入基準**:
- [ ] Chip UIで条件表示
- [ ] カテゴリー別に色分け
- [ ] 個別削除・全削除が可能
- [ ] スクロール可能

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

| 指標 | v3.0（現状） | v4.0目標 | v4.0実測値 | 達成状況 |
|------|-------------|---------|---------|------|
| 初回起動時間 | 60-90秒 | **1秒以内** | **1秒以内** | ✅ |
| 2回目起動 | 60-90秒 | **1秒以内** | **1秒以内** | ✅ |
| データ変換 | - | - | **18秒 → 1秒** | ✅ |
| 技フィルター | 80秒 | **3秒以内** | **3秒以内** | ✅ |
| アプリサイズ | 5MB | 25MB以下 | **約12MB** | ✅ |
| オフライン対応 | ❌ | ✅ | ✅（初回から） | ✅ |

### 定性的基準

- [x] ユーザーが「速くなった」と体感できる
- [x] オフラインでも快適に使える
- [x] 技フィルターが実用的になる
- [x] エラーが発生しても部分的に動作する
- [x] タイプバッジの幅が統一され、見やすくなった

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
| 2025-10-12 | 3.0 | Phase 1-3完了、実装結果を反映、埋め込みモデル採用、PokedexModel追加、パフォーマンス実測値更新 | Claude |
| 2025-10-12 | 3.1 | Phase 4追加：高度なフィルタリング機能（技メタデータ、特性メタデータ、区分、進化のきせき、Chip UI） | Claude |
| 2025-10-12 | 3.2 | Phase 4拡張：タイプ/特性/技のOR/AND切り替え、最終進化フィルター追加、実数値フィルターUI簡素化、画面分離設計追加 | Claude |
