//
//  AbilityMetadata.swift
//  Pokedex
//
//  Created by Claude Code on 2025-10-15.
//

import Foundation

// MARK: - AbilityMetadata

struct AbilityMetadata: Codable {
    let schemaVersion: Int
    let id: Int
    let name: String
    let nameJa: String
    let effect: String      // 英語説明
    let effectJa: String    // 日本語説明
    let effects: [AbilityEffect]
    let categories: [String]
    let pokemonRestriction: [String]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        nameJa = try container.decode(String.self, forKey: .nameJa)
        effect = try container.decode(String.self, forKey: .effect)
        effectJa = try container.decode(String.self, forKey: .effectJa)
        effects = try container.decode([AbilityEffect].self, forKey: .effects)
        categories = try container.decode([String].self, forKey: .categories)
        pokemonRestriction = try container.decodeIfPresent([String].self, forKey: .pokemonRestriction)
    }
}

// MARK: - AbilityEffect

struct AbilityEffect: Codable {
    let trigger: Trigger
    let condition: Condition?
    let effectType: EffectType
    let target: Target
    let value: EffectValue?
}

// MARK: - Trigger

enum Trigger: String, Codable {
    case passive = "passive"
    case onSwitchIn = "on_switch_in"
    case onAttacking = "on_attacking"
    case onBeingHit = "on_being_hit"
    case onContact = "on_contact"
    case onMakingContact = "on_making_contact"
    case onTurnEnd = "on_turn_end"
    case onSwitchOut = "on_switch_out"
    case onStatChange = "on_stat_change"
    case onKO = "on_ko"
    case onAllyFainted = "on_ally_fainted"
    case onHPThreshold = "on_hp_threshold"
    case afterMove = "after_move"
    case onCriticalHit = "on_critical_hit"
    case onFlinch = "on_flinch"
    case onAllyMove = "on_ally_move"
    case onAnyPokemonMove = "on_any_pokemon_move"
    case afterSpecificMove = "after_specific_move"
    case onItemConsumed = "on_item_consumed"
    case onFaintAny = "on_faint_any"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Trigger(rawValue: rawValue) ?? .unknown
    }
}

// MARK: - Condition

struct Condition: Codable {
    let type: ConditionType
    let value: ConditionValue?
}

enum ConditionType: String, Codable {
    case hpBelow = "hp_below"
    case hpAbove = "hp_above"
    case hpFull = "hp_full"
    case weather = "weather"
    case terrain = "terrain"
    case moveType = "move_type"
    case pokemonType = "pokemon_type"
    case movePower = "move_power"
    case moveCategory = "move_category"
    case moveFlag = "move_flag"
    case status = "status"
    case confused = "confused"
    case turnCount = "turn_count"
    case hasItem = "has_item"
    case targetSwitchedIn = "target_switched_in"
    case effectiveness = "effectiveness"
    case holdingSpecificItem = "holding_specific_item"
    case highestStat = "highest_stat"
    case specificMoveUsed = "specific_move_used"
    case defeatedAlliesCount = "defeated_allies_count"
    case flagActive = "flag_active"
    case opposingPokemonCount = "opposing_pokemon_count"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = ConditionType(rawValue: rawValue) ?? .unknown
    }
}

enum ConditionValue: Codable {
    case fraction(numerator: Int, denominator: Int)
    case percentage(Int)
    case weather(Weather)
    case terrain(Terrain)
    case type(String)
    case types([String])
    case moveFlag(MoveFlag)
    case status(Status)
    case number(Int)
    case effectiveness(Effectiveness)
    case itemName(String)
    case itemCategory(String)
    case moveNames([String])
    case flagName(String)

