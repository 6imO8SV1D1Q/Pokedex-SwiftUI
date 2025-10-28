//
//  MoveCategory.swift
//  Pokedex
//
//  技カテゴリーの定義（v2 - 43カテゴリー対応）
//

import Foundation

/// 技カテゴリーの定義
enum MoveCategory {
    /// カテゴリーグループの定義
    struct CategoryGroup {
        let name: String
        let categories: [(id: String, name: String)]
    }

    /// グループ分けされたカテゴリー
    static var categoryGroups: [CategoryGroup] {
        return [
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("status_condition"),
                categories: [
                    ("poison", L10n.MoveCategory.displayName("poison")),
                    ("paralyze", L10n.MoveCategory.displayName("paralyze")),
                    ("burn", L10n.MoveCategory.displayName("burn")),
                    ("freeze", L10n.MoveCategory.displayName("freeze")),
                    ("sleep", L10n.MoveCategory.displayName("sleep"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("disruption"),
                categories: [
                    ("confusion", L10n.MoveCategory.displayName("confusion")),
                    ("flinch", L10n.MoveCategory.displayName("flinch")),
                    ("bind", L10n.MoveCategory.displayName("bind")),
                    ("never-miss", L10n.MoveCategory.displayName("never_miss")),
                    ("fixed-damage", L10n.MoveCategory.displayName("fixed_damage"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("attack_timing"),
                categories: [
                    ("priority", L10n.MoveCategory.displayName("priority")),
                    ("delayed", L10n.MoveCategory.displayName("delayed"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("damage_boost"),
                categories: [
                    ("power-boost", L10n.MoveCategory.displayName("power_boost")),
                    ("multi-hit", L10n.MoveCategory.displayName("multi_hit")),
                    ("high-crit", L10n.MoveCategory.displayName("high_crit"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("risk"),
                categories: [
                    ("recoil", L10n.MoveCategory.displayName("recoil")),
                    ("recharge", L10n.MoveCategory.displayName("recharge")),
                    ("charge", L10n.MoveCategory.displayName("charge")),
                    ("ohko", L10n.MoveCategory.displayName("ohko"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("stat_change"),
                categories: [
                    ("stat-change", L10n.MoveCategory.displayName("stat_change")),
                    ("setup", L10n.MoveCategory.displayName("setup")),
                    ("type-change", L10n.MoveCategory.displayName("type_change")),
                    ("ability-change", L10n.MoveCategory.displayName("ability_change"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("defense_counter"),
                categories: [
                    ("counter", L10n.MoveCategory.displayName("counter")),
                    ("protect", L10n.MoveCategory.displayName("protect"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("recovery_support"),
                categories: [
                    ("healing", L10n.MoveCategory.displayName("healing")),
                    ("drain", L10n.MoveCategory.displayName("drain")),
                    ("revival", L10n.MoveCategory.displayName("revival"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("switch"),
                categories: [
                    ("switch", L10n.MoveCategory.displayName("switch"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("field_control"),
                categories: [
                    ("hazard", L10n.MoveCategory.displayName("hazard")),
                    ("weather", L10n.MoveCategory.displayName("weather")),
                    ("terrain", L10n.MoveCategory.displayName("terrain"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("move_types"),
                categories: [
                    ("sound", L10n.MoveCategory.displayName("sound")),
                    ("punch", L10n.MoveCategory.displayName("punch")),
                    ("powder", L10n.MoveCategory.displayName("powder")),
                    ("pulse", L10n.MoveCategory.displayName("pulse")),
                    ("bite", L10n.MoveCategory.displayName("bite")),
                    ("ball", L10n.MoveCategory.displayName("ball")),
                    ("dance", L10n.MoveCategory.displayName("dance")),
                    ("wind", L10n.MoveCategory.displayName("wind")),
                    ("slash", L10n.MoveCategory.displayName("slash"))
                ]
            ),
            CategoryGroup(
                name: L10n.MoveCategoryGroup.displayName("other"),
                categories: [
                    ("contact", L10n.MoveCategory.displayName("contact")),
                    ("defrost", L10n.MoveCategory.displayName("defrost"))
                ]
            )
        ]
    }

    /// カテゴリーIDから表示名を取得
    static func displayName(for categoryId: String) -> String {
        // ハイフンをアンダースコアに変換してローカライゼーションキーを取得
        let key = categoryId.replacingOccurrences(of: "-", with: "_")
        return L10n.MoveCategory.displayName(key)
    }

    /// カテゴリーごとの技名リスト（手動定義）
    static let categoryDefinitions: [String: Set<String>] = [
        // 既存カテゴリー（9個）
        "sound": [
            "growl", "roar", "sing", "supersonic", "screech", "snore", "perish-song",
            "heal-bell", "uproar", "hyper-voice", "metal-sound", "grass-whistle",
            "bug-buzz", "chatter", "round", "echoed-voice", "snarl", "boomburst",
            "disarming-voice", "parting-shot", "sparkling-aria", "clanging-scales",
            "clangorous-soul", "clangorous-soulblaze", "torch-song", "alluring-voice",
            "relic-song", "synchronoise", "throat-chop", "overdrive"
        ],

        "punch": [
            "mega-punch", "fire-punch", "ice-punch", "thunder-punch", "comet-punch",
            "mach-punch", "dynamic-punch", "meteor-mash", "focus-punch", "hammer-arm",
            "bullet-punch", "drain-punch", "shadow-punch", "plasma-fists",
            "dizzy-punch", "power-up-punch", "sky-uppercut", "double-iron-bash",
            "thunderous-kick", "wicked-blow", "surging-strikes"
        ],

        "dance": [
            "swords-dance", "petal-dance", "rain-dance", "dragon-dance", "lunar-dance",
            "teeter-dance", "feather-dance", "fiery-dance", "quiver-dance",
            "revelation-dance", "victory-dance", "aqua-step"
        ],

        "bite": [
            "bite", "crunch", "super-fang", "hyper-fang", "thunder-fang", "ice-fang",
            "fire-fang", "poison-fang", "psychic-fangs", "fishious-rend", "jaw-lock"
        ],

        "powder": [
            "poison-powder", "stun-spore", "sleep-powder", "spore", "cotton-spore",
            "rage-powder"
        ],

        "pulse": [
            "water-pulse", "aura-sphere", "dark-pulse", "dragon-pulse", "heal-pulse",
            "terrain-pulse", "origin-pulse"
        ],

        "ball": [
            "shadow-ball", "energy-ball", "focus-blast", "sludge-bomb", "zap-cannon",
            "weather-ball", "electro-ball", "acid-spray", "pollen-puff", "pyro-ball",
            "barrage", "egg-bomb", "ice-ball", "mist-ball", "octazooka", "luster-purge"
        ],

        "wind": [
            "gust", "whirlwind", "razor-wind", "twister", "hurricane", "air-cutter",
            "ominous-wind", "tailwind", "air-slash", "bleakwind-storm", "sandsear-storm",
            "wildbolt-storm", "springtide-storm", "petal-blizzard", "icy-wind",
            "fairy-wind", "heat-wave"
        ],

        "slash": [
            "cut", "slash", "fury-cutter", "x-scissor", "night-slash",
            "psycho-cut", "leaf-blade", "cross-poison", "sacred-sword", "razor-shell",
            "solar-blade", "ceaseless-edge", "population-bomb", "kowtow-cleave",
            "aqua-cutter", "stone-axe"
        ],

        // 新規カテゴリー（34個）
        "switch": [
            "u-turn", "volt-switch", "flip-turn", "baton-pass", "parting-shot",
            "teleport", "shed-tail", "chilly-reception"
        ],

        "ohko": [
            "guillotine", "horn-drill", "fissure", "sheer-cold"
        ],

        "counter": [
            "counter", "mirror-coat", "metal-burst", "bide"
        ],

        "protect": [
            "protect", "detect", "endure", "wide-guard", "quick-guard",
            "baneful-bunker", "spiky-shield", "kings-shield", "obstruct",
            "silk-trap", "burning-bulwark"
        ],

        "hazard": [
            "stealth-rock", "spikes", "toxic-spikes", "sticky-web", "ceaseless-edge",
            "stone-axe"
        ],

        "weather": [
            "rain-dance", "sunny-day", "sandstorm", "hail", "snowscape"
        ],

        "terrain": [
            "electric-terrain", "grassy-terrain", "misty-terrain", "psychic-terrain"
        ],

        "revival": [
            "revival-blessing"
        ],

        "defrost": [
            "flame-wheel", "sacred-fire", "flare-blitz", "fusion-flare",
            "scald", "steam-eruption", "scorching-sands", "burn-up"
        ],

        "charge": [
            "solar-beam", "solar-blade", "razor-wind", "skull-bash", "sky-attack",
            "freeze-shock", "ice-burn", "geomancy", "phantom-force", "fly", "dig",
            "dive", "bounce", "shadow-force", "meteor-beam", "electro-shot"
        ],

        "recharge": [
            "hyper-beam", "giga-impact", "blast-burn", "frenzy-plant", "hydro-cannon",
            "rock-wrecker", "roar-of-time", "prismatic-laser", "eternabeam"
        ]
    ]

    /// 指定された技名が指定されたカテゴリーに属するかチェック
    static func moveMatchesCategory(_ moveName: String, category: String) -> Bool {
        guard let movesInCategory = categoryDefinitions[category] else {
            return false
        }
        return movesInCategory.contains(moveName)
    }

    /// 指定された技名が選択されたカテゴリーのいずれかに属するかチェック
    static func moveMatchesAnyCategory(_ moveName: String, categories: Set<String>) -> Bool {
        for category in categories {
            if moveMatchesCategory(moveName, category: category) {
                return true
            }
        }
        return false
    }
}
