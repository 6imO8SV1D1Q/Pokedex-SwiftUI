#!/usr/bin/env python3
"""
コスメティックフォームに日本語説明を追加

1. フラベベ系統に色の説明を追加
2. アルセウスにタイプの説明を追加
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 コスメティックフォームに日本語説明を追加")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # フラベベ系統の色説明
    florges_colors = {
        'red': 'あかいはな',
        'yellow': 'きいろのはな',
        'orange': 'オレンジいろのはな',
        'blue': 'あおいはな',
        'white': 'しろいはな',
    }

    florges_family = ['flabebe', 'floette', 'florges']
    florges_base_names = {
        'flabebe': 'フラベベ',
        'floette': 'フラエッテ',
        'florges': 'フラージェス',
    }

    print("\n【フラベベ系統】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        for base_name in florges_family:
            if name.startswith(base_name + '-'):
                # 色を取得
                color = name.replace(base_name + '-', '')
                if color in florges_colors:
                    base_ja = florges_base_names[base_name]
                    new_name = f"{base_ja}（{florges_colors[color]}）"
                    old_name = pokemon.get('nameJa', '')
                    if old_name != new_name:
                        pokemon['nameJa'] = new_name
                        print(f"  {name}: {old_name} → {new_name}")
                        updated_count += 1

    # アルセウスのタイプ説明
    arceus_types = {
        'fighting': 'かくとう',
        'flying': 'ひこう',
        'poison': 'どく',
        'ground': 'じめん',
        'rock': 'いわ',
        'bug': 'むし',
        'ghost': 'ゴースト',
        'steel': 'はがね',
        'fire': 'ほのお',
        'water': 'みず',
        'grass': 'くさ',
        'electric': 'でんき',
        'psychic': 'エスパー',
        'ice': 'こおり',
        'dragon': 'ドラゴン',
        'dark': 'あく',
        'fairy': 'フェアリー',
    }

    print("\n【アルセウス】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name.startswith('arceus-'):
            # タイプを取得
            type_name = name.replace('arceus-', '')
            if type_name in arceus_types:
                new_name = f"アルセウス（{arceus_types[type_name]}）"
                old_name = pokemon.get('nameJa', '')
                if old_name != new_name:
                    pokemon['nameJa'] = new_name
                    print(f"  {name}: {old_name} → {new_name}")
                    updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {updated_count}件の名前に説明を追加")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
