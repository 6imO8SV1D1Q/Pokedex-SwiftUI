# Pokedex-SwiftUI v3.0 実装プロンプト集

このドキュメントは、Pokedex-SwiftUI v3.0の実装を段階的に進めるためのプロンプト集です。
各プロンプトをClaude Codeに渡して、順番に実装を進めてください。

---

## フェーズ1: データ層の拡充

### プロンプト1-1: PokéAPI調査

```
Pokedex-SwiftUI v3.0の実装のため、PokéAPIの以下の項目について調査してください：

1. 進化条件（evolution-chain）
   - 取得可能な進化トリガーの種類
   - 進化条件の詳細情報（レベル、アイテム、時間帯など）
   - イーブイ、ニョロモなど分岐進化のレスポンスJSONサンプル

2. フォーム情報（pokemon-form）
   - リージョンフォーム、メガシンカ、フォルムチェンジの識別方法
   - バージョングループとの関連
   - リザードン、ロトムなど複数フォームを持つポケモンのレスポンスJSONサンプル

3. タイプ相性（type）
   - damage_relationsの構造
   - ほのおタイプのレスポンスJSONサンプル

4. 特性詳細（ability）
   - effectとflavor_textの違い
   - 言語対応状況（日本語effectの有無）
   - しんりょくのレスポンスJSONサンプル

5. 生息地情報（pokemon/encounters）
   - データ構造
   - バージョンごとの出現情報
   - ピカチュウのレスポンスJSONサンプル

6. 技情報（move）
   - TM/HM/TR番号の取得方法
   - バージョングループごとの習得方法の違い
   - 10まんボルトのレスポンスJSONサンプル

調査結果をもとに、実装に必要なDTO定義の提案をしてください。
設計書（design_v3.md）のセクション4.3を参考にしてください。
```

---

### プロンプト1-2: Entity実装

```
設計書（design_v3.md）のセクション3.1に従って、以下のEntityを実装してください：

実装するEntity：
1. PokemonForm
   - id, name, formName, types, sprites, stats, abilities
   - isDefault, isMega, isRegional, versionGroup

2. TypeMatchup
   - offensive: 攻撃面の相性
   - defensive: 防御面の相性（4倍、2倍、1/2倍、1/4倍、無効）

3. CalculatedStats
   - 5パターンの実数値（理想、252、無振り、最低、下降）
   - level=50固定
   - 各パターンのconfig（IV、EV、性格補正）

4. EvolutionNode / EvolutionChain
   - ツリー構造の進化ルート
   - 進化条件（trigger, conditions）
   - evolvesTo, evolvesFromの関係

5. PokemonLocation
   - locationName, versionDetails, encounterDetails

6. AbilityDetail
   - id, name, effect, flavorText, isHidden

7. PokemonFlavorText
   - text, language, versionGroup

8. MoveEntityの拡張
   - displayPower, displayAccuracy, displayPP
   - categoryIcon

実装場所：
- Pokedex/Domain/Entities/

注意事項：
- 全てのEntityはEquatableに準拠
- 必要に応じてIdentifiableに準拠
- 設計書の定義を正確に反映してください
```

---

### プロンプト1-3: Repository Protocol拡張

```
設計書（design_v3.md）のセクション3.3に従って、Repository Protocolを拡張してください：

1. PokemonRepositoryProtocol の拡張
   既存のProtocolに以下のメソッドを追加：
   - fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm]
   - fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation]

2. TypeRepositoryProtocol（新規作成）
   - fetchTypeDetail(type: PokemonType) async throws -> TypeDetail
   - TypeDetail structも定義

3. AbilityRepositoryProtocol（新規作成）
   - fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail

実装場所：
- Pokedex/Domain/Interfaces/Repositories/

注意事項：
- 既存のPokemonRepositoryProtocolを壊さないように拡張
- 新規Protocolは別ファイルで作成
```

---

### プロンプト1-4: DTO実装

```
プロンプト1-1のPokéAPI調査結果をもとに、以下のDTOを実装してください：

実装するDTO：
1. PokemonFormDTO
   - PokéAPIの/pokemon/{id}レスポンスのforms部分に対応
   - Codableに準拠

2. TypeDetailDTO
   - PokéAPIの/type/{id}レスポンスに対応
   - damage_relationsの構造を正確に反映

3. AbilityDetailDTO
   - PokéAPIの/ability/{id}レスポンスに対応
   - effectEntries, flavorTextEntriesを含む

4. PokemonLocationDTO
   - PokéAPIの/pokemon/{id}/encountersレスポンスに対応
   - locationArea, versionDetails, encounterDetailsを含む

実装場所：
- Pokedex/Data/DTOs/

注意事項：
- 全てのDTOはCodableに準拠
- プロパティ名はPokéAPIのレスポンスキーと一致させる（snake_caseはcamelCaseに変換）
- CodingKeysを使用してマッピング
- 設計書のセクション4.3を参考にしてください
```

---

### プロンプト1-5: API Client拡張

```
設計書（design_v3.md）のセクション4.2に従って、PokemonAPIClientを拡張してください：

1. PokemonAPIClientProtocol の拡張
   以下のメソッドを追加：
   - fetchPokemonForms(pokemonId: Int) async throws -> [PokemonFormDTO]
   - fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocationDTO]
   - fetchTypeDetail(type: PokemonType) async throws -> TypeDetailDTO
   - fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetailDTO

2. PokemonAPIEndpoint の拡張
   以下のケースを追加：
   - case pokemonForms(pokemonId: Int)
   - case pokemonLocations(pokemonId: Int)
   - case typeDetail(typeId: Int)
   - case abilityDetail(abilityId: Int)
   
   各ケースのurlを正しく実装してください。

3. PokemonAPIClient の実装
   - 追加したProtocolメソッドを実装
   - URLSessionを使用してAPIリクエスト
   - エラーハンドリング（networkError, decodingError）
   - 既存のリトライロジックを活用

実装場所：
- Pokedex/Data/Network/

注意事項：
- 既存のAPIClientの実装パターンに従う
- async/awaitを使用
- 適切なエラーハンドリング
```

---

### プロンプト1-6: Cache実装

```
設計書（design_v3.md）のセクション4.4に従って、以下のCacheを実装してください：

実装するCache：
1. FormCache
   - FormCacheProtocol（Actor）
   - get(pokemonId: Int) -> [PokemonForm]?
   - set(pokemonId: Int, forms: [PokemonForm])
   - clear()

2. TypeCache
   - TypeCacheProtocol（Actor）
   - get(type: PokemonType) -> TypeDetail?
   - set(type: PokemonType, detail: TypeDetail)
   - clear()

3. AbilityCache
   - AbilityCacheProtocol（Actor）
   - get(abilityId: Int) -> AbilityDetail?
   - set(abilityId: Int, detail: AbilityDetail)
   - clear()

4. LocationCache
   - LocationCacheProtocol（Actor）
   - get(pokemonId: Int) -> [PokemonLocation]?
   - set(pokemonId: Int, locations: [PokemonLocation])
   - clear()

実装場所：
- Pokedex/Data/Cache/

注意事項：
- 全てのCacheはActorで実装（スレッドセーフ）
- Protocolと実装クラスを分離
- 既存のMoveCacheの実装パターンを参考にする
```

