//
//  AbilityMetadataFilter.swift
//  Pokedex
//
//  特性の詳細フィルター条件
//

import Foundation

struct AbilityMetadataFilter: Identifiable, Equatable {
    var id = UUID()

    // 発動タイミング
    var triggers: Set<String> = []

    // 効果タイプ
    var effectTypes: Set<String> = []

    // 数値条件
    var statMultiplierCondition: NumericCondition?     // 能力値倍率（例: 攻撃2倍）
    var movePowerMultiplierCondition: NumericCondition? // 技威力倍率（例: 1.5倍）
    var probabilityCondition: NumericCondition?        // 発動確率（例: 30%）

    // 天候・フィールド
    var weathers: Set<String> = []
    var terrains: Set<String> = []

    // タイプ関連
    var affectedTypes: Set<String> = []  // 無効化/強化されるタイプ

    // 状態異常
    var affectedStatuses: Set<String> = []  // 無効化/付与/回復する状態異常

    // カテゴリ（既存の簡易フィルター）
    var categories: Set<AbilityCategory> = []

    var isEmpty: Bool {
        triggers.isEmpty &&
        effectTypes.isEmpty &&
        statMultiplierCondition == nil &&
        movePowerMultiplierCondition == nil &&
        probabilityCondition == nil &&
        weathers.isEmpty &&
        terrains.isEmpty &&
        affectedTypes.isEmpty &&
        affectedStatuses.isEmpty &&
        categories.isEmpty
    }
}

// 数値条件（技フィルターと同様）
struct NumericCondition: Equatable {
    let value: Double
    let comparisonOperator: ComparisonOperator

    func displayText(label: String) -> String {
        "\(label) \(comparisonOperator.rawValue) \(value)"
    }

    func matches(_ targetValue: Double?) -> Bool {
        guard let targetValue = targetValue else { return false }

        switch comparisonOperator {
        case .greaterThan:
            return targetValue > value
        case .greaterThanOrEqual:
            return targetValue >= value
        case .lessThan:
            return targetValue < value
        case .lessThanOrEqual:
            return targetValue <= value
        case .equal:
            return abs(targetValue - value) < 0.001
        }
    }
}
