#!/usr/bin/env swift

import Foundation

// MARK: - Input Structures
struct AbilityInput: Codable {
    let id: Int
    let name: String
    let nameJa: String
    let effect: String
    let effectJa: String
}

struct InputData: Codable {
    let abilities: [AbilityInput]
}

// MARK: - Output Structures
struct AbilityMetadata: Codable {
    let schemaVersion: Int
    let id: Int
    let name: String
    let nameJa: String
    let effect: String
    let effectJa: String
    let effects: [AbilityEffect]
    let categories: [String]
    let pokemonRestriction: [String]?
}

struct AbilityEffect: Codable {
    let trigger: String
    let condition: Condition?
    let effectType: String
    let target: String
    let value: EffectValue?
}

struct Condition: Codable {
    let type: String
    let value: ConditionValue?
}

enum ConditionValue: Codable {
    case fraction(numerator: Int, denominator: Int)
    case percentage(Int)
    case weather(String)
    case terrain(String)
    case type(String)
    case types([String])
    case number(Int)
    case effectiveness(String)
    case itemName(String)
    case itemCategory(String)
    case moveNames([String])
    case flagName(String)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .fraction(let num, let den):
            try container.encode(["numerator": num, "denominator": den])
        case .percentage(let val):
            try container.encode(["percentage": val])
        case .weather(let val):
            try container.encode(["weather": val])
        case .terrain(let val):
            try container.encode(["terrain": val])
        case .type(let val):
            try container.encode(["type": val])
        case .types(let val):
            try container.encode(["types": val])
        case .number(let val):
            try container.encode(["number": val])
        case .effectiveness(let val):
            try container.encode(["effectiveness": val])
        case .itemName(let val):
            try container.encode(["itemName": val])
        case .itemCategory(let val):
            try container.encode(["itemCategory": val])
        case .moveNames(let val):
            try container.encode(["moveNames": val])
        case .flagName(let val):
            try container.encode(["flagName": val])
        }
    }
}

struct EffectValue: Codable {
    let stat: String?
    let multiplier: Double?
    let stageChange: Int?
    let probability: Int?
    let healAmount: HealAmount?
    let weather: String?
    let terrain: String?
    let status: String?
    let moveType: String?
    let moveTypes: [String]?
    let moveFlag: String?
    let specificMoveName: String?
    let specificMoveNames: [String]?
    let specificFormName: String?
    let specificItemName: String?
    let itemCategory: String?
    let randomElement: Bool?
    let accumulationSource: String?
    let flagName: String?
    let fixedValue: Int?
    let highestStat: Bool?
    let typeSource: String?
    let hazardType: String?
    let stageChangeUp: Int?
    let stageChangeDown: Int?
}

enum HealAmount: Codable {
    case fraction(numerator: Int, denominator: Int)
    case percentage(Int)

    enum CodingKeys: String, CodingKey {
        case fraction, percentage
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .fraction(let num, let den):
            try container.encode(["numerator": num, "denominator": den], forKey: .fraction)
        case .percentage(let val):
            try container.encode(val, forKey: .percentage)
        }
    }
}

// MARK: - Effect Analyzer v2.0
class AbilityEffectAnalyzer {

    // MARK: - Special Cases (Name-based overrides)

    func analyzeSpecialCase(_ ability: AbilityInput) -> AbilityMetadata? {
        let name = ability.name

        // intimidate - 場に出た時、相手全体の攻撃を1段階下げる
        if name == "intimidate" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_switch_in",
                        condition: nil,
                        effectType: "stat_stage_change",
                        target: "all_opponents",
                        value: EffectValue(
                            stat: "attack", multiplier: nil, stageChange: -1, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["stat_boost_trigger", "stat_reducer", "switch_in_effect"],
                pokemonRestriction: nil
            )
        }

