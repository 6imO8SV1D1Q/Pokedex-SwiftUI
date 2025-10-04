# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-04

### Added

- 初回リリース
- **ポケモン一覧表示機能**
  - リスト形式での表示
  - グリッド形式での表示
  - リスト⇔グリッド切り替え機能
- **ポケモン詳細情報表示**
  - 基本情報（図鑑番号、名前、タイプ、身長、体重）
  - ステータス（種族値）の表示
  - 特性の表示
  - 進化チェーンの表示
  - 色違い表示の切り替え
  - 習得技リストの表示（レベルアップ・わざマシンなど習得方法別フィルタリング）
- **検索・フィルター機能**
  - 名前による検索（部分一致、大文字小文字を区別しない）
  - タイプによるフィルター（複数選択可能）
  - フィルターのクリア機能
- **Clean Architecture + MVVM による設計**
  - Domain層（Entities、UseCases、Protocols）
  - Data層（Repositories、Network、DTOs）
  - Presentation層（Views、ViewModels）
  - 依存性注入（DIContainer）
- **ユニットテスト実装**
  - Domain層のテスト（FetchPokemonListUseCase、FetchEvolutionChainUseCase）
  - Presentation層のテスト（PokemonListViewModel、PokemonDetailViewModel）
  - MockオブジェクトとFixtureヘルパーの実装
  - 合計23テストを実装、全てパス

### Technical

- iOS 26.0+ 対応
- Swift 6.0 使用
- SwiftUI フレームワーク採用
- **依存ライブラリ**
  - PokemonAPI 7.0.3+ - PokéAPI連携
  - Kingfisher 8.5.0+ - 画像キャッシュ・ダウンロード
- **非同期処理**
  - async/await による非同期処理
  - リトライ機能（最大3回）
  - タイムアウト処理（10秒）
- **パフォーマンス最適化**
  - メモリキャッシュによる高速化
  - 並列リクエスト処理
- **対応デバイス**
  - iPhone専用（iPad非対応）

### Documentation

- README.md の作成
- CHANGELOG.md の作成
- requirements.md（要件定義書）の作成
- design.md（設計書）の作成
- コードへの doc コメント追加（Domain層）
- コードへの MARK コメント追加（Presentation層）

[1.0.0]: https://github.com/yourusername/Pokedex-SwiftUI/releases/tag/v1.0.0
