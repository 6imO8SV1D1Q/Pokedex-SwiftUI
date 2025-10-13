//
//  StatFilterCondition.swift
//  Pokedex
//
//  実数値フィルター用のモデル
//

import Foundation

/// ステータスの種類
enum StatType: String, CaseIterable, Identifiable {
    case hp = "HP"
    case attack = "こうげき"
    case defense = "ぼうぎょ"
    case specialAttack = "とくこう"
    case specialDefense = "とくぼう"
    case speed = "すばやさ"

    var id: String { rawValue }

    /// PokemonStatで使用される名前
    var statName: String {
        switch self {
        case .hp: return "hp"
        case .attack: return "attack"
        case .defense: return "defense"
        case .specialAttack: return "special-attack"
        case .specialDefense: return "special-defense"
        case .speed: return "speed"
        }
    }
}

/// 比較演算子
enum ComparisonOperator: String, CaseIterable, Identifiable {
    case greaterThan = ">"
    case greaterThanOrEqual = "≥"
    case lessThan = "<"
    case lessThanOrEqual = "≤"

    var id: String { rawValue }

    /// 実数値が条件を満たすか判定
    /// - Parameters:
    ///   - actual: 実際の実数値
    ///   - target: 条件の値
    /// - Returns: 条件を満たす場合true
    func evaluate(_ actual: Int, _ target: Int) -> Bool {
        switch self {
        case .greaterThan: return actual > target
        case .greaterThanOrEqual: return actual >= target
        case .lessThan: return actual < target
        case .lessThanOrEqual: return actual <= target
        }
    }
}

/// 実数値フィルターの条件
struct StatFilterCondition: Identifiable, Equatable {
    let id = UUID()
    var statType: StatType
    var `operator`: ComparisonOperator
    var value: Int

    /// 指定した実数値が条件を満たすか判定
    /// - Parameter stat: 実数値
    /// - Returns: 条件を満たす場合true
    func matches(_ stat: Int) -> Bool {
        self.`operator`.evaluate(stat, value)
    }

    /// 表示用の文字列
    var displayText: String {
        "\(statType.rawValue) \(`operator`.rawValue) \(value)"
    }

    static func == (lhs: StatFilterCondition, rhs: StatFilterCondition) -> Bool {
        lhs.id == rhs.id
    }
}
