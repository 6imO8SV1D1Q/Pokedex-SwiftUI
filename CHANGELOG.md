# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-05

### Added
- **バージョングループ別表示**: 22種類のゲームバージョンに対応（赤・緑・青からスカーレット・バイオレットまで）
- **全ポケモン対応**: 1025匹の全ポケモンに対応（第1〜9世代）
- **特性表示**: ポケモン一覧に特性を表示（通常特性 + 隠れ特性）
  - 第1〜2世代: 特性システム未実装のため非表示
  - 第3〜4世代: 通常特性のみ
  - 第5世代以降: 通常特性 + 隠れ特性
- **種族値表示**: ポケモン一覧に全ステータスと合計値を表示（形式: \`HP-攻撃-防御-特攻-特防-素早さ (合計)\`）
- **特性フィルター**: 特性で絞り込み機能（第3世代以降で利用可能）
- **技フィルター**: 最大4技で絞り込み、習得方法も表示（バージョングループ選択時のみ）
  - レベルアップ、TM/TR、タマゴ技などの習得方法を表示
- **種族値ソート**: 合計値または個別ステータスでソート
  - HP、攻撃、防御、特攻、特防、素早さ、合計値
  - 昇順/降順切り替え対応
- **スクロール位置保持**: 詳細画面から戻った時の位置を保持
- **ローディングプログレスバー**: 進捗率を表示（例: 450/1025）
- **並列データ取得**: TaskGroupを使用した高速化
- **メモリキャッシュ**: バージョングループ別キャッシュ
- **技データキャッシュ**: MoveCache実装（MainActor対応）
- **ユニットテスト**: 主要UseCasesとViewModelsのテスト追加
- **統合テスト**: バージョングループ切り替え、フィルター連携、ソート、エラーハンドリングのテスト追加
- **パフォーマンステスト**: ロード時間とフィルター速度のテスト追加

### Changed
- \`Pokemon\`エンティティに特性・種族値・世代情報を追加
- \`PokemonListItem\`エンティティを\`Pokemon\`に統合
- 一覧画面のUIを拡張（情報量増加）
- \`PokemonListViewModel\`にバージョングループ管理機能を追加
- \`PokemonRepository\`をバージョングループ対応に拡張
- キャッシュ戦略をバージョングループ別に分離
- \`DIContainer\`を全UseCases対応に拡張
- テストアーキテクチャを改善（Fixture、Mock、Helper追加）

### Fixed
- 大量データ取得時のパフォーマンス改善（並列取得導入）
- メモリ管理の最適化（キャッシュサイズ管理）
- MainActor警告の解消（Swift 6対応）
- リトライロジックの改善（最大3回、指数バックオフ）
- エラーハンドリングの強化

### Performance
- 初回ロード: TaskGroupによる並列取得で高速化
- バージョングループ切り替え: キャッシュにより2回目以降は高速
- フィルター処理: タイプ・特性は即座、技フィルターはAPI呼び出しのため時間がかかる
- ソート処理: メモリ上の操作のため高速

## [1.0.0] - 2024-10-04

### Added
- ポケモン一覧表示（第1世代151匹）
- ポケモン詳細表示
  - 基本情報（図鑑番号、名前、タイプ、身長、体重）
  - ステータス（種族値）
  - 特性
  - 進化チェーン
  - 色違い表示切り替え
  - 習得技リスト
- タイプフィルター（複数選択可能）
- 名前検索（部分一致、大文字小文字区別なし）
- 画像キャッシュ（Kingfisher）
- リスト/グリッド表示切り替え
- Clean Architecture + MVVMアーキテクチャ
- PokéAPI v2統合
- 基本的なユニットテスト

### Technical Stack
- Swift 6.0
- SwiftUI
- iOS 17.0+
- Kingfisher (画像キャッシュ)
- async/await, TaskGroup（非同期処理）

## リンク

[2.0.0]: https://github.com/yourusername/Pokedex-SwiftUI/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/yourusername/Pokedex-SwiftUI/releases/tag/v1.0.0
