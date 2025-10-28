# 技・特性の説明文 多言語対応プロンプト

## 背景

現在、`scarlet_violet.json`には技（moves）と特性（abilities）の説明文が英語（`effect`）と日本語（`effectJa`）の両方で保存されているが、アプリでは常に英語の説明文のみが表示されている。

ユーザーの言語設定（日本語/英語）に応じて、適切な言語の説明文を表示するように修正する必要がある。

## 現状の問題点

### 1. データ層は準備完了
- ✅ `scarlet_violet.json` - `effect`（英語）と`effectJa`（日本語）が存在
- ✅ `MoveModel`（SwiftData） - `effect`と`effectJa`プロパティが存在
- ✅ `AbilityModel`（SwiftData） - `effect`と`effectJa`プロパティが存在

### 2. Domain層が不完全
- ❌ `MoveEntity` - `effect`のみ、`effectJa`プロパティがない
- ❌ `AbilityEntity` - `effect`のみ、`effectJa`プロパティがない（要確認）

### 3. Repository層が英語固定
- ❌ `MoveRepository` - 常に`model.effect`（英語）のみを使用
- ❌ `AbilityRepository` - 同様の問題がある可能性（要確認）

### 4. Presentation層が言語切り替え未対応
- ❌ `MovesView`（`MoveRow`） - `detail.effect`を直接表示、言語切り替えなし
- ❌ `AbilitiesView` - 同様の問題がある可能性（要確認）

## 作業前の確認事項

### 1. 特性（Ability）の現状確認

以下のファイルを確認し、技と同じ問題があるか調査：

```bash
# AbilityEntityの定義を確認
grep -A 20 "struct AbilityEntity" Pokedex/Pokedex/Domain/Entities/**/*.swift

# AbilityRepositoryがeffectをどう扱っているか確認
grep -A 5 "effect:" Pokedex/Pokedex/Data/Repositories/Ability/*.swift

# AbilitiesViewでの表示方法を確認
grep -A 10 "effect" Pokedex/Pokedex/Presentation/PokemonDetail/Components/AbilitiesView.swift
```

### 2. 他に技・特性の説明を表示している場所がないか確認

```bash
# 技の説明を表示している可能性のある箇所を検索
grep -r "moveDetail" Pokedex/Pokedex/Presentation --include="*.swift"
grep -r "\.effect" Pokedex/Pokedex/Presentation --include="*.swift"

# 特性の説明を表示している可能性のある箇所を検索
grep -r "ability.*effect" Pokedex/Pokedex/Presentation --include="*.swift"
```

## 修正対象ファイル一覧

### Phase 1: Domain層の拡張

#### 1. `Pokedex/Pokedex/Domain/Entities/Move/MoveEntity.swift`

**現在（28-29行目）:**
```swift
/// 技の説明文（effectテキスト）
let effect: String?
```

**修正後:**
```swift
/// 技の説明文（英語）
let effect: String?
/// 技の説明文（日本語）
let effectJa: String?
```

**また、計算プロパティを追加（93-96行目の後）:**
```swift
/// 現在の言語設定に応じた説明文を返す
func localizedEffect(language: AppLanguage) -> String {
    switch language {
    case .japanese:
        return effectJa ?? effect ?? "説明なし"
    case .english:
        return effect ?? "No description"
    }
}
```

#### 2. `Pokedex/Pokedex/Domain/Entities/Ability/AbilityEntity.swift`（要確認）

**現状確認:**
- `effect`プロパティがあるか？
- `effectJa`プロパティがないか？

**修正内容（MoveEntityと同様）:**
```swift
/// 特性の説明文（英語）
let effect: String?
/// 特性の説明文（日本語）
let effectJa: String?

/// 現在の言語設定に応じた説明文を返す
func localizedEffect(language: AppLanguage) -> String {
    switch language {
    case .japanese:
        return effectJa ?? effect ?? "説明なし"
    case .english:
        return effect ?? "No description"
    }
}
```

### Phase 2: Repository層の修正

#### 3. `Pokedex/Pokedex/Data/Repositories/Move/MoveRepository.swift`

**現在（56-86行目のMoveEntityへの変換部分）:**
```swift
let moves: [MoveEntity] = models.map { model in
    MoveEntity(
        id: model.id,
        name: model.name,
        nameJa: model.nameJa,
        type: PokemonType(slot: 1, name: model.type, nameJa: nil),
        power: model.power,
        accuracy: model.accuracy,
        pp: model.pp,
        damageClass: model.damageClass,
        effect: model.effect,  // ← ここを修正
        machineNumber: nil,
        categories: model.categories,
        priority: model.priority,
        effectChance: model.effectChance,
        target: model.target,
        meta: model.meta.map { ... }
    )
}
```

