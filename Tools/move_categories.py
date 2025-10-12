#!/usr/bin/env python3
"""
Move category detection logic (v2 - 43 categories)
技カテゴリー判定ロジック（v2 - 43カテゴリー対応）
"""

# カテゴリー定義（手動リスト）- 技名ベース
MOVE_CATEGORY_DEFINITIONS = {
    # 既存カテゴリー（9個）
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

    # 新規カテゴリー（34個）
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
}


def detect_move_categories(move_data: dict) -> list[str]:
    """
    技データから該当するカテゴリーを判定

    Args:
        move_data: 技の全データ（name, effect, meta, priority, accuracyなど）

    Returns:
        カテゴリーリスト（例: ["punch", "contact", "burn"]）
    """
    categories = []

    move_name = move_data.get("name", "")
    effect = move_data.get("effect", "")
    effect_lower = effect.lower()

    meta = move_data.get("meta") or {}
    priority = move_data.get("priority", 0)
    accuracy = move_data.get("accuracy")
    power = move_data.get("power")
    damage_class = move_data.get("damageClass", "")

    # 手動定義リストで判定
    for category, move_list in MOVE_CATEGORY_DEFINITIONS.items():
        if move_name in move_list:
            categories.append(category)

    # === メタデータベース判定 ===

    # 状態異常系
    ailment = (meta.get("ailment") or {}).get("name") if isinstance(meta.get("ailment"), dict) else meta.get("ailment", "")
    if ailment and ailment != "none":
        if ailment == "poison":
            categories.append("poison")
        elif ailment == "paralysis":
            categories.append("paralyze")
        elif ailment == "burn":
            categories.append("burn")
        elif ailment == "freeze":
            categories.append("freeze")
        elif ailment == "sleep":
            categories.append("sleep")
        elif ailment == "confusion":
            categories.append("confusion")

    # ひるみ
    if meta.get("flinchChance", 0) > 0 or meta.get("flinch_chance", 0) > 0:
        categories.append("flinch")

    # 先制技・後攻技
    if priority > 0:
        categories.append("priority")
    elif priority < 0:
        categories.append("delayed")

    # 連続攻撃
    max_hits = meta.get("maxHits") or meta.get("max_hits")
    min_hits = meta.get("minHits") or meta.get("min_hits")
    if max_hits and max_hits > 1:
        categories.append("multi-hit")
    elif min_hits and min_hits > 1:
        categories.append("multi-hit")

    # 急所
    crit_rate = meta.get("critRate", 0) or meta.get("crit_rate", 0)
    if crit_rate > 0:
        categories.append("high-crit")

    # 必中技
    if accuracy is None and damage_class != "status":
        categories.append("never-miss")

    # バインド技（トラップ）
    meta_category = (meta.get("category") or {}).get("name") if isinstance(meta.get("category"), dict) else meta.get("category", "")
    if "trap" in meta_category.lower():
        categories.append("bind")

    # 固定ダメ技
    if damage_class not in ["status", ""] and power is None:
        # 例: seismic-toss, night-shade, dragon-rage
        if "level" in effect_lower or "fixed" in effect_lower or "equal to" in effect_lower:
            categories.append("fixed-damage")

    # 反動ダメ
    drain = meta.get("drain", 0)
    if drain < 0:
        categories.append("recoil")

    # HP吸収
    if drain > 0:
        categories.append("drain")

    # 回復
    healing = meta.get("healing", 0)
    if healing > 0:
        categories.append("healing")

    # ランク変化（能力変化）
    stat_changes = meta.get("statChanges") or meta.get("stat_changes") or []
    if stat_changes:
        categories.append("stat-change")

        # 積み技（自分の能力上昇）
        if any(s.get("change", 0) > 0 for s in stat_changes):
            categories.append("setup")

    # 接触技（contactフィールドがある場合）- ただしAPIには無いので効果文で判定
    if "contact" in effect_lower or "makes contact" in effect_lower:
        categories.append("contact")

    # === エフェクトテキストベース判定 ===

    # タイプ変化
    if "changes" in effect_lower and "type" in effect_lower:
        categories.append("type-change")

    # 特性変化
    if "ability" in effect_lower and ("changes" in effect_lower or "replaces" in effect_lower):
        categories.append("ability-change")

    # 威力上昇系の技（効果で判定）
    if "power" in effect_lower and ("increases" in effect_lower or "doubles" in effect_lower):
        categories.append("power-boost")

    # 音技（補完）
    if "sound" in effect_lower and "sound" not in categories:
        categories.append("sound")

    # 粉技（補完）
    if "powder" in effect_lower and "powder" not in categories:
        categories.append("powder")

    return categories


