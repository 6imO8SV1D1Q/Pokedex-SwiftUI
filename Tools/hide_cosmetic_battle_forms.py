#!/usr/bin/env python3
"""
バトルフォーム・コスメティックフォームを非表示化

対象:
1. メテノ: 殻あり1個、殻なし1個のみ表示（他の色違いは非表示）
2. コライドン・ミライドン: 通常フォームのみ表示（移動フォームは非表示）
3. ピカチュウ: 通常のみ表示（帽子違いは非表示）
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 バトル・コスメティックフォーム非表示化")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # メテノ: 殻あり代表（red-meteor）と殻なし代表（red）のみ表示
    print("\n【メテノ】")
    minior_keep = ['minior-red-meteor', 'minior-red']
    for pokemon in pokemon_list:
        if pokemon['name'].startswith('minior') and pokemon['name'] not in minior_keep:
            if pokemon.get('pokedexNumbers'):
                pokemon['pokedexNumbers'] = {}
                print(f"  非表示: {pokemon['name']}")
                updated_count += 1
    print(f"  表示: {', '.join(minior_keep)}")

    # コライドン: 通常フォームのみ（移動フォームを非表示）
    print("\n【コライドン】")
    koraidon_hide = [
        'koraidon-limited-build',
        'koraidon-sprinting-build',
        'koraidon-swimming-build',
        'koraidon-gliding-build'
    ]
    for pokemon in pokemon_list:
        if pokemon['name'] in koraidon_hide:
            if pokemon.get('pokedexNumbers'):
                pokemon['pokedexNumbers'] = {}
                print(f"  非表示: {pokemon['name']}")
                updated_count += 1
    print(f"  表示: koraidon")

    # ミライドン: 通常フォームのみ（移動フォームを非表示）
    print("\n【ミライドン】")
    miraidon_hide = [
        'miraidon-low-power-mode',
        'miraidon-drive-mode',
        'miraidon-aquatic-mode',
        'miraidon-glide-mode'
    ]
    for pokemon in pokemon_list:
        if pokemon['name'] in miraidon_hide:
            if pokemon.get('pokedexNumbers'):
                pokemon['pokedexNumbers'] = {}
                print(f"  非表示: {pokemon['name']}")
                updated_count += 1
    print(f"  表示: miraidon")

    # ピカチュウ: 通常のみ（帽子違いを非表示）
    print("\n【ピカチュウ】")
    pikachu_hide = [
        'pikachu-original-cap',
        'pikachu-hoenn-cap',
        'pikachu-sinnoh-cap',
        'pikachu-unova-cap',
        'pikachu-kalos-cap',
        'pikachu-alola-cap',
        'pikachu-partner-cap',
        'pikachu-world-cap'
    ]
    for pokemon in pokemon_list:
        if pokemon['name'] in pikachu_hide:
            if pokemon.get('pokedexNumbers'):
                pokemon['pokedexNumbers'] = {}
                print(f"  非表示: {pokemon['name']}")
                updated_count += 1
    print(f"  表示: pikachu")

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {updated_count}フォームを一覧非表示化")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
