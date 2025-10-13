#!/usr/bin/env python3
"""
追加したポケモン（maushold, dudunsparce, meowstic）に不足しているフィールドを補完するスクリプト
"""

import json
import sys

def fix_added_pokemon(input_file, output_file):
    """追加したポケモンのフィールドを補完"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_count = 0

    # ベースとなるポケモンと追加したポケモンのペア
    pairs = [
        ('maushold-family-of-four', 'maushold'),
        ('dudunsparce-two-segment', 'dudunsparce'),
        ('meowstic-female', 'meowstic'),
    ]

    for base_name, added_name in pairs:
        # ベースポケモンを探す
        base_pokemon = None
        added_pokemon = None
        added_index = None

        for i, pokemon in enumerate(data['pokemon']):
            if pokemon['name'] == base_name:
                base_pokemon = pokemon
            if pokemon['name'] == added_name:
                added_pokemon = pokemon
                added_index = i

        if not base_pokemon:
            print(f"⚠️  {base_name} が見つかりません")
            continue

        if not added_pokemon:
            print(f"⚠️  {added_name} が見つかりません")
            continue

        # ベースポケモンから全フィールドをコピー（nameは除く）
        new_pokemon = base_pokemon.copy()
        new_pokemon['name'] = added_name

        # 上書き
        data['pokemon'][added_index] = new_pokemon

        print(f"修正: {added_name} のフィールドを {base_name} からコピー")
        fixed_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_added_pokemon(input_file, output_file)
