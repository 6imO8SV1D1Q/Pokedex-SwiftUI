#!/usr/bin/env python3
"""
タイプマスタデータをscarlet_violet.jsonに追加するスクリプト
"""

import json

# 18種類のタイプとその日本語名
TYPE_MASTER = {
    "normal": {"name": "normal", "nameJa": "ノーマル"},
    "fire": {"name": "fire", "nameJa": "ほのお"},
    "water": {"name": "water", "nameJa": "みず"},
    "grass": {"name": "grass", "nameJa": "くさ"},
    "electric": {"name": "electric", "nameJa": "でんき"},
    "ice": {"name": "ice", "nameJa": "こおり"},
    "fighting": {"name": "fighting", "nameJa": "かくとう"},
    "poison": {"name": "poison", "nameJa": "どく"},
    "ground": {"name": "ground", "nameJa": "じめん"},
    "flying": {"name": "flying", "nameJa": "ひこう"},
    "psychic": {"name": "psychic", "nameJa": "エスパー"},
    "bug": {"name": "bug", "nameJa": "むし"},
    "rock": {"name": "rock", "nameJa": "いわ"},
    "ghost": {"name": "ghost", "nameJa": "ゴースト"},
    "dragon": {"name": "dragon", "nameJa": "ドラゴン"},
    "dark": {"name": "dark", "nameJa": "あく"},
    "steel": {"name": "steel", "nameJa": "はがね"},
    "fairy": {"name": "fairy", "nameJa": "フェアリー"}
}

def main():
    input_file = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"

    print(f"📖 Reading {input_file}...")
    with open(input_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    # タイプマスタを追加
    data["types"] = TYPE_MASTER

    print(f"✅ Added type master data (18 types)")

    # 保存
    print(f"💾 Writing to {input_file}...")
    with open(input_file, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("✨ Done!")

if __name__ == "__main__":
    main()
