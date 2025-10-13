//
//  MoveFilterCondition.swift
//  Pokedex
//
//  技のメタデータフィルター条件
//

import Foundation

/// 技のメタデータフィルター条件
struct MoveMetadataFilter: Equatable {
    // MARK: - 基本情報

    /// タイプフィルター
    var types: Set<String> = []

    /// 分類フィルター（physical, special, status）
    var damageClasses: Set<String> = []

    /// 威力範囲
    var powerRange: ClosedRange<Int>?

    /// 命中率範囲
    var accuracyRange: ClosedRange<Int>?

    /// PP範囲
    var ppRange: ClosedRange<Int>?

    /// 優先度フィルター
    var priorities: Set<Int> = []

    // MARK: - 状態異常

    /// 状態異常フィルター
    var ailments: Set<Ailment> = []

    // MARK: - 効果

    /// 急所率アップ（critRate > 0）
    var hasHighCritRate: Bool = false

    /// HP吸収（drain > 0）
    var hasDrain: Bool = false

    /// HP回復（healing > 0）
    var hasHealing: Bool = false

    /// ひるみ（flinchChance > 0）
    var hasFlinch: Bool = false

    // MARK: - 能力変化

    /// 能力変化フィルター（自分・相手両方）
    var statChanges: Set<StatChangeFilter> = []

    // MARK: - 技カテゴリー

    /// 技カテゴリーフィルター
    var categories: Set<String> = []

    /// フィルターが空かどうか
    var isEmpty: Bool {
        types.isEmpty &&
        damageClasses.isEmpty &&
        powerRange == nil &&
        accuracyRange == nil &&
        ppRange == nil &&
        priorities.isEmpty &&
        ailments.isEmpty &&
        !hasHighCritRate &&
        !hasDrain &&
        !hasHealing &&
        !hasFlinch &&
        statChanges.isEmpty &&
        categories.isEmpty
    }
}

// MARK: - Supporting Types

/// 状態異常の種類
enum Ailment: String, CaseIterable, Identifiable {
    case paralysis = "まひ"
    case burn = "やけど"
    case poison = "どく"
    case badlyPoison = "もうどく"
    case freeze = "こおり"
    case sleep = "ねむり"
    case confusion = "こんらん"

    var id: String { rawValue }

    /// PokéAPIでの名前
    var apiName: String {
        switch self {
        case .paralysis: return "paralysis"
        case .burn: return "burn"
        case .poison: return "poison"
        case .badlyPoison: return "badly-poison"
        case .freeze: return "freeze"
        case .sleep: return "sleep"
        case .confusion: return "confusion"
        }
    }
}

/// 能力変化フィルター
enum StatChangeFilter: String, CaseIterable, Identifiable {
    // 自分の能力上昇
    case attackUp = "こうげき↑"
    case defenseUp = "ぼうぎょ↑"
    case spAttackUp = "とくこう↑"
    case spDefenseUp = "とくぼう↑"
    case speedUp = "すばやさ↑"
    case accuracyUp = "命中↑"
    case evasionUp = "回避↑"

    // 相手の能力下降
    case attackDown = "こうげき↓"
    case defenseDown = "ぼうぎょ↓"
    case spAttackDown = "とくこう↓"
    case spDefenseDown = "とくぼう↓"
    case speedDown = "すばやさ↓"
    case accuracyDown = "命中↓"
    case evasionDown = "回避↓"

    var id: String { rawValue }

    /// PokéAPIでのステータス名と変化量
    var statAndChange: (stat: String, change: Int) {
        switch self {
        case .attackUp: return ("attack", 1)
        case .defenseUp: return ("defense", 1)
        case .spAttackUp: return ("special-attack", 1)
        case .spDefenseUp: return ("special-defense", 1)
        case .speedUp: return ("speed", 1)
        case .accuracyUp: return ("accuracy", 1)
        case .evasionUp: return ("evasion", 1)
        case .attackDown: return ("attack", -1)
        case .defenseDown: return ("defense", -1)
        case .spAttackDown: return ("special-attack", -1)
        case .spDefenseDown: return ("special-defense", -1)
        case .speedDown: return ("speed", -1)
        case .accuracyDown: return ("accuracy", -1)
        case .evasionDown: return ("evasion", -1)
        }
    }
}
