# アイテムJSONスキーマ設計 (v5.0)

**作成日**: 2025-11-01
**対象**: ダメージ計算機能で使用するアイテムデータ

---

## 概要

ダメージ計算に必要なアイテム情報を格納するJSONスキーマを定義する。
既存のMoveEntity、AbilityEntityのパターンに準拠し、拡張性を考慮した設計とする。

---

## JSONスキーマ

### 基本構造

```json
{
  "items": [
    {
      "id": 198,
      "name": "wellspring-mask",
      "nameJa": "いどのめん",
      "category": "held-item",
      "description": "Ogerpon's mask. It boosts the power of the holder's Water-type moves.",
      "descriptionJa": "オーガポンのお面。持たせると水タイプの技の威力が上がる。",
      "effects": {
        "damageMultiplier": {
          "condition": "same_type_as_mask",
          "types": ["water"],
          "baseMultiplier": 1.2,
          "teraMultiplier": 1.3,
          "appliesDuringTera": true,
          "restrictedTo": ["ogerpon"]
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/wellspring-mask.png"
    },
    {
      "id": 234,
      "name": "choice-band",
      "nameJa": "こだわりハチマキ",
      "category": "held-item",
      "description": "An item to be held by a Pokémon. It boosts Attack, but allows only one move to be used.",
      "descriptionJa": "持たせると攻撃は上がるが、同じ技しか出せなくなる。",
      "effects": {
        "statMultiplier": {
          "stat": "attack",
          "multiplier": 1.5
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/choice-band.png"
    },
    {
      "id": 245,
      "name": "life-orb",
      "nameJa": "いのちのたま",
      "category": "held-item",
      "description": "An item to be held by a Pokémon. It boosts the power of moves, but at the cost of some HP on each hit.",
      "descriptionJa": "持たせると技の威力が上がるが、攻撃する度にHPが少し減る。",
      "effects": {
        "damageMultiplier": {
          "condition": "all_damaging_moves",
          "baseMultiplier": 1.3
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/life-orb.png"
    },
    {
      "id": 251,
      "name": "expert-belt",
      "nameJa": "たつじんのおび",
      "category": "held-item",
      "description": "An item to be held by a Pokémon. It boosts the power of super effective moves.",
      "descriptionJa": "持たせると効果抜群の技の威力が少し上がる。",
      "effects": {
        "damageMultiplier": {
          "condition": "super_effective",
          "baseMultiplier": 1.2
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/expert-belt.png"
    },
    {
      "id": 270,
      "name": "assault-vest",
      "nameJa": "とつげきチョッキ",
      "category": "held-item",
      "description": "An item to be held by a Pokémon. It boosts Sp. Def, but prevents the use of status moves.",
      "descriptionJa": "持たせると特防は上がるが、変化技が出せなくなる。",
      "effects": {
        "statMultiplier": {
          "stat": "special-defense",
          "multiplier": 1.5
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/assault-vest.png"
    },
    {
      "id": 279,
      "name": "weakness-policy",
      "nameJa": "じゃくてんほけん",
      "category": "held-item",
      "description": "An item to be held by a Pokémon. If hit by a super effective move, it sharply raises Attack and Sp. Atk.",
      "descriptionJa": "持たせると効果抜群の技を受けたとき、攻撃と特攻がぐーんと上がる。",
      "effects": {
        "triggerEffect": {
          "condition": "hit_by_super_effective",
          "statChanges": [
            {"stat": "attack", "change": 2},
            {"stat": "special-attack", "change": 2}
          ]
        }
      },
      "sprite": "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/items/weakness-policy.png"
    }
  ]
}
```

---

## フィールド定義

### トップレベル

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `items` | Array | ✅ | アイテムの配列 |

### アイテムオブジェクト

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `id` | Integer | ✅ | アイテムのID（PokeAPI準拠） |
| `name` | String | ✅ | アイテム名（英語、ケバブケース） |
| `nameJa` | String | ✅ | アイテム名（日本語） |
| `category` | String | ✅ | カテゴリー（"held-item", "berry", "mega-stone"など） |
| `description` | String | ❌ | 説明文（英語） |
| `descriptionJa` | String | ❌ | 説明文（日本語） |
| `effects` | Object | ❌ | 効果の詳細 |
| `sprite` | String | ❌ | 画像URL |

