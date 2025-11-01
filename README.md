# Pokedex-SwiftUI

SwiftUIで実装したポケモン図鑑アプリケーション。PokéAPI v2を使用してポケモンの情報を表示します。

## 🌟 主な機能

### タブ構成

- 📚 **ポケモン図鑑タブ**：ポケモンの閲覧・検索・フィルター
- 🧮 **実数値計算機タブ**：個体値・努力値・性格補正を考慮したステータス計算

### 図鑑機能

#### 図鑑選択
- **全国図鑑**：スカーレット・バイオレットに登場するポケモンを全て表示
- **パルデア図鑑**：スカーレット・バイオレットのパルデア地方
- **キタカミ図鑑**：スカーレット・バイオレットのキタカミ地方
- **ブルーベリー図鑑**：スカーレット・バイオレットのブルーベリー地方
- 画面上部のSegmented Controlで切り替え可能

#### 検索・フィルター
- **名前検索**：ポケモン名で検索
- **タイプフィルター**：複数タイプで絞り込み（OR/AND切り替え可能）
- **特性フィルター**：
  - メタデータ対応（攻撃強化、防御強化、素早さ操作、天候操作など）
  - カテゴリー検索（「攻撃を上げる特性」で一括検索可能）
- **技フィルター**：
  - メタデータ対応（先制技、優先度-など）
  - 習得方法も表示（レベル、TM/TR、タマゴ技など）
- **カテゴリーフィルター**：伝説、幻、準伝説等
- **進化段階フィルター**：0〜3段階
- **種族値フィルター**：範囲指定

#### ソート
- 図鑑番号（デフォルト）
- 名前（昇順/降順）
- 種族値合計（昇順/降順）
- 各ステータス（HP、攻撃、防御、特攻、特防、素早さ）

#### 表示設定
- リスト/グリッド表示切り替え
- 多言語対応（日本語/英語）
- ダークモード対応

### ポケモン詳細画面

#### バトルタブ
- **タイプ相性**：
  - 攻撃面：このポケモンの技が効果ばつぐんになるタイプ
  - 防御面：受けるダメージの倍率別表示（4倍/2倍/等倍/1/2倍/1/4倍/無効）
  - 複合タイプの相性計算に対応
- **種族値**：レーダーチャート風表示
- **実数値計算**：Lv.50時の5パターン表示
  - 理想個体、252振り、無振り、最低、下降補正
- **特性**：通常特性・隠れ特性（説明文付き）
- **覚える技**：
  - 習得方法別表示（レベルアップ、TM/TR、タマゴ技、教え技）
  - ライバル除外フィルター（他ポケモンが覚えない技のみ表示）

#### 生態タブ
- **進化チェーン**：
  - ツリー形式で進化の流れを表示
  - 進化条件表示（レベル、進化石、通信交換、なつき度など）
  - 分岐進化に対応（イーブイなど）
  - タップで進化先/進化前ポケモンに遷移
- **図鑑説明文**：バージョン選択可能
- **フォーム選択**：
  - リージョンフォーム（アローラ、ガラル、ヒスイ、パルデア）
  - フォルムチェンジ（ロトム、デオキシスなど）
  - フォーム変更時に画像、タイプ、種族値、実数値が自動更新

### 実数値計算機

- **ポケモン選択**：スカーレット・バイオレットに登場するポケモンから検索・選択
- **詳細設定**：
  - レベル（1-100）
  - 個体値（0-31）- 各ステータス個別設定可能
  - 努力値（0-252、合計510まで）- 残り努力値を表示
  - 性格補正（1.1倍/1.0倍/0.9倍）
- **リアルタイム計算**：入力と同時に実数値を表示
- **種族値表示**：選択したポケモンの種族値も併記

### その他の機能

- **設定画面**：
  - 言語設定（デバイスの設定に従う）
  - バージョン優先度設定
- **オフライン対応**：初回起動から完全オフライン動作
- **プリロードデータ**：スカーレット・バイオレットに登場するポケモンのデータを事前収録
- **高速起動**：1秒以内で起動

## 🏛 アーキテクチャ

Clean Architecture + MVVMパターンを採用

```
├── Application/     # DIContainer、アプリ設定
├── Common/          # 多言語対応、共通ユーティリティ
├── Domain/          # エンティティ、ユースケース、プロトコル
├── Data/            # リポジトリ、API、キャッシュ、永続化
├── Presentation/    # ビュー、ビューモデル
└── Resources/       # プリロードデータ、多言語リソース
```

