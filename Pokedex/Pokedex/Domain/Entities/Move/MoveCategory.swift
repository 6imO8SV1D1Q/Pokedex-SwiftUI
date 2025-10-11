//
//  MoveCategory.swift
//  Pokedex
//
//  技カテゴリーの定義（v2 - 43カテゴリー対応）
//

import Foundation

/// 技カテゴリーの定義
enum MoveCategory {
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
        ("priority", "先制技"),
        ("delayed", "後攻技"),
        ("switch", "交代技"),

        // 行3
        ("power-boost", "威力上昇"),
        ("multi-hit", "連続攻撃"),
        ("high-crit", "急所"),
        ("never-miss", "必中技"),
        ("bind", "バインド技"),

        // 行4
        ("fixed-damage", "固定ダメ技"),
        ("recoil", "反動ダメ"),
        ("recharge", "反動ターン"),
        ("stat-change", "ランク変化"),
        ("setup", "積み技"),

        // 行5
        ("type-change", "タイプ変化"),
        ("ability-change", "特性変化"),
        ("charge", "ターン技"),
        ("ohko", "一撃必殺"),
        ("counter", "カウンター"),

        // 行6
        ("healing", "回復"),
        ("drain", "HP吸収"),
        ("revival", "蘇生"),
        ("hazard", "設置技"),
        ("weather", "天候"),

        // 行7
        ("terrain", "フィールド"),
        ("sound", "音系"),
        ("punch", "パンチ系"),
        ("powder", "粉/胞子"),
        ("pulse", "波動技"),

        // 行8
        ("bite", "あご系"),
        ("ball", "弾"),
        ("dance", "踊り"),
        ("wind", "風技"),
        ("slash", "切る技"),

        // 行9
        ("contact", "接触技"),
        ("protect", "まもる"),
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