---

### プロンプト1-7: Repository実装

```
設計書（design_v3.md）のセクション4.1に従って、Repositoryを実装してください：

1. PokemonRepository の拡張
   以下のメソッドを実装：
   - fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm]
   - fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation]
   
   実装パターン：
   - キャッシュチェック → APIから取得 → キャッシュに保存
   - DTOからEntityへの変換

2. TypeRepository（新規作成）
   - TypeRepositoryProtocolの実装
   - fetchTypeDetail(type: PokemonType) async throws -> TypeDetail
   - TypeCacheを活用

3. AbilityRepository（新規作成）
   - AbilityRepositoryProtocolの実装
   - fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail
   - AbilityCacheを活用

実装場所：
- Pokedex/Data/Repositories/

注意事項：
- 既存のPokemonRepositoryの実装パターンに従う
- キャッシュ機構を適切に実装
- エラーハンドリング
- DTOからEntityへの変換ロジックを正確に実装
```

---

## フェーズ2: Domain層の実装

### プロンプト2-1: CalculateStatsUseCase実装

```
設計書（design_v3.md）のセクション3.2.2に従って、CalculateStatsUseCaseを実装してください：

機能：
- ポケモンの種族値から実数値を計算
- レベル50固定
- 5パターン（理想、252、無振り、最低、下降）

計算式：
- HP: floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + level + 10
- その他: floor((floor(((base * 2 + IV + floor(EV / 4)) * level) / 100) + 5) * nature)

性格補正：
- boosted: 1.1倍
- neutral: 1.0倍
- hindered: 0.9倍

実装するもの：
1. CalculateStatsUseCaseProtocol
2. CalculateStatsUseCase
   - execute(baseStats: [PokemonStat]) -> CalculatedStats
   - calculatePattern(...) private メソッド
   - calculateHP(...) private メソッド
   - calculateStat(...) private メソッド

実装場所：
- Pokedex/Domain/UseCases/

テスト：
- CalculateStatsUseCaseTests も実装してください
- フシギダネ（HP45, 攻撃49など）で各パターンの実数値を検証
- テスト場所: PokedexTests/Domain/UseCases/

注意事項：
- 計算式を正確に実装
- 整数演算に注意（切り捨て処理）
```

---

### プロンプト2-2: FetchTypeMatchupUseCase実装

```
設計書（design_v3.md）のセクション3.2.3に従って、FetchTypeMatchupUseCaseを実装してください：

機能：
- ポケモンのタイプからタイプ相性を計算
- 攻撃面：効果ばつぐんになるタイプ
- 防御面：4倍、2倍、1/2倍、1/4倍、無効

実装ポイント：
- 複合タイプの場合、倍率を掛け合わせる（例: ほのお・ひこう → いわ4倍弱点）
- 結果はタイプ番号順にソート
- TypeRepositoryを使用してタイプ詳細を取得
- TaskGroupで並列取得

実装するもの：
1. FetchTypeMatchupUseCaseProtocol
2. FetchTypeMatchupUseCase
   - execute(types: [PokemonType]) async throws -> TypeMatchup
   - calculateOffensiveMatchup(...) private メソッド
   - calculateDefensiveMatchup(...) private メソッド

実装場所：
- Pokedex/Domain/UseCases/

テスト：
- FetchTypeMatchupUseCaseTests も実装してください
- 単タイプ（ほのお）の相性を検証
- 複合タイプ（ほのお・ひこう）の4倍弱点を検証
- テスト場所: PokedexTests/Domain/UseCases/

注意事項：
- MockTypeRepositoryを使用してテスト
- 倍率計算ロジックを正確に実装（0.0, 0.25, 0.5, 1.0, 2.0, 4.0）
```

---

### プロンプト2-3: FetchPokemonFormsUseCase実装

```
設計書（design_v3.md）のセクション3.2.1に従って、FetchPokemonFormsUseCaseを実装してください：

機能：
- ポケモンのフォーム一覧を取得
- バージョングループでフィルタリング

実装するもの：
1. FetchPokemonFormsUseCaseProtocol
2. FetchPokemonFormsUseCase
   - execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonForm]
   - filterByVersionGroup(...) private メソッド

フィルタリングロジック：
- versionGroupがnilの場合：全フォームを返す
- versionGroupが指定されている場合：
  - メガシンカ：X-Y以降のみ
  - アローラフォーム：サン・ムーン以降のみ
  - ガラルフォーム：ソード・シールド以降のみ
  - など、バージョンごとの存在判定

実装場所：
- Pokedex/Domain/UseCases/

テスト：
- FetchPokemonFormsUseCaseTests も実装してください
- リザードン（通常、メガX、メガY）でバージョングループフィルタを検証
- テスト場所: PokedexTests/Domain/UseCases/

注意事項：
- PokemonRepositoryProtocolを使用
- バージョングループのマッピングロジックは将来的に拡張可能にする
```

---

### プロンプト2-4: その他UseCase実装

```
設計書（design_v3.md）のセクション3.2.4〜3.2.7に従って、以下のUseCaseを実装してください：

1. FetchEvolutionChainUseCaseの拡張
   - 既存のUseCaseを拡張
   - execute(speciesId: Int) async throws -> EvolutionChain
   - buildEvolutionNode(from:) private メソッドで再帰的にツリー構築
   - 進化条件をEvolutionConditionに変換

2. FetchPokemonLocationsUseCase
   - execute(pokemonId: Int, versionGroup: String?) async throws -> [PokemonLocation]
   - belongsToVersionGroup(...) private メソッドでフィルタリング

3. FetchAbilityDetailUseCase
   - execute(abilityId: Int) async throws -> AbilityDetail
   - シンプルなRepository呼び出し

4. FetchFlavorTextUseCase
   - execute(speciesId: Int, versionGroup: String?) async throws -> PokemonFlavorText?
   - バージョングループに応じた図鑑説明を選択
   - 日本語（"ja"）の説明文を優先

実装場所：
- Pokedex/Domain/UseCases/

テスト：
- 各UseCaseのテストも実装
- テスト場所: PokedexTests/Domain/UseCases/

注意事項：
- 各UseCaseは単一責任の原則に従う
- エラーハンドリングを適切に実装
```

---

## フェーズ3: Presentation層の基本機能実装

### プロンプト3-1: PokemonDetailViewModel拡張