### 主要コンポーネント

**Domain層（30+ エンティティ、20+ ユースケース）:**
- **Entity**:
  - `Pokemon` / `PokemonListItem`: ポケモンエンティティ
  - `VersionGroup`: バージョングループエンティティ
  - `MoveEntity`: 技エンティティ
  - `PokemonForm`: フォームエンティティ
  - `TypeMatchup`: タイプ相性エンティティ
  - `CalculatedStats`: 実数値エンティティ
  - `AbilityMetadata`: 特性メタデータ
- **UseCase**:
  - `FetchPokemonListUseCase`: ポケモンリスト取得
  - `FilterPokemonByMovesUseCase`: 技フィルター
  - `FilterPokemonByAbilityUseCase`: 特性フィルター
  - `SortPokemonUseCase`: ソート
  - `FetchPokemonFormsUseCase`: フォーム取得
  - `FetchTypeMatchupUseCase`: タイプ相性計算
  - `CalculateStatsUseCase`: 実数値計算

**Data層（10+ リポジトリ）:**
- **Repository**:
  - `PokemonRepository`: ポケモンデータ取得
  - `MoveRepository`: 技データ取得
  - `AbilityRepository`: 特性データ取得
  - `TypeRepository`: タイプデータ取得
- **API**: `PokemonAPIClient` - PokéAPI通信
- **Cache**: Actor-basedメモリキャッシュ
  - `MoveCache`, `TypeCache`, `FormCache`, `AbilityCache`, `LocationCache`
- **Persistence**: SwiftDataによる永続化
  - `PokemonModel`, `MoveModel`, `AbilityModel`, `PokedexModel`
  - `PreloadedDataLoader`: プリロードデータの読み込み

**Presentation層:**
- `PokemonListViewModel`: 一覧画面のビジネスロジック
- `PokemonDetailViewModel`: 詳細画面ロジック
- `StatsCalculatorViewModel`: 実数値計算機ロジック

## 🛠 技術スタック

