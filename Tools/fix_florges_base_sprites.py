#!/usr/bin/env python3
"""
フラベベ・フラエッテ・フラージェスの基本形スプライトを赤い花に修正

基本形は赤い花がデフォルトなので、-red サフィックスを付けたURLに変更
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 フラベベ系統の基本形スプライトを修正")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # フラベベ系統の基本形
    florges_family = {
        'flabebe': 669,
        'floette': 670,
        'florges': 671,
    }

    print("\n【基本形を赤い花に修正】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in florges_family:
            dex_num = florges_family[name]
            old_sprites = pokemon.get('sprites', {})
            new_sprites = {
                'normal': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{dex_num}-red.png',
                'shiny': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/{dex_num}-red.png'
            }

            if old_sprites != new_sprites:
                pokemon['sprites'] = new_sprites
                print(f"  {name}: 赤い花のスプライトに変更")
                print(f"    {old_sprites.get('normal', '')} →")
                print(f"    {new_sprites['normal']}")
                updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {updated_count}件のスプライトを修正")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
