#!/usr/bin/env python3
"""
Move category detection logic
技カテゴリー判定ロジック
"""

# カテゴリー定義（手動リスト）
MOVE_CATEGORY_DEFINITIONS = {
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
}


def detect_move_categories(move_name: str, effect: str) -> list[str]:
    """
    技名とeffectから該当するカテゴリーを判定

    Args:
        move_name: 技の英語名（例: "fire-punch"）
        effect: 技の効果説明（英語）

    Returns:
        カテゴリーリスト（例: ["punch", "fire"]）
    """
    categories = []

    # 手動定義リストで判定
    for category, move_list in MOVE_CATEGORY_DEFINITIONS.items():
        if move_name in move_list:
            categories.append(category)

    # effect説明ベースの判定（補完用）
    effect_lower = effect.lower()

    # 音技: "sound" が効果に含まれる
    if "sound" in effect_lower and "sound" not in categories:
        categories.append("sound")

    # 粉技: "powder" が効果に含まれる
    if "powder" in effect_lower and "powder" not in categories:
        categories.append("powder")

    return categories


def get_category_display_name(category: str, lang: str = "ja") -> str:
    """
    カテゴリーの表示名を取得

    Args:
        category: カテゴリーID（例: "punch"）
        lang: 言語コード（"ja" or "en"）

    Returns:
        表示名（例: "パンチ技"）
    """
    display_names = {
        "sound": {"ja": "音技", "en": "Sound"},
        "punch": {"ja": "パンチ技", "en": "Punch"},
        "dance": {"ja": "踊り技", "en": "Dance"},
        "bite": {"ja": "噛む技", "en": "Bite"},
        "powder": {"ja": "粉技", "en": "Powder"},
        "pulse": {"ja": "波動技", "en": "Pulse"},
        "ball": {"ja": "弾技", "en": "Ball"},
        "wind": {"ja": "風技", "en": "Wind"},
        "slash": {"ja": "切る技", "en": "Slash"}
    }

    return display_names.get(category, {}).get(lang, category)


if __name__ == "__main__":
    # テスト
    test_moves = [
        ("fire-punch", "Burns the target."),
        ("hyper-voice", "Inflicts damage with sound."),
        ("swords-dance", "Raises user's Attack by two stages."),
        ("crunch", "Has a 20% chance to lower the target's Defense by one stage.")
    ]

    print("技カテゴリー判定テスト:")
    print("=" * 60)
    for name, effect in test_moves:
        categories = detect_move_categories(name, effect)
        print(f"\n{name}:")
        print(f"  Categories: {categories}")
        if categories:
            print(f"  Display (JP): {', '.join([get_category_display_name(c, 'ja') for c in categories])}")