    enum CodingKeys: String, CodingKey {
        case fraction, percentage, weather, terrain, type, types, moveFlag, status, number, effectiveness, itemName, itemCategory, moveNames, flagName
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let fraction = try? container.decode([String: Int].self, forKey: .fraction) {
            self = .fraction(numerator: fraction["numerator"] ?? 0, denominator: fraction["denominator"] ?? 1)
        } else if let percentage = try? container.decode(Int.self, forKey: .percentage) {
            self = .percentage(percentage)
        } else if let weather = try? container.decode(Weather.self, forKey: .weather) {
            self = .weather(weather)
        } else if let terrain = try? container.decode(Terrain.self, forKey: .terrain) {
            self = .terrain(terrain)
        } else if let types = try? container.decode([String].self, forKey: .types) {
            self = .types(types)
        } else if let type = try? container.decode(String.self, forKey: .type) {
            self = .type(type)
        } else if let moveFlag = try? container.decode(MoveFlag.self, forKey: .moveFlag) {
            self = .moveFlag(moveFlag)
        } else if let status = try? container.decode(Status.self, forKey: .status) {
            self = .status(status)
        } else if let number = try? container.decode(Int.self, forKey: .number) {
            self = .number(number)
        } else if let effectiveness = try? container.decode(Effectiveness.self, forKey: .effectiveness) {
            self = .effectiveness(effectiveness)
        } else if let itemName = try? container.decode(String.self, forKey: .itemName) {
            self = .itemName(itemName)
        } else if let itemCategory = try? container.decode(String.self, forKey: .itemCategory) {
            self = .itemCategory(itemCategory)
        } else if let moveNames = try? container.decode([String].self, forKey: .moveNames) {
            self = .moveNames(moveNames)
        } else if let flagName = try? container.decode(String.self, forKey: .flagName) {
            self = .flagName(flagName)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode ConditionValue")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .fraction(let numerator, let denominator):
            try container.encode(["numerator": numerator, "denominator": denominator], forKey: .fraction)
        case .percentage(let value):
            try container.encode(value, forKey: .percentage)
        case .weather(let value):
            try container.encode(value, forKey: .weather)
        case .terrain(let value):
            try container.encode(value, forKey: .terrain)
        case .type(let value):
            try container.encode(value, forKey: .type)
        case .types(let value):
            try container.encode(value, forKey: .types)
        case .moveFlag(let value):
            try container.encode(value, forKey: .moveFlag)
        case .status(let value):
            try container.encode(value, forKey: .status)
        case .number(let value):
            try container.encode(value, forKey: .number)
        case .effectiveness(let value):
            try container.encode(value, forKey: .effectiveness)
        case .itemName(let value):
            try container.encode(value, forKey: .itemName)
        case .itemCategory(let value):
            try container.encode(value, forKey: .itemCategory)
        case .moveNames(let value):
            try container.encode(value, forKey: .moveNames)
        case .flagName(let value):
            try container.encode(value, forKey: .flagName)
        }
    }
}

// MARK: - EffectType

