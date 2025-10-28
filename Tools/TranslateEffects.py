#!/usr/bin/env python3
"""
Translate Pokemon ability and move effects from English to Japanese.
Uses the existing translation_dictionary.json for moves.
"""

import json
from pathlib import Path
import sys


def load_translation_dictionary(dict_path: Path) -> dict:
    """Load the translation dictionary for moves."""
    try:
        with open(dict_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
            return data.get('moves', {})
    except FileNotFoundError:
        print(f"Warning: Translation dictionary not found at {dict_path}")
        return {}


def convert_to_da_dearu(text: str) -> str:
    """
    Convert Japanese text from polite form (ですます調) to plain form (だ・である調).
    """
    if not text:
        return text

    # Apply conversions in order (more specific patterns first)
    conversions = [
        ("します。", "する。"),
        ("します", "する"),
        ("されます。", "される。"),
        ("されます", "される"),
        ("なります。", "なる。"),
        ("なります", "なる"),
        ("あります。", "ある。"),
        ("あります", "ある"),
        ("できます。", "できる。"),
        ("できます", "できる"),
        ("ません。", "ない。"),
        ("ません", "ない"),
        ("与えます。", "与える。"),
        ("与えます", "与える"),
        ("回復します。", "回復する。"),
        ("回復します", "回復する"),
        ("上昇します。", "上昇する。"),
        ("上昇します", "上昇する"),
        ("減少します。", "減少する。"),
        ("減少します", "減少する"),
        ("失敗します。", "失敗する。"),
        ("失敗します", "失敗する"),
        ("終了します。", "終了する。"),
        ("終了します", "終了する"),
        ("解除します。", "解除する。"),
        ("解除します", "解除する"),
        ("破壊します。", "破壊する。"),
        ("破壊します", "破壊する"),
        ("変更します。", "変更する。"),
        ("変更します", "変更する"),
        ("追加します。", "追加する。"),
        ("追加します", "追加する"),
        ("軽減します。", "軽減する。"),
        ("軽減します", "軽減する"),
        ("無視します。", "無視する。"),
        ("無視します", "無視する"),
        ("持続します。", "持続する。"),
        ("持続します", "持続する"),
        ("発動します。", "発動する。"),
        ("発動します", "発動する"),
        ("引き継ぎます。", "引き継ぐ。"),
        ("引き継ぎます", "引き継ぐ"),
        ("入れ替わります。", "入れ替わる。"),
        ("入れ替わります", "入れ替わる"),
        ("受けません。", "受けない。"),
        ("受けません", "受けない"),
        ("吸収します。", "吸収する。"),
        ("吸収します", "吸収する"),
        ("選ばれません。", "選ばれない。"),
        ("選ばれません", "選ばれない"),
        ("コピーできません。", "コピーできない。"),
        ("コピーできません", "コピーできない"),
        ("使用できません。", "使用できない。"),
        ("使用できません", "使用できない"),
        ("行動できなくします。", "行動できなくする。"),
        ("行動できなくします", "行動できなくする"),
    ]

    result = text
    for polite, plain in conversions:
        result = result.replace(polite, plain)

    return result


def translate_ability_effect(english_text: str) -> str:
    """
    Translate ability effect from English to Japanese.
    This provides basic translations for common Pokemon terms.
    """
    if not english_text or english_text.strip() == "":
        return ""

    # For abilities, we'll do a comprehensive term-by-term translation
    # Start with the original text
    japanese = english_text

    # Core Pokemon terms - case sensitive replacements
    term_replacements = [
        # Pronouns and basic terms
        ("This Pokémon's", "このポケモンの"),
        ("This Pokémon", "このポケモン"),
        ("this Pokémon", "このポケモン"),
        ("the user", "使用者"),
        ("the target", "相手"),
        ("The target", "相手"),

        # Stats
        (" HP", " HP"),
        (" PP", " PP"),
        ("Attack", "攻撃"),
        ("attack", "攻撃"),
        ("Defense", "防御"),
        ("defense", "防御"),
        ("Special Attack", "特攻"),
        ("special attack", "特攻"),
        ("Special Defense", "特防"),
        ("special defense", "特防"),
        ("Speed", "素早さ"),
        ("speed", "素早さ"),
        ("accuracy", "命中率"),
        ("evasion", "回避率"),

        # Status conditions
        ("paralyzed", "まひ状態"),
        ("paralyze", "まひ"),
        ("paralysis", "まひ"),
        ("poisoned", "どく状態"),
        ("poison", "どく"),
        ("badly poisoned", "もうどく状態"),
        ("burned", "やけど状態"),
        ("burn", "やけど"),
        ("frozen", "こおり状態"),
        ("freeze", "こおり"),
        ("asleep", "ねむり状態"),
        ("sleep", "ねむり"),
        ("confused", "こんらん状態"),
        ("confusion", "こんらん"),
        ("flinch", "ひるみ"),
        ("flinching", "ひるみ"),
        ("infatuated", "メロメロ状態"),
        ("infatuation", "メロメロ"),

        # Battle mechanics
        ("critical hit", "急所"),
        ("critical hits", "急所"),
        (" stage", " 段階"),
        (" stages", " 段階"),
        (" turn", " ターン"),
        (" turns", " ターン"),
        ("damage", "ダメージ"),
        ("heals", "回復する"),
        ("heal", "回復"),
        ("faints", "ひんし状態になる"),
        ("faint", "ひんし"),
        ("move", "技"),
        ("moves", "技"),
        ("ability", "特性"),
        ("abilities", "特性"),
        (" field", " 場"),
        ("battle", "戦闘"),
        ("weather", "天候"),
        ("makes contact", "接触"),

        # Types (with hyphen)
        ("normal-type", "ノーマルタイプ"),
        ("fire-type", "ほのおタイプ"),
        ("water-type", "みずタイプ"),
        ("electric-type", "でんきタイプ"),
        ("grass-type", "くさタイプ"),
        ("ice-type", "こおりタイプ"),
        ("fighting-type", "かくとうタイプ"),
        ("poison-type", "どくタイプ"),
        ("ground-type", "じめんタイプ"),
        ("flying-type", "ひこうタイプ"),
        ("psychic-type", "エスパータイプ"),
        ("bug-type", "むしタイプ"),
        ("rock-type", "いわタイプ"),
        ("ghost-type", "ゴーストタイプ"),
        ("dragon-type", "ドラゴンタイプ"),
        ("dark-type", "あくタイプ"),
        ("steel-type", "はがねタイプ"),
        ("fairy-type", "フェアリータイプ"),

        # Common phrases
        (" has a ", " には"),
        ("% chance", "%の確率"),
        ("chance to", "の確率で"),
        (" to ", " で"),
        ("when ", "とき"),
        ("When ", "とき"),
        ("Whenever ", "するたびに"),
        ("While ", "の間"),
        ("If ", "もし"),
        ("will ", "する"),
        ("cannot ", "できない"),
        ("cannot be", "できない"),
        (" is ", " は"),
        (" are ", " は"),
        (" at the end of every turn", " 毎ターン終了時"),
        (" at the end of each turn", " 毎ターン終了時"),
        (" at the start of the turn", " ターン開始時"),
        ("for five turns", "5ターンの間"),
        ("for 5 turns", "5ターンの間"),
        (" will fail", " 失敗する"),
        (" raises ", " 上げる"),
        (" lowers ", " 下げる"),
        (" doubled", " 2倍"),
        (" halved", " 半減"),
        (" ignores ", " 無視する"),
        (" with each hit", " 命中するたびに"),
        ("may ", "可能性がある"),
        (" by one stage", " 1段階"),
        (" by two stages", " 2段階"),
        (" one stage", " 1段階"),
        (" two stages", " 2段階"),

        # Weather
        ("sandstorm", "すなあらし"),
        ("rain", "あめ"),
        ("sunshine", "にほんばれ"),
        ("sunny day", "にほんばれ"),
        ("hail", "あられ"),

        # Specific ability/move names (some common ones)
        ("substitute", "みがわり"),
        ("protect", "まもる"),
        ("detect", "みきり"),
    ]

    # Apply replacements in order
    for en, ja in term_replacements:
        japanese = japanese.replace(en, ja)

    # Convert to plain form (だ・である調)
    japanese = convert_to_da_dearu(japanese)

    return japanese


def translate_json_files(base_path: Path, translation_dict: dict):
    """
    Translate effectJa fields in JSON files.
    """
    # Process ability_metadata.json
    ability_metadata_path = base_path / 'ability_metadata.json'
    if ability_metadata_path.exists():
        print(f"Processing {ability_metadata_path.name}...")

        with open(ability_metadata_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        count = 0
        for item in data:
            if 'effect' in item and 'effectJa' in item:
                if not item['effectJa'] or item['effectJa'].strip() == "":
                    item['effectJa'] = translate_ability_effect(item['effect'])
                    count += 1

        with open(ability_metadata_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"  ✓ Translated {count} abilities")

    # Process scarlet_violet.json
    scarlet_violet_path = base_path / 'scarlet_violet.json'
    if scarlet_violet_path.exists():
        print(f"Processing {scarlet_violet_path.name}...")

        with open(scarlet_violet_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        ability_count = 0
        move_count = 0

        # Process abilities
        if 'abilities' in data:
            for ability in data['abilities']:
                if 'effect' in ability and 'effectJa' in ability:
                    if not ability['effectJa'] or ability['effectJa'].strip() == "":
                        ability['effectJa'] = translate_ability_effect(ability['effect'])
                        ability_count += 1

        # Process moves using the translation dictionary
        if 'moves' in data:
            for move in data['moves']:
                if 'effect' in move and 'effectJa' in move:
                    if not move['effectJa'] or move['effectJa'].strip() == "":
                        # Try to find translation in dictionary
                        english_effect = move['effect']
                        if english_effect in translation_dict:
                            # Apply da-dearu conversion to dictionary translation
                            move['effectJa'] = convert_to_da_dearu(translation_dict[english_effect])
                        else:
                            # Fall back to basic translation
                            move['effectJa'] = translate_ability_effect(english_effect)
                        move_count += 1

        with open(scarlet_violet_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"  ✓ Translated {ability_count} abilities and {move_count} moves")


def main():
    """Main execution function."""
    base_path = Path(__file__).parent.parent / 'Pokedex' / 'Pokedex' / 'Resources' / 'PreloadedData'
    dict_path = Path(__file__).parent / 'translation_dictionary.json'

    # Load translation dictionary
    print("Loading translation dictionary...")
    translation_dict = load_translation_dictionary(dict_path)
    print(f"  ✓ Loaded {len(translation_dict)} move translations")

    # Translate JSON files
    translate_json_files(base_path, translation_dict)

    print("\nTranslation complete!")


if __name__ == '__main__':
    main()
