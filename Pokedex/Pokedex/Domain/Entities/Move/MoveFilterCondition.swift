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
struct MoveMetadataFilter: Identifiable, Equatable {
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

/// 能力変化フィルター（自分/相手を明確に区別）
enum StatChangeFilter: String, CaseIterable, Identifiable {
    // 自分の能力上昇
    case userAttackUp = "自分こうげき↑"
    case userDefenseUp = "自分ぼうぎょ↑"
    case userSpAttackUp = "自分とくこう↑"
    case userSpDefenseUp = "自分とくぼう↑"
    case userSpeedUp = "自分すばやさ↑"
    case userAccuracyUp = "自分命中↑"
    case userEvasionUp = "自分回避↑"
    case userCritRateUp = "自分急所ランク↑"

    // 相手の能力下降
    case opponentAttackDown = "相手こうげき↓"
    case opponentDefenseDown = "相手ぼうぎょ↓"
    case opponentSpAttackDown = "相手とくこう↓"
    case opponentSpDefenseDown = "相手とくぼう↓"
    case opponentSpeedDown = "相手すばやさ↓"
    case opponentAccuracyDown = "相手命中↓"
    case opponentEvasionDown = "相手回避↓"

    var id: String { rawValue }

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