```
設計書（design_v3.md）のセクション5.1に従って、PokemonDetailViewModelを拡張してください：

新規プロパティ：
- availableForms: [PokemonForm]
- selectedForm: PokemonForm?
- typeMatchup: TypeMatchup?
- calculatedStats: CalculatedStats?
- evolutionChain: EvolutionChain?
- locations: [PokemonLocation]
- abilityDetails: [Int: AbilityDetail]
- flavorText: PokemonFlavorText?
- isSectionExpanded: [String: Bool]

新規メソッド：
1. loadPokemonDetail(id: Int) async
   - 並列でデータ取得（async let使用）
   - pokemon, forms, evolution, locations, flavorTextを同時取得
   - 取得後にloadFormDependentData()を呼び出し

2. selectForm(_ form: PokemonForm) async
   - selectedFormを更新
   - loadFormDependentData()を呼び出し

3. loadFormDependentData() async
   - タイプ相性を取得（FetchTypeMatchupUseCase）
   - 実数値を計算（CalculateStatsUseCase）
   - 特性詳細を取得（loadAbilityDetails）

4. loadAbilityDetails(abilities:) async
   - TaskGroupで並列取得
   - abilityDetailsに格納

5. toggleSection(_ sectionId: String)
   - セクションの展開/折りたたみ切り替え

依存性注入：
- 8つのUseCaseをinitで受け取る
- versionGroup: String?も受け取る

実装場所：
- Pokedex/Presentation/PokemonDetail/

テスト：
- PokemonDetailViewModelTests も実装
- loadPokemonDetail成功ケース
- selectForm時のデータ更新
- toggleShiny
- テスト場所: PokedexTests/Presentation/

注意事項：
- @MainActor属性を付与
- 並列処理を適切に実装
- エラーハンドリング
```

---

### プロンプト3-2: フォルム切り替えUI実装

