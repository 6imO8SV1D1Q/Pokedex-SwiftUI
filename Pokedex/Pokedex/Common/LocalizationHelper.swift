//
//  LocalizationHelper.swift
//  Pokedex
//
//  Created on 2025-10-27.
//

import Foundation
import SwiftUI

/// ローカライズ文字列を取得するためのヘルパー
enum L10n {
    // MARK: - Common
    enum Common {
        static let ok = LocalizedStringKey("common.ok")
        static let cancel = LocalizedStringKey("common.cancel")
        static let add = LocalizedStringKey("common.add")
        static let save = LocalizedStringKey("common.save")
        static let delete = LocalizedStringKey("common.delete")
        static let done = LocalizedStringKey("common.done")
        static let clear = LocalizedStringKey("common.clear")
        static let all = LocalizedStringKey("common.all")
        static let loading = LocalizedStringKey("common.loading")
        static let error = LocalizedStringKey("common.error")
        static let unknownError = NSLocalizedString("common.unknown_error", comment: "")
        static let pokedex = LocalizedStringKey("common.pokedex")
        static let versionGroup = LocalizedStringKey("common.version_group")
    }

    // MARK: - Stats
    enum Stat {
        static let hp = LocalizedStringKey("stat.hp")
        static let attack = LocalizedStringKey("stat.attack")
        static let defense = LocalizedStringKey("stat.defense")
        static let specialAttack = LocalizedStringKey("stat.special_attack")
        static let specialDefense = LocalizedStringKey("stat.special_defense")
        static let speed = LocalizedStringKey("stat.speed")
        static let total = LocalizedStringKey("stat.total")
        static let power = LocalizedStringKey("stat.power")
        static let accuracy = LocalizedStringKey("stat.accuracy")
        static let pp = LocalizedStringKey("stat.pp")
        static let priority = LocalizedStringKey("stat.priority")
    }

    // MARK: - Types
    enum PokemonType {
        static func localized(_ type: String) -> LocalizedStringKey {
            return LocalizedStringKey("type.\(type)")
        }

        static func localizedString(_ type: String) -> String {
            return NSLocalizedString("type.\(type)", comment: "")
        }
    }

    // MARK: - Damage Classes
    enum DamageClass {
        static func localized(_ damageClass: String) -> LocalizedStringKey {
            return LocalizedStringKey("damage_class.\(damageClass)")
        }

        static func localizedString(_ damageClass: String) -> String {
            return NSLocalizedString("damage_class.\(damageClass)", comment: "")
        }
    }

    // MARK: - Sections
    enum Section {
        static let typeMatchup = LocalizedStringKey("section.type_matchup")
        static let baseStats = LocalizedStringKey("section.base_stats")
        static let calculatedStats = LocalizedStringKey("section.calculated_stats")
        static let abilities = LocalizedStringKey("section.abilities")
        static let moves = LocalizedStringKey("section.moves")
        static let ecology = LocalizedStringKey("section.ecology")
        static let battle = LocalizedStringKey("section.battle")
    }

