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
    case statusInflictor = "status_inflictor"

    // ダメージ・回復
    case damageReduction = "damage_reduction"
    case damageIncrease = "damage_increase"
    case healing = "healing"

    // 特殊効果
    case switchInEffect = "switch_in_effect"
    case switchOutEffect = "switch_out_effect"
    case randomEffect = "random_effect"
    case hpDependent = "hp_dependent"

    var id: String { rawValue }

    var displayName: String {
        return L10n.AbilityCategory.displayName(rawValue)
    }

    var description: String {
        return L10n.AbilityCategory.description(rawValue)
    }

    // MARK: - Category Groups

    /// カテゴリーグループの定義
    struct CategoryGroup {
        let name: String
        let categories: [AbilityCategory]
    }

    /// グループ分けされたカテゴリー
    static var categoryGroups: [CategoryGroup] {
        return [
            CategoryGroup(name: L10n.AbilityCategory.groupName("weather_terrain"), categories: [
                .weatherSetter,
                .weatherDependent,
                .terrainSetter,
                .terrainDependent
            ]),
            CategoryGroup(name: L10n.AbilityCategory.groupName("stat_change"), categories: [
                .statBoost,
                .statReducer
            ]),
            CategoryGroup(name: L10n.AbilityCategory.groupName("type_related"), categories: [
                .typeBoost,
                .typeImmunity,
                .typeDefense
            ]),
            CategoryGroup(name: L10n.AbilityCategory.groupName("status_condition"), categories: [
                .statusImmunity,
                .statusInflictor
            ]),
            CategoryGroup(name: L10n.AbilityCategory.groupName("damage_recovery"), categories: [
                .damageReduction,
                .damageIncrease,
                .healing
            ]),
            CategoryGroup(name: L10n.AbilityCategory.groupName("special_effects"), categories: [
                .switchInEffect,
                .switchOutEffect,
                .randomEffect,
                .hpDependent
            ])
        ]
    }
}