enum EffectType: String, Codable {
    case statMultiplier = "stat_multiplier"
    case statStageChange = "stat_stage_change"
    case preventStatDecrease = "prevent_stat_decrease"
    case ignoreStatChanges = "ignore_stat_changes"
    case reverseStatChanges = "reverse_stat_changes"
    case doubleStatChanges = "double_stat_changes"
    case movePowerMultiplier = "move_power_multiplier"
    case damageMultiplier = "damage_multiplier"
    case immuneToMove = "immune_to_move"
    case immuneToType = "immune_to_type"
    case absorbType = "absorb_type"
    case contactDamage = "contact_damage"
    case surviveHit = "survive_hit"
    case immuneToStatus = "immune_to_status"
    case inflictStatus = "inflict_status"
    case cureStatus = "cure_status"
    case syncStatus = "sync_status"
    case setWeather = "set_weather"
    case setTerrain = "set_terrain"
    case nullifyWeather = "nullify_weather"
    case healHP = "heal_hp"
    case accuracyMultiplier = "accuracy_multiplier"
    case evasionMultiplier = "evasion_multiplier"
    case criticalRateChange = "critical_rate_change"
    case criticalDamageMultiplier = "critical_damage_multiplier"
    case preventCritical = "prevent_critical"
    case alwaysHit = "always_hit"
    case additionalEffectChance = "additional_effect_chance"
    case removeAdditionalEffect = "remove_additional_effect"
    case preventAdditionalEffect = "prevent_additional_effect"
    case multiHitCount = "multi_hit_count"
    case priorityChange = "priority_change"
    case convertMoveType = "convert_move_type"
    case makeNonContact = "make_non_contact"
    case reflectStatusMove = "reflect_status_move"
    case changeUserType = "change_user_type"
    case changeTargetType = "change_target_type"
    case ignoreAbility = "ignore_ability"
    case nullifyAbilities = "nullify_abilities"
    case copyAbility = "copy_ability"
    case changeAbility = "change_ability"
    case swapAbility = "swap_ability"
    case preventItemLoss = "prevent_item_loss"
    case stealItem = "steal_item"
    case disableItem = "disable_item"
    case berryEffect = "berry_effect"
    case preventSwitch = "prevent_switch"
    case preventForcedSwitch = "prevent_forced_switch"
    case forceSwitch = "force_switch"
    case redirectMove = "redirect_move"
    case formChange = "form_change"
    case transform = "transform"
    case disguise = "disguise"
    case preventRecoil = "prevent_recoil"
    case immuneToIndirectDamage = "immune_to_indirect_damage"
    case increasePPCost = "increase_pp_cost"
    case disableMove = "disable_move"
    case weightMultiplier = "weight_multiplier"
    case preventAction = "prevent_action"
    case protectAlly = "protect_ally"
    case damageReductionFullHP = "damage_reduction_full_hp"
    case bypassProtection = "bypass_protection"
    case reflectStatChanges = "reflect_stat_changes"
    case copyStatChanges = "copy_stat_changes"
    case cumulativeStatBoost = "cumulative_stat_boost"
    case randomStatChange = "random_stat_change"
    case setAccuracyFixed = "set_accuracy_fixed"
    case forceSlowStatusMove = "force_slow_status_move"
    case multiHitExact = "multi_hit_exact"
    case replicateMove = "replicate_move"
    case createHazard = "create_hazard"
    case grantAbilityToAlly = "grant_ability_to_ally"
    case boostAllyMovePower = "boost_ally_move_power"
    case healAlly = "heal_ally"
    case passItemToAlly = "pass_item_to_ally"
    case protectAllyFromStatus = "protect_ally_from_status"
    case setFlag = "set_flag"
    case consumeItemAgain = "consume_item_again"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = EffectType(rawValue: rawValue) ?? .unknown
    }
}

// MARK: - Target

enum Target: String, Codable {
    case self_ = "self"
    case opponent = "opponent"
    case allOpponents = "all_opponents"
    case ally = "ally"
    case allAllies = "all_allies"
    case field = "field"
    case move = "move"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Target(rawValue: rawValue) ?? .unknown
    }
}

// MARK: - EffectValue

struct EffectValue: Codable {
    let stat: Stat?
    let multiplier: Double?
    let stageChange: Int?
    let probability: Int?
    let healAmount: HealAmount?
    let weather: Weather?
    let terrain: Terrain?
    let status: Status?
    let moveType: String?
    let moveTypes: [String]?
    let moveFlag: MoveFlag?
    let turnCount: Int?
    let effectiveness: Effectiveness?
    let specificMoveName: String?
    let specificMoveNames: [String]?
    let specificFormName: String?
    let specificItemName: String?
    let itemCategory: String?
    let randomElement: Bool?
    let accumulationSource: AccumulationSource?
    let flagName: String?
    let fixedValue: Int?
    let highestStat: Bool?
    let typeSource: String?
    let hazardType: String?
    let stageChangeUp: Int?
    let stageChangeDown: Int?
}

// MARK: - Supporting Enums

enum Stat: String, Codable {
    case hp, attack, defense, specialAttack, specialDefense, speed, accuracy, evasion
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Stat(rawValue: rawValue) ?? .unknown
    }
}

enum HealAmount: Codable {
    case fraction(numerator: Int, denominator: Int)
    case percentage(Int)

    enum CodingKeys: String, CodingKey {
        case fraction, percentage
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let fraction = try? container.decode([String: Int].self, forKey: .fraction) {
            self = .fraction(numerator: fraction["numerator"] ?? 0, denominator: fraction["denominator"] ?? 1)
        } else if let percentage = try? container.decode(Int.self, forKey: .percentage) {
            self = .percentage(percentage)
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unable to decode HealAmount")
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case .fraction(let numerator, let denominator):
            try container.encode(["numerator": numerator, "denominator": denominator], forKey: .fraction)
        case .percentage(let value):
            try container.encode(value, forKey: .percentage)
        }
    }
}

