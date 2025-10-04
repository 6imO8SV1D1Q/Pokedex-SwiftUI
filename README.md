# Pokédex SwiftUI

## 📱 概要

第1世代（初代151匹）のポケモン図鑑アプリ。Clean Architecture + MVVMで設計された、SwiftUI製のモダンなiOSアプリです。

## ✨ 主な機能

- **ポケモン一覧表示**
  - リスト形式での表示
  - グリッド形式での表示
  - リスト⇔グリッド切り替え機能
- **ポケモン詳細情報**
  - 基本情報（図鑑番号、名前、タイプ、身長、体重）
  - ステータス（種族値）の表示
  - 特性の表示
  - 進化チェーンの表示
  - 色違い表示の切り替え
  - 習得技リストの表示（レベルアップ・わざマシンなど、習得方法別に表示可能）
- **検索・フィルター機能**
  - 名前による検索（部分一致、大文字小文字を区別しない）
  - タイプによるフィルター（複数選択可能）
  - フィルターのクリア機能

## 🏗️ アーキテクチャ

このプロジェクトは **Clean Architecture + MVVM** を採用しています。

### アーキテクチャの利点

- **保守性**: 変更が特定の層に限定され、影響範囲が明確
- **テスタビリティ**: ビジネスロジックを独立してテスト可能
- **再利用性**: Domain層は将来のUIKit版でも再利用可能
- **理解しやすさ**: 責務が明確に分離されている

### レイヤー構成

```
Presentation Layer (SwiftUI Views + ViewModels)
           ↓↑
Domain Layer (Entities + UseCases + Protocols)
           ↓↑
Data Layer (Repositories + API Clients)
           ↓↑
External Services (PokéAPI)
```

詳細は [docs/design.md](docs/design.md) を参照してください。

## 🛠️ 技術スタック

- **言語**: Swift 6.0
- **UIフレームワーク**: SwiftUI
- **最低iOS**: iOS 26.0+
- **対応デバイス**: iPhone専用
- **アーキテクチャ**: Clean Architecture + MVVM
- **非同期処理**: async/await, TaskGroup
- **状態管理**: @State, @StateObject, @Published
- **データ保存**: メモリキャッシュのみ（永続化なし）
- **依存ライブラリ**:
  - [PokemonAPI](https://github.com/kinkofer/PokemonAPI) - PokéAPI通信ライブラリ
  - [Kingfisher](https://github.com/onevcat/Kingfisher) - 画像キャッシュ・ダウンロードライブラリ

## 📂 プロジェクト構成

```
Pokedex-SwiftUI/
├── docs/                       # ドキュメント
│   ├── requirements.md         # 要件定義書
│   └── design.md              # 設計書
├── Pokedex/
│   ├── Domain/                # ビジネスロジック層
│   │   ├── Entities/         # データ構造
│   │   ├── UseCases/         # ビジネスロジック
│   │   └── Interfaces/       # プロトコル定義
│   ├── Data/                  # データアクセス層
│   │   ├── Repositories/     # リポジトリ実装
│   │   ├── Network/          # API通信
│   │   └── DTOs/             # データ変換
│   ├── Presentation/          # UI層
│   │   ├── PokemonList/      # 一覧画面
│   │   ├── PokemonDetail/    # 詳細画面
│   │   ├── Search/           # 検索・フィルター画面
│   │   └── Common/           # 共通UI部品
│   ├── Application/           # アプリ設定
│   │   └── DIContainer.swift # 依存性注入
│   └── Resources/            # リソース
└── PokedexTests/              # ユニットテスト
    ├── Mocks/                # テスト用Mock
    ├── Helpers/              # テスト用ヘルパー
    ├── Domain/               # Domain層のテスト
    └── Presentation/         # Presentation層のテスト
```

詳細は [docs/requirements.md](docs/requirements.md) を参照してください。

## 🚀 セットアップ

### 必要な環境

- Xcode 26.0+
- iOS 26.0+
- iPhone（iPadには対応していません）

### インストール手順

1. リポジトリをクローン

```bash
git clone https://github.com/yourusername/Pokedex-SwiftUI.git
cd Pokedex-SwiftUI
```

2. Xcodeでプロジェクトを開く

```bash
open Pokedex/Pokedex.xcodeproj
```

3. Swift Packageが自動で解決されます

4. シミュレータまたは実機でビルド＆実行

```
⌘ + R
```

## 🧪 テスト

### テストの実行

Xcode上で実行：

```
⌘ + U
```

または、コマンドラインから：

```bash
xcodebuild test -scheme Pokedex -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### テストカバレッジ

- Domain層（UseCases）のテスト: 完全にカバー
- Presentation層（ViewModels）のテスト: 完全にカバー
- 合計23テストを実装

テスト戦略の詳細は [docs/design.md](docs/design.md) の「テスト戦略」セクションを参照してください。

## 📚 API仕様

- **データソース**: [PokéAPI](https://pokeapi.co/)
- **利用ポリシー**: フェアユース・ポリシー準拠
- **キャッシュ**: メモリキャッシュによるリクエスト削減
- **対象データ**: 第1世代（図鑑番号001〜151）

## 🚫 対象外機能

以下の機能は実装していません（[requirements.md](docs/requirements.md) の「対象外機能」セクション参照）：

- 背面画像の表示
- 説明文（フレーバーテキスト）
- 出現場所
- 完全なオフライン対応（永続化によるオフライン動作）
- お気に入り機能
- 性別による見た目の違い
- 鳴き声再生
- タイプ相性チェッカー
- ポケモン同士の比較機能

## 📝 今後の改善案

- [ ] 第2世代以降のポケモン対応
- [ ] お気に入り機能（永続化層の追加）
- [ ] タイプ相性チェッカー
- [ ] ポケモン比較機能
- [ ] ウィジェット対応
- [ ] オフライン対応の強化
- [ ] 説明文（フレーバーテキスト）の表示
- [ ] 出現場所の表示
- [ ] 鳴き声再生機能
- [ ] ダークモード対応

## 📖 ドキュメント

- [要件定義書](docs/requirements.md) - プロジェクトの要件と機能仕様
- [設計書](docs/design.md) - アーキテクチャとコンポーネント設計

## 📄 ライセンス

MIT License

## 🙏 クレジット

- **PokéAPI**: https://pokeapi.co/ - ポケモンデータの提供
- **Pokemon API Swift Package**: https://github.com/kinkofer/PokemonAPI - API通信ライブラリ
- **Kingfisher**: https://github.com/onevcat/Kingfisher - 画像キャッシュライブラリ

## 👤 作成者

Yusuke Abe

---

**作成日**: 2025-10-04
**バージョン**: 1.0.0