- **言語**: Swift 6.0
- **フレームワーク**: SwiftUI, SwiftData
- **最小デプロイメントターゲット**: iOS 17.0
- **依存ライブラリ**:
  - [Kingfisher](https://github.com/onevcat/Kingfisher) 8.6.0 - 画像キャッシュ
  - [PokemonAPI](https://github.com/kinkofer/PokemonAPI) 7.0.3 - PokéAPI Swiftクライアント
- **API**: [PokéAPI v2](https://pokeapi.co/)
- **永続化**: SwiftData（ディスク永続化）
- **多言語**: 日本語、英語

## ⚙️ セットアップ

### 必要要件
- Xcode 15.0+
- iOS 17.0+

### インストール手順

1. リポジトリをクローン
```bash
git clone https://github.com/yourusername/Pokedex-SwiftUI.git
cd Pokedex-SwiftUI
```

2. 依存関係の解決
```bash
# Swift Package Managerが自動的に依存関係を解決します
# Kingfisher 8.6.0 と PokemonAPI 7.0.3 がインストールされます
```

3. Xcodeでプロジェクトを開く
```bash
open Pokedex/Pokedex.xcodeproj
```

4. ビルド＆実行
- ターゲットデバイス/シミュレータを選択
- Cmd+R でビルド＆実行

## 📱 使い方

### 図鑑タブ

1. **図鑑選択**
   - 画面上部のSegmented Controlから図鑑を選択
   - 「全国」「パルデア」「キタカミ」「ブルーベリー」から選択可能

2. **フィルター機能**
   - 虫眼鏡アイコンをタップして検索画面を開く
   - タイプ、特性、技、カテゴリー、進化段階、種族値で絞り込み可能
   - 特性・技フィルターはメタデータ対応（カテゴリー検索可能）

3. **ソート機能**
   - 「ソート」ボタンをタップ
   - 種族値合計や各ステータスでソート可能

4. **表示モード切り替え**
   - リスト/グリッドアイコンで表示を切り替え

5. **詳細画面**
   - ポケモンをタップして詳細画面を表示
   - **バトルタブ**：タイプ相性、種族値、実数値、特性、技
   - **生態タブ**：進化チェーン、図鑑説明文、フォーム選択

### 実数値計算機タブ

1. **ポケモン選択**
   - 検索ボックスに名前を入力してポケモンを検索
   - リストから選択

2. **パラメータ設定**
   - **レベル**：スライダーで1-100を設定
   - **個体値**：各ステータスごとに0-31を設定（一括で最大/最小設定も可能）
   - **努力値**：各ステータスごとに0-252を設定（合計510まで、残り努力値を表示）
   - **性格補正**：各ステータスごとに1.1倍/1.0倍/0.9倍を選択

3. **結果確認**
   - 設定に基づいた実数値がリアルタイムで表示される
   - 種族値も併記されるため、実数値との比較が可能

### 設定画面

- 歯車アイコンから設定画面を開く
- **言語**：デバイスの設定に従う（日本語/英語）
- **バージョン優先度**：データ表示の優先順位を設定

## ⚡️ パフォーマンス

- **初回起動**：1秒以内（プリロードデータ使用）
- **2回目以降**：1秒以内（SwiftDataキャッシュ）
- **技フィルター**：3秒以内
- **オフライン対応**：初回起動から完全オフライン動作

**最適化手法:**
- SwiftDataによるディスク永続化
- プリロードデータ（スカーレット・バイオレット登場ポケモン）
- バックグラウンドデータ読み込み
- Actor-basedメモリキャッシュ
- Kingfisherによる画像キャッシュ

## 🧪 テスト

### ユニットテスト実行

Xcodeから:
```
Cmd+U
```

コマンドラインから:
```bash
xcodebuild test -scheme Pokedex -destination 'platform=iOS Simulator,name=iPhone 15'
```

### テスト構成

**ユニットテスト（46テストケース、899行）:**
- `CalculateStatsUseCaseTests`: 実数値計算
- `FetchTypeMatchupUseCaseTests`: タイプ相性計算
- `FetchPokemonFormsUseCaseTests`: フォルム取得
- `FetchPokemonListUseCaseTests`: ポケモンリスト取得
- `FilterPokemonByMovesUseCaseTests`: 技フィルター
- `FetchAllMovesUseCaseTests`: 技データ取得
- `FetchEvolutionChainUseCaseTests`: 進化チェーン取得
- `PokemonListViewModelTests`: 一覧画面ロジック
- `PokemonDetailViewModelTests`: 詳細画面ロジック
- `MoveCacheTests`: キャッシュ機能
- `MockTypeRepository`: モックリポジトリ

**統合テスト（4件）:**
- バージョングループ切り替え
- フィルター連携
- ソート機能
- エラーハンドリング

**パフォーマンステスト（7件）:**
- 初回ロード、キャッシュロード、フィルター処理速度など

### テストカバレッジ

| 層 | カバレッジ | テストケース数 |
|-----|-----------|---------------|
| Domain | ~60% | 46 |
| Data | ~10% | 0 |
| Presentation | ~5% | 0 |
| **合計** | **~25%** | **46** |

## 🐛 トラブルシューティング

**Q: 画像が表示されない**
- A: ネットワーク接続を確認してください。Kingfisherが自動的にリトライします。

## 📚 ドキュメント

### プロジェクト状況
- [実装状況](docs/implementation_status.md) - 現在の実装状況とバージョン別進捗
- [今後の改善予定](docs/future_improvements.md) - 既知の課題と将来の機能拡張

### バージョン別ドキュメント
- **v4.0（開発中）**: [要件](docs/v4/requirements.md) | [設計](docs/v4/design.md) | [プロンプト](docs/v4/prompts.md)
- **v3.0（完了）**: [要件](docs/v3/requirements.md) | [設計](docs/v3/design.md) | [プロンプト](docs/v3/prompts.md)
- **v2.0（完了）**: [要件](docs/v2/requirements.md) | [設計](docs/v2/design.md)

### 機能別設計
- [特性メタデータ](docs/features/ability_metadata/) - 特性フィルター機能の設計
- [スカーレット・バイオレット](docs/features/scarlet_violet/) - 第9世代データ構造

### 開発ガイドライン
- [Claude Code開発ガイド](CLAUDE.md) - Claude Codeでの開発ルール

## 📄 ライセンス

MIT License

## 🙏 クレジット

- **PokéAPI**: https://pokeapi.co/
- **Kingfisher**: https://github.com/onevcat/Kingfisher
- **PokemonAPI**: https://github.com/kinkofer/PokemonAPI
- ポケモンの名前、画像、データは任天堂・クリーチャーズ・ゲームフリークの著作物です

## 🤝 貢献

プルリクエストを歓迎します。大きな変更の場合は、まずIssueを開いて変更内容を議論してください。

## 📧 連絡先

- **作成者**: Yusuke Abe
- **作成日**: 2025-10-04
- **最終更新**: 2025-11-01