        // protosynthesis - 晴れまたはブーストエナジー所持時、最も高い能力が1.3倍
        if name == "protosynthesis" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "weather", value: .weather("sun")),
                        effectType: "stat_multiplier",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 1.3, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: true, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "holding_specific_item", value: .itemName("booster-energy")),
                        effectType: "stat_multiplier",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 1.3, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: true, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["stat_multiplier", "weather_boost", "weather_dependent"],
                pokemonRestriction: nil
            )
        }

        // quark-drive - 同様にエレキフィールドまたはブーストエナジー
        if name == "quark-drive" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "terrain", value: .terrain("electric")),
                        effectType: "stat_multiplier",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 1.3, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: true, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "holding_specific_item", value: .itemName("booster-energy")),
                        effectType: "stat_multiplier",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 1.3, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: true, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["stat_multiplier", "terrain_boost", "terrain_dependent"],
                pokemonRestriction: nil
            )
        }

        // moody - 毎ターン終了時、ランダムな能力が2段階上昇、別のランダムな能力が1段階低下
        if name == "moody" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_turn_end",
                        condition: nil,
                        effectType: "random_stat_change",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: true,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: 2, stageChangeDown: -1
                        )
                    )
                ],
                categories: ["stat_boost_trigger", "drawback", "random_effect"],
                pokemonRestriction: nil
            )
        }

        // gulp-missile - 2段階トリガー（なみのり/ダイビング使用後にフラグ設定、被弾時に発動）
        if name == "gulp-missile" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "after_specific_move",
                        condition: Condition(type: "specific_move_used", value: .moveNames(["surf", "dive"])),
                        effectType: "set_flag",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: "gulp_missile_active", fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "flag_active", value: .flagName("gulp_missile_active")),
                        effectType: "contact_damage",
                        target: "opponent",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: .fraction(numerator: 1, denominator: 4), weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["special_mechanic"],
                pokemonRestriction: ["cramorant"]
            )
        }

        // multitype - プレート所持でタイプ変更
        if name == "multitype" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "holding_specific_item", value: .itemCategory("plate")),
                        effectType: "change_user_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: "heldItem", hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_change"],
                pokemonRestriction: ["arceus"]
            )
        }

        // rks-system - メモリ所持でタイプ変更
        if name == "rks-system" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "holding_specific_item", value: .itemCategory("memory")),
                        effectType: "change_user_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: "heldItem", hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_change"],
                pokemonRestriction: ["silvally"]
            )
        }

        // multiscale - HP満タン時、受けるダメージ半減
        if name == "multiscale" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "hp_full", value: nil),
                        effectType: "damage_reduction_full_hp",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 0.5, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["damage_reduction", "hp_dependent"],
                pokemonRestriction: nil
            )
        }

        // shadow-shield - 同じくHP満タン時ダメージ半減
        if name == "shadow-shield" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "hp_full", value: nil),
                        effectType: "damage_reduction_full_hp",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 0.5, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["damage_reduction", "hp_dependent"],
                pokemonRestriction: nil
            )
        }

        // tera-shell - HP満タン時、すべてのダメージ技が今ひとつになる
        if name == "tera-shell" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: Condition(type: "hp_full", value: nil),
                        effectType: "damage_reduction_full_hp",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: 0.5, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["damage_reduction", "hp_dependent"],
                pokemonRestriction: ["terapagos"]
            )
        }

        // mirror-armor - 能力低下の効果を跳ね返す
        if name == "mirror-armor" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_stat_change",
                        condition: nil,
                        effectType: "reflect_stat_changes",
                        target: "opponent",
                        value: nil
                    )
                ],
                categories: ["stat_protection"],
                pokemonRestriction: nil
            )
        }

        // regenerator - 交代時にHP1/3回復
        if name == "regenerator" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_switch_out",
                        condition: nil,
                        effectType: "heal_hp",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: .fraction(numerator: 1, denominator: 3),
                            weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["healing", "recovery", "switch_out_effect"],
                pokemonRestriction: nil
            )
        }

        // competitive - 能力が下がると特攻2段階上昇
        if name == "competitive" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_stat_change",
                        condition: Condition(type: "stat_lowered", value: nil),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "special-attack", multiplier: nil, stageChange: 2, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["stat_boost", "stat_boost_trigger"],
                pokemonRestriction: nil
            )
        }

        // defiant - 能力が下がると攻撃2段階上昇
        if name == "defiant" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_stat_change",
                        condition: Condition(type: "stat_lowered", value: nil),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "attack", multiplier: nil, stageChange: 2, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["stat_boost", "stat_boost_trigger"],
                pokemonRestriction: nil
            )
        }

        // flash-fire - ほのお無効+技威力上昇
        if name == "flash-fire" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "fire", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "power_boost"],
                pokemonRestriction: nil
            )
        }

        // lightning-rod - でんき無効+特攻上昇
        if name == "lightning-rod" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "electric", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("electric")),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "special-attack", multiplier: nil, stageChange: 1, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "stat_boost"],
                pokemonRestriction: nil
            )
        }

        // storm-drain - みず無効+特攻上昇
        if name == "storm-drain" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "water", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("water")),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "special-attack", multiplier: nil, stageChange: 1, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "stat_boost"],
                pokemonRestriction: nil
            )
        }

        // motor-drive - でんき無効+素早さ上昇
        if name == "motor-drive" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "electric", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("electric")),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "speed", multiplier: nil, stageChange: 1, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "stat_boost"],
                pokemonRestriction: nil
            )
        }

        // sap-sipper - くさ無効+攻撃上昇
        if name == "sap-sipper" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "grass", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("grass")),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "attack", multiplier: nil, stageChange: 1, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "stat_boost"],
                pokemonRestriction: nil
            )
        }

        // earth-eater - じめん無効+HP回復
        if name == "earth-eater" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("ground")),
                        effectType: "absorb_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: .fraction(numerator: 1, denominator: 4), weather: nil, terrain: nil, status: nil,
                            moveType: "ground", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity"],
                pokemonRestriction: nil
            )
        }

        // well-baked-body - ほのお無効+防御上昇
        if name == "well-baked-body" {
            return AbilityMetadata(
                schemaVersion: 1,
                id: ability.id,
                name: ability.name,
                nameJa: ability.nameJa,
                effect: ability.effect,
                effectJa: ability.effectJa,
                effects: [
                    AbilityEffect(
                        trigger: "passive",
                        condition: nil,
                        effectType: "immune_to_type",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: "fire", moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ),
                    AbilityEffect(
                        trigger: "on_being_hit",
                        condition: Condition(type: "incoming_move_type", value: .type("fire")),
                        effectType: "stat_stage_change",
                        target: "self",
                        value: EffectValue(
                            stat: "defense", multiplier: nil, stageChange: 2, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    )
                ],
                categories: ["type_immunity", "stat_boost"],
                pokemonRestriction: nil
            )
        }

        return nil
    }

    // MARK: - General Analysis

    func analyze(_ ability: AbilityInput) -> AbilityMetadata {
        // まず特殊ケースをチェック
        if let specialCase = analyzeSpecialCase(ability) {
            return specialCase
        }

        // 一般的なパターンマッチング
        let effect = ability.effect.lowercased()
        var effects: [AbilityEffect] = []
        var categories: [String] = []
        var pokemonRestriction: [String]? = nil

        // 天候条件の検出
        let weatherCondition: Condition? = detectWeatherCondition(effect)

        // フィールド条件の検出
        let terrainCondition: Condition? = detectTerrainCondition(effect)

        // 統合条件
        let condition = weatherCondition ?? terrainCondition

        // 天候設定
        effects.append(contentsOf: detectWeatherSetter(effect, &categories))

        // フィールド設定
        effects.append(contentsOf: detectTerrainSetter(effect, &categories))

        // ステータスランク変化
        effects.append(contentsOf: detectStatStageChanges(effect, condition, &categories))

        // ステータス倍率
        effects.append(contentsOf: detectStatMultipliers(effect, condition, &categories))

        // タイプ別技威力上昇
        effects.append(contentsOf: detectTypePowerBoosts(effect, condition, &categories))

        // タイプ耐性（受けるダメージ軽減）
        effects.append(contentsOf: detectTypeDefense(effect, condition, &categories))

        // タイプ吸収
        effects.append(contentsOf: detectAbsorbType(effect, &categories))

        // タイプ無効
        effects.append(contentsOf: detectImmuneToType(effect, &categories))

        // 状態異常無効
        effects.append(contentsOf: detectImmuneToStatus(effect, &categories))

        // 急所無効
        effects.append(contentsOf: detectPreventCritical(effect, &categories))

        // 一撃耐え
        effects.append(contentsOf: detectSurviveHit(effect, &categories))

        // 接触ダメージ・状態異常
        effects.append(contentsOf: detectContactEffects(effect, &categories))

        // 命中率倍率
        effects.append(contentsOf: detectAccuracyMultiplier(effect, condition, &categories))

        // 回避率倍率
        effects.append(contentsOf: detectEvasionMultiplier(effect, condition, &categories))

        // 天候無効化
        effects.append(contentsOf: detectNullifyWeather(effect, &categories))

        // HP回復
        effects.append(contentsOf: detectHealHP(effect, condition, &categories))

        // 状態異常付与
        effects.append(contentsOf: detectInflictStatus(effect, &categories))

        // 能力下降無効
        effects.append(contentsOf: detectPreventStatDecrease(effect, &categories))

        // 状態異常同期
        effects.append(contentsOf: detectSyncStatus(effect, &categories))

        // 追加効果確率倍化
        effects.append(contentsOf: detectDoubleEffectChance(effect, &categories))

        // ひるみ無効
        effects.append(contentsOf: detectPreventFlinch(effect, &categories))

        // 状態異常回復
        effects.append(contentsOf: detectCureStatus(effect, &categories))

        // 状態異常時の能力上昇
        effects.append(contentsOf: detectStatusBoost(effect, &categories))

        // 技フラグベースの威力上昇
        effects.append(contentsOf: detectMoveFlagPowerBoost(effect, &categories))

        // STAB倍率変更
        effects.append(contentsOf: detectSTABChange(effect, &categories))

        // 急所ダメージ倍率変更
        effects.append(contentsOf: detectCriticalDamageChange(effect, &categories))

        // 命中率変更（必中等）
        effects.append(contentsOf: detectAlwaysHit(effect, &categories))

        // 反動無効
        effects.append(contentsOf: detectNoRecoil(effect, &categories))

        // 音技無効
        effects.append(contentsOf: detectSoundproofing(effect, &categories))

        // 特定能力下降無効
        effects.append(contentsOf: detectSpecificStatProtection(effect, &categories))

        // 急所率変更
        effects.append(contentsOf: detectCriticalRateChange(effect, &categories))

        // 受けるダメージ倍率
        effects.append(contentsOf: detectDamageMultiplier(effect, &categories))

        // フォールバック：最低限1つのeffectを生成
        if effects.isEmpty {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "unknown",
                target: "self",
                value: nil
            ))
            categories.append("special_mechanic")
        }

        // 検出したeffectsに基づいてカテゴリを自動追加
        for effect in effects {
            // 天候依存
            if let condition = effect.condition, condition.type == "weather" {
                categories.append("weather_dependent")
            }

            // フィールド依存
            if let condition = effect.condition, condition.type == "terrain" {
                categories.append("terrain_dependent")
            }

            // HP依存
            if let condition = effect.condition,
               condition.type == "hp_below" || condition.type == "hp_above" || condition.type == "hp_full" {
                categories.append("hp_dependent")
            }

            // 相手能力下降
            if effect.effectType == "stat_stage_change",
               let stageChange = effect.value?.stageChange,
               stageChange < 0,
               (effect.target == "opponent" || effect.target == "all_opponents") {
                categories.append("stat_reducer")
            }

            // 状態異常付与
            if effect.effectType == "inflict_status" {
                categories.append("status_inflict")
            }

            // HP回復
            if effect.effectType == "heal_hp" {
                categories.append("healing")
            }

            // 登場時効果
            if effect.trigger == "on_switch_in" {
                categories.append("switch_in_effect")
            }

            // 交代時効果
            if effect.trigger == "on_switch_out" {
                categories.append("switch_out_effect")
            }

            // ダメージ軽減（damage_multiplierで倍率が1.0未満）
            if effect.effectType == "damage_multiplier",
               let multiplier = effect.value?.multiplier,
               multiplier < 1.0 {
                categories.append("damage_reduction")
            }

            // ダメージ増加（damage_multiplierで倍率が1.0より大きい）
            if effect.effectType == "damage_multiplier",
               let multiplier = effect.value?.multiplier,
               multiplier > 1.0 {
                categories.append("damage_increase")
            }

            // ランダム効果
            if effect.effectType == "random_stat_change" || effect.value?.randomElement == true {
                categories.append("random_effect")
            }

            // タイプ耐性（特定タイプに対するダメージ軽減）
            if effect.effectType == "move_power_multiplier",
               let multiplier = effect.value?.multiplier,
               multiplier < 1.0,
               effect.value?.moveType != nil || effect.value?.moveTypes != nil {
                categories.append("type_defense")
            }

            // ダメージ増加（被ダメ増加は除く、与ダメ増加のみ）
            if effect.effectType == "move_power_multiplier",
               let multiplier = effect.value?.multiplier,
               multiplier > 1.0 {
                categories.append("damage_increase")
            }
        }

        // effectテキストベースでHP依存を検出（50%以下などの条件）
        let effectLower = ability.effect.lowercased()
        if (effectLower.contains("below 50%") ||
            effectLower.contains("50% or above") ||
            effectLower.contains("drops below") ||
            effectLower.contains("drop to half") ||
            effectLower.contains("half or less") ||
            effectLower.contains("half its maximum hp") ||
            effectLower.contains("hp is below") ||
            effectLower.contains("hp drops below") ||
            effectLower.contains("when its hp")) &&
           !categories.contains("hp_dependent") {
            categories.append("hp_dependent")
        }

        return AbilityMetadata(
            schemaVersion: 1,
            id: ability.id,
            name: ability.name,
            nameJa: ability.nameJa,
            effect: ability.effect,
            effectJa: ability.effectJa,
            effects: effects,
            categories: Array(Set(categories)), // 重複削除
            pokemonRestriction: pokemonRestriction
        )
    }

    // MARK: - Detection Helpers

    private func detectWeatherCondition(_ effect: String) -> Condition? {
        if effect.contains("during strong sunlight") || effect.contains("during harsh sunlight") || effect.contains("in harsh sunlight") {
            return Condition(type: "weather", value: .weather("sun"))
        } else if effect.contains("during rain") {
            return Condition(type: "weather", value: .weather("rain"))
        } else if effect.contains("during a sandstorm") || effect.contains("during sandstorm") {
            return Condition(type: "weather", value: .weather("sandstorm"))
        } else if effect.contains("during snow") || effect.contains("during hail") {
            return Condition(type: "weather", value: .weather("snow"))
        }
        return nil
    }

    private func detectTerrainCondition(_ effect: String) -> Condition? {
        if effect.contains("electric terrain") || effect.contains("on electric terrain") {
            return Condition(type: "terrain", value: .terrain("electric"))
        } else if effect.contains("grassy terrain") || effect.contains("on grassy terrain") {
            return Condition(type: "terrain", value: .terrain("grassy"))
        } else if effect.contains("misty terrain") || effect.contains("on misty terrain") {
            return Condition(type: "terrain", value: .terrain("misty"))
        } else if effect.contains("psychic terrain") || effect.contains("on psychic terrain") {
            return Condition(type: "terrain", value: .terrain("psychic"))
        }
        return nil
    }

    private func detectWeatherSetter(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // 天候設定を検出（フィールドと混同しないようにチェック）
        if !effect.contains("terrain") {
            // 晴れ: "changes to strong sunlight" or "summons harsh sunlight" or "turns the sunlight harsh"
            if ((effect.contains("changes to") && effect.contains("strong sunlight")) ||
                (effect.contains("summons") && effect.contains("harsh")) ||
                effect.contains("turns the sunlight")) &&
               effect.contains("when") && (effect.contains("enters") || effect.contains("battle")) {
                results.append(makeWeatherSetterEffect(weather: "sun"))
                categories.append("weather_setter")
            // 雨: "changes to rain" or "summons rain"
            } else if ((effect.contains("changes to rain") || effect.contains("summons rain")) &&
                       effect.contains("when") && (effect.contains("enters") || effect.contains("battle"))) {
                results.append(makeWeatherSetterEffect(weather: "rain"))
                categories.append("weather_setter")
            // 砂嵐: "changes to a sandstorm" or "summons a sandstorm"
            } else if ((effect.contains("changes to a sandstorm") || effect.contains("summons a sandstorm")) &&
                       effect.contains("when") && (effect.contains("enters") || effect.contains("battle"))) {
                results.append(makeWeatherSetterEffect(weather: "sandstorm"))
                categories.append("weather_setter")
            // 雪: "summons snow" or "summons a hailstorm" or "changes to hail"
            } else if ((effect.contains("summons snow") ||
                        effect.contains("summons a hailstorm") ||
                        effect.contains("changes to hail")) &&
                       effect.contains("when") && (effect.contains("enters") || effect.contains("battle"))) {
                results.append(makeWeatherSetterEffect(weather: "snow"))
                categories.append("weather_setter")
            }
        }

        return results
    }

    private func makeWeatherSetterEffect(weather: String) -> AbilityEffect {
        return AbilityEffect(
            trigger: "on_switch_in",
            condition: nil,
            effectType: "set_weather",
            target: "field",
            value: EffectValue(
                stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                healAmount: nil, weather: weather, terrain: nil, status: nil,
                moveType: nil, moveTypes: nil, moveFlag: nil,
                specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                specificItemName: nil, itemCategory: nil, randomElement: nil,
                accumulationSource: nil, flagName: nil, fixedValue: nil,
                highestStat: nil, typeSource: nil, hazardType: nil,
                stageChangeUp: nil, stageChangeDown: nil
            )
        )
    }

    private func detectTerrainSetter(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        let terrains: [(keyword: String, value: String)] = [
            ("electric terrain", "electric"),
            ("grassy terrain", "grassy"),
            ("misty terrain", "misty"),
            ("psychic terrain", "psychic")
        ]

        for terrain in terrains {
            if effect.contains(terrain.keyword) && effect.contains("when") && (effect.contains("enters") || effect.contains("battle")) {
                results.append(makeTerrainSetterEffect(terrain: terrain.value))
                categories.append("terrain_setter")
                break
            }
        }

        return results
    }

    private func makeTerrainSetterEffect(terrain: String) -> AbilityEffect {
        return AbilityEffect(
            trigger: "on_switch_in",
            condition: nil,
            effectType: "set_terrain",
            target: "field",
            value: EffectValue(
                stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                healAmount: nil, weather: nil, terrain: terrain, status: nil,
                moveType: nil, moveTypes: nil, moveFlag: nil,
                specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                specificItemName: nil, itemCategory: nil, randomElement: nil,
                accumulationSource: nil, flagName: nil, fixedValue: nil,
                highestStat: nil, typeSource: nil, hazardType: nil,
                stageChangeUp: nil, stageChangeDown: nil
            )
        )
    }

    private func detectStatStageChanges(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        let statNames = ["attack", "defense", "special attack", "special defense", "speed", "accuracy", "evasion"]

        for statName in statNames {
            if effect.contains(statName) && (effect.contains("stage") || effect.contains("stages")) {
                let stageChange: Int?
                let isRaise = effect.contains("raises") || effect.contains("rises") || effect.contains("increased")
                let isLower = effect.contains("lowers") || effect.contains("decreased") || effect.contains("lowered")

                if effect.contains("two stages") || effect.contains("2 stages") || effect.contains("by 2") {
                    stageChange = isRaise ? 2 : (isLower ? -2 : nil)
                } else if effect.contains("one stage") || effect.contains("1 stage") || effect.contains("by 1") || effect.contains("by one") {
                    stageChange = isRaise ? 1 : (isLower ? -1 : nil)
                } else {
                    stageChange = nil
                }

                if let stage = stageChange {
                    let trigger: String
                    let target: String

                    if effect.contains("enters battle") || effect.contains("sent out") {
                        trigger = "on_switch_in"
                        if effect.contains("opposing") || effect.contains("opponents") || effect.contains("opponent's") {
                            target = "all_opponents"
                        } else {
                            target = "self"
                        }
                    } else if effect.contains("after each turn") || effect.contains("end of each turn") {
                        trigger = "on_turn_end"
                        target = "self"
                    } else if effect.contains("when hit") || effect.contains("struck") || effect.contains("being hit") {
                        trigger = "on_being_hit"
                        target = stage > 0 ? "self" : "opponent"
                    } else if effect.contains("after") && effect.contains("attack") {
                        trigger = "after_move"
                        target = "self"
                    } else {
                        trigger = "passive"
                        target = "self"
                    }

                    let stat = statName.replacingOccurrences(of: " ", with: "_")
                    results.append(AbilityEffect(
                        trigger: trigger,
                        condition: condition,
                        effectType: "stat_stage_change",
                        target: target,
                        value: EffectValue(
                            stat: stat, multiplier: nil, stageChange: stage, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: nil, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ))
                    categories.append("stat_boost_trigger")
                    break
                }
            }
        }

        return results
    }

    private func detectStatMultipliers(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // Speed倍率
        if effect.contains("speed") && effect.contains("doubled") && !effect.contains("stage") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: condition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(
                    stat: "speed", multiplier: 2.0, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("stat_multiplier")
        }

        // Attack倍率
        if effect.contains("attack") && effect.contains("doubled") && !effect.contains("stage") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: condition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(
                    stat: "attack", multiplier: 2.0, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append(contentsOf: ["stat_multiplier", "power_boost"])
        }

        // Special Attack倍率
        if effect.contains("special attack") && (effect.contains("1.5") || effect.contains("doubled")) && !effect.contains("stage") {
            let multiplier = effect.contains("1.5") ? 1.5 : 2.0
            results.append(AbilityEffect(
                trigger: "passive",
                condition: condition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(
                    stat: "special_attack", multiplier: multiplier, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append(contentsOf: ["stat_multiplier", "power_boost"])
        }

        return results
    }

    private func detectTypePowerBoosts(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        let typePowerPatterns: [(type: String, keywords: [String])] = [
            ("fire", ["fire-type moves", "fire moves", "fire-type"]),
            ("water", ["water-type moves", "water moves", "water-type"]),
            ("grass", ["grass-type moves", "grass moves", "grass-type"]),
            ("electric", ["electric-type moves", "electric moves", "electric-type"]),
            ("normal", ["normal-type moves", "normal moves", "normal-type"]),
            ("steel", ["steel-type moves", "steel moves", "steel-type"]),
            ("dragon", ["dragon-type moves", "dragon moves", "dragon-type"]),
            ("dark", ["dark-type moves", "dark moves", "dark-type"]),
            ("fairy", ["fairy-type moves", "fairy moves", "fairy-type"]),
            ("fighting", ["fighting-type moves", "fighting moves", "fighting-type"]),
            ("flying", ["flying-type moves", "flying moves", "flying-type"]),
            ("poison", ["poison-type moves", "poison moves", "poison-type"]),
            ("ground", ["ground-type moves", "ground moves", "ground-type"]),
            ("rock", ["rock-type moves", "rock moves", "rock-type"]),
            ("bug", ["bug-type moves", "bug moves", "bug-type"]),
            ("ghost", ["ghost-type moves", "ghost moves", "ghost-type"]),
            ("ice", ["ice-type moves", "ice moves", "ice-type"]),
            ("psychic", ["psychic-type moves", "psychic moves", "psychic-type"])
        ]

        for pattern in typePowerPatterns {
            for keyword in pattern.keywords {
                if effect.contains(keyword) && (effect.contains("1.5") || effect.contains("1.3") || effect.contains("1.2") || effect.contains("power") || effect.contains("damage")) {
                    let multiplier: Double
                    if effect.contains("1.5") {
                        multiplier = 1.5
                    } else if effect.contains("1.3") {
                        multiplier = 1.3
                    } else if effect.contains("1.2") {
                        multiplier = 1.2
                    } else {
                        multiplier = 1.5 // デフォルト
                    }

                    results.append(AbilityEffect(
                        trigger: "passive",
                        condition: condition,
                        effectType: "move_power_multiplier",
                        target: "self",
                        value: EffectValue(
                            stat: nil, multiplier: multiplier, stageChange: nil, probability: nil,
                            healAmount: nil, weather: nil, terrain: nil, status: nil,
                            moveType: pattern.type, moveTypes: nil, moveFlag: nil,
                            specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                            specificItemName: nil, itemCategory: nil, randomElement: nil,
                            accumulationSource: nil, flagName: nil, fixedValue: nil,
                            highestStat: nil, typeSource: nil, hazardType: nil,
                            stageChangeUp: nil, stageChangeDown: nil
                        )
                    ))
                    categories.append(contentsOf: ["power_boost", "type_boost"])
                    break
                }
            }
        }

        // 複数タイプの技威力上昇（sand-force等）
        if effect.contains("rock-, ground-, and steel-type") || effect.contains("rock, ground, and steel") {
            let multiplier: Double = effect.contains("1.3") ? 1.3 : 1.5
            results.append(AbilityEffect(
                trigger: "passive",
                condition: condition,
                effectType: "move_power_multiplier",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: multiplier, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: ["rock", "ground", "steel"], moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append(contentsOf: ["power_boost", "type_boost"])
        }

        return results
    }

    // タイプ耐性（受けるダメージ軽減）
    private func detectTypeDefense(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // 「takes half as much damage from」または「half damage from」パターン
        if effect.contains("takes half as much damage from") || effect.contains("half damage from") ||
           effect.contains("halves damage from") || effect.contains("damage from") && effect.contains("half") {

            let typePatterns: [(type: String, keywords: [String])] = [
                ("fire", ["fire-type", "fire and ice", "fire- and ice-type"]),
                ("ice", ["ice-type", "fire and ice", "fire- and ice-type"]),
                ("water", ["water-type"]),
                ("grass", ["grass-type"]),
                ("electric", ["electric-type"]),
                ("dragon", ["dragon-type"]),
                ("psychic", ["psychic-type"]),
                ("dark", ["dark-type"])
            ]

            var detectedTypes: [String] = []
            for pattern in typePatterns {
                for keyword in pattern.keywords {
                    if effect.contains(keyword) {
                        detectedTypes.append(pattern.type)
                        break
                    }
                }
            }

            // 重複削除
            detectedTypes = Array(Set(detectedTypes))

            for type in detectedTypes {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: condition,
                    effectType: "move_power_multiplier",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: 0.5, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: type, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
            }

            if !detectedTypes.isEmpty {
                categories.append("type_defense")
            }
        }

        return results
    }

    // タイプ吸収
    private func detectAbsorbType(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("heals for 1/4") || effect.contains("heals for ¼") {
            var moveType: String? = nil
            if effect.contains("electric-type move") || effect.contains("electric move") {
                moveType = "electric"
            } else if effect.contains("water-type move") || effect.contains("water move") {
                moveType = "water"
            } else if effect.contains("fire-type move") || effect.contains("fire move") {
                moveType = "fire"
            } else if effect.contains("grass-type move") || effect.contains("grass move") {
                moveType = "grass"
            }

            if let type = moveType {
                results.append(AbilityEffect(
                    trigger: "on_being_hit",
                    condition: Condition(type: "incoming_move_type", value: .type(type)),
                    effectType: "absorb_type",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                        healAmount: .fraction(numerator: 1, denominator: 4), weather: nil, terrain: nil, status: nil,
                        moveType: type, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("type_immunity")
            }
        }

        return results
    }

    // タイプ無効
    private func detectImmuneToType(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // 「this pokémon is immune to」のパターンのみ検出（「pokémon that are immune to」を除外）
        // 単数形(-type move)と複数形(-type moves)の両方に対応
        if (effect.contains("this pokémon is immune to") || effect.contains("this pokemon is immune to")) {
            var immuneType: String? = nil
            if effect.contains("immune to ground-type") {
                immuneType = "ground"
            } else if effect.contains("immune to electric-type") {
                immuneType = "electric"
            } else if effect.contains("immune to water-type") {
                immuneType = "water"
            } else if effect.contains("immune to fire-type") {
                immuneType = "fire"
            } else if effect.contains("immune to grass-type") {
                immuneType = "grass"
            } else if effect.contains("immune to psychic-type") {
                immuneType = "psychic"
            }

            if let type = immuneType {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: nil,
                    effectType: "immune_to_type",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: type, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("type_immunity")
            }
        }

        return results
    }

    // 状態異常無効
    private func detectImmuneToStatus(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        var status: String? = nil
        if effect.contains("cannot be paralyzed") || effect.contains("immune to paralysis") {
            status = "paralysis"
        } else if effect.contains("cannot be poisoned") || effect.contains("immune to poison") {
            status = "poison"
        } else if effect.contains("cannot be burned") || effect.contains("immune to burn") {
            status = "burn"
        } else if effect.contains("cannot be frozen") || effect.contains("immune to freeze") {
            status = "freeze"
        } else if effect.contains("cannot be asleep") || effect.contains("cannot be put to sleep") {
            status = "sleep"
        } else if effect.contains("cannot be confused") {
            status = "confusion"
        } else if effect.contains("cannot be infatuated") {
            status = "infatuation"
        }

        if let status = status {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "immune_to_status",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: status,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("status_immunity")
        }

        return results
    }

    // 急所無効
    private func detectPreventCritical(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("cannot score critical hits") || effect.contains("cannot land critical hits") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "prevent_critical",
                target: "self",
                value: nil
            ))
            categories.append("defensive")
        }

        return results
    }

    // 一撃耐え
    private func detectSurviveHit(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("will instead leave it with 1 hp") {
            results.append(AbilityEffect(
                trigger: "on_being_hit",
                condition: Condition(type: "at_full_hp", value: nil),
                effectType: "survive_hit",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: 1,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("defensive")
        }

        return results
    }

    // 接触ダメージ・状態異常
    private func detectContactEffects(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("whenever a move makes contact") || effect.contains("when this pokémon is hit by a contact move") {
            // ダメージ反射
            if effect.contains("takes 1/8 of its maximum hp in damage") || effect.contains("takes ⅛ of its maximum hp") {
                results.append(AbilityEffect(
                    trigger: "on_being_hit",
                    condition: Condition(type: "move_makes_contact", value: nil),
                    effectType: "contact_damage",
                    target: "attacker",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                        healAmount: .fraction(numerator: 1, denominator: 8), weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("contact_punish")
            }

            // 状態異常付与
            var status: String? = nil
            var probability = 30

            if effect.contains("paralyzed") {
                status = "paralysis"
            } else if effect.contains("poisoned") {
                status = "poison"
            } else if effect.contains("burned") {
                status = "burn"
            } else if effect.contains("frozen") || effect.contains("freeze") {
                status = "freeze"
            }

            if let status = status {
                results.append(AbilityEffect(
                    trigger: "on_being_hit",
                    condition: Condition(type: "move_makes_contact", value: nil),
                    effectType: "inflict_status",
                    target: "attacker",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: probability,
                        healAmount: nil, weather: nil, terrain: nil, status: status,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("contact_punish")
            }
        }

        return results
    }

    // 命中率倍率
    private func detectAccuracyMultiplier(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("moves have") && effect.contains("their accuracy") {
            var multiplier: Double? = nil
            if effect.contains("1.3×") || effect.contains("1.3x") {
                multiplier = 1.3
            } else if effect.contains("1.25×") || effect.contains("1.25x") {
                multiplier = 1.25
            }

            if let mult = multiplier {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: condition,
                    effectType: "accuracy_multiplier",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: mult, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("accuracy_boost")
            }
        }

        return results
    }

    // 回避率倍率
    private func detectEvasionMultiplier(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("has") && effect.contains("evasion") && !effect.contains("opponent") {
            var multiplier: Double? = nil
            if effect.contains("1.25×") || effect.contains("1.25x") {
                multiplier = 1.25
            } else if effect.contains("1.2×") || effect.contains("1.2x") {
                multiplier = 1.2
            }

            if let mult = multiplier {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: condition,
                    effectType: "evasion_multiplier",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: mult, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("evasion_boost")
            }
        }

        return results
    }

    // 天候無効化
    private func detectNullifyWeather(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("weather can still be in play, but will not have any of its effects") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "nullify_weather",
                target: "field",
                value: nil
            ))
            categories.append("weather_nullify")
        }

        return results
    }

    // HP回復
    private func detectHealHP(_ effect: String, _ condition: Condition?, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // ターン終了時のHP回復
        if ((effect.contains("at the end of each turn") || effect.contains("at the end of every turn") || effect.contains("after each turn")) &&
           (effect.contains("restores") || effect.contains("heals") || effect.contains("regains"))) ||
           (effect.contains("heals for") && effect.contains("after each turn")) {
            var healAmount: HealAmount? = nil
            if effect.contains("1/16") || effect.contains("⅟16") {
                healAmount = .fraction(numerator: 1, denominator: 16)
            } else if effect.contains("1/8") || effect.contains("⅛") {
                healAmount = .fraction(numerator: 1, denominator: 8)
            } else if effect.contains("1/3") {
                healAmount = .fraction(numerator: 1, denominator: 3)
            }

            if let heal = healAmount {
                results.append(AbilityEffect(
                    trigger: "on_turn_end",
                    condition: condition,
                    effectType: "heal_hp",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                        healAmount: heal, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("recovery")
            }
        }

        return results
    }

    // 状態異常付与（怯み等）
    private func detectInflictStatus(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // 怯み
        if effect.contains("have a") && effect.contains("chance") && effect.contains("flinch") {
            var probability: Int? = nil
            if effect.contains("10%") {
                probability = 10
            } else if effect.contains("20%") {
                probability = 20
            } else if effect.contains("30%") {
                probability = 30
            }

            if let prob = probability {
                results.append(AbilityEffect(
                    trigger: "on_dealing_damage",
                    condition: nil,
                    effectType: "additional_effect_chance",
                    target: "opponent",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: prob,
                        healAmount: nil, weather: nil, terrain: nil, status: "flinch",
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("flinch")
            }
        }

        // 接触技で状態異常付与
        if effect.contains("contact moves") && effect.contains("chance") {
            var status: String? = nil
            var probability = 30

            if effect.contains("paralyzed") {
                status = "paralysis"
            } else if effect.contains("poisoning") || effect.contains("poison") {
                status = "poison"
            } else if effect.contains("burn") || effect.contains("burned") {
                status = "burn"
            } else if effect.contains("freeze") || effect.contains("frozen") {
                status = "freeze"
            }

            if effect.contains("10%") {
                probability = 10
            } else if effect.contains("20%") {
                probability = 20
            } else if effect.contains("30%") {
                probability = 30
            }

            if let statusValue = status {
                results.append(AbilityEffect(
                    trigger: "on_attacking",
                    condition: nil,
                    effectType: "inflict_status",
                    target: "opponent",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: probability,
                        healAmount: nil, weather: nil, terrain: nil, status: statusValue,
                        moveType: nil, moveTypes: nil, moveFlag: "contact",
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("status_inflict")
            }
        }

        return results
    }

    // 能力下降無効
    private func detectPreventStatDecrease(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("cannot have its stats lowered") || effect.contains("cannot have any stat lowered") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "prevent_stat_decrease",
                target: "self",
                value: nil
            ))
            categories.append("stat_protection")
        }

        return results
    }

    // 状態異常同期
    private func detectSyncStatus(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if (effect.contains("is burned, paralyzed, or poisoned") || effect.contains("receives a burn, paralysis, or poison")) &&
           effect.contains("is also given the ailment") {
            results.append(AbilityEffect(
                trigger: "on_receiving_status",
                condition: nil,
                effectType: "sync_status",
                target: "attacker",
                value: nil
            ))
            categories.append("status_reflection")
        }

        return results
    }

    // 追加効果確率倍化
    private func detectDoubleEffectChance(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("moves have twice their usual effect chance") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "additional_effect_chance",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: 2.0, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("effect_boost")
        }

        return results
    }

    // ひるみ無効
    private func detectPreventFlinch(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("cannot be made to flinch") || effect.contains("cannot flinch") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "immune_to_status",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: "flinch",
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("status_immunity")
        }

        return results
    }

    // 状態異常回復
    private func detectCureStatus(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // 交代時の状態異常回復
        if (effect.contains("when this pokémon switches out") || effect.contains("when switched out")) &&
           (effect.contains("cured") || effect.contains("healed")) {
            results.append(AbilityEffect(
                trigger: "on_switch_out",
                condition: nil,
                effectType: "cure_status",
                target: "self",
                value: nil
            ))
            categories.append("status_recovery")
        }

        // ターン終了時の状態異常回復
        if effect.contains("has a") && effect.contains("chance of being cured") && effect.contains("at the end of each turn") {
            var probability: Int? = nil
            if effect.contains("30%") || effect.contains("33%") {
                probability = 33
            } else if effect.contains("50%") {
                probability = 50
            }

            if let prob = probability {
                results.append(AbilityEffect(
                    trigger: "on_turn_end",
                    condition: Condition(type: "has_status", value: nil),
                    effectType: "cure_status",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: nil, stageChange: nil, probability: prob,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("status_recovery")
            }
        }

        return results
    }

    // 状態異常時の能力上昇
    private func detectStatusBoost(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // guts, marvel-scale, quick-feet等
        if effect.contains("has a major status ailment") || effect.contains("is asleep, burned, paralyzed, or poisoned") {
            var stat: String? = nil
            var multiplier: Double? = nil

            if effect.contains("1.5× its attack") || effect.contains("1.5x its attack") {
                stat = "attack"
                multiplier = 1.5
            } else if effect.contains("1.5× its defense") || effect.contains("1.5x its defense") {
                stat = "defense"
                multiplier = 1.5
            } else if effect.contains("1.5× its speed") || effect.contains("1.5x its speed") {
                stat = "speed"
                multiplier = 1.5
            } else if effect.contains("1.5× its special attack") {
                stat = "special-attack"
                multiplier = 1.5
            } else if effect.contains("1.5× its special defense") {
                stat = "special-defense"
                multiplier = 1.5
            }

            if let stat = stat, let mult = multiplier {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: Condition(type: "has_status", value: nil),
                    effectType: "stat_multiplier",
                    target: "self",
                    value: EffectValue(
                        stat: stat, multiplier: mult, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("status_boost")
            }
        }

        return results
    }

    // 技フラグベースの威力上昇
    private func detectMoveFlagPowerBoost(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        var moveFlag: String? = nil
        var multiplier: Double? = nil

        if effect.contains("moves that make contact") || effect.contains("contact moves") {
            moveFlag = "contact"
            if effect.contains("1.33×") {
                multiplier = 1.33
            } else if effect.contains("1.3×") || effect.contains("1.3x") {
                multiplier = 1.3
            } else if effect.contains("1.2×") || effect.contains("1.2x") {
                multiplier = 1.2
            }
        } else if effect.contains("moves flagged as being punch-based") || effect.contains("punch-based moves") {
            moveFlag = "punch"
            if effect.contains("1.2×") || effect.contains("1.2x") {
                multiplier = 1.2
            } else if effect.contains("1.1×") || effect.contains("1.1x") {
                multiplier = 1.1
            }
        } else if effect.contains("moves flagged as being sound-based") && effect.contains("have") && effect.contains("their base power") {
            moveFlag = "sound"
            if effect.contains("1.3×") {
                multiplier = 1.3
            }
        } else if effect.contains("biting moves") || effect.contains("moves flagged as being bite-based") {
            moveFlag = "bite"
            if effect.contains("1.5×") {
                multiplier = 1.5
            }
        } else if effect.contains("pulse moves") || effect.contains("moves flagged as being pulse-based") {
            moveFlag = "pulse"
            if effect.contains("1.5×") {
                multiplier = 1.5
            }
        } else if effect.contains("slicing moves") || effect.contains("moves flagged as being slicing") {
            moveFlag = "slicing"
            if effect.contains("1.5×") {
                multiplier = 1.5
            }
        }

        if let flag = moveFlag, let mult = multiplier {
            results.append(AbilityEffect(
                trigger: "on_attacking",
                condition: nil,
                effectType: "move_power_multiplier",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: mult, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: flag,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append(contentsOf: ["power_boost", "move_flag_boost"])
        }

        return results
    }

    // STAB倍率変更
    private func detectSTABChange(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("inflicts twice as much damage with moves whose types match its own") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "move_power_multiplier",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: 2.0, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: "stab",
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("power_boost")
        }

        return results
    }

    // 急所ダメージ倍率変更
    private func detectCriticalDamageChange(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("inflicts triple damage with critical hits") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "critical_damage_multiplier",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: 3.0, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("critical_boost")
        }

        return results
    }

    // 命中必中
    private func detectAlwaysHit(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("moves used by or against this pokémon never miss") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "always_hit",
                target: "self",
                value: nil
            ))
            categories.append("accuracy_boost")
        }

        return results
    }

    // 反動無効
    private func detectNoRecoil(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("does not receive recoil damage") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "remove_additional_effect",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: "recoil",
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("defensive")
        }

        return results
    }

    // 音技無効
    private func detectSoundproofing(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("immune to moves flagged as being sound-based") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "immune_to_move",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: "sound",
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("move_immunity")
        }

        return results
    }

    // 特定能力下降無効
    private func detectSpecificStatProtection(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        var protectedStat: String? = nil

        if effect.contains("attack cannot be lowered") {
            protectedStat = "attack"
        } else if effect.contains("defense cannot be lowered") {
            protectedStat = "defense"
        } else if effect.contains("cannot have its accuracy lowered") {
            protectedStat = "accuracy"
        } else if effect.contains("cannot have its evasion lowered") {
            protectedStat = "evasion"
        } else if effect.contains("speed cannot be lowered") {
            protectedStat = "speed"
        }

        if let stat = protectedStat {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "prevent_stat_decrease",
                target: "self",
                value: EffectValue(
                    stat: stat, multiplier: nil, stageChange: nil, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("stat_protection")
        }

        return results
    }

    // 急所率変更
    private func detectCriticalRateChange(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        if effect.contains("critical hit rates one stage higher") {
            results.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "critical_rate_change",
                target: "self",
                value: EffectValue(
                    stat: nil, multiplier: nil, stageChange: 1, probability: nil,
                    healAmount: nil, weather: nil, terrain: nil, status: nil,
                    moveType: nil, moveTypes: nil, moveFlag: nil,
                    specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                    specificItemName: nil, itemCategory: nil, randomElement: nil,
                    accumulationSource: nil, flagName: nil, fixedValue: nil,
                    highestStat: nil, typeSource: nil, hazardType: nil,
                    stageChangeUp: nil, stageChangeDown: nil
                )
            ))
            categories.append("critical_boost")
        }

        return results
    }

    // 受けるダメージ倍率
    private func detectDamageMultiplier(_ effect: String, _ categories: inout [String]) -> [AbilityEffect] {
        var results: [AbilityEffect] = []

        // "takes X× as much damage" または "damage this Pokémon takes is reduced to X×"
        if (effect.contains("takes") && effect.contains("as much damage")) ||
           (effect.contains("damage") && effect.contains("takes") && effect.contains("reduced")) {

            var multiplier: Double? = nil
            var condition: Condition? = nil

            // 倍率の検出
            if effect.contains("0.75×") {
                multiplier = 0.75
            } else if effect.contains("0.5×") || effect.contains("half") {
                multiplier = 0.5
            } else if effect.contains("0.25×") || effect.contains("quarter") {
                multiplier = 0.25
            }

            // 条件の検出（効果抜群）
            if effect.contains("super effective") || effect.contains("super-effective") {
                condition = Condition(
                    type: "effectiveness",
                    value: ConditionValue.effectiveness("super_effective")
                )
            }

            if let mult = multiplier {
                results.append(AbilityEffect(
                    trigger: "passive",
                    condition: condition,
                    effectType: "damage_multiplier",
                    target: "self",
                    value: EffectValue(
                        stat: nil, multiplier: mult, stageChange: nil, probability: nil,
                        healAmount: nil, weather: nil, terrain: nil, status: nil,
                        moveType: nil, moveTypes: nil, moveFlag: nil,
                        specificMoveName: nil, specificMoveNames: nil, specificFormName: nil,
                        specificItemName: nil, itemCategory: nil, randomElement: nil,
                        accumulationSource: nil, flagName: nil, fixedValue: nil,
                        highestStat: nil, typeSource: nil, hazardType: nil,
                        stageChangeUp: nil, stageChangeDown: nil
                    )
                ))
                categories.append("damage_reduction")
            }
        }

        return results
    }
}

// MARK: - Main Script

// 入力ファイルの読み込み
let inputPath = "Pokedex/Resources/PreloadedData/scarlet_violet.json"
guard let inputData = try? Data(contentsOf: URL(fileURLWithPath: inputPath)) else {
    print("❌ Failed to read input file: \(inputPath)")
    exit(1)
}

guard let input = try? JSONDecoder().decode(InputData.self, from: inputData) else {
    print("❌ Failed to decode input data")
    exit(1)
}

print("✅ Loaded \(input.abilities.count) abilities")

// メタデータ生成
let analyzer = AbilityEffectAnalyzer()
let metadataList = input.abilities.map { analyzer.analyze($0) }

print("✅ Generated metadata for \(metadataList.count) abilities")

// JSON出力
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

guard let outputData = try? encoder.encode(metadataList) else {
    print("❌ Failed to encode output data")
    exit(1)
}

let outputPath = "Pokedex/Resources/PreloadedData/ability_metadata.json"
do {
    try outputData.write(to: URL(fileURLWithPath: outputPath))
    print("✅ Successfully wrote to: \(outputPath)")
} catch {
    print("❌ Failed to write output file: \(error)")
    exit(1)
}

print("🎉 Generation complete!")