**修正後:**
```swift
let moves: [MoveEntity] = models.map { model in
    MoveEntity(
        id: model.id,
        name: model.name,
        nameJa: model.nameJa,
        type: PokemonType(slot: 1, name: model.type, nameJa: nil),
        power: model.power,
        accuracy: model.accuracy,
        pp: model.pp,
        damageClass: model.damageClass,
        effect: model.effect,      // 英語
        effectJa: model.effectJa,  // 日本語 ← 追加
        machineNumber: nil,
        categories: model.categories,
        priority: model.priority,
        effectChance: model.effectChance,
        target: model.target,
        meta: model.meta.map { ... }
    )
}
```

**注意:** `fetchMoveDetail`メソッド（行番号要確認）でも同様の変換があるため、そこも修正すること。

#### 4. `Pokedex/Pokedex/Data/Repositories/Ability/AbilityRepository.swift`（要確認）

**同様の修正が必要:**
- AbilityModelからAbilityEntityへの変換箇所を探す
- `effect: model.effect`を見つける
- `effectJa: model.effectJa`を追加する

### Phase 3: Presentation層の修正

#### 5. `Pokedex/Pokedex/Presentation/PokemonDetail/Components/MovesView.swift`

**現在（398-404行目）:**
```swift
// 説明文（展開時のみ表示）
if isExpanded, let effect = detail.effect {
    Text(effect)
        .font(.caption2)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
}
```

**修正後:**
```swift
// 説明文（展開時のみ表示）
if isExpanded {
    Text(detail.localizedEffect(language: localizationManager.currentLanguage))
        .font(.caption2)
        .foregroundColor(.secondary)
        .fixedSize(horizontal: false, vertical: true)
}
```

**注意:** `MoveRow`は既に`@EnvironmentObject private var localizationManager: LocalizationManager`（273行目）を持っているため、追加のインポートは不要。

#### 6. `Pokedex/Pokedex/Presentation/PokemonDetail/Components/AbilitiesView.swift`（要確認）

**現状確認:**
- 特性の説明を表示している箇所があるか？
- どのように表示しているか？

**修正内容（予想）:**
```swift
// 現在
Text(ability.effect)

// 修正後
Text(ability.localizedEffect(language: localizationManager.currentLanguage))
```

**必要に応じて:**
```swift
@EnvironmentObject private var localizationManager: LocalizationManager
```

#### 7. その他の表示箇所（確認事項より発見した箇所）

Phase 1の「確認事項」で発見した全ての箇所について、同様の修正を適用する。

### Phase 4: テストの更新（該当する場合）

#### 8. `Pokedex/PokedexTests/Domain/Entities/MoveEntityTests.swift`（存在する場合）

**追加テスト:**
```swift
func test_localizedEffect_returnsJapaneseWhenLanguageIsJapanese() {
    let move = MoveEntity(
        id: 1,
        name: "tackle",
        nameJa: "たいあたり",
        type: PokemonType(slot: 1, name: "normal", nameJa: "ノーマル"),
        power: 40,
        accuracy: 100,
        pp: 35,
        damageClass: "physical",
        effect: "Inflicts regular damage.",
        effectJa: "通常のダメージを与えます。",
        machineNumber: nil,
        categories: [],
        priority: 0,
        effectChance: nil,
        target: "selected-pokemon",
        meta: nil
    )

    XCTAssertEqual(move.localizedEffect(language: .japanese), "通常のダメージを与えます。")
}

func test_localizedEffect_returnsEnglishWhenLanguageIsEnglish() {
    let move = MoveEntity(
        id: 1,
        name: "tackle",
        nameJa: "たいあたり",
        type: PokemonType(slot: 1, name: "normal", nameJa: "ノーマル"),
        power: 40,
        accuracy: 100,
        pp: 35,
        damageClass: "physical",
        effect: "Inflicts regular damage.",
        effectJa: "通常のダメージを与えます。",
        machineNumber: nil,
        categories: [],
        priority: 0,
        effectChance: nil,
        target: "selected-pokemon",
        meta: nil
    )

    XCTAssertEqual(move.localizedEffect(language: .english), "Inflicts regular damage.")
}

func test_localizedEffect_fallsBackToEffectWhenEffectJaIsNil() {
    let move = MoveEntity(
        id: 1,
        name: "tackle",
        nameJa: "たいあたり",
        type: PokemonType(slot: 1, name: "normal", nameJa: "ノーマル"),
        power: 40,
        accuracy: 100,
        pp: 35,
        damageClass: "physical",
        effect: "Inflicts regular damage.",
        effectJa: nil,  // 日本語がない
        machineNumber: nil,
        categories: [],
        priority: 0,
        effectChance: nil,
        target: "selected-pokemon",
        meta: nil
    )

    XCTAssertEqual(move.localizedEffect(language: .japanese), "Inflicts regular damage.")
}
```