enum Weather: String, Codable {
    case sun, rain, sandstorm, hail, snow
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Weather(rawValue: rawValue) ?? .unknown
    }
}

enum Terrain: String, Codable {
    case electric, grassy, misty, psychic
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Terrain(rawValue: rawValue) ?? .unknown
    }
}

enum Status: String, Codable {
    case burn, freeze, paralysis, poison, badlyPoisoned, sleep
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Status(rawValue: rawValue) ?? .unknown
    }
}

enum MoveFlag: String, Codable {
    case contact, sound, punch, bite, pulse, blade, ballistic
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = MoveFlag(rawValue: rawValue) ?? .unknown
    }
}

enum Effectiveness: String, Codable {
    case superEffective = "super_effective"
    case notVeryEffective = "not_very_effective"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Effectiveness(rawValue: rawValue) ?? .unknown
    }
}

enum AccumulationSource: String, Codable {
    case defeatedAllies = "defeated_allies"
    case defeatedOpponents = "defeated_opponents"
    case defeatedAny = "defeated_any"
    case unknown = "unknown"

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = AccumulationSource(rawValue: rawValue) ?? .unknown
    }
}

// MARK: - UI Extensions

extension Trigger {
    var displayName: String {
        switch self {
        case .passive: return "常時"
        case .onSwitchIn: return "場に出た時"
        case .onAttacking: return "攻撃時"
        case .onBeingHit: return "被弾時"
        case .onContact: return "接触時（防御）"
        case .onMakingContact: return "接触時（攻撃）"
        case .onTurnEnd: return "ターン終了時"
        case .onSwitchOut: return "交代時"
        case .onStatChange: return "能力変化時"
        case .onKO: return "相手を倒した時"
        case .onAllyFainted: return "味方が倒れた時"
        case .onHPThreshold: return "HP閾値到達時"
        case .afterMove: return "技使用後"
        case .onCriticalHit: return "急所を受けた時"
        case .onFlinch: return "ひるんだ時"
        case .onAllyMove: return "味方の技使用時"
        case .onAnyPokemonMove: return "誰かの技使用時"
        case .afterSpecificMove: return "特定技使用後"
        case .onItemConsumed: return "道具消費時"
        case .onFaintAny: return "誰かが倒れた時"
        case .unknown: return "不明"
        }
    }

    // UI用の主要なトリガー
    static let uiCases: [Trigger] = [
        .passive,
        .onSwitchIn,
        .onAttacking,
        .onBeingHit,
        .onTurnEnd,
        .onSwitchOut,
        .onContact,
        .onStatChange
    ]
}

