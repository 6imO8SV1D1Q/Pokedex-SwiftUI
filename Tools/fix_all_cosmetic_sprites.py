#!/usr/bin/env python3
"""
全てのコスメティックフォームのスプライトURLを修正
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 全てのコスメティックフォームのスプライトURLを修正")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # スプライトURL修正マップ
    sprite_map = {
        # フラベベ系統
        'flabebe-red': (669, 'red'),
        'flabebe-yellow': (669, 'yellow'),
        'flabebe-orange': (669, 'orange'),
        'flabebe-blue': (669, 'blue'),
        'flabebe-white': (669, 'white'),
        'floette-red': (670, 'red'),
        'floette-yellow': (670, 'yellow'),
        'floette-orange': (670, 'orange'),
        'floette-blue': (670, 'blue'),
        'floette-white': (670, 'white'),
        'florges-red': (671, 'red'),
        'florges-yellow': (671, 'yellow'),
        'florges-orange': (671, 'orange'),
        'florges-blue': (671, 'blue'),
        'florges-white': (671, 'white'),

        # メテノ（殻あり）- Pokemon HOMEのスプライトはID番号を使用
        'minior-orange-meteor': (774, 'orange-meteor'),
        'minior-yellow-meteor': (774, 'yellow-meteor'),
        'minior-green-meteor': (774, 'green-meteor'),
        'minior-blue-meteor': (774, 'blue-meteor'),
        'minior-indigo-meteor': (774, 'indigo-meteor'),
        'minior-violet-meteor': (774, 'violet-meteor'),

        # メテノ（殻なし）
        'minior-orange': (774, 'orange'),
        'minior-yellow': (774, 'yellow'),
        'minior-green': (774, 'green'),
        'minior-blue': (774, 'blue'),
        'minior-indigo': (774, 'indigo'),
        'minior-violet': (774, 'violet'),
    }

    print("\n【スプライトURL修正】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in sprite_map:
            dex_num, form_suffix = sprite_map[name]
            new_sprites = {
                'normal': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{dex_num}-{form_suffix}.png',
                'shiny': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/{dex_num}-{form_suffix}.png'
            }

            old_sprite = pokemon['sprites']['normal']
            if old_sprite != new_sprites['normal']:
                pokemon['sprites'] = new_sprites
                print(f"  {name}:")
                print(f"    {old_sprite.split('/')[-1]} → {new_sprites['normal'].split('/')[-1]}")
                updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了: {updated_count}件のスプライトURLを修正")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