#### 9. `Pokedex/PokedexTests/Data/Repositories/MoveRepositoryTests.swift`（存在する場合）

**確認・修正:**
- MoveEntityの生成箇所で`effectJa`パラメータが追加されているか確認
- 既存のテストが失敗しないか確認

## 実装手順

### ステップ1: 確認作業
1. 「作業前の確認事項」に記載されたコマンドを実行
2. 特性（Ability）の現状を把握
3. 他の表示箇所がないか確認
4. 結果をメモし、修正が必要な箇所をリストアップ

### ステップ2: Domain層の修正
1. `MoveEntity.swift`を修正
   - `effectJa`プロパティを追加
   - `localizedEffect`メソッドを追加
2. 特性が同様の問題を持つ場合、`AbilityEntity.swift`も修正

### ステップ3: Repository層の修正
1. `MoveRepository.swift`を修正
   - 全ての`MoveEntity`生成箇所で`effectJa: model.effectJa`を追加
   - `fetchAllMoves`メソッド（56-86行目）
   - `fetchMoveDetail`メソッド（該当箇所を検索）
2. 特性が同様の問題を持つ場合、`AbilityRepository.swift`も修正

### ステップ4: Presentation層の修正
1. `MovesView.swift`（`MoveRow`）を修正
   - `detail.effect`を`detail.localizedEffect(language: localizationManager.currentLanguage)`に変更
2. 特性が同様の問題を持つ場合、`AbilitiesView.swift`も修正
3. ステップ1で発見した他の箇所も修正

### ステップ5: ビルド確認
```bash
# Xcodeでビルド（Linuxではxcodebuild）
xcodebuild -scheme Pokedex \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  clean build
```

### ステップ6: シミュレータで動作確認
1. アプリをシミュレータにインストール・起動
2. 設定画面で言語を「日本語」に設定
3. 任意のポケモンの詳細画面を開く
4. 技一覧で技を展開し、**日本語の説明**が表示されることを確認
5. 特性についても同様に確認
6. 設定画面で言語を「English」に変更
7. 技・特性の説明が**英語**に切り替わることを確認

### ステップ7: テストの更新（該当する場合）
1. 既存のテストが失敗していないか確認
2. 新しいテストケースを追加（Phase 4参照）
3. テストを実行し、全て通過することを確認