```
設計書（design_v3.md）のセクション5.2.2に従って、PokemonFormSelectorSectionを実装してください：

実装内容：
1. PokemonFormSelectorSection
   - props: forms, selectedForm, onFormSelect
   - Menuでドロップダウン表示
   - 各フォームにボタン配置
   - 選択中のフォームにチェックマーク（Image(systemName: "checkmark")）

UI構成：
```
VStack(alignment: .leading, spacing: 8) {
    Text("フォルム")
        .font(.headline)
    
    Menu {
        ForEach(forms) { form in
            Button {
                onFormSelect(form)
            } label: {
                HStack {
                    Text(form.formName)
                    if form.id == selectedForm?.id {
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    } label: {
        // ドロップダウンボタン
    }
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- formNameの表示を工夫（"normal" → "通常"、"alola" → "アローラ"など）
- SwiftUIのMenu標準スタイルを使用
```

---

### プロンプト3-3: 基本情報セクション拡張

```
既存のPokemonBasicInfoSectionに性別比とたまごグループを追加してください：

追加表示項目：
1. 性別比
   - 表示形式: HStack { Text("♂ 87.5% / ♀ 12.5%") }
   - 性別不明の場合: Text("性別不明")
   - カラー: ♂は青系、♀はピンク系

2. たまごグループ
   - 複数の場合は全て表示
   - 例: Text("すいちゅう1、りくじょう")
   - 未発見の場合: Text("みはっけん")

表示位置：
- 身長・体重の下に追加
- 既存のレイアウトに合わせる

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/PokemonBasicInfoSection.swift

注意事項：
- 既存のUIスタイルに統一
- VoiceOver対応（アクセシビリティ）
```

---

## フェーズ4: 高度な表示機能実装

### プロンプト4-1: タイプ相性表示実装

```
設計書（design_v3.md）のセクション5.2.3に従って、TypeMatchupViewを実装してください：

表示内容：
【攻撃面】
- 効果ばつぐん: タイプのリスト

【防御面】
- 効果ばつぐん（4倍）: 赤色
- 効果ばつぐん（2倍）: オレンジ色
- いまひとつ（1/2倍）: 緑色
- いまひとつ（1/4倍）: 緑色
- 効果なし: 灰色

実装するコンポーネント：
1. TypeMatchupView
   - VStackで攻撃面・防御面を表示
   - 各倍率グループをHStackで表示
   - TypeListViewを使用してタイプ一覧を表示

2. TypeListView
   - FlowLayoutでタイプバッジを横並び
   - 自動折り返し

UI構成：
```
VStack(alignment: .leading, spacing: 16) {
    // 攻撃面
    VStack(alignment: .leading, spacing: 8) {
        Text("【攻撃面】").font(.subheadline).fontWeight(.bold)
        HStack {
            Text("効果ばつぐん:").foregroundColor(.secondary)
            TypeListView(types: matchup.offensive.superEffective)
        }
    }
    
    Divider()
    
    // 防御面
    VStack(alignment: .leading, spacing: 8) {
        Text("【防御面】").font(.subheadline).fontWeight(.bold)
        // 各倍率グループ
    }
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 等倍は表示しない
- タイプはタイプ番号順に表示
- 空の倍率グループは表示しない
```

---

### プロンプト4-2: 進化ルート表示実装（パート1）

```
設計書（design_v3.md）のセクション5.2.4に従って、進化ルート表示の基本構造を実装してください：

今回実装するもの：
1. EvolutionChainView
   - ScrollView(.horizontal)で横スクロール対応
   - buildEvolutionTreeView(node:)メソッドで再帰的に構築

2. EvolutionNodeCard
   - ポケモン画像（AsyncImage、80x80）
   - 図鑑番号（#001形式）
   - ポケモン名
   - タイプバッジ（小サイズ）
   - タップでポケモン詳細画面に遷移

UI構成：
```
ScrollView(.horizontal) {
    HStack(spacing: 0) {
        buildEvolutionTreeView(node: chain.rootNode)
    }
    .padding()
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 今回は通常進化（一直線）のみ実装
- 分岐進化は次のプロンプトで実装
- タップ時の画面遷移ロジックも実装
```

---

### プロンプト4-3: 進化ルート表示実装（パート2）

```
前回実装したEvolutionChainViewに分岐進化の表示を追加してください：

実装内容：
1. buildEvolutionTreeView(node:)の拡張
   - 進化先が1つの場合：横並び（HStack）
   - 進化先が複数の場合：縦並び（VStack）で分岐表示

2. EvolutionArrow
   - 矢印アイコン（Image(systemName: "arrow.right")）
   - 進化条件テキスト（Lv.16、みずのいし、など）
   - conditionTextの生成ロジック

分岐進化の表示例：
```
HStack(alignment: .center, spacing: 0) {
    EvolutionNodeCard(node: イーブイ)
    
    VStack(spacing: 8) {
        HStack {
            EvolutionArrow(edge: みずのいし)
            EvolutionNodeCard(node: シャワーズ)
        }
        HStack {
            EvolutionArrow(edge: かみなりのいし)
            EvolutionNodeCard(node: サンダース)
        }
        // ... 他の進化先
    }
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/EvolutionChainView.swift

注意事項：
- 進化条件を日本語で表示（"level-up" → "Lv.XX"など）
- 複数の条件がある場合は全て表示
- 横スクロールで全体が見えるようにする
```

---

### プロンプト4-4: 図鑑説明と生息地表示実装

```
図鑑説明と生息地の表示を実装してください：

1. FlavorTextView
   - Text(flavorText.text)
   - font: .body
   - padding適用
   - データがない場合は空白

2. LocationsView
   - VStack(alignment: .leading)
   - 生息地名をカンマ区切りで表示
   - 複数バージョンの出現情報がある場合は統合
   - データがない場合: Text("生息地不明")

UI構成：
```
// FlavorTextView
Text(flavorText.text)
    .font(.body)
    .padding()

// LocationsView
VStack(alignment: .leading, spacing: 8) {
    ForEach(locations, id: \.locationName) { location in
        Text(location.locationName)
    }
}
.padding()
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 生息地名の重複を除去
- 見やすいレイアウト
```

---

## フェーズ5: 実数値と特性表示実装

### プロンプト5-1: 実数値表示実装

```
設計書（design_v3.md）のセクション5.2.5に従って、CalculatedStatsViewを実装してください：

表示形式：
- 表形式（5列）
- ヘッダー行：理想 / 252 / 無振り / 最低 / 下降
- サブヘッダー：252↑ / 252 / 31-0 / 0-0 / 0-0↓
- データ行：HP / 攻撃 / 防御 / 特攻 / 特防 / 素早さ

実装するコンポーネント：
1. CalculatedStatsView
   - ヘッダー行（VStackで2段）
   - Divider
   - 6つのStatsRow

2. StatsRow
   - ラベル（width: 80）
   - 5つの数値（frame(maxWidth: .infinity)で均等配置）

3. PatternConfig.displayTextの拡張
   - "31-252↑"のような表示形式

UI構成：
```
VStack(spacing: 0) {
    // ヘッダー
    HStack(spacing: 0) {
        Text("").frame(width: 80)
        ForEach(patterns) { pattern in
            VStack {
                Text(pattern.displayName)
                Text(pattern.config.displayText)
            }
            .frame(maxWidth: .infinity)
        }
    }
    .background(Color(.systemGray6))
    
    // データ行
    StatsRow(label: "HP", values: patterns.map { $0.hp })
    // ...
}
.font(.system(.body, design: .monospaced))
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 等幅フォント使用（.monospaced）
- 列の幅を統一
- 左から右へ数値が高い順
```

---

### プロンプト5-2: 特性表示実装

```
設計書（design_v3.md）のセクション5.2.6に従って、AbilitiesViewを実装してください：

表示内容：
【通常特性】
- 特性名（font: .headline）
- 特性の説明文（effect、font: .caption、英語）

【隠れ特性】
- 特性名
- 特性の説明文

実装するコンポーネント：
1. AbilitiesView
   - 通常特性のVStack
   - 隠れ特性のVStack
   - normalAbilities、hiddenAbilitiesの算出プロパティ

2. AbilityCard
   - 特性名
   - 説明文（detailがある場合）
   - ローディング表示（detailがない場合）
   - 背景: Color(.systemGray6)
   - cornerRadius: 8

UI構成：
```
VStack(alignment: .leading, spacing: 16) {
    // 通常特性
    VStack(alignment: .leading, spacing: 8) {
        Text("【通常特性】")
        ForEach(normalAbilities) { ability in
            AbilityCard(ability: ability, detail: abilityDetails[ability.id])
        }
    }
    
    // 隠れ特性
    if !hiddenAbilities.isEmpty {
        VStack(alignment: .leading, spacing: 8) {
            Text("【隠れ特性】")
            ForEach(hiddenAbilities) { ability in
                AbilityCard(ability: ability, detail: abilityDetails[ability.id])
            }
        }
    }
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 特性詳細がない場合の表示（"読み込み中..."）
- 説明文が長い場合の折り返し
```

---

## フェーズ6: 技一覧表示実装

### プロンプト6-1: 技一覧表示実装

```
設計書（design_v3.md）のセクション5.2.7に従って、MovesViewを拡張してください：

表示セクション（習得方法別）：
1. レベルアップ（レベル順）
2. わざマシン（TM）（番号順）
3. わざレコード（TR）（番号順）
4. ひでんマシン（HM）（番号順）
5. タマゴわざ（名前順）
6. おしえわざ（名前順）

実装するコンポーネント：
1. MovesView
   - 各習得方法のフィルタリング
   - levelUpMoves, tmMoves, trMoves, hmMoves, eggMoves, tutorMovesの算出プロパティ

2. MoveSection
   - title（【レベルアップ】など）
   - ForEachでMoveRowを配置
   - Divider

3. MoveRow
   - 習得情報（width: 50）
   - 技名（width: 100）
   - タイプバッジ（width: 60、small size）
   - 分類（width: 40）
   - 威力（width: 40、右寄せ）
   - 命中（width: 40、右寄せ）
   - PP（width: 30、右寄せ）

UI構成：
```
VStack(spacing: 0) {
    if !levelUpMoves.isEmpty {
        MoveSection(title: "【レベルアップ】", moves: levelUpMoves)
    }
    // ... 他のセクション
}
```

習得方法の判定：
- learnMethod プロパティを使用
- machineType プロパティでTM/HM/TRを区別
- machineNumber プロパティで番号を表示

実装場所：
- Pokedex/Presentation/PokemonDetail/Components/

注意事項：
- 威力・命中・PPが null の場合は "-" 表示
- 各セクションは習得方法がある場合のみ表示
- font: .caption で統一
```

---

## フェーズ7: 共通コンポーネントとUI統合

### プロンプト7-1: 共通コンポーネント実装

```
設計書（design_v3.md）のセクション5.2.8に従って、共通コンポーネントを実装してください：

1. ExpandableSection
   - title: String
   - isExpanded: Bool
   - onToggle: () -> Void
   - content: @ViewBuilder

   UI構成：
   ```
   VStack(spacing: 0) {
       Button(action: onToggle) {
           HStack {
               Text(title).font(.headline)
               Spacer()
               Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
           }
           .padding()
           .background(Color(.systemGray6))
       }
       
       if isExpanded {
           content()
       }
   }
   ```

2. FlowLayout (Layout protocol準拠)
   - spacing: CGFloat
   - sizeThatFits(proposal:subviews:cache:)
   - placeSubviews(in:proposal:subviews:cache:)
   
   タイプバッジが横に並び、幅が足りなくなったら次の行に折り返す

実装場所：
- Pokedex/Presentation/Common/Components/

注意事項：
- ExpandableSectionは折りたたみアニメーション付き
- FlowLayoutはiOS 16+のLayout protocolを使用
```

---

### プロンプト7-2: PokemonDetailView統合

```
設計書（design_v3.md）のセクション5.2.1に従って、PokemonDetailViewに全セクションを統合してください：

表示順序（上から）：
1. ポケモン画像・基本情報（常に表示）
2. フォルムドロップダウン（ExpandableSection）
3. タイプ相性（ExpandableSection）
4. 図鑑説明（ExpandableSection）
5. 進化ルート（ExpandableSection）
6. 生息地（ExpandableSection）
7. 種族値表示（ExpandableSection）
8. 実数値（ExpandableSection）
9. 特性（ExpandableSection）
10. 覚える技（ExpandableSection）

実装内容：
```
ScrollView {
    VStack(spacing: 0) {
        // 1. 基本情報
        PokemonBasicInfoSection(...)
        
        // 2. フォルム
        if !viewModel.availableForms.isEmpty {
            PokemonFormSelectorSection(...)
        }
        
        // 3. タイプ相性
        if let matchup = viewModel.typeMatchup {
            ExpandableSection(
                title: "タイプ相性",
                isExpanded: viewModel.isSectionExpanded["typeMatchup"] ?? true,
                onToggle: { viewModel.toggleSection("typeMatchup") }
            ) {
                TypeMatchupView(matchup: matchup)
            }
        }
        
        // ... 他のセクション
    }
}
.task {
    await viewModel.loadPokemonDetail(id: pokemonId)
}
```

実装場所：
- Pokedex/Presentation/PokemonDetail/PokemonDetailView.swift

注意事項：
- 全セクションはデフォルトで展開
- データがない場合の表示も考慮（生息地不明など）
- ローディング状態、エラー状態の表示
```

---

## フェーズ8: DIContainer更新とテスト実装

### プロンプト8-1: DIContainer更新

```
設計書（design_v3.md）のセクション6に従って、DIContainerを更新してください：

追加項目：
1. 新規キャッシュの登録
   ```
   private let formCache: FormCacheProtocol
   private let typeCache: TypeCacheProtocol
   private let abilityCache: AbilityCacheProtocol
   private let locationCache: LocationCacheProtocol
   ```

2. 新規リポジトリの登録
   ```
   private let typeRepository: TypeRepositoryProtocol
   private let abilityRepository: AbilityRepositoryProtocol
   ```

3. init()の更新
   - 新規キャッシュの初期化
   - 新規リポジトリの初期化
   - PokemonRepositoryに新規キャッシュを注入

4. 新規UseCaseのファクトリメソッド
   ```
   func makeFetchPokemonFormsUseCase() -> FetchPokemonFormsUseCaseProtocol
   func makeFetchTypeMatchupUseCase() -> FetchTypeMatchupUseCaseProtocol
   func makeCalculateStatsUseCase() -> CalculateStatsUseCaseProtocol
   func makeFetchEvolutionChainUseCase() -> FetchEvolutionChainUseCaseProtocol
   func makeFetchPokemonLocationsUseCase() -> FetchPokemonLocationsUseCaseProtocol
   func makeFetchAbilityDetailUseCase() -> FetchAbilityDetailUseCaseProtocol
   func makeFetchFlavorTextUseCase() -> FetchFlavorTextUseCaseProtocol
   ```

5. ViewModelファクトリメソッドの更新
   ```
   func makePokemonDetailViewModel(versionGroup: String?) -> PokemonDetailViewModel {
       PokemonDetailViewModel(
           fetchPokemonDetailUseCase: makeFetchPokemonDetailUseCase(),
           fetchPokemonFormsUseCase: makeFetchPokemonFormsUseCase(),
           fetchTypeMatchupUseCase: makeFetchTypeMatchupUseCase(),
           calculateStatsUseCase: makeCalculateStatsUseCase(),
           fetchEvolutionChainUseCase: makeFetchEvolutionChainUseCase(),
           fetchPokemonLocationsUseCase: makeFetchPokemonLocationsUseCase(),
           fetchAbilityDetailUseCase: makeFetchAbilityDetailUseCase(),
           fetchFlavorTextUseCase: makeFetchFlavorTextUseCase(),
           versionGroup: versionGroup
       )
   }
   ```

実装場所：
- Pokedex/Application/DIContainer.swift

注意事項：
- シングルトンパターンを維持
- 依存関係を正しく注入
```

---

### プロンプト8-2: ユニットテスト実装（Domain層）

```
設計書（design_v3.md）のセクション7.1.1に従って、Domain層のユニットテストを実装してください：

実装するテスト：
1. CalculateStatsUseCaseTests
   ```
   - testCalculateStats_理想個体()
   - testCalculateStats_252()
   - testCalculateStats_無振り()
   - testCalculateStats_最低()
   - testCalculateStats_下降()
   - testCalculateStats_全パターン()
   - testCalculateHP_正しい計算()
   - testCalculateStat_性格補正()
   ```

2. FetchTypeMatchupUseCaseTests
   ```
   - testFetchTypeMatchup_単タイプ()
   - testFetchTypeMatchup_複合タイプ_4倍弱点()
   - testFetchTypeMatchup_複合タイプ_4倍耐性()
   - testOffensiveMatchup_集約()
   - testDefensiveMatchup_倍率計算()
   - testDefensiveMatchup_タイプ番号順()
   ```

3. FetchPokemonFormsUseCaseTests
   ```
   - testFetchForms_バージョングループなし()
   - testFetchForms_バージョングループフィルタ_XY()
   - testFetchForms_バージョングループフィルタ_赤緑()
   ```

テスト実装のポイント：
- Mockオブジェクトを使用（MockPokemonRepository、MockTypeRepository）
- 実際のポケモンデータで検証（フシギダネ、リザードンなど）
- エッジケースもテスト

実装場所：
- PokedexTests/Domain/UseCases/

注意事項：
- XCTestを使用
- @testable import Pokedex
- 各テストケースは独立して実行可能
```

---

### プロンプト8-3: ユニットテスト実装（Presentation層）

```
設計書（design_v3.md）のセクション7.1.2に従って、Presentation層のユニットテストを実装してください：

実装するテスト：
PokemonDetailViewModelTests
```
@MainActor
final class PokemonDetailViewModelTests: XCTestCase {
    var sut: PokemonDetailViewModel!
    var mockFetchPokemonDetailUseCase: MockFetchPokemonDetailUseCase!
    var mockFetchPokemonFormsUseCase: MockFetchPokemonFormsUseCase!
    var mockFetchTypeMatchupUseCase: MockFetchTypeMatchupUseCase!
    var mockCalculateStatsUseCase: MockCalculateStatsUseCase!
    // ... 他のMockUseCases
    
    override func setUp() {
        super.setUp()
        // Mockオブジェクトの初期化
        // ViewModelの初期化
    }
    
    // テストケース
    func testLoadPokemonDetail_成功()
    func testLoadPokemonDetail_エラー()
    func testSelectForm_タイプ相性更新()
    func testSelectForm_実数値更新()
    func testSelectForm_特性詳細更新()
    func testToggleShiny()
    func testToggleSection()
    func testLoadAbilityDetails_並列取得()
}
```

Mock実装：
- 各UseCaseのMockを作成
- resultプロパティで成功/失敗を制御

実装場所：
- PokedexTests/Presentation/PokemonDetail/

注意事項：
- @MainActor属性を忘れずに
- 非同期テストはasync関数で実装
- Mockの戻り値を適切に設定
```

---

### プロンプト8-4: Data層のユニットテスト実装

```
Data層のキャッシュとリポジトリのユニットテストを実装してください：

実装するテスト：

1. FormCacheTests
   ```
   final class FormCacheTests: XCTestCase {
       var sut: FormCache!
       
       override func setUp() async throws {
           sut = FormCache()
       }
       
       func testGet_キャッシュなし() async {
           // When
           let result = await sut.get(pokemonId: 1)
           
           // Then
           XCTAssertNil(result)
       }
       
       func testSet_Get_正常に保存と取得() async {
           // Given
           let forms = [PokemonForm(/* テストデータ */)]
           
           // When
           await sut.set(pokemonId: 1, forms: forms)
           let result = await sut.get(pokemonId: 1)
           
           // Then
           XCTAssertEqual(result?.count, forms.count)
       }
       
       func testClear_全削除() async {
           // Given
           await sut.set(pokemonId: 1, forms: [/* データ */])
           
           // When
           await sut.clear()
           
           // Then
           let result = await sut.get(pokemonId: 1)
           XCTAssertNil(result)
       }
   }
   ```

2. TypeCacheTests
   - testGet_キャッシュなし()
   - testSet_Get_正常に保存と取得()
   - testClear_全削除()

3. AbilityCacheTests
   - testGet_キャッシュなし()
   - testSet_Get_正常に保存と取得()
   - testClear_全削除()

4. LocationCacheTests
   - testGet_キャッシュなし()
   - testSet_Get_正常に保存と取得()
   - testClear_全削除()

5. PokemonRepositoryTests（拡張）
   ```
   func testFetchPokemonForms_キャッシュヒット() async throws {
       // Given: キャッシュにデータあり
       let cachedForms = [PokemonForm(/* データ */)]
       await mockFormCache.set(pokemonId: 1, forms: cachedForms)
       
       // When
       let result = try await sut.fetchPokemonForms(pokemonId: 1)
       
       // Then
       XCTAssertEqual(result, cachedForms)
       XCTAssertEqual(mockApiClient.fetchPokemonFormsCallCount, 0)
   }
   
   func testFetchPokemonForms_キャッシュミス() async throws {
       // Given: キャッシュにデータなし
       let apiForms = [PokemonForm(/* データ */)]
       mockApiClient.fetchPokemonFormsResult = .success(apiForms)
       
       // When
       let result = try await sut.fetchPokemonForms(pokemonId: 1)
       
       // Then
       XCTAssertEqual(result, apiForms)
       XCTAssertEqual(mockApiClient.fetchPokemonFormsCallCount, 1)
       
       // キャッシュに保存されたか確認
       let cached = await mockFormCache.get(pokemonId: 1)
       XCTAssertEqual(cached, apiForms)
   }
   
   func testFetchPokemonLocations_成功() async throws
   ```

6. TypeRepositoryTests
   - testFetchTypeDetail_キャッシュヒット()
   - testFetchTypeDetail_キャッシュミス()
   - testFetchTypeDetail_APIエラー()

7. AbilityRepositoryTests
   - testFetchAbilityDetail_キャッシュヒット()
   - testFetchAbilityDetail_キャッシュミス()
   - testFetchAbilityDetail_APIエラー()

実装場所：
- PokedexTests/Data/Cache/
- PokedexTests/Data/Repositories/

注意事項：
- Actorのテストは async 関数で実装
- MockAPIClientを使用してネットワークをモック
- キャッシュヒット/ミスの両方をテスト
```

---

### プロンプト8-5: 統合テスト実装

```
設計書（design_v3.md）のセクション7.2に従って、統合テストを実装してください：

実装するテスト：

1. FormSwitchingIntegrationTests
   ```
   @MainActor
   final class FormSwitchingIntegrationTests: XCTestCase {
       var container: DIContainer!
       var viewModel: PokemonDetailViewModel!
       
       override func setUp() {
           super.setUp()
           container = DIContainer.shared
       }
       
       func testFormSwitching_通常からメガシンカへ切り替え() async throws {
           // Given: X-Yバージョングループを選択
           viewModel = container.makePokemonDetailViewModel(versionGroup: "x-y")
           
           // When: リザードンのデータをロード
           await viewModel.loadPokemonDetail(id: 6)
           
           // Then: 通常フォームが選択されている
           XCTAssertNotNil(viewModel.pokemon)
           XCTAssertEqual(viewModel.selectedForm?.isDefault, true)
           XCTAssertFalse(viewModel.selectedForm?.isMega ?? true)
           
           // 通常フォームのタイプを確認（ほのお・ひこう）
           XCTAssertEqual(viewModel.selectedForm?.types.count, 2)
           XCTAssertTrue(viewModel.selectedForm?.types.contains(.fire) ?? false)
           XCTAssertTrue(viewModel.selectedForm?.types.contains(.flying) ?? false)
           
           // When: メガリザードンXに切り替え
           let megaXForm = viewModel.availableForms.first { 
               $0.isMega && $0.formName.contains("mega-x") 
           }
           XCTAssertNotNil(megaXForm, "メガリザードンXが見つかりません")
           
           await viewModel.selectForm(megaXForm!)
           
           // Then: メガフォームに切り替わっている
           XCTAssertTrue(viewModel.selectedForm?.isMega ?? false)
           
           // タイプが変化している（ほのお・ドラゴン）
           XCTAssertTrue(viewModel.selectedForm?.types.contains(.fire) ?? false)
           XCTAssertTrue(viewModel.selectedForm?.types.contains(.dragon) ?? false)
           XCTAssertFalse(viewModel.selectedForm?.types.contains(.flying) ?? false)
           
           // タイプ相性が更新されている
           XCTAssertNotNil(viewModel.typeMatchup)
           
           // 実数値が更新されている
           XCTAssertNotNil(viewModel.calculatedStats)
           
           // 種族値が変化している（メガシンカで攻撃力アップ）
           let megaAttack = viewModel.selectedForm?.stats.first { $0.name == "attack" }?.baseStat
           XCTAssertNotNil(megaAttack)
           XCTAssertGreaterThan(megaAttack ?? 0, 84) // 通常の攻撃84より高い
       }
       
       func testFormSwitching_タイプ相性の変化() async throws {
           // Given
           viewModel = container.makePokemonDetailViewModel(versionGroup: "x-y")
           await viewModel.loadPokemonDetail(id: 6)
           
           let normalTypeMatchup = viewModel.typeMatchup
           
           // When: メガリザードンXに切り替え
           let megaXForm = viewModel.availableForms.first { 
               $0.isMega && $0.formName.contains("mega-x") 
           }
           await viewModel.selectForm(megaXForm!)
           
           // Then: タイプ相性が変化している
           let megaTypeMatchup = viewModel.typeMatchup
           
           // ドラゴンタイプになったので、ドラゴン技が弱点に
           XCTAssertTrue(
               megaTypeMatchup?.defensive.doubleWeak.contains(.dragon) ?? false,
               "メガリザードンXはドラゴンタイプが弱点"
           )
           
           // ひこうタイプでなくなったので、でんき弱点が消える
           XCTAssertFalse(
               megaTypeMatchup?.defensive.doubleWeak.contains(.electric) ?? true,
               "メガリザードンXはでんきタイプが弱点でない"
           )
       }
   }
   ```

2. VersionGroupFilteringIntegrationTests
   ```
   @MainActor
   final class VersionGroupFilteringIntegrationTests: XCTestCase {
       var container: DIContainer!
       
       func testVersionGroupFiltering_赤緑ではメガシンカなし() async throws {
           // Given: 赤・緑バージョングループ
           let viewModel = container.makePokemonDetailViewModel(versionGroup: "red-blue")
           
           // When: リザードンのデータをロード
           await viewModel.loadPokemonDetail(id: 6)
           
           // Then: メガシンカフォームが存在しない
           let megaForms = viewModel.availableForms.filter { $0.isMega }
           XCTAssertTrue(megaForms.isEmpty, "赤・緑にメガシンカは存在しない")
       }
       
       func testVersionGroupFiltering_XYではメガシンカあり() async throws {
           // Given: X-Yバージョングループ
           let viewModel = container.makePokemonDetailViewModel(versionGroup: "x-y")
           
           // When: リザードンのデータをロード
           await viewModel.loadPokemonDetail(id: 6)
           
           // Then: メガシンカフォームが存在する
           let megaForms = viewModel.availableForms.filter { $0.isMega }
           XCTAssertFalse(megaForms.isEmpty, "X-Yにメガシンカが存在する")
           XCTAssertEqual(megaForms.count, 2, "リザードンはメガX・メガYの2種類")
       }
   }
   ```

3. DataFlowIntegrationTests
   ```
   @MainActor
   final class DataFlowIntegrationTests: XCTestCase {
       var container: DIContainer!
       
       func testDataFlow_ポケモン詳細取得からUI表示まで() async throws {
           // Given
           let viewModel = container.makePokemonDetailViewModel(versionGroup: nil)
           
           // When: フシギダネのデータをロード
           await viewModel.loadPokemonDetail(id: 1)
           
           // Then: 全データが取得されている
           XCTAssertNotNil(viewModel.pokemon, "ポケモン基本情報")
           XCTAssertFalse(viewModel.availableForms.isEmpty, "フォーム情報")
           XCTAssertNotNil(viewModel.selectedForm, "選択中フォーム")
           XCTAssertNotNil(viewModel.typeMatchup, "タイプ相性")
           XCTAssertNotNil(viewModel.calculatedStats, "実数値")
           XCTAssertNotNil(viewModel.evolutionChain, "進化チェーン")
           XCTAssertNotNil(viewModel.flavorText, "図鑑説明")
           
           // 実数値が正しく計算されている
           let stats = viewModel.calculatedStats!
           XCTAssertEqual(stats.patterns.count, 5, "5パターン")
           
           // 進化チェーンが正しい
           let chain = viewModel.evolutionChain!
           XCTAssertEqual(chain.rootNode.speciesId, 1, "フシギダネから始まる")
           XCTAssertFalse(chain.rootNode.evolvesTo.isEmpty, "進化先がある")
       }
   }
   ```

4. AbilityLoadingIntegrationTests
   ```
   @MainActor
   final class AbilityLoadingIntegrationTests: XCTestCase {
       var container: DIContainer!
       
       func testAbilityLoading_並列取得() async throws {
           // Given
           let viewModel = container.makePokemonDetailViewModel(versionGroup: nil)
           
           // When: ポケモンをロード
           await viewModel.loadPokemonDetail(id: 1)
           
           // Then: 特性詳細が取得されている
           let abilities = viewModel.selectedForm?.abilities ?? []
           XCTAssertFalse(abilities.isEmpty, "特性がある")
           
           for ability in abilities {
               let detail = viewModel.abilityDetails[ability.id]
               XCTAssertNotNil(detail, "特性\(ability.name)の詳細が取得されている")
               XCTAssertFalse(detail?.effect.isEmpty ?? true, "effectが空でない")
           }
       }
   }
   ```

実装場所：
- PokedexTests/Integration/

注意事項：
- 実際のDIContainerとUseCaseを使用
- APIを呼び出すため、ネットワーク接続が必要
- テストは少し時間がかかる可能性がある
- テストデータは実際のPokéAPIから取得
- 各テストは独立して実行可能にする
```

---

### プロンプト8-6: パフォーマンステスト実装

```
設計書（design_v3.md）のセクション7.3に従って、パフォーマンステストを実装してください：

実装するテスト：

1. LoadPokemonDetailPerformanceTests
   ```
   @MainActor
   final class LoadPokemonDetailPerformanceTests: XCTestCase {
       var container: DIContainer!
       var viewModel: PokemonDetailViewModel!
       
       override func setUp() {
           super.setUp()
           container = DIContainer.shared
           viewModel = container.makePokemonDetailViewModel(versionGroup: nil)
       }
       
       func testLoadPokemonDetail_初回ロードパフォーマンス() {
           measure {
               Task {
                   await viewModel.loadPokemonDetail(id: 1)
               }
           }
           
           // 目標: 3秒以内
       }
       
       func testLoadPokemonDetail_キャッシュありパフォーマンス() async {
           // Given: 一度ロードしてキャッシュを作成
           await viewModel.loadPokemonDetail(id: 1)
           
           // 新しいViewModelで再度ロード
           let newViewModel = container.makePokemonDetailViewModel(versionGroup: nil)
           
           // When & Then: キャッシュがあるので高速
           measure {
               Task {
                   await newViewModel.loadPokemonDetail(id: 1)
               }
           }
           
           // 目標: 1秒以内
       }
       
       func testSelectForm_フォーム切り替えパフォーマンス() async {
           // Given
           await viewModel.loadPokemonDetail(id: 6) // リザードン
           let megaForm = viewModel.availableForms.first { $0.isMega }!
           
           // When & Then
           measure {
               Task {
                   await viewModel.selectForm(megaForm)
               }
           }
           
           // 目標: 0.5秒以内
       }
   }
   ```

2. CalculateStatsPerformanceTests
   ```
   final class CalculateStatsPerformanceTests: XCTestCase {
       var sut: CalculateStatsUseCase!
       
       override func setUp() {
           super.setUp()
           sut = CalculateStatsUseCase()
       }
       
       func testCalculateStats_単一ポケモン() {
           // Given
           let baseStats = [
               PokemonStat(name: "hp", baseStat: 45),
               PokemonStat(name: "attack", baseStat: 49),
               PokemonStat(name: "defense", baseStat: 49),
               PokemonStat(name: "special-attack", baseStat: 65),
               PokemonStat(name: "special-defense", baseStat: 65),
               PokemonStat(name: "speed", baseStat: 45)
           ]
           
           // When & Then
           measure {
               _ = sut.execute(baseStats: baseStats)
           }
           
           // 目標: 0.001秒以内
       }
       
       func testCalculateStats_複数ポケモン() {
           // Given
           let allPokemonStats = (1...151).map { _ in
               [
                   PokemonStat(name: "hp", baseStat: Int.random(in: 40...100)),
                   PokemonStat(name: "attack", baseStat: Int.random(in: 40...100)),
                   // ... 他のステータス
               ]
           }
           
           // When & Then
           measure {
               for stats in allPokemonStats {
                   _ = sut.execute(baseStats: stats)
               }
           }
           
           // 目標: 0.2秒以内（151匹全て）
       }
   }
   ```

3. TypeMatchupPerformanceTests
   ```
   final class TypeMatchupPerformanceTests: XCTestCase {
       var sut: FetchTypeMatchupUseCase!
       var mockRepository: MockTypeRepository!
       
       override func setUp() {
           super.setUp()
           mockRepository = MockTypeRepository()
           sut = FetchTypeMatchupUseCase(repository: mockRepository)
       }
       
       func testFetchTypeMatchup_単タイプ() async {
           // Given
           mockRepository.setupMockData()
           
           // When & Then
           measure {
               Task {
                   try? await sut.execute(types: [.fire])
               }
           }
           
           // 目標: 0.01秒以内
       }
       
       func testFetchTypeMatchup_複合タイプ() async {
           // Given
           mockRepository.setupMockData()
           
           // When & Then
           measure {
               Task {
                   try? await sut.execute(types: [.fire, .flying])
               }
           }
           
           // 目標: 0.02秒以内
       }
   }
   ```

4. CachePerformanceTests
   ```
   final class CachePerformanceTests: XCTestCase {
       func testFormCache_大量データ保存取得() async {
           // Given
           let cache = FormCache()
           let forms = (1...100).map { id in
               PokemonForm(/* テストデータ */)
           }
           
           // When & Then: 保存
           measure {
               Task {
                   for (index, form) in forms.enumerated() {
                       await cache.set(pokemonId: index + 1, forms: [form])
                   }
               }
           }
           
           // 目標: 0.1秒以内
           
           // When & Then: 取得
           measure {
               Task {
                   for index in 1...100 {
                       _ = await cache.get(pokemonId: index)
                   }
               }
           }
           
           // 目標: 0.05秒以内
       }
   }
   ```

実装場所：
- PokedexTests/Performance/

注意事項：
- measure {} ブロックを使用
- ベースラインを設定して性能劣化を検知
- 非同期処理のパフォーマンス測定に注意
- 目標値は環境に応じて調整
- CI/CDでも実行できるようにする
```

---

## フェーズ9: エラーハンドリングと最終調整

### プロンプト9-1: エラーハンドリング実装

```
設計書（design_v3.md）のセクション8に従って、エラーハンドリングを実装してください：

1. エラー定義
   ```
   enum PokemonError: LocalizedError {
       case networkError(Error)
       case decodingError(Error)
       case notFound
       case invalidVersionGroup
       case cacheError
       
       var errorDescription: String? {
           // エラーメッセージ
       }
   }
   ```

2. ErrorView
   ```
   struct ErrorView: View {
       let error: Error
       let retry: () -> Void
       
       var body: some View {
           VStack(spacing: 16) {
               Image(systemName: "exclamationmark.triangle")
                   .font(.system(size: 50))
                   .foregroundColor(.red)
               
               Text(error.localizedDescription)
                   .multilineTextAlignment(.center)
               
               Button("再試行") {
                   retry()
               }
               .buttonStyle(.bordered)
           }
           .padding()
       }
   }
   ```

3. ViewModelでのエラーハンドリング
   - 各UseCaseの呼び出しをdo-catch-で囲む
   - エラー時はerrorプロパティに設定
   - ローディング状態を適切に管理

4. Viewでのエラー表示
   ```
   if let error = viewModel.error {
       ErrorView(error: error) {
           Task {
               await viewModel.loadPokemonDetail(id: pokemonId)
           }
       }
   }
   ```

実装場所：
- Pokedex/Domain/Entities/PokemonError.swift
- Pokedex/Presentation/Common/Components/ErrorView.swift

注意事項：
- ユーザーフレンドリーなエラーメッセージ
- 再試行機能の実装
- ネットワークエラーとデコードエラーを区別
```

---

### プロンプト9-2: パフォーマンス最適化

```
以下のパフォーマンス最適化を実装してください：

1. 並列データ取得の最適化
   - PokemonDetailViewModelのloadPokemonDetail()
   - async letを活用して複数のデータを同時取得
   - TaskGroupで特性詳細を並列取得

2. キャッシュ戦略の見直し
   - キャッシュヒット率の向上
   - メモリ使用量の最適化
   - 不要なキャッシュのクリア処理

3. UI描画の最適化
   - LazyVStackの活用（技一覧など）
   - 不要な再描画の削減
   - Identifiableの適切な実装

4. 画像ロードの最適化
   - Kingfisherのキャッシュ設定
   - プレースホルダーの表示
   - 画像サイズの最適化

検証方法：
- パフォーマンステストで効果を測定
- Instrumentsでプロファイリング
- メモリリークのチェック

実装場所：
- 各ViewModel、View、Repository

注意事項：
- 最適化前後でベンチマークを取る
- 過度な最適化は避ける（可読性とのバランス）
```

---

### プロンプト9-3: 最終調整とドキュメント更新

```
v3.0リリースに向けた最終調整を行ってください：

1. コードレビューとリファクタリング
   - コードの重複を削除
   - 命名の統一
   - コメントの追加（複雑なロジック）
   - SwiftLintの警告を解消

2. ドキュメント更新
   - README.mdの更新
     - v3.0の新機能を追加
     - スクリーンショットの更新
   - CHANGELOG.mdの作成
     - v3.0の変更内容を記載

3. テストカバレッジの確認
   - 未カバーの部分にテストを追加
   - テスト実行の確認（全てパス）
   - テストカバレッジレポートの生成

4. アクセシビリティの確認
   - VoiceOver対応
   - Dynamic Type対応
   - 色覚多様性への配慮

5. 動作確認
   - 様々なポケモンで動作確認
   - エッジケースの確認（データがない場合など）
   - 異なるiOSバージョンでの動作確認

6. リリース準備
   - バージョン番号を3.0.0に更新
   - ビルド番号の更新
   - リリースノートの作成

完了条件：
- 全テストがパス
- テストカバレッジ80%以上
- SwiftLint警告ゼロ
- ドキュメント更新完了

注意事項：
- 既存機能を壊さない
- パフォーマンスの劣化がない
- メモリリークがない
```

---

## プロンプト使用時の注意事項

1. **順序を守る**: プロンプトは依存関係があるため、順番に実行してください

2. **エラー対応**: エラーが発生した場合は、エラーメッセージをClaude Codeに伝えて修正を依頼してください

3. **テスト実行**: 各フェーズ後にテストを実行し、動作確認してください

4. **コミット**: 各フェーズ完了後にGitコミットすることを推奨します

5. **レビュー**: 実装されたコードは必ずレビューしてください

6. **カスタマイズ**: プロジェクトの状況に応じてプロンプトをカスタマイズしても構いません

---

**以上**