extension EffectType {
    var displayName: String {
        switch self {
        case .statMultiplier: return "能力値倍率"
        case .statStageChange: return "能力ランク変化"
        case .preventStatDecrease: return "能力低下無効"
        case .ignoreStatChanges: return "能力変化無視"
        case .reverseStatChanges: return "能力変化反転"
        case .doubleStatChanges: return "能力変化2倍"
        case .movePowerMultiplier: return "技威力倍率"
        case .damageMultiplier: return "受けるダメージ倍率"
        case .immuneToMove: return "技無効化"
        case .immuneToType: return "タイプ無効化"
        case .absorbType: return "タイプ吸収"
        case .contactDamage: return "接触ダメージ"
        case .surviveHit: return "一撃耐え"
        case .immuneToStatus: return "状態異常無効"
        case .inflictStatus: return "状態異常付与"
        case .cureStatus: return "状態異常回復"
        case .syncStatus: return "状態異常反射"
        case .setWeather: return "天候設定"
        case .setTerrain: return "フィールド設定"
        case .nullifyWeather: return "天候無効化"
        case .healHP: return "HP回復"
        case .accuracyMultiplier: return "命中率倍率"
        case .evasionMultiplier: return "回避率倍率"
        case .criticalRateChange: return "急所率変化"
        case .criticalDamageMultiplier: return "急所ダメージ倍率"
        case .preventCritical: return "急所無効"
        case .alwaysHit: return "必中"
        case .additionalEffectChance: return "追加効果確率変化"
        case .removeAdditionalEffect: return "追加効果削除"
        case .preventAdditionalEffect: return "追加効果無効"
        case .multiHitCount: return "連続攻撃回数変化"
        case .priorityChange: return "優先度変更"
        case .convertMoveType: return "技タイプ変換"
        case .makeNonContact: return "非接触化"
        case .reflectStatusMove: return "変化技反射"
        case .changeUserType: return "自分タイプ変更"
        case .changeTargetType: return "相手タイプ変更"
        case .ignoreAbility: return "特性無視"
        case .nullifyAbilities: return "全特性無効化"
        case .copyAbility: return "特性コピー"
        case .changeAbility: return "特性変更"
        case .swapAbility: return "特性入れ替え"
        case .preventItemLoss: return "道具保護"
        case .stealItem: return "道具奪取"
        case .disableItem: return "道具無効化"
        case .berryEffect: return "きのみ効果変更"
        case .preventSwitch: return "交代封じ"
        case .preventForcedSwitch: return "強制交代無効"
        case .forceSwitch: return "強制交代"
        case .redirectMove: return "技引き寄せ"
        case .formChange: return "フォルムチェンジ"
        case .transform: return "変身"
        case .disguise: return "見た目変更"
        case .preventRecoil: return "反動無効"
        case .immuneToIndirectDamage: return "間接ダメージ無効"
        case .increasePPCost: return "PP消費増加"
        case .disableMove: return "技封じ"
        case .weightMultiplier: return "重さ変更"
        case .preventAction: return "行動制限"
        case .protectAlly: return "味方保護"
        case .damageReductionFullHP: return "満タン時ダメージ軽減"
        case .bypassProtection: return "保護技貫通"
        case .reflectStatChanges: return "能力変化反射"
        case .copyStatChanges: return "能力変化コピー"
        case .cumulativeStatBoost: return "累積型能力上昇"
        case .randomStatChange: return "ランダム能力変化"
        case .setAccuracyFixed: return "命中率固定"
        case .forceSlowStatusMove: return "変化技後攻化"
        case .multiHitExact: return "連続攻撃回数固定"
        case .replicateMove: return "技コピー"
        case .createHazard: return "設置技設置"
        case .grantAbilityToAlly: return "味方に特性付与"
        case .boostAllyMovePower: return "味方技威力上昇"
        case .healAlly: return "味方回復"
        case .passItemToAlly: return "味方に道具渡す"
        case .protectAllyFromStatus: return "味方状態異常防止"
        case .setFlag: return "内部フラグ設定"
        case .consumeItemAgain: return "きのみ再消費"
        case .unknown: return "不明"
        }
    }

    // UI用の主要な効果タイプ
    static let uiCases: [EffectType] = [
        .statMultiplier,
        .movePowerMultiplier,
        .immuneToType,
        .absorbType,
        .immuneToStatus,
        .setWeather,
        .setTerrain,
        .healHP,
        .statStageChange,
        .preventStatDecrease,
        .damageMultiplier,
        .contactDamage
    ]
}

extension Weather {
    var displayName: String {
        switch self {
        case .sun: return "晴れ"
        case .rain: return "雨"
        case .sandstorm: return "砂嵐"
        case .hail: return "あられ"
        case .snow: return "雪"
        case .unknown: return "不明"
        }
    }
}

extension Terrain {
    var displayName: String {
        switch self {
        case .electric: return "エレキフィールド"
        case .grassy: return "グラスフィールド"
        case .misty: return "ミストフィールド"
        case .psychic: return "サイコフィールド"
        case .unknown: return "不明"
        }
    }
}

extension Status {
    var displayName: String {
        switch self {
        case .burn: return "やけど"
        case .freeze: return "こおり"
        case .paralysis: return "まひ"
        case .poison: return "どく"
        case .badlyPoisoned: return "もうどく"
        case .sleep: return "ねむり"
        case .unknown: return "不明"
        }
    }
}
