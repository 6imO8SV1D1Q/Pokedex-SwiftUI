//
//  StatFilterCondition.swift
//  Pokedex
//
//  種族値フィルター用のモデル
//

import Foundation

/// 比較演算子（技フィルター用に残す）
enum ComparisonOperator: String, CaseIterable, Identifiable {
    case equal = "="
    case greaterThan = ">"
    case greaterThanOrEqual = "≥"
    case lessThan = "<"
    case lessThanOrEqual = "≤"

    var id: String { rawValue }

    /// 値が条件を満たすか判定
    /// - Parameters:
    ///   - actual: 実際の値
    ///   - target: 条件の値
    /// - Returns: 条件を満たす場合true
    func evaluate(_ actual: Int, _ target: Int) -> Bool {
        switch self {
        case .equal: return actual == target
        case .greaterThan: return actual > target
        case .greaterThanOrEqual: return actual >= target
        case .lessThan: return actual < target
        case .lessThanOrEqual: return actual <= target
        }
    }
}

/// ステータスの種類
enum StatType: String, CaseIterable, Identifiable {
    case hp = "HP"
    case attack = "こうげき"
    case defense = "ぼうぎょ"
    case specialAttack = "とくこう"
    case specialDefense = "とくぼう"
    case speed = "すばやさ"
    case total = "種族値合計"

    var id: String { rawValue }

    /// ローカライズされた表示名
    var localizedName: String {
        switch self {
        case .hp:
            return NSLocalizedString("stat.hp", comment: "")
        case .attack:
            return NSLocalizedString("stat.attack", comment: "")
        case .defense:
            return NSLocalizedString("stat.defense", comment: "")
        case .specialAttack:
            return NSLocalizedString("stat.special_attack", comment: "")
        case .specialDefense:
            return NSLocalizedString("stat.special_defense", comment: "")
        case .speed:
            return NSLocalizedString("stat.speed", comment: "")
        case .total:
            return NSLocalizedString("stat.total", comment: "")
        }
    }

    /// PokemonStatで使用される名前
    var statName: String {
        switch self {
        case .hp: return "hp"
        case .attack: return "attack"
        case .defense: return "defense"
        case .specialAttack: return "special-attack"
        case .specialDefense: return "special-defense"
        case .speed: return "speed"
        case .total: return "total"
        }
    }
}

/// フィルターモード
enum StatFilterMode: String, CaseIterable, Identifiable {
    case above = "以上"
    case below = "以下"
    case range = "範囲"
    case exact = "ちょうど"

    var id: String { rawValue }
}

/// 種族値フィルターの条件
struct StatFilterCondition: Identifiable, Equatable {
    let id = UUID()
    var statType: StatType
    var mode: StatFilterMode
    var minValue: Int
    var maxValue: Int?

    /// 指定した種族値が条件を満たすか判定
    /// - Parameter stat: 種族値
    /// - Returns: 条件を満たす場合true
    func matches(_ stat: Int) -> Bool {
        // 範囲フィルターの場合（最小値・最大値の片方または両方）
        if mode == .range {
            let hasMin = minValue > 0
            let hasMax = maxValue != nil

            if hasMin && hasMax {
                // 両方指定
                return stat >= minValue && stat <= maxValue!
            } else if hasMin {
                // 最小値のみ（以上）
                return stat >= minValue
            } else if hasMax {
                // 最大値のみ（以下）
                return stat <= maxValue!
            } else {
                return true
            }
        }

        // 旧形式との互換性（以上/以下/ちょうど）
        switch mode {
        case .above:
            return stat >= minValue
        case .below:
            return stat <= minValue
        case .exact:
            return stat == minValue
        case .range:
            return true // 上で処理済み
        }
    }

    /// 表示用の文字列
    var displayText: String {
        if mode == .range {
            let hasMin = minValue > 0
            let hasMax = maxValue != nil

            if hasMin && hasMax {
                return "\(statType.localizedName) \(minValue) 〜 \(maxValue!)"
            } else if hasMin {
                return "\(statType.localizedName) \(minValue) 以上"
            } else if hasMax {
                return "\(statType.localizedName) \(maxValue!) 以下"
            } else {
                return "\(statType.localizedName) すべて"
            }
        }

        switch mode {
        case .above:
            return "\(statType.localizedName) \(mode.rawValue) \(minValue)"
        case .below:
            return "\(statType.localizedName) \(mode.rawValue) \(minValue)"
        case .exact:
            return "\(statType.localizedName) \(mode.rawValue) \(minValue)"
        case .range:
            return "" // 上で処理済み
        }
    }

    static func == (lhs: StatFilterCondition, rhs: StatFilterCondition) -> Bool {
        lhs.id == rhs.id
    }
}
