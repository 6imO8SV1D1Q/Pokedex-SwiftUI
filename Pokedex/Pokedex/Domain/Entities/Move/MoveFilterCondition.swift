//
//  MoveFilterCondition.swift
//  Pokedex
//
//  技のメタデータフィルター条件
//

import Foundation

/// 技の数値パラメータフィルター条件
struct MoveNumericCondition: Equatable {
    var value: Int
    var `operator`: ComparisonOperator

    /// 指定した値が条件を満たすか判定
    func matches(_ actual: Int?) -> Bool {
        guard let actual = actual else { return false }
        return self.`operator`.evaluate(actual, value)
    }

    /// 表示用の文字列
    func displayText(label: String) -> String {
        "\(label) \(`operator`.rawValue) \(value)"
    }
}

/// 技のメタデータフィルター条件
struct MoveMetadataFilter: Identifiable {
    var id = UUID()

    // MARK: - 基本情報

    /// タイプフィルター
    var types: Set<String> = []

    /// 分類フィルター（physical, special, status）
    var damageClasses: Set<String> = []

    /// 威力条件
    var powerCondition: MoveNumericCondition?

    /// 命中率条件
    var accuracyCondition: MoveNumericCondition?

    /// PP条件
    var ppCondition: MoveNumericCondition?

    /// 優先度
    var priority: Int?

    // MARK: - 対象

    /// 技の対象フィルター（例: "selected-pokemon", "user", "all-opponents"）
    var targets: Set<String> = []

    // MARK: - 状態異常

    /// 状態異常フィルター
    var ailments: Set<Ailment> = []

    // MARK: - 効果

    /// HP吸収（drain > 0）
    var hasDrain: Bool = false

    /// HP回復（healing > 0）
    var hasHealing: Bool = false

    // MARK: - 能力変化

    /// 能力変化フィルター（自分・相手明示）
    var statChanges: Set<StatChangeFilter> = []

    // MARK: - 技カテゴリー

    /// 技カテゴリーフィルター
    var categories: Set<String> = []

    /// フィルターが空かどうか
    var isEmpty: Bool {
        types.isEmpty &&
        damageClasses.isEmpty &&
        powerCondition == nil &&
        accuracyCondition == nil &&
        ppCondition == nil &&
        priority == nil &&
        targets.isEmpty &&
        ailments.isEmpty &&
        !hasDrain &&
        !hasHealing &&
        statChanges.isEmpty &&
        categories.isEmpty
    }
}

// MARK: - Supporting Types

/// 状態異常の種類
enum Ailment: String, CaseIterable, Identifiable {
    case paralysis
    case burn
    case poison
    case badlyPoison = "badly_poison"
    case freeze
    case sleep
    case confusion

    var id: String { rawValue }

    /// ローカライズされた表示名
    var displayName: String {
        return L10n.Ailment.displayName(rawValue)
    }

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

/// 能力変化フィルター（自分/相手を明確に区別）
enum StatChangeFilter: String, CaseIterable, Identifiable {
    // 自分の能力上昇
    case userAttackUp = "user_attack_up"
    case userDefenseUp = "user_defense_up"
    case userSpAttackUp = "user_sp_attack_up"
    case userSpDefenseUp = "user_sp_defense_up"
    case userSpeedUp = "user_speed_up"
    case userAccuracyUp = "user_accuracy_up"
    case userEvasionUp = "user_evasion_up"
    case userCritRateUp = "user_crit_rate_up"

    // 相手の能力下降
    case opponentAttackDown = "opponent_attack_down"
    case opponentDefenseDown = "opponent_defense_down"
    case opponentSpAttackDown = "opponent_sp_attack_down"
    case opponentSpDefenseDown = "opponent_sp_defense_down"
    case opponentSpeedDown = "opponent_speed_down"
    case opponentAccuracyDown = "opponent_accuracy_down"
    case opponentEvasionDown = "opponent_evasion_down"

    var id: String { rawValue }

    /// ローカライズされた表示名
    var displayName: String {
        return L10n.StatChange.displayName(rawValue)
    }

    /// PokéAPIでのステータス名、変化量、対象
    var statChangeInfo: (stat: String, change: Int, isUser: Bool) {
        switch self {
        case .userAttackUp: return ("attack", 1, true)
        case .userDefenseUp: return ("defense", 1, true)
        case .userSpAttackUp: return ("special-attack", 1, true)
        case .userSpDefenseUp: return ("special-defense", 1, true)
        case .userSpeedUp: return ("speed", 1, true)
        case .userAccuracyUp: return ("accuracy", 1, true)
        case .userEvasionUp: return ("evasion", 1, true)
        case .userCritRateUp: return ("critical-hit", 1, true)
        case .opponentAttackDown: return ("attack", -1, false)
        case .opponentDefenseDown: return ("defense", -1, false)
        case .opponentSpAttackDown: return ("special-attack", -1, false)
        case .opponentSpDefenseDown: return ("special-defense", -1, false)
        case .opponentSpeedDown: return ("speed", -1, false)
        case .opponentAccuracyDown: return ("accuracy", -1, false)
        case .opponentEvasionDown: return ("evasion", -1, false)
        }
    }
}
