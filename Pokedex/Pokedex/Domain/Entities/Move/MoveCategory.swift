//
//  MoveCategory.swift
//  Pokedex
//
//  技カテゴリーの定義
//

import Foundation

/// 技カテゴリーの定義
enum MoveCategory {
    /// カテゴリーIDからカテゴリー名を取得
    static func displayName(for categoryId: String) -> String {
        switch categoryId {
        case "sound": return "音技"
        case "punch": return "パンチ技"
        case "dance": return "踊り技"
        case "bite": return "噛む技"
        case "powder": return "粉技"
        case "pulse": return "波動技"
        case "ball": return "弾技"
        case "wind": return "風技"
        case "slash": return "切る技"
        default: return categoryId
        }
    }

    /// カテゴリーごとの技名リスト（move_categories.pyから移植）
    static let categoryDefinitions: [String: Set<String>] = [
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
            "revelation-dance", "victory-dance", "aqua-step", "clanging-scales"
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
            "cut", "slash", "fury-cutter", "air-slash", "x-scissor", "night-slash",
            "psycho-cut", "leaf-blade", "cross-poison", "sacred-sword", "razor-shell",
            "solar-blade", "ceaseless-edge", "population-bomb", "kowtow-cleave",
            "aqua-cutter", "stone-axe"
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
