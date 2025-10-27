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
        static let all = LocalizedStringKey("common.all")
        static let loading = LocalizedStringKey("common.loading")
        static let error = LocalizedStringKey("common.error")
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
    }

    // MARK: - Move Learn Methods
    enum LearnMethod {
        static let levelUp = LocalizedStringKey("learn_method.level_up")
        static let egg = LocalizedStringKey("learn_method.egg")
        static let tutor = LocalizedStringKey("learn_method.tutor")
        static let machine = LocalizedStringKey("learn_method.machine")
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
}