### ステップ8: コミット
```bash
git add -A
git commit -m "feat: 技・特性の説明文を多言語対応

- MoveEntityにeffectJaプロパティとlocalizedEffectメソッドを追加
- AbilityEntityにeffectJaプロパティとlocalizedEffectメソッドを追加
- MoveRepositoryでeffectJaをSwiftDataから取得するように修正
- AbilityRepositoryでeffectJaをSwiftDataから取得するように修正
- MovesViewで言語設定に応じた説明文を表示
- AbilitiesViewで言語設定に応じた説明文を表示
- 日本語・英語の切り替えに対応

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

## チェックリスト

実装完了後、以下を確認：

### コード修正
- [ ] `MoveEntity.swift` - `effectJa`プロパティ追加
- [ ] `MoveEntity.swift` - `localizedEffect`メソッド追加
- [ ] `AbilityEntity.swift` - 同様の修正（必要な場合）
- [ ] `MoveRepository.swift` - 全てのMoveEntity生成箇所で`effectJa`を追加
- [ ] `AbilityRepository.swift` - 同様の修正（必要な場合）
- [ ] `MovesView.swift` - `localizedEffect`を使用するように修正
- [ ] `AbilitiesView.swift` - 同様の修正（必要な場合）
- [ ] その他の表示箇所 - 全て修正

### ビルド・動作確認
- [ ] ビルドが成功する
- [ ] シミュレータでアプリが起動する
- [ ] エラー・警告が出ていない
- [ ] 日本語設定で技の説明が日本語で表示される
- [ ] 日本語設定で特性の説明が日本語で表示される（該当する場合）
- [ ] 英語設定で技の説明が英語で表示される
- [ ] 英語設定で特性の説明が英語で表示される（該当する場合）
- [ ] 言語切り替えが即座に反映される
- [ ] `effectJa`がnilの場合でもクラッシュしない（フォールバックが機能）

### テスト
- [ ] 既存のテストが全て通過する
- [ ] 新しいテストケースを追加した（該当する場合）
- [ ] 新しいテストが全て通過する

### コミット
- [ ] 変更内容をコミットした
- [ ] コミットメッセージが明確
- [ ] リモートにプッシュした

## 注意事項

1. **イニシャライザの修正**
   - `MoveEntity`のイニシャライザに`effectJa`パラメータを追加する際、既存のコードがコンパイルエラーにならないよう、デフォルト値`= nil`を設定すること
   - 例: `effectJa: String? = nil`

2. **Repositoryの全箇所を修正**
   - `MoveRepository`には複数の箇所でMoveEntityを生成している可能性がある
   - `grep`で全箇所を確認: `grep -n "MoveEntity(" Pokedex/Pokedex/Data/Repositories/Move/MoveRepository.swift`

3. **フォールバック処理**
   - `effectJa`が空文字列の場合もある（現在は既にデータが入っているが念のため）
   - `localizedEffect`メソッドで`effectJa?.isEmpty == true`のチェックを追加するか検討

4. **既存のPreview・テストデータ**
   - PreviewProviderで使用されているモックデータも修正が必要
   - テストで使用されているモックデータも修正が必要

5. **特性の優先順位**
   - 技と特性の両方を修正する場合、まず技を完全に修正・テストしてから特性に取り掛かること
   - 同じパターンを2回繰り返すことになるため、最初の修正から学んだことを2回目に活かせる

## 参考情報

### 関連ファイルパス
```
Domain層:
  Pokedex/Pokedex/Domain/Entities/Move/MoveEntity.swift
  Pokedex/Pokedex/Domain/Entities/Ability/AbilityEntity.swift（要確認）

Data層:
  Pokedex/Pokedex/Data/Persistence/MoveModel.swift（確認用、修正不要）
  Pokedex/Pokedex/Data/Repositories/Move/MoveRepository.swift
  Pokedex/Pokedex/Data/Repositories/Ability/AbilityRepository.swift（要確認）

Presentation層:
  Pokedex/Pokedex/Presentation/PokemonDetail/Components/MovesView.swift
  Pokedex/Pokedex/Presentation/PokemonDetail/Components/AbilitiesView.swift（要確認）

Common:
  Pokedex/Pokedex/Common/Localization/LocalizationManager.swift（確認用、修正不要）
```

### LocalizationManager使用例
```swift
// すでに@EnvironmentObjectで注入されている場合
@EnvironmentObject private var localizationManager: LocalizationManager

// 使用
let text = someEntity.localizedEffect(language: localizationManager.currentLanguage)
```

### MoveEntity初期化の例（修正後）
```swift
MoveEntity(
    id: 1,
    name: "tackle",
    nameJa: "たいあたり",
    type: PokemonType(slot: 1, name: "normal", nameJa: "ノーマル"),
    power: 40,
    accuracy: 100,
    pp: 35,
    damageClass: "physical",
    effect: "Inflicts regular damage.",
    effectJa: "通常のダメージを与えます。",  // ← 追加
    machineNumber: nil,
    categories: [],
    priority: 0,
    effectChance: nil,
    target: "selected-pokemon",
    meta: nil
)
```

## トラブルシューティング

### ビルドエラー: "Missing argument for parameter 'effectJa'"
**原因:** 既存のコードで`MoveEntity`を生成している箇所が`effectJa`パラメータを渡していない

**解決策:**
1. `MoveEntity`のイニシャライザで`effectJa: String? = nil`とデフォルト値を設定
2. または、全ての生成箇所で`effectJa`パラメータを追加

### 実行時エラー: "説明なし"が表示される
**原因:** `effectJa`が実際にはnilまたは空文字列

**確認:**
```swift
print("DEBUG: effect = \(detail.effect ?? "nil")")
print("DEBUG: effectJa = \(detail.effectJa ?? "nil")")
```

**解決策:** MoveRepositoryで`effectJa: model.effectJa`が正しく設定されているか確認

### UI: 言語切り替えが反映されない
**原因:** LocalizationManagerの変更を監視していない

**解決策:** Viewで`@EnvironmentObject`または`@ObservedObject`でLocalizationManagerを監視

---

このプロンプトに従って実装することで、技・特性の説明文が言語設定に応じて正しく表示されるようになります。
