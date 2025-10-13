#!/usr/bin/env python3
"""
コスメティックフォームのスプライトURLを正しく設定

基本形からコピーしたため、全て基本形のスプライトになってしまっている。
各フォームに応じた正しいスプライトURLに修正する。
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 コスメティックフォームのスプライトURLを修正")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # スプライトURL修正が必要なフォーム
    sprite_fixes = {
        # カラナクシ・トリトドン
        'shellos-east': (422, 'east'),
        'shellos-west': (422, 'west'),
        'gastrodon-east': (423, 'east'),
        'gastrodon-west': (423, 'west'),

        # シキジカ・メブキジカ
        'deerling-spring': (585, 'spring'),
        'deerling-summer': (585, 'summer'),
        'deerling-autumn': (585, 'autumn'),
        'deerling-winter': (585, 'winter'),
        'sawsbuck-spring': (586, 'spring'),
        'sawsbuck-summer': (586, 'summer'),
        'sawsbuck-autumn': (586, 'autumn'),
        'sawsbuck-winter': (586, 'winter'),

        # ビビヨン
        'vivillon-meadow': (666, 'meadow'),
        'vivillon-icy-snow': (666, 'icy-snow'),
        'vivillon-polar': (666, 'polar'),
        'vivillon-tundra': (666, 'tundra'),
        'vivillon-continental': (666, 'continental'),
        'vivillon-garden': (666, 'garden'),
        'vivillon-elegant': (666, 'elegant'),
        'vivillon-modern': (666, 'modern'),
        'vivillon-marine': (666, 'marine'),
        'vivillon-archipelago': (666, 'archipelago'),
        'vivillon-high-plains': (666, 'high-plains'),
        'vivillon-sandstorm': (666, 'sandstorm'),
        'vivillon-river': (666, 'river'),
        'vivillon-monsoon': (666, 'monsoon'),
        'vivillon-savanna': (666, 'savanna'),
        'vivillon-sun': (666, 'sun'),
        'vivillon-ocean': (666, 'ocean'),
        'vivillon-jungle': (666, 'jungle'),
        'vivillon-fancy': (666, 'fancy'),
        'vivillon-poke-ball': (666, 'poke-ball'),
    }

    print("\n【スプライトURL修正】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in sprite_fixes:
            dex_num, form_suffix = sprite_fixes[name]
            new_sprites = {
                'normal': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{dex_num}-{form_suffix}.png',
                'shiny': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/{dex_num}-{form_suffix}.png'
            }

            old_sprite = pokemon['sprites']['normal']
            pokemon['sprites'] = new_sprites
            print(f"  {name}:")
            print(f"    {old_sprite} →")
            print(f"    {new_sprites['normal']}")
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
