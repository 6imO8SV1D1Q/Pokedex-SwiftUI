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
    case type(String)
    case types([String])
    case number(Int)
    case itemName(String)
    case moveNames([String])

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .fraction(let num, let den):
            try container.encode(["numerator": num, "denominator": den])
        case .percentage(let val):
            try container.encode(["percentage": val])
        case .weather(let val):
            try container.encode(["weather": val])
        case .type(let val):
            try container.encode(["type": val])
        case .types(let val):
            try container.encode(["types": val])
        case .number(let val):
            try container.encode(["number": val])
        case .itemName(let val):
            try container.encode(["itemName": val])
        case .moveNames(let val):
            try container.encode(["moveNames": val])
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
    let specificMoveNames: [String]?
}

enum HealAmount: Codable {
    case fraction(numerator: Int, denominator: Int)
    case percentage(Int)

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .fraction(let num, let den):
            try container.encode(["numerator": num, "denominator": den])
        case .percentage(let val):
            try container.encode(["percentage": val])
        }
    }
}

// MARK: - Effect Analyzer
class AbilityEffectAnalyzer {
    func analyze(_ ability: AbilityInput) -> AbilityMetadata {
        let effect = ability.effect.lowercased()
        var effects: [AbilityEffect] = []
        var categories: [String] = []
        var pokemonRestriction: [String]? = nil

        // Detect weather condition
        let weatherCondition: Condition? = {
            if effect.contains("during strong sunlight") || effect.contains("during harsh sunlight") {
                return Condition(type: "weather", value: .weather("sun"))
            } else if effect.contains("during rain") {
                return Condition(type: "weather", value: .weather("rain"))
            } else if effect.contains("during a sandstorm") || effect.contains("during sandstorm") {
                return Condition(type: "weather", value: .weather("sandstorm"))
            } else if effect.contains("during snow") || effect.contains("during hail") {
                return Condition(type: "weather", value: .weather("snow"))
            }
            return nil
        }()

        // Detect terrain condition
        let terrainCondition: Condition? = {
            if effect.contains("electric terrain") || effect.contains("on electric terrain") {
                return Condition(type: "terrain", value: .type("electric"))
            } else if effect.contains("grassy terrain") || effect.contains("on grassy terrain") {
                return Condition(type: "terrain", value: .type("grassy"))
            } else if effect.contains("misty terrain") || effect.contains("on misty terrain") {
                return Condition(type: "terrain", value: .type("misty"))
            } else if effect.contains("psychic terrain") || effect.contains("on psychic terrain") {
                return Condition(type: "terrain", value: .type("psychic"))
            }
            return nil
        }()

        // Combine weather and terrain condition
        let condition = weatherCondition ?? terrainCondition

        // Analyze effect text and generate metadata

        // Terrain setters - check before weather setters
        if effect.contains("electric terrain") && effect.contains("when") && effect.contains("enters battle") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_terrain",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: "electric", status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["terrain_setter"])
        } else if effect.contains("grassy terrain") && effect.contains("when") && effect.contains("enters battle") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_terrain",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: "grassy", status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["terrain_setter"])
        } else if effect.contains("misty terrain") && effect.contains("when") && effect.contains("enters battle") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_terrain",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: "misty", status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["terrain_setter"])
        } else if effect.contains("psychic terrain") && effect.contains("when") && effect.contains("enters battle") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_terrain",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: "psychic", status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["terrain_setter"])
        }

        // Weather setters - check most specific patterns first, excluding terrain setters
        if (effect.contains("strong sunlight") || effect.contains("harsh sunlight")) && effect.contains("when") && effect.contains("enters battle") && !effect.contains("terrain") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_weather",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: "sun", terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["weather_setter"])
        } else if effect.contains("rain") && effect.contains("when") && effect.contains("enters battle") && !effect.contains("terrain") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_weather",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: "rain", terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["weather_setter"])
        } else if effect.contains("sandstorm") && effect.contains("when") && effect.contains("enters battle") && !effect.contains("terrain") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_weather",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: "sandstorm", terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["weather_setter"])
        } else if effect.contains("snow") && effect.contains("when") && effect.contains("enters battle") && !effect.contains("snow warning") && !effect.contains("terrain") {
            effects.append(AbilityEffect(
                trigger: "on_switch_in",
                condition: nil,
                effectType: "set_weather",
                target: "field",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: "snow", terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["weather_setter"])
        }

        // General stat stage changes (MUST come before stat multipliers to avoid confusion)
        let statNames = ["attack", "defense", "special attack", "special defense", "speed", "accuracy", "evasion"]
        for statName in statNames {
            if effect.contains(statName) && (effect.contains("stage") || effect.contains("stages")) {
                let stageChange: Int?
                let isRaise = effect.contains("raises") || effect.contains("rises") || effect.contains("increased")
                let isLower = effect.contains("lowers") || effect.contains("decreased")

                if effect.contains("two stages") || effect.contains("2 stages") {
                    stageChange = isRaise ? 2 : (isLower ? -2 : nil)
                } else if effect.contains("one stage") || effect.contains("1 stage") {
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
                    } else if effect.contains("when hit") || effect.contains("struck") {
                        trigger = "on_being_hit"
                        target = stage > 0 ? "self" : "opponent"
                    } else {
                        trigger = "passive"
                        target = "self"
                    }

                    let stat = statName.replacingOccurrences(of: " ", with: "_")
                    effects.append(AbilityEffect(
                        trigger: trigger,
                        condition: condition,
                        effectType: "stat_stage_change",
                        target: target,
                        value: EffectValue(stat: stat, multiplier: nil, stageChange: stage, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                    ))
                    categories.append(contentsOf: ["stat_boost_trigger"])
                    break
                }
            }
        }

        // Stat multipliers (check for "doubled" or multiplier values)
        if effect.contains("speed") && effect.contains("doubled") && !effect.contains("stage") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: weatherCondition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(stat: "speed", multiplier: 2.0, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["stat_multiplier"])
        }

        if effect.contains("attack") && effect.contains("doubled") && !effect.contains("stage") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: weatherCondition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(stat: "attack", multiplier: 2.0, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["stat_multiplier", "power_boost"])
        }

        if effect.contains("special attack") && (effect.contains("1.5") || effect.contains("doubled")) && !effect.contains("stage") {
            let multiplier = effect.contains("1.5") ? 1.5 : 2.0
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: weatherCondition,
                effectType: "stat_multiplier",
                target: "self",
                value: EffectValue(stat: "special_attack", multiplier: multiplier, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["stat_multiplier", "power_boost"])
        }

        // Type-specific move power multipliers
        let typePowerPatterns: [(type: String, keywords: [String], multiplier: Double)] = [
            ("fire", ["fire-type moves", "fire moves"], 1.5),
            ("water", ["water-type moves", "water moves"], 1.5),
            ("grass", ["grass-type moves", "grass moves"], 1.5),
            ("electric", ["electric-type moves", "electric moves"], 1.5),
            ("normal", ["normal-type moves", "normal moves"], 1.5),
            ("steel", ["steel-type moves", "steel moves"], 1.5),
            ("dragon", ["dragon-type moves", "dragon moves"], 1.5),
            ("dark", ["dark-type moves", "dark moves"], 1.5),
            ("fairy", ["fairy-type moves", "fairy moves"], 1.5),
            ("fighting", ["fighting-type moves", "fighting moves"], 1.5),
            ("flying", ["flying-type moves", "flying moves"], 1.5),
            ("poison", ["poison-type moves", "poison moves"], 1.5),
            ("ground", ["ground-type moves", "ground moves"], 1.5),
            ("rock", ["rock-type moves", "rock moves"], 1.5),
            ("bug", ["bug-type moves", "bug moves"], 1.5),
            ("ghost", ["ghost-type moves", "ghost moves"], 1.5),
            ("ice", ["ice-type moves", "ice moves"], 1.5),
            ("psychic", ["psychic-type moves", "psychic moves"], 1.5)
        ]

        for pattern in typePowerPatterns {
            for keyword in pattern.keywords {
                if effect.contains(keyword) && (effect.contains("1.5") || effect.contains("power") || effect.contains("damage")) {
                    let multiplier: Double = effect.contains("1.5") ? 1.5 : (effect.contains("1.3") ? 1.3 : (effect.contains("1.2") ? 1.2 : 1.5))
                    effects.append(AbilityEffect(
                        trigger: "passive",
                        condition: condition,
                        effectType: "move_power_multiplier",
                        target: "self",
                        value: EffectValue(stat: nil, multiplier: multiplier, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: pattern.type, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                    ))
                    categories.append(contentsOf: ["power_boost", "type_boost"])
                    break
                }
            }
        }

        // Multi-type power boost (e.g., sand-force: rock, ground, steel)
        if effect.contains("rock-, ground-, and steel-type") || effect.contains("rock, ground, and steel") {
            let multiplier: Double = effect.contains("1.3") ? 1.3 : 1.5
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: condition,
                effectType: "move_power_multiplier",
                target: "self",
                value: EffectValue(stat: nil, multiplier: multiplier, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: ["rock", "ground", "steel"], moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["power_boost", "type_boost"])
        }

        // Speed rises
        if effect.contains("speed rises") && effect.contains("one stage") && effect.contains("after each turn") {
            effects.append(AbilityEffect(
                trigger: "on_turn_end",
                condition: nil,
                effectType: "stat_stage_change",
                target: "self",
                value: EffectValue(stat: "speed", multiplier: nil, stageChange: 1, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["stat_boost_trigger"])
        }

        // Critical hit immunity
        if effect.contains("cannot score critical hits against") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "prevent_critical",
                target: "self",
                value: nil
            ))
            categories.append(contentsOf: ["critical_modifier"])
        }

        // Sturdy
        if effect.contains("full hp") && effect.contains("knock it out") && effect.contains("leave it with 1 hp") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: Condition(type: "hp_full", value: nil),
                effectType: "survive_hit",
                target: "self",
                value: nil
            ))
            categories.append(contentsOf: ["survive_hit"])
        }

        // Paralysis immunity
        if effect.contains("cannot be paralyzed") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "immune_to_status",
                target: "self",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: "paralysis", moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["status_immunity"])
        }

        // Type absorption
        if effect.contains("electric-type move") && effect.contains("heals for 1/4") {
            effects.append(AbilityEffect(
                trigger: "on_being_hit",
                condition: Condition(type: "move_type", value: .type("electric")),
                effectType: "absorb_type",
                target: "self",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: .fraction(numerator: 1, denominator: 4), weather: nil, terrain: nil, status: nil, moveType: "electric", moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["type_absorb", "hp_recovery_trigger"])
        }

        if effect.contains("water-type move") && effect.contains("heals for 1/4") {
            effects.append(AbilityEffect(
                trigger: "on_being_hit",
                condition: Condition(type: "move_type", value: .type("water")),
                effectType: "absorb_type",
                target: "self",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: .fraction(numerator: 1, denominator: 4), weather: nil, terrain: nil, status: nil, moveType: "water", moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["type_absorb", "hp_recovery_trigger"])
        }

        // Infatuation immunity
        if effect.contains("cannot be infatuated") {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "immune_to_status",
                target: "self",
                value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: "infatuation", moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
            ))
            categories.append(contentsOf: ["status_immunity"])
        }

        // Weather nullification
        if (effect.contains("weather") && effect.contains("will not have any of its effects")) ||
           (effect.contains("suppresses the effects of weather")) {
            effects.append(AbilityEffect(
                trigger: "passive",
                condition: nil,
                effectType: "nullify_weather",
                target: "field",
                value: nil
            ))
            categories.append(contentsOf: ["weather_nullifier"])
        }

        // Accuracy multiplier
        if effect.contains("moves have") && effect.contains("their accuracy") {
            if effect.contains("1.3×") {
                effects.append(AbilityEffect(
                    trigger: "passive",
                    condition: nil,
                    effectType: "accuracy_multiplier",
                    target: "move",
                    value: EffectValue(stat: "accuracy", multiplier: 1.3, stageChange: nil, probability: nil, healAmount: nil, weather: nil, terrain: nil, status: nil, moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                ))
                categories.append(contentsOf: ["accuracy_modifier"])
            }
        }

        // Contact-based status infliction
        if effect.contains("makes contact with this pokémon") {
            if effect.contains("30% chance") && effect.contains("paralyzed") {
                effects.append(AbilityEffect(
                    trigger: "on_contact",
                    condition: nil,
                    effectType: "inflict_status",
                    target: "opponent",
                    value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: 30, healAmount: nil, weather: nil, terrain: nil, status: "paralysis", moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                ))
                categories.append(contentsOf: ["status_inflict", "contact_damage"])
            }

            if effect.contains("30% chance") && effect.contains("burned") {
                effects.append(AbilityEffect(
                    trigger: "on_contact",
                    condition: nil,
                    effectType: "inflict_status",
                    target: "opponent",
                    value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: 30, healAmount: nil, weather: nil, terrain: nil, status: "burn", moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                ))
                categories.append(contentsOf: ["status_inflict", "contact_damage"])
            }

            if effect.contains("30% chance") && effect.contains("poisoned") {
                effects.append(AbilityEffect(
                    trigger: "on_contact",
                    condition: nil,
                    effectType: "inflict_status",
                    target: "opponent",
                    value: EffectValue(stat: nil, multiplier: nil, stageChange: nil, probability: 30, healAmount: nil, weather: nil, terrain: nil, status: "poison", moveType: nil, moveTypes: nil, moveFlag: nil, specificMoveNames: nil)
                ))
                categories.append(contentsOf: ["status_inflict", "contact_damage"])
            }
        }

        // Default fallback for abilities without specific patterns
        if effects.isEmpty {
            // Determine a basic trigger and effect type based on keywords
            var trigger = "passive"
            var effectType = "unknown"
            let target = "self"

            if effect.contains("enters battle") || effect.contains("sent out") {
                trigger = "on_switch_in"
            } else if effect.contains("makes contact") {
                trigger = "on_contact"
            } else if effect.contains("end of each turn") || effect.contains("turn end") || effect.contains("after each turn") {
                trigger = "on_turn_end"
            } else if effect.contains("hit") || effect.contains("struck") {
                trigger = "on_being_hit"
            } else if effect.contains("when attacking") || effect.contains("damaging moves") {
                trigger = "on_attacking"
            }

            if effect.contains("power") || effect.contains("damage") {
                effectType = "move_power_multiplier"
                categories.append("power_boost")
            } else if (effect.contains("speed") || effect.contains("attack") || effect.contains("defense") || effect.contains("special")) && !effect.contains("stage") {
                effectType = "stat_multiplier"
                categories.append("stat_multiplier")
            } else if effect.contains("stage") || effect.contains("stages") {
                effectType = "stat_stage_change"
                categories.append("stat_boost_trigger")
            } else if effect.contains("immune") || effect.contains("cannot be") {
                effectType = "immune_to_status"
                categories.append("status_immunity")
            } else if effect.contains("heals") || effect.contains("restores") || effect.contains("recovers") {
                effectType = "heal_hp"
                categories.append("hp_recovery")
            } else if effect.contains("cured") && effect.contains("status") {
                effectType = "cure_status"
                categories.append("status_cure")
            } else if effect.contains("weather") {
                effectType = "set_weather"
                categories.append("weather_setter")
            } else if effect.contains("terrain") || effect.contains("field") {
                effectType = "set_terrain"
                categories.append("terrain_setter")
            } else {
                effectType = "unknown"
                categories.append("special_mechanic")
            }

            effects.append(AbilityEffect(
                trigger: trigger,
                condition: condition,  // Apply detected weather/terrain condition
                effectType: effectType,
                target: target,
                value: nil
            ))
        }

        // Detect Pokemon-specific abilities
        if ability.name.contains("multitype") {
            pokemonRestriction = ["arceus"]
        } else if ability.name.contains("rks-system") {
            pokemonRestriction = ["silvally"]
        } else if ability.name.contains("gulp-missile") {
            pokemonRestriction = ["cramorant"]
        } else if ability.name.contains("disguise") {
            pokemonRestriction = ["mimikyu"]
        } else if ability.name.contains("ice-face") {
            pokemonRestriction = ["eiscue"]
        } else if ability.name.contains("schooling") {
            pokemonRestriction = ["wishiwashi"]
        } else if ability.name.contains("stance-change") {
            pokemonRestriction = ["aegislash"]
        } else if ability.name.contains("power-construct") {
            pokemonRestriction = ["zygarde"]
        } else if ability.name.contains("shields-down") {
            pokemonRestriction = ["minior"]
        } else if ability.name.contains("zen-mode") {
            pokemonRestriction = ["darmanitan"]
        } else if ability.name.contains("battle-bond") {
            pokemonRestriction = ["greninja"]
        } else if ability.name.contains("zero-to-hero") {
            pokemonRestriction = ["palafin"]
        }

        // Ensure at least one category
        if categories.isEmpty {
            categories.append("special_mechanic")
        }

        return AbilityMetadata(
            schemaVersion: 1,
            id: ability.id,
            name: ability.name,
            nameJa: ability.nameJa,
            effect: ability.effect,
            effectJa: ability.effectJa,
            effects: effects,
            categories: Array(Set(categories)), // Remove duplicates
            pokemonRestriction: pokemonRestriction
        )
    }
}

