//
//  AbilityCategory.swift
//  Pokedex
//
//  Created by Claude Code on 2025-10-15.
//

import Foundation

/// 特性のカテゴリ分類
enum AbilityCategory: String, CaseIterable, Identifiable {
    // 天候・フィールド
    case weatherSetter = "weather_setter"
    case weatherDependent = "weather_dependent"
    case terrainSetter = "terrain_setter"
    case terrainDependent = "terrain_dependent"

    // ステータス変化
    case statBoost = "stat_boost"
    case statReducer = "stat_reducer"

    // タイプ関連
    case typeBoost = "type_boost"
    case typeImmunity = "type_immunity"
    case typeDefense = "type_defense"

    // 状態異常
    case statusImmunity = "status_immunity"
    case statusInflictor = "status_inflict"

    // ダメージ・回復
    case damageReduction = "damage_reduction"
    case damageIncrease = "damage_increase"
    case healing = "healing"

    // 特殊効果
    case switchInEffect = "switch_in_effect"
    case randomEffect = "random_effect"
    case hpDependent = "hp_dependent"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .weatherSetter: return "天候設定"
        case .weatherDependent: return "天候依存"
        case .terrainSetter: return "フィールド設定"
        case .terrainDependent: return "フィールド依存"
        case .statBoost: return "能力上昇"
        case .statReducer: return "能力下降"
        case .typeBoost: return "タイプ強化"
        case .typeImmunity: return "タイプ無効"
        case .typeDefense: return "タイプ耐性"
        case .statusImmunity: return "状態異常無効"
        case .statusInflictor: return "状態異常付与"
        case .damageReduction: return "ダメージ軽減"
        case .damageIncrease: return "ダメージ増加"
        case .healing: return "HP回復"
        case .switchInEffect: return "登場時効果"
        case .randomEffect: return "ランダム効果"
        case .hpDependent: return "HP依存"
        }
    }

    var description: String {
        switch self {
        case .weatherSetter: return "天候を変更する特性"
        case .weatherDependent: return "天候によって効果が変わる特性"
        case .terrainSetter: return "フィールドを変更する特性"
        case .terrainDependent: return "フィールドによって効果が変わる特性"
        case .statBoost: return "能力を上昇させる特性"
        case .statReducer: return "相手の能力を下げる特性"
        case .typeBoost: return "特定タイプの技を強化する特性"
        case .typeImmunity: return "特定タイプを無効化する特性"
        case .typeDefense: return "特定タイプのダメージを軽減する特性"
        case .statusImmunity: return "状態異常を防ぐ特性"
        case .statusInflictor: return "状態異常を付与する特性"
        case .damageReduction: return "受けるダメージを軽減する特性"
        case .damageIncrease: return "与えるダメージを増加させる特性"
        case .healing: return "HPを回復する特性"
        case .switchInEffect: return "場に出たときに効果を発動する特性"
        case .randomEffect: return "ランダムに効果を発動する特性"
        case .hpDependent: return "HPの状態によって効果が変わる特性"
        }
    }
}