    // MARK: - Filters
    enum Filter {
        static let title = LocalizedStringKey("filter.title")
        static let clear = LocalizedStringKey("filter.clear")
        static let apply = LocalizedStringKey("filter.apply")
        static let or = LocalizedStringKey("filter.or")
        static let and = LocalizedStringKey("filter.and")
        static let type = LocalizedStringKey("filter.type")
        static let category = LocalizedStringKey("filter.category")
        static let target = LocalizedStringKey("filter.target")
        static let statusCondition = LocalizedStringKey("filter.status_condition")
        static let statChangeUser = LocalizedStringKey("filter.stat_change_user")
        static let statChangeOpponent = LocalizedStringKey("filter.stat_change_opponent")
        static let hpDrain = LocalizedStringKey("filter.hp_drain")
        static let hpHealing = LocalizedStringKey("filter.hp_healing")
        static let moveNote = LocalizedStringKey("filter.move_note")
        static let trigger = LocalizedStringKey("filter.trigger")
        static let effect = LocalizedStringKey("filter.effect")
        static let weather = LocalizedStringKey("filter.weather")
        static let terrain = LocalizedStringKey("filter.terrain")
        static let searchMode = LocalizedStringKey("filter.search_mode")
        static let min = LocalizedStringKey("filter.min")
        static let max = LocalizedStringKey("filter.max")
        static let baseStats = LocalizedStringKey("filter.base_stats")
        static let baseStatsDescription = LocalizedStringKey("filter.base_stats_description")
        static let evolution = LocalizedStringKey("filter.evolution")
        static let evolutionStageLabel = LocalizedStringKey("filter.evolution_stage_label")
        static let evolutionAllDescription = LocalizedStringKey("filter.evolution_all_description")
        static let evolutionFinalDescription = LocalizedStringKey("filter.evolution_final_description")
        static let evolutionEvioliteDescription = LocalizedStringKey("filter.evolution_eviolite_description")
        static let typeOrDescription = LocalizedStringKey("filter.type_or_description")
        static let typeAndDescription = LocalizedStringKey("filter.type_and_description")
        static let region = LocalizedStringKey("filter.region")
        static let regionDescription = LocalizedStringKey("filter.region_description")
        static let ability = LocalizedStringKey("filter.ability")
        static let abilitySearchPlaceholder = LocalizedStringKey("filter.ability_search_placeholder")
        static let abilityAddCondition = LocalizedStringKey("filter.ability_add_condition")
        static let abilityConditionsHeader = LocalizedStringKey("filter.ability_conditions_header")
        static let abilityOrDescription = LocalizedStringKey("filter.ability_or_description")
        static let abilityAndDescription = LocalizedStringKey("filter.ability_and_description")
        static let abilityCategory = LocalizedStringKey("filter.ability_category")
        static let move = LocalizedStringKey("filter.move")
        static let moveSearchPlaceholder = LocalizedStringKey("filter.move_search_placeholder")
        static let moveAddCondition = LocalizedStringKey("filter.move_add_condition")
        static let moveConditionsHeader = LocalizedStringKey("filter.move_conditions_header")
        static let moveOrDescription = LocalizedStringKey("filter.move_or_description")
        static let moveAndDescription = LocalizedStringKey("filter.move_and_description")
        static let recovery = LocalizedStringKey("filter.recovery")
        static let statChange = LocalizedStringKey("filter.stat_change")
        static let categories = LocalizedStringKey("filter.categories")
        static let statMultiplier = LocalizedStringKey("filter.stat_multiplier")
        static let movePowerMultiplier = LocalizedStringKey("filter.move_power_multiplier")
        static let activationRate = LocalizedStringKey("filter.activation_rate")
        static let abilityCategoryDescriptionEmpty = LocalizedStringKey("filter.ability_category_description_empty")
        static let abilityCategoryDescription = LocalizedStringKey("filter.ability_category_description")
        static let moveConditions = LocalizedStringKey("filter.move_conditions")
        static let abilityConditions = LocalizedStringKey("filter.ability_conditions")
        static let moveCategoryHeader = LocalizedStringKey("filter.move_category_header")
        static let moveCategoryFooter = LocalizedStringKey("filter.move_category_footer")
        static let numericConditions = LocalizedStringKey("filter.numeric_conditions")
        static let numericConditionsDescription = LocalizedStringKey("filter.numeric_conditions_description")
        static let activationRatePercent = LocalizedStringKey("filter.activation_rate_percent")
        static let powerAccuracyPP = LocalizedStringKey("filter.power_accuracy_pp")
        static let setConditionsDescription = LocalizedStringKey("filter.set_conditions_description")
        static let notSpecified = LocalizedStringKey("filter.not_specified")
        static let priorityDescription = LocalizedStringKey("filter.priority_description")
        static let damageClassHeader = LocalizedStringKey("filter.damage_class_header")
        static let effectType = LocalizedStringKey("filter.effect_type")
        static let effectTypeDescriptionEmpty = LocalizedStringKey("filter.effect_type_description_empty")
        static let effectTypeDescription = LocalizedStringKey("filter.effect_type_description")
        static let weatherTerrain = LocalizedStringKey("filter.weather_terrain")
        static let weatherTerrainDescriptionEmpty = LocalizedStringKey("filter.weather_terrain_description_empty")
        static let weatherTerrainDescription = LocalizedStringKey("filter.weather_terrain_description")
        static let moveTarget = LocalizedStringKey("filter.move_target")
        static let moveType = LocalizedStringKey("filter.move_type")
        static let triggerTiming = LocalizedStringKey("filter.trigger_timing")
        static let triggerTimingDescriptionEmpty = LocalizedStringKey("filter.trigger_timing_description_empty")
        static let triggerTimingDescription = LocalizedStringKey("filter.trigger_timing_description")