### effects オブジェクト

#### damageMultiplier（ダメージ倍率効果）

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `condition` | String | ✅ | 適用条件（"same_type_as_mask", "all_damaging_moves", "super_effective"など） |
| `types` | Array\<String\> | ❌ | 対象タイプ（オーガポンマスクなど特定タイプに限定する場合） |
| `baseMultiplier` | Float | ✅ | 基本倍率（例: 1.2, 1.3, 1.5） |
| `teraMultiplier` | Float | ❌ | テラスタル時の倍率（オーガポン用） |
| `appliesDuringTera` | Boolean | ❌ | テラスタル時も適用されるか |
| `restrictedTo` | Array\<String\> | ❌ | 特定のポケモンにのみ適用（例: ["ogerpon"]） |

#### statMultiplier（ステータス倍率効果）

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `stat` | String | ✅ | 対象ステータス（"attack", "defense", "special-attack", "special-defense", "speed"） |
| `multiplier` | Float | ✅ | 倍率（例: 1.5） |

#### triggerEffect（トリガー型効果）

| フィールド | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| `condition` | String | ✅ | トリガー条件（"hit_by_super_effective"など） |
| `statChanges` | Array | ❌ | ステータス変化（じゃくてんほけんなど） |

---

## 実装優先度

### Phase 0で実装するアイテム

**最優先（オーガポン専用）:**
- Wellspring Mask (いどのめん)
- Hearthflame Mask (かまどのめん)
- Cornerstone Mask (いしずえのめん)
- Teal Mask (みどりのめん)

**高優先（汎用ダメージ補正）:**
- Choice Band (こだわりハチマキ)
- Choice Specs (こだわりメガネ)
- Life Orb (いのちのたま)
- Expert Belt (たつじんのおび)

**中優先（防御補正）:**
- Assault Vest (とつげきチョッキ)
- Eviolite (しんかのきせき)

**低優先（タイプ特化）:**
- Charcoal (もくたん)
- Mystic Water (しんぴのしずく)
- など全18タイプ分

### v5.1以降で追加予定

- ステータス変化アイテム（じゃくてんほけんなど）
- 反動ダメージアイテム（いのちのたまのHP減少）
- きのみ類（オボンのみなど）

---

## Entity設計

```swift
// Domain/Entities/Item/ItemEntity.swift
struct ItemEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let nameJa: String
    let category: String
    let description: String?
    let descriptionJa: String?
    let effects: ItemEffects?
    let sprite: String?
}

struct ItemEffects: Equatable {
    let damageMultiplier: DamageMultiplierEffect?
    let statMultiplier: StatMultiplierEffect?
    let triggerEffect: TriggerEffect?
}

struct DamageMultiplierEffect: Equatable {
    let condition: String
    let types: [String]?
    let baseMultiplier: Double
    let teraMultiplier: Double?
    let appliesDuringTera: Bool?
    let restrictedTo: [String]?
}

struct StatMultiplierEffect: Equatable {
    let stat: String
    let multiplier: Double
}

struct TriggerEffect: Equatable {
    let condition: String
    let statChanges: [StatChange]?
}

struct StatChange: Equatable {
    let stat: String
    let change: Int
}
```

---

## データソース

### 手動作成 vs PokeAPI

- **Phase 0**: 手動でJSONを作成（最優先アイテムのみ）
- **Phase 1以降**: PokeAPIから自動生成スクリプトを作成

### 配置場所

```
Pokedex/Resources/PreloadedData/items_v5.json
```

---

## バージョン管理

JSONに`schemaVersion`フィールドを追加し、スキーマ変更時にバージョンアップする。

```json
{
  "schemaVersion": 1,
  "items": [...]
}
```

---

## 次のステップ

1. ✅ スキーマ確定
2. ⏭️ 手動でitems_v5.jsonを作成（最優先アイテムのみ）
3. ⏭️ ItemEntity実装
4. ⏭️ ItemProvider実装
5. ⏭️ 単体テスト作成
