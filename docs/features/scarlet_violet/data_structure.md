# スカーレット・バイオレット データ構造設計

## 概要
- バージョン: scarlet-violet
- 対象: スカーレット・バイオレットに登場する全ポケモン、技、特性

---

## JSON構造

```json
{
  "dataVersion": "1.0.0",
  "lastUpdated": "2025-10-10",
  "versionGroup": "scarlet-violet",
  "versionGroupId": 25,
  "generation": 9,

  "pokemon": [...],
  "moves": [...],
  "abilities": [...],
  "types": [...]
}
```

---

## Pokemon構造

```json
{
  "id": 25,
  "nationalDexNumber": 25,
  "name": "pikachu",
  "nameJa": "ピカチュウ",
  "genus": "Mouse Pokémon",
  "genusJa": "ねずみポケモン",

  "sprites": {
    "normal": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/25.png",
    "shiny": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/25.png"
  },

  "types": ["electric"],

  "abilities": {
    "primary": [9],
    "hidden": 31
  },

  "baseStats": {
    "hp": 35,
    "attack": 55,
    "defense": 40,
    "spAttack": 50,
    "spDefense": 50,
    "speed": 90,
    "total": 320
  },

  "moves": [
    {
      "moveId": 85,
      "learnMethod": "level-up",
      "level": 26
    },
    {
      "moveId": 98,
      "learnMethod": "machine",
      "machineNumber": "TM025"
    },
    {
      "moveId": 84,
      "learnMethod": "egg"
    }
  ],

  "eggGroups": ["ground", "fairy"],
  "genderRate": 4,
  "height": 4,
  "weight": 60,

  "evolutionChain": {
    "chainId": 10,
    "evolutionStage": 2,
    "evolvesFrom": 172,
    "evolvesTo": [26],
    "canUseEviolite": true
  },

  "varieties": [25, 10080, 10081, 10082, 10083, 10084, 10085],

  "pokedexNumbers": {
    "paldea": 25,
    "kitakami": 196
  },

  "category": "normal"
}
```

---

## Move構造

```json
{
  "id": 85,
  "name": "thunderbolt",
  "nameJa": "10まんボルト",

  "type": "electric",
  "damageClass": "special",

  "power": 90,
  "accuracy": 100,
  "pp": 15,
  "priority": 0,

  "effectChance": 10,
  "effect": "Inflicts regular damage. Has a 10% chance to paralyze the target.",
  "effectJa": "通常のダメージを与える。10%の確率で相手をまひ状態にする。",

  "meta": {
    "ailment": "paralysis",
    "ailmentChance": 10,
    "category": "damage+ailment",
    "critRate": 0,
    "drain": 0,
    "flinchChance": 0,
    "healing": 0,
    "maxHits": null,
    "maxTurns": null,
    "minHits": null,
    "minTurns": null,
    "statChance": 0,
    "statChanges": []
  },

  "flags": {
    "isContact": false,
    "isSound": false,
    "isPunch": false,
    "isBite": false,
    "isPowder": false,
    "isWind": false
  }
}
```

---

## Ability構造

```json
{
  "id": 9,
  "name": "static",
  "nameJa": "せいでんき",

  "effect": "Whenever a move makes contact with this Pokémon, the move's user has a 30% chance of being paralyzed.",
  "effectJa": "接触技を受けたとき、30%の確率で相手をまひ状態にする。",

  "overworldEffect": "If the lead Pokémon has this ability, there is a 50% chance that encounters will be with an electric Pokémon, if applicable.",
  "overworldEffectJa": "手持ちの先頭にいると、50%の確率で電気タイプの野生ポケモンと遭遇しやすくなる。"
}
```

---

## Type構造（アプリ側定義）

```json
{
  "name": "electric",
  "nameJa": "でんき"
}
```

※ タイプは18種類固定のため、アプリ側で定義する（JSONには含めない）

---

## 補足情報

### ポケモン区分（category）
- `normal`: 一般ポケモン
- `subLegendary`: 準伝説（600族など）
- `legendary`: 伝説
- `mythical`: 幻

### 性別比（genderRate）
- -1: 性別なし
- 0: オスのみ
- 8: メスのみ
- 1-7: オス/メス比率（1=87.5%オス、4=50%、7=12.5%オス）

### しんかのきせき適用判定
- `canUseEviolite`: true = 進化可能（しんかのきせき有効）

### フォーム情報（varieties）
- 関連フォームのID配列
- 例: ピカチュウの各コスチューム、キャップピカチュウ等

### 図鑑登録情報（pokedexNumbers）
- ポケモンが登録されている図鑑と図鑑番号の辞書
- キー: 図鑑名 (`"paldea"`, `"kitakami"`, `"blueberry"`)
- 値: 図鑑番号（整数）
- 空辞書 `{}` の場合: 図鑑未登場（HOME経由でのみ転送可能）
- 例: `{"paldea": 25, "kitakami": 196}` = パルデア図鑑No.025、キタカミ図鑑No.196
- 全国図鑑番号は `nationalDexNumber` フィールドに格納

---

## データ取得元

### PokéAPI エンドポイント
- `/api/v2/pokemon/{id}` - 基本情報
- `/api/v2/pokemon-species/{id}` - 種族情報
- `/api/v2/evolution-chain/{id}` - 進化情報
- `/api/v2/move/{id}` - 技情報
- `/api/v2/ability/{id}` - 特性情報

### バージョングループフィルタリング
- 技: `version_group_details` で `scarlet-violet` のみ抽出
- ポケモン: Pokedex `paldea` に登録されているもの + HOME経由で転送可能なもの
