# Pokédex SwiftUI - 設計書 v5.0

**プロジェクト名**: Pokédex SwiftUI  
**バージョン**: 5.0  
**作成者**: v5 設計チーム（ChatGPT支援）  
**作成日**: 2025-10-21  
**最終更新**: 2025-10-21

---

## 📋 目次

1. [アーキテクチャ概要](#アーキテクチャ概要)
2. [機能モジュール構成](#機能モジュール構成)
3. [UI設計](#ui設計)
4. [状態管理とデータモデル](#状態管理とデータモデル)
5. [ダメージ計算エンジン設計](#ダメージ計算エンジン設計)
6. [アイテムJSONスキーマ](#アイテムjsonスキーマ)
7. [シングル・ダブルバトル対応](#シングルダブルバトル対応)
8. [連続ターン撃破確率アルゴリズム](#連続ターン撃破確率アルゴリズム)
9. [データフロー](#データフロー)
10. [実装フェーズと優先度](#実装フェーズと優先度)
11. [テスト戦略](#テスト戦略)
12. [未解決事項](#未解決事項)

---

## アーキテクチャ概要

### 全体構成（v5.0: Damage Calculator Feature）

```
┌──────────────────────────────────────────────────────────────┐
│                        Presentation (SwiftUI)                 │
│  ┌─────────────────────┐  ┌────────────────────┐             │
│  │ DamageCalculatorView│  │ DamageResultPanel  │             │
│  │  + Tabs/Sections    │  │  + ProbabilityView │             │
│  └─────────────────────┘  └────────────────────┘             │
│                │                         │                     │
└────────────────┼─────────────────────────┼─────────────────────┘
                 │                         │
┌────────────────┴─────────────────────────┴─────────────────────┐
│                     ViewModel / Domain Layer                   │
│  ┌─────────────────────────┐  ┌────────────────────────────┐   │
│  │ DamageCalculatorStore   │  │ DamageSimulationCoordinator│   │
│  │  - ObservableObject     │  │  - シナリオ/ターン制御       │   │
│  └─────────────────────────┘  └────────────────────────────┘   │
│                 │                         │                     │
└─────────────────┼─────────────────────────┼─────────────────────┘
                  │                         │
┌─────────────────┴─────────────────────────┴────────────────────┐
│                           Domain Services                      │
│  ┌─────────────────────────┐  ┌────────────────────────────┐   │
│  │ DamageFormulaEngine     │  │ BattleModifierResolver     │   │
│  │  - 公式計算式           │  │  - 天候/特性/アイテム        │   │
│  └─────────────────────────┘  └────────────────────────────┘   │
│                  │                        │                    │
└──────────────────┼────────────────────────┼────────────────────┘
                   │                        │
┌──────────────────┴────────────────────────┴───────────────────┐
│                         Data Providers                        │
│  ┌───────────────────┐  ┌──────────────────┐  ┌──────────────┐│
│  │ PokemonRepository │  │ MoveRepository   │  │ ItemProvider ││
│  │ (既存)            │  │ (既存)           │  │ (新規 JSON)  ││
│  └───────────────────┘  └──────────────────┘  └──────────────┘│
└───────────────────────────────────────────────────────────────┘
```

- 既存の図鑑データ層を再利用しつつ、ダメージ計算専用の`DamageFormulaEngine`とUI状態を管理する`DamageCalculatorStore`を新設する。
- `ItemProvider`はv5で追加するプリバンドルJSONを読み込み、オーガポン用マスク倍率など補正データを返す。
- ビュー層はSwiftUIでセクション分割された入力フォームと結果表示を持つ。

---

## 機能モジュール構成

| モジュール | 役割 | 備考 |
|------------|------|------|
| `DamageCalculatorView` | メイン画面。攻守入力、条件設定、結果表示を統括する。 | 既存タブナビゲーションに統合。 |
| `DamageCalculatorStore` | `@Observable` (iOS 17)/`ObservableObject`で入力状態と結果を管理。 | 単体テストで演算結果を検証可能にする。 |
| `DamageSimulationCoordinator` | 連続ターンのシナリオを保持し、1ターン目→2ターン目の繋がりを制御。 | 将来的な3ターン拡張に備えた抽象化。 |
| `DamageFormulaEngine` | 公式計算式を実装。タイプ一致、テラスタル、天候等を処理。 | 純粋関数群として実装し、副作用を排除。 |
| `BattleModifierResolver` | 特性、アイテム、フィールド効果を解決し、倍率リストを構築。 | 単体テストで条件分岐を網羅。 |
| `ProbabilityCalculator` | 乱数、命中率、急所確率から撃破率を算出。 | v5は2ターンまでサポート。 |
| `ItemProvider` | プリバンドルJSONからアイテム情報を読み込み。 | キャッシュレイヤーを内包。 |
| `BattlePresetStore` | UserDefaults等でローカル保存/読込を管理。 | 外部共有はv5では対象外。 |

---

## UI設計

### 画面構成

1. **セクションA: モード・プリセット**
   - シングル/ダブル切替トグル。
   - プリセット選択（保存済み構築のロード/保存）。
2. **セクションB: 攻撃側入力**
   - ポケモン選択（検索付きピッカー）。
   - レベル、性格、努力値、個体値、ランク補正。
   - タイプ、テラスタイプ、テラスON/OFF。
   - 技/持ち物/特性（検索バー付きリスト）。
3. **セクションC: 防御側入力**
   - 攻撃側と同等の項目。
   - ワンタップ切替ボタンで攻守を入れ替え。
4. **セクションD: バトル環境**
   - 天候、フィールド、壁、設置技、その他補助条件。
5. **セクションE: 連続ターン設定**
   - 1ターン目技、2ターン目技、命中補助。
6. **セクションF: 結果表示**
   - ダメージ範囲、確定数、撃破確率。
   - HPバー可視化、条件サマリー、コピー共有ボタン。

### ナビゲーション
- 既存タブバーに「ダメージ計算」を追加。
- iPadでは左右2カラム（入力 / 結果）をSplitViewで表示。
- iPhoneではセクション間スクロール + 結果パネルを常時Dock表示。

### コンポーネント再利用
- `SearchablePickerView`（新規コンポーネント）でポケモン、技、アイテム、特性の検索を統一。
- `TypeBadgeView`を通常タイプとテラスタイプで色分け。テラスタイプ選択時は枠線強調。
- `TogglePill`でシングル/ダブル切替、テラスタルON/OFFを表示。

---

## 状態管理とデータモデル

### コアモデル

```swift
struct BattleParticipantState {
    var pokemon: PokemonIdentifier
    var level: Int
    var nature: Nature
    var effortValues: EffortValueSet
    var individualValues: IndividualValueSet
    var statStages: StatStageSet
    var ability: AbilityIdentifier
    var heldItem: ItemIdentifier?
    var baseType: [PokemonType]
    var teraType: PokemonType?
    var isTerastallized: Bool
}

struct BattleEnvironmentState {
    var weather: WeatherCondition?
    var terrain: TerrainField?
    var screen: ScreenEffect? // Reflect/Light Screen/Aurora Veil
    var hazards: HazardState
    var otherModifiers: [BattleModifier]
}

struct TurnPlan {
    var firstMove: MoveIdentifier
    var secondMove: MoveIdentifier?
    var applyAccuracy: Bool
}
```

- `BattleParticipantState`を攻守で2つ保持。ワンタップ切替時は構造体をスワップするのみ。
- `BattleEnvironmentState`でシングル/ダブル共通の環境設定を表現し、ダブル固有情報（味方支援等）は`otherModifiers`に拡張可能。
- `DamageCalculatorStore`は`BattleState`（攻撃側、防御側、環境、ターンプラン、モード）を保持し、変更時に再計算をトリガー。

### データ正規化
- UIから選択されるエンティティはすべてID（`PokemonIdentifier`等）で保持し、リポジトリから詳細情報を遅延取得。
- これにより、プリセット保存時も軽量なJSONを生成可能。

---

## ダメージ計算エンジン設計

### 処理フロー

1. `DamageSimulationCoordinator`が現在の`BattleState`を受け取り、ターン毎に`DamageRequest`を生成。
2. `DamageFormulaEngine`が以下のステップで計算:
   1. 基本ステータス計算（努力値、個体値、性格、ランク）。
   2. 技の基礎威力確定（Ivy Cudgel等の特殊技はここで調整）。
   3. タイプ一致補正（通常STAB 1.5、テラスタル時2.0、オーガポンマスク補正1.2/1.3）。
   4. タイプ相性倍率（テラスタル後のタイプ構成に基づき算出）。
   5. その他補正（天候、フィールド、壁、アイテム、特性、範囲技半減）。
   6. ダメージ乱数16通りを生成。
3. `ProbabilityCalculator`が命中率・急所率・乱数からKO確率を算出。
4. 結果を`DamageCalculatorStore`に戻し、UIへ反映。

### オーガポン特殊処理
- `BattleModifierResolver`で攻撃側がオーガポンか判定。
- 所持アイテムが対応マスクかつ技タイプがマスクタイプの場合、倍率を付与。
- テラスタルONの場合、テラスタイプがマスクタイプなら1.3倍、それ以外は1.2倍を維持。
- オーガポン専用技「Ivy Cudgel」は技側でタイプ変化を考慮しつつ、マスクタイプのとき威力強化を適用。

### 拡張性
- 状態異常はv5で非対応だが、`BattleModifier`プロトコルを通じて将来追加可能。
- 乱数生成は純粋関数でテストしやすく、`SeededRandom`を用意してリグレッションを再現。

---

## アイテムJSONスキーマ

```jsonc
{
  "item_id": "wellspring_mask",
  "display_name": {
    "ja": "いどのめん",
    "en": "Wellspring Mask"
  },
  "category": "held",
  "effects": {
    "damage_multiplier": {
      "target_type": "water",
      "value": 1.2,
      "applies_during_tera": true,
      "tera_multiplier": 1.3
    }
  },
  "notes": "オーガポン専用。マスクと同タイプの技に補正を与える。"
}
```

- **必須キー**: `item_id`, `display_name`, `category`, `effects`。
- `effects.damage_multiplier`に倍率情報を格納し、ターゲットタイプやテラスタル時の増分を指定。
- 一般アイテムは`effects`に`type`: `attack`, `defense`, `accuracy`等を持たせ、`BattleModifierResolver`で用途別に解釈。
- JSONは`Resources/Items/items_v5.json`としてバンドルし、`ItemProvider`がアプリ起動時に読み込みキャッシュ。

---

## シングル・ダブルバトル対応

- `BattleState`に`battleMode: BattleMode`を追加し、`single`/`double`を保持。
- ダブルバトル時の追加補正:
  - 範囲技威力0.75倍。
  - いかりのこな等のターゲット変更はv5では非対応。
  - 味方の特性支援（例: フレンドガード）は`otherModifiers`で表現。
- UIではダブル選択時に味方サポート入力行を表示（例: フレンドガードON/OFF）。
- 計算エンジンでは`BattleMode`に応じた補正セットを`BattleModifierResolver`から受け取る。

---

## 連続ターン撃破確率アルゴリズム

1. **入力整形**: `TurnPlan`からターン毎の`DamageRequest`を生成。
2. **1ターン目計算**: 乱数分布（16値）と命中率からHP残量分布を算出。
3. **2ターン目計算**: 1ターン目のHP分布を初期HPとして再計算し、撃破確率を集計。
4. **急所**: 公式仕様に基づき、急所時のダメージを別分布として重み付き合算。
5. **結果整形**: 
   - 撃破確率（%）
   - 確定数テキスト（例: "乱数2発 (68.75%)"）
   - 被ダメシナリオ表（HPバー表示用）

計算は`ProbabilityCalculator`でPure Swift実装。性能要件を満たすため、重複する計算は`MemoizationCache`で再利用。

---

## データフロー

1. アプリ起動時に`ItemProvider`がJSONを読み込み、`ItemDictionary`として保持。
2. ユーザーが入力を変更すると`DamageCalculatorStore`が`BattleState`を更新。
3. `DamageSimulationCoordinator`が非同期タスクで再計算を依頼。
4. `DamageFormulaEngine`が同期計算し、結果を`DamageResult`として返却。
5. `DamageCalculatorStore`が`DamageResult`を公開プロパティに反映し、UIが自動更新。
6. プリセット保存時は`BattleState`をJSON化し`BattlePresetStore`経由でUserDefaultsに保存。

---

## 実装フェーズと優先度

| フェーズ | 期間目安 | 内容 | 成果物 |
|----------|----------|------|--------|
| Phase 0 | 1週 | アイテムJSON整備、`ItemProvider`実装、既存データ確認。 | `items_v5.json`, Provider単体テスト |
| Phase 1 | 2週 | UIスキャフォールド（入力フォーム、結果パネル、状態管理基盤）。 | `DamageCalculatorView`, `DamageCalculatorStore` |
| Phase 2 | 3週 | `DamageFormulaEngine`実装（テラスタル、オーガポン、環境補正）。 | Engineユニットテスト、Ogreponケース検証 |
| Phase 3 | 2週 | 連続ターン・確率計算、ダブルバトル補正対応。 | `ProbabilityCalculator`, ダブルバトルテスト |
| Phase 4 | 1週 | プリセット保存、UI磨き、アクセシビリティ、回帰テスト。 | リリース候補ビルド |

---

## テスト戦略

### 単体テスト
- `DamageFormulaEngineTests`
  - テラスタルSTAB、オーガポン各マスク、範囲技補正、壁補正などを個別検証。
- `ProbabilityCalculatorTests`
  - 乱数16通り・急所確率を固定Seedで照合。
- `ItemProviderTests`
  - JSONスキーマバリデーション、未知キーの扱い。

### 結合テスト
- `DamageCalculatorStoreTests`でUI操作をシミュレートし、結果が要件通り更新されるか検証。
- Snapshotテストで主要フォームのUI崩れを検知。

### リグレッションデータ
- 公式ドキュメントや既存Webツールから基準ケースを収集し`Fixtures/damage_cases.json`として管理。
- CIで毎回ダメージ結果を照合し差分を検出。

---

## 未解決事項

1. **アイテムJSON詳細仕様**
   - PokeAPIから取得するフィールド一覧とマッピングルールを設計フェーズで確定する。
2. **ダブルバトル参照資料**
   - 範囲技以外の補正（例: フレンドガード）に関する公式根拠資料を調査。
3. **オーガポン検証データ**
   - 各マスク×テラスタイプの期待ダメージを既存ツールから抜粋し、ユニットテストに取り込む。

上記は設計フェーズ継続タスクとして管理し、実装開始前に確定させる。

---

## ドキュメント更新履歴

- 2025-10-21: v5ダメージ計算機能の初版設計書を作成。
- 2025-10-21: 設計レビュー向けに未解決事項と検証データ要件を更新。

今後の設計変更や追加要件が発生した際は、本書の更新履歴を追記して関係者へ周知する。