// MARK: - Main
func main() {
    let inputPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"
    let outputPath = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/ability_metadata.json"

    // Read input
    guard let inputData = try? Data(contentsOf: URL(fileURLWithPath: inputPath)) else {
        print("❌ Failed to read input file")
        return
    }

    // Decode
    let decoder = JSONDecoder()
    guard let input = try? decoder.decode(InputData.self, from: inputData) else {
        print("❌ Failed to decode input JSON")
        return
    }

    print("✅ Loaded \(input.abilities.count) abilities")

    // Analyze and generate metadata
    let analyzer = AbilityEffectAnalyzer()
    let metadata = input.abilities.map { analyzer.analyze($0) }

    print("✅ Generated metadata for \(metadata.count) abilities")

    // Encode output
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    guard let outputData = try? encoder.encode(metadata) else {
        print("❌ Failed to encode output JSON")
        return
    }

    // Write output
    do {
        try outputData.write(to: URL(fileURLWithPath: outputPath))
        print("✅ Successfully wrote to \(outputPath)")
        print("\n📊 Statistics:")
        print("   Total abilities: \(metadata.count)")
        print("   Abilities with restrictions: \(metadata.filter { $0.pokemonRestriction != nil }.count)")

        // Print first 3 examples
        print("\n📝 First 3 examples:")
        for i in 0..<min(3, metadata.count) {
            let ability = metadata[i]
            print("\n[\(i + 1)] \(ability.name) (\(ability.nameJa))")
            print("   Effects: \(ability.effects.count)")
            print("   Categories: \(ability.categories.joined(separator: ", "))")
            if let restriction = ability.pokemonRestriction {
                print("   Restriction: \(restriction.joined(separator: ", "))")
            }
        }

    } catch {
        print("❌ Failed to write output file: \(error)")
    }
}

main()