def get_category_display_name(category: str, lang: str = "ja") -> str:
    """
    カテゴリーの表示名を取得

    Args:
        category: カテゴリーID
        lang: 言語コード（"ja" or "en"）

    Returns:
        表示名
    """
    display_names = {
        # 既存カテゴリー
        "sound": {"ja": "音系", "en": "Sound"},
        "punch": {"ja": "パンチ系", "en": "Punch"},
        "dance": {"ja": "踊り", "en": "Dance"},
        "bite": {"ja": "あご系", "en": "Bite"},
        "powder": {"ja": "粉/胞子", "en": "Powder"},
        "pulse": {"ja": "波動技", "en": "Pulse"},
        "ball": {"ja": "弾", "en": "Ball"},
        "wind": {"ja": "風技", "en": "Wind"},
        "slash": {"ja": "切る技", "en": "Slash"},

        # 状態異常系
        "poison": {"ja": "どく", "en": "Poison"},
        "paralyze": {"ja": "まひ", "en": "Paralyze"},
        "burn": {"ja": "やけど", "en": "Burn"},
        "freeze": {"ja": "こおり", "en": "Freeze"},
        "sleep": {"ja": "ねむり", "en": "Sleep"},
        "confusion": {"ja": "こんらん", "en": "Confusion"},

        # 戦闘効果系
        "flinch": {"ja": "ひるみ", "en": "Flinch"},
        "priority": {"ja": "先制技", "en": "Priority"},
        "delayed": {"ja": "後攻技", "en": "Delayed"},
        "switch": {"ja": "交代技", "en": "Switch"},
        "power-boost": {"ja": "威力上昇", "en": "Power Boost"},
        "multi-hit": {"ja": "連続攻撃", "en": "Multi-Hit"},
        "high-crit": {"ja": "急所", "en": "High Crit"},
        "never-miss": {"ja": "必中技", "en": "Never Miss"},
        "bind": {"ja": "バインド技", "en": "Bind"},

        # ダメージ計算系
        "fixed-damage": {"ja": "固定ダメ技", "en": "Fixed Damage"},
        "recoil": {"ja": "反動ダメ", "en": "Recoil"},
        "recharge": {"ja": "反動ターン", "en": "Recharge"},

        # 能力変化系
        "stat-change": {"ja": "ランク変化", "en": "Stat Change"},
        "setup": {"ja": "積み技", "en": "Setup"},
        "type-change": {"ja": "タイプ変化", "en": "Type Change"},
        "ability-change": {"ja": "特性変化", "en": "Ability Change"},

        # 特殊メカニクス
        "charge": {"ja": "ターン技", "en": "Charge"},
        "ohko": {"ja": "一撃必殺", "en": "OHKO"},
        "counter": {"ja": "カウンター", "en": "Counter"},
        "healing": {"ja": "回復", "en": "Healing"},
        "drain": {"ja": "HP吸収", "en": "Drain"},
        "revival": {"ja": "蘇生", "en": "Revival"},

        # 場の技
        "hazard": {"ja": "設置技", "en": "Hazard"},
        "weather": {"ja": "天候", "en": "Weather"},
        "terrain": {"ja": "フィールド", "en": "Terrain"},

        # その他
        "contact": {"ja": "接触技", "en": "Contact"},
        "protect": {"ja": "まもる", "en": "Protect"},
        "defrost": {"ja": "こおり解除", "en": "Defrost"}
    }

    return display_names.get(category, {}).get(lang, category)


if __name__ == "__main__":
    # テスト
    test_moves = [
        {
            "name": "fire-punch",
            "effect": "Burns the target.",
            "meta": {"ailment": "burn", "ailmentChance": 10},
            "priority": 0,
            "accuracy": 100,
            "power": 75,
            "damageClass": "physical"
        },
        {
            "name": "quick-attack",
            "effect": "Inflicts regular damage.",
            "meta": {},
            "priority": 1,
            "accuracy": 100,
            "power": 40,
            "damageClass": "physical"
        },
        {
            "name": "guillotine",
            "effect": "Causes the target to faint if it hits.",
            "meta": {},
            "priority": 0,
            "accuracy": 30,
            "power": None,
            "damageClass": "physical"
        }
    ]

    print("技カテゴリー判定テスト:")
    print("=" * 60)
    for move_data in test_moves:
        categories = detect_move_categories(move_data)
        print(f"\n{move_data['name']}:")
        print(f"  Categories: {categories}")
        if categories:
            print(f"  Display (JP): {', '.join([get_category_display_name(c, 'ja') for c in categories])}")
