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
    static let categoryGroups: [CategoryGroup] = [
        CategoryGroup(name: "状態異常", categories: [
            ("poison", "どく"),
            ("paralyze", "まひ"),
            ("burn", "やけど"),
            ("freeze", "こおり"),
            ("sleep", "ねむり")
        ]),
        CategoryGroup(name: "妨害効果", categories: [
            ("confusion", "こんらん"),
            ("flinch", "ひるみ"),
            ("bind", "バインド技"),
            ("never-miss", "必中技"),
            ("fixed-damage", "固定ダメ技")
        ]),
        CategoryGroup(name: "攻撃タイミング", categories: [
            ("priority", "先制技"),
            ("delayed", "後攻技")
        ]),
        CategoryGroup(name: "ダメージ増強", categories: [
            ("power-boost", "威力上昇"),
            ("multi-hit", "連続攻撃"),
            ("high-crit", "急所")
        ]),
        CategoryGroup(name: "リスク技", categories: [
            ("recoil", "反動ダメ"),
            ("recharge", "反動ターン"),
            ("charge", "ターン技"),
            ("ohko", "一撃必殺")
        ]),
        CategoryGroup(name: "能力変化", categories: [
            ("stat-change", "ランク変化"),
            ("setup", "積み技"),
            ("type-change", "タイプ変化"),
            ("ability-change", "特性変化")
        ]),
        CategoryGroup(name: "防御・カウンター", categories: [
            ("counter", "カウンター"),
            ("protect", "まもる")
        ]),
        CategoryGroup(name: "回復・補助", categories: [
            ("healing", "回復"),
            ("drain", "HP吸収"),
            ("revival", "蘇生")
        ]),
        CategoryGroup(name: "交代・退場", categories: [
            ("switch", "交代技")
        ]),
        CategoryGroup(name: "フィールド操作", categories: [
            ("hazard", "設置技"),
            ("weather", "天候"),
            ("terrain", "フィールド")
        ]),
        CategoryGroup(name: "技の系統", categories: [
            ("sound", "音系"),
            ("punch", "パンチ系"),
            ("powder", "粉/胞子"),
            ("pulse", "波動技"),
            ("bite", "あご系"),
            ("ball", "弾"),
            ("dance", "踊り"),
            ("wind", "風技"),
            ("slash", "切る技")
        ]),
        CategoryGroup(name: "その他", categories: [
            ("contact", "接触技"),
            ("defrost", "こおり解除")
        ])
    ]

    /// 全カテゴリーのリスト（順序は画像の表示順）
    static let allCategories: [(id: String, name: String)] = [
        // 行1
        ("poison", "どく"),
        ("paralyze", "まひ"),
        ("burn", "やけど"),
        ("freeze", "こおり"),
        ("sleep", "ねむり"),

        // 行2
        ("confusion", "こんらん"),
        ("flinch", "ひるみ"),
        ("bind", "バインド技"),
        ("never-miss", "必中技"),
        ("fixed-damage", "固定ダメ技"),

        // 行3
        ("priority", "先制技"),
        ("delayed", "後攻技"),
        ("power-boost", "威力上昇"),
        ("multi-hit", "連続攻撃"),
        ("high-crit", "急所"),

        // 行4
        ("recoil", "反動ダメ"),
        ("recharge", "反動ターン"),
        ("charge", "ターン技"),
        ("ohko", "一撃必殺"),
        ("stat-change", "ランク変化"),

        // 行5
        ("setup", "積み技"),
        ("type-change", "タイプ変化"),
        ("ability-change", "特性変化"),
        ("counter", "カウンター"),
        ("protect", "まもる"),

        // 行6
        ("healing", "回復"),
        ("drain", "HP吸収"),
        ("revival", "蘇生"),
        ("switch", "交代技"),
        ("hazard", "設置技"),

        // 行7
        ("weather", "天候"),
        ("terrain", "フィールド"),
        ("sound", "音系"),
        ("punch", "パンチ系"),
        ("powder", "粉/胞子"),

        // 行8
        ("pulse", "波動技"),
        ("bite", "あご系"),
        ("ball", "弾"),
        ("dance", "踊り"),
        ("wind", "風技"),

        // 行9
        ("slash", "切る技"),
        ("contact", "接触技"),
        ("defrost", "こおり解除")
    ]

    /// カテゴリーIDから表示名を取得
    static func displayName(for categoryId: String) -> String {
        return allCategories.first { $0.id == categoryId }?.name ?? categoryId
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