        static func condition(_ number: Int) -> String {
            return String(format: NSLocalizedString("filter.condition", comment: ""), number)
        }

        static func conditionCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("filter.condition_count", comment: ""), count)
        }

        static func selectedCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("filter.selected_count", comment: ""), count)
        }

        static func maxSelection(_ current: Int) -> String {
            return String(format: NSLocalizedString("filter.max_selection", comment: ""), current)
        }

        static func categoriesCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("filter.categories_count", comment: ""), count)
        }

        static let powerLabel = NSLocalizedString("filter.power_label", comment: "")
        static let accuracyLabel = NSLocalizedString("filter.accuracy_label", comment: "")
        static let ppLabel = NSLocalizedString("filter.pp_label", comment: "")
        static let priorityLabel = NSLocalizedString("filter.priority_label", comment: "")

        static func priorityValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.priority_value", comment: ""), value)
        }

        static func affectedTypesValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.affected_types_value", comment: ""), value)
        }

        static func targetValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.target_value", comment: ""), value)
        }

        static func statusConditionValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.status_condition_value", comment: ""), value)
        }

        static func recoveryValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.recovery_value", comment: ""), value)
        }

        static func statChangeValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.stat_change_value", comment: ""), value)
        }

        static func triggerValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.trigger_value", comment: ""), value)
        }

        static func effectValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.effect_value", comment: ""), value)
        }

        static func weatherValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.weather_value", comment: ""), value)
        }

        static func terrainValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.terrain_value", comment: ""), value)
        }

        static func categoryValue(_ value: String) -> String {
            return String(format: NSLocalizedString("filter.category_value", comment: ""), value)
        }
    }

    // MARK: - Move Targets
    enum Target {
        static func localized(_ target: String) -> LocalizedStringKey {
            let key = target.replacingOccurrences(of: "-", with: "_")
            return LocalizedStringKey("target.\(key)")
        }

        static func localizedString(_ target: String) -> String {
            let key = target.replacingOccurrences(of: "-", with: "_")
            return NSLocalizedString("target.\(key)", comment: "")
        }
    }

    // MARK: - Messages
    enum Message {
        static let loading = LocalizedStringKey("message.loading")
        static let registeringData = LocalizedStringKey("message.registering_data")

        static func loadingFailed(_ error: String) -> String {
            return String(format: NSLocalizedString("message.loading_failed", comment: ""), error)
        }

        static func unexpectedError(_ error: String) -> String {
            return String(format: NSLocalizedString("message.unexpected_error", comment: ""), error)
        }

        static func progress(_ current: Int, _ total: Int) -> String {
            return String(format: NSLocalizedString("message.progress", comment: ""), current, total)
        }

        static func percent(_ value: Int) -> String {
            return String(format: NSLocalizedString("message.percent", comment: ""), value)
        }
    }

    // MARK: - Pokemon List
    enum PokemonList {
        static let title = LocalizedStringKey("pokemon_list.title")
        static let searchPrompt = LocalizedStringKey("pokemon_list.search_prompt")
        static let filteringMoves = LocalizedStringKey("pokemon_list.filtering_moves")
        static let pleaseWait = LocalizedStringKey("pokemon_list.please_wait")
        static let emptyTitle = LocalizedStringKey("pokemon_list.empty_title")
        static let emptyMessage = LocalizedStringKey("pokemon_list.empty_message")
        static let clearFilters = LocalizedStringKey("pokemon_list.clear_filters")

        static func filterResult(_ count: Int) -> String {
            return String(format: NSLocalizedString("pokemon_list.filter_result", comment: ""), count)
        }

        static func totalCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("pokemon_list.total_count", comment: ""), count)
        }

        static let countSeparator = NSLocalizedString("pokemon_list.count_separator", comment: "")
    }

    // MARK: - Pokemon Detail
    enum PokemonDetail {
        static let normal = LocalizedStringKey("pokemon_detail.normal")
        static let shiny = LocalizedStringKey("pokemon_detail.shiny")
        static let abilityLabel = LocalizedStringKey("pokemon_detail.ability_label")
        static let hiddenAbility = NSLocalizedString("pokemon_detail.hidden_ability", comment: "")
        static let genderRatio = LocalizedStringKey("pokemon_detail.gender_ratio")
        static let eggGroups = LocalizedStringKey("pokemon_detail.egg_groups")
        static let evolution = LocalizedStringKey("pokemon_detail.evolution")
        static let heightLabel = LocalizedStringKey("pokemon_detail.height_label")
        static let weightLabel = LocalizedStringKey("pokemon_detail.weight_label")
        static let form = LocalizedStringKey("pokemon_detail.form")
        static let totalStats = LocalizedStringKey("pokemon_detail.total_stats")
        static let none = LocalizedStringKey("pokemon_detail.none")
        static let loadingData = LocalizedStringKey("pokemon_detail.loading_data")
        static let searchButton = LocalizedStringKey("pokemon_detail.search_button")
        static let clearButton = LocalizedStringKey("pokemon_detail.clear_button")
        static let rivalSelection = LocalizedStringKey("pokemon_detail.rival_selection")
        static let clearSelection = NSLocalizedString("pokemon_detail.clear_selection", comment: "")
        static let clearFilter = NSLocalizedString("pokemon_detail.clear_filter", comment: "")

        static func abilityOverflow(_ count: Int) -> String {
            return String(format: NSLocalizedString("pokemon_detail.ability_overflow", comment: ""), count)
        }

        static func flavorTextSource(_ source: String) -> String {
            return String(format: NSLocalizedString("pokemon_detail.flavor_text_source", comment: ""), source)
        }

        static func level(_ level: Int) -> String {
            return String(format: NSLocalizedString("pokemon_detail.level", comment: ""), level)
        }

        static func height(_ height: Double) -> String {
            return String(format: NSLocalizedString("pokemon_detail.height", comment: ""), height)
        }

        static func weight(_ weight: Double) -> String {
            return String(format: NSLocalizedString("pokemon_detail.weight", comment: ""), weight)
        }

        static func moveCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("pokemon_detail.move_count", comment: ""), count)
        }

        static func levelPrefix(_ level: Int) -> String {
            return String(format: NSLocalizedString("pokemon_detail.level_prefix", comment: ""), level)
        }

        static func filterResultsCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("pokemon_detail.filter_results_count", comment: ""), count)
        }
    }

    // MARK: - Move Learn Methods
    enum LearnMethod {
        static let all = NSLocalizedString("learn_method.all", comment: "")
        static let levelUp = NSLocalizedString("learn_method.level_up", comment: "")
        static let egg = NSLocalizedString("learn_method.egg", comment: "")
        static let tutor = NSLocalizedString("learn_method.tutor", comment: "")
        static let machine = NSLocalizedString("learn_method.machine", comment: "")

        static func displayName(_ method: String) -> String {
            switch method {
            case "all": return all
            case "level-up": return levelUp
            case "egg": return egg
            case "tutor": return tutor
            case "machine": return machine
            default: return method.replacingOccurrences(of: "-", with: " ").capitalized
            }
        }
    }

    // MARK: - Move Details
    enum Move {
        static let excludeRivals = LocalizedStringKey("move.exclude_rivals")
        static let selectButton = LocalizedStringKey("move.select_button")
        static let noMovesAvailable = LocalizedStringKey("move.no_moves_available")
        static let powerLabel = NSLocalizedString("move.power_label", comment: "")
        static let accuracyLabel = NSLocalizedString("move.accuracy_label", comment: "")
        static let ppLabel = NSLocalizedString("move.pp_label", comment: "")
        static let noDescription = NSLocalizedString("move.no_description", comment: "")

        static func rivalCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("move.rival_count", comment: ""), count)
        }
    }

    // MARK: - Ability Details
    enum Ability {
        static let hidden = LocalizedStringKey("ability.hidden")
        static let loading = LocalizedStringKey("ability.loading")
    }

    // MARK: - Settings
    enum Settings {
        static let title = LocalizedStringKey("settings.title")
        static let done = LocalizedStringKey("settings.done")
        static let language = LocalizedStringKey("settings.language")
        static let displaySectionHeader = LocalizedStringKey("settings.display_section_header")
        static let displaySectionFooter = LocalizedStringKey("settings.display_section_footer")
        static let versionPreference = LocalizedStringKey("settings.version_preference")
        static let dataSectionHeader = LocalizedStringKey("settings.data_section_header")
        static let dataSectionFooter = LocalizedStringKey("settings.data_section_footer")
    }

    // MARK: - Sort Options
    enum Sort {
        static let title = LocalizedStringKey("sort.title")
        static let done = LocalizedStringKey("sort.done")
        static let order = LocalizedStringKey("sort.order")
        static let ascending = LocalizedStringKey("sort.ascending")
        static let descending = LocalizedStringKey("sort.descending")
        static let sectionBasic = LocalizedStringKey("sort.section_basic")
        static let sectionBaseStats = LocalizedStringKey("sort.section_base_stats")
        static let pokedexNumber = LocalizedStringKey("sort.pokedex_number")
        static let attack = LocalizedStringKey("sort.attack")
        static let defense = LocalizedStringKey("sort.defense")
        static let specialAttack = LocalizedStringKey("sort.special_attack")
        static let specialDefense = LocalizedStringKey("sort.special_defense")
        static let speed = LocalizedStringKey("sort.speed")
        static let totalStats = LocalizedStringKey("sort.total_stats")
    }

    // MARK: - Loading Messages
    enum Loading {
        static let pokemon = LocalizedStringKey("loading.pokemon")
        static let moveFilterDisabled = LocalizedStringKey("loading.move_filter_disabled")
    }

    // MARK: - Move Filter (Common component)
    enum MoveFilter {
        static let title = LocalizedStringKey("move_filter.title")
        static let searchPlaceholder = LocalizedStringKey("move_filter.search_placeholder")

        static func maxSelectionWithCount(_ count: Int) -> String {
            return String(format: NSLocalizedString("move_filter.max_selection_with_count", comment: ""), count)
        }
    }

    // MARK: - Stats Calculator
    enum StatsCalc {
        static let title = LocalizedStringKey("stats_calc.title")
        static let level = LocalizedStringKey("stats_calc.level")
        static let levelRange = LocalizedStringKey("stats_calc.level_range")
        static let iv = LocalizedStringKey("stats_calc.iv")
        static let ivShort = LocalizedStringKey("stats_calc.iv_short")
        static let ivRange = LocalizedStringKey("stats_calc.iv_range")
        static let ivSetMax = LocalizedStringKey("stats_calc.iv_set_max")
        static let ivSetMaxShort = LocalizedStringKey("stats_calc.iv_set_max_short")
        static let ivSetMin = LocalizedStringKey("stats_calc.iv_set_min")
        static let ivSetMinShort = LocalizedStringKey("stats_calc.iv_set_min_short")
        static let ev = LocalizedStringKey("stats_calc.ev")
        static let evShort = LocalizedStringKey("stats_calc.ev_short")
        static let evRange = LocalizedStringKey("stats_calc.ev_range")
        static let evOverLimit = LocalizedStringKey("stats_calc.ev_over_limit")
        static let evOverLimitMessage = LocalizedStringKey("stats_calc.ev_over_limit_message")
        static let evSetMax = LocalizedStringKey("stats_calc.ev_set_max")
        static let evSetZero = LocalizedStringKey("stats_calc.ev_set_zero")
        static let evButton252 = LocalizedStringKey("stats_calc.ev_button_252")
        static let nature = LocalizedStringKey("stats_calc.nature")
        static let natureCorrection = LocalizedStringKey("stats_calc.nature_correction")
        static let natureDescription = LocalizedStringKey("stats_calc.nature_description")
        static let baseStat = LocalizedStringKey("stats_calc.base_stat")
        static let calculatedStat = LocalizedStringKey("stats_calc.calculated_stat")
        static let result = LocalizedStringKey("stats_calc.result")
        static let pokemonSearch = LocalizedStringKey("stats_calc.pokemon_search")
        static let pokemonSearchPlaceholder = LocalizedStringKey("stats_calc.pokemon_search_placeholder")
        static let pokemonSelected = LocalizedStringKey("stats_calc.pokemon_selected")
        static let pokemonChange = LocalizedStringKey("stats_calc.pokemon_change")
        static let pokemonLoading = LocalizedStringKey("stats_calc.pokemon_loading")
        static let pokemonNotFound = LocalizedStringKey("stats_calc.pokemon_not_found")

        static func evRemaining(_ count: Int) -> String {
            return String(format: NSLocalizedString("stats_calc.ev_remaining", comment: ""), count)
        }
    }

    // MARK: - Pokemon Category
    enum Category {
        static let normal = NSLocalizedString("category.normal", comment: "")
        static let subLegendary = NSLocalizedString("category.sub_legendary", comment: "")
        static let legendary = NSLocalizedString("category.legendary", comment: "")
        static let mythical = NSLocalizedString("category.mythical", comment: "")
    }

    // MARK: - Evolution Filter Mode
    enum EvolutionMode {
        static let all = NSLocalizedString("evolution_mode.all", comment: "")
        static let finalOnly = NSLocalizedString("evolution_mode.final_only", comment: "")
        static let evioliteOnly = NSLocalizedString("evolution_mode.eviolite_only", comment: "")
    }

    // MARK: - Ability Category
    enum AbilityCategory {
        static func displayName(_ category: String) -> String {
            return NSLocalizedString("ability_category.\(category)", comment: "")
        }

        static func description(_ category: String) -> String {
            return NSLocalizedString("ability_category.\(category)_desc", comment: "")
        }

        static func groupName(_ group: String) -> String {
            return NSLocalizedString("ability_category_group.\(group)", comment: "")
        }
    }

    // MARK: - Ability Trigger
    enum AbilityTrigger {
        static func displayName(_ trigger: String) -> String {
            return NSLocalizedString("ability_trigger.\(trigger)", comment: "")
        }
    }

    // MARK: - Effect Type
    enum EffectType {
        static func displayName(_ effectType: String) -> String {
            return NSLocalizedString("effect_type.\(effectType)", comment: "")
        }
    }

    // MARK: - Weather
    enum Weather {
        static func displayName(_ weather: String) -> String {
            return NSLocalizedString("weather.\(weather)", comment: "")
        }

        static let header = NSLocalizedString("weather.header", comment: "")
    }

    // MARK: - Terrain
    enum Terrain {
        static func displayName(_ terrain: String) -> String {
            return NSLocalizedString("terrain.\(terrain)", comment: "")
        }

        static let header = NSLocalizedString("terrain.header", comment: "")
    }

    // MARK: - Move Ailment
    enum Ailment {
        static func displayName(_ ailment: String) -> String {
            return NSLocalizedString("ailment.\(ailment)", comment: "")
        }
    }

    // MARK: - Move Stat Change
    enum StatChange {
        static func displayName(_ statChange: String) -> String {
            return NSLocalizedString("stat_change.\(statChange)", comment: "")
        }
    }

    // MARK: - Move Category Group
    enum MoveCategoryGroup {
        static func displayName(_ group: String) -> String {
            return NSLocalizedString("move_category_group.\(group)", comment: "")
        }
    }

    // MARK: - Move Category
    enum MoveCategory {
        static func displayName(_ category: String) -> String {
            return NSLocalizedString("move_category.\(category)", comment: "")
        }
    }

    // MARK: - Egg Group
    enum EggGroup {
        static func localizedString(_ name: String) -> String {
            let key = name.replacingOccurrences(of: "-", with: "_")
            return NSLocalizedString("egg_group.\(key)", comment: "")
        }
    }

    // MARK: - Pattern Name
    enum PatternName {
        static func localizedString(_ patternId: String) -> String {
            return NSLocalizedString("pattern_name.\(patternId)", comment: "")
        }
    }

    // MARK: - Gender Ratio
    enum GenderRatio {
        static let unknown = NSLocalizedString("gender_ratio.unknown", comment: "")
    }

}
