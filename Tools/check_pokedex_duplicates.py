#!/usr/bin/env python3
"""
図鑑番号の重複をチェックするスクリプト
"""

import json
import sys
from collections import defaultdict

def check_duplicates(pokedex_name):
    """指定された図鑑の重複をチェック"""
    with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 図鑑番号ごとにポケモンをグループ化
    number_to_pokemon = defaultdict(list)
    for pokemon in data['pokemon']:
        pokedex_numbers = pokemon.get('pokedexNumbers', {})
        if pokedex_name in pokedex_numbers:
            number = pokedex_numbers[pokedex_name]
            number_to_pokemon[number].append({
                'name': pokemon['name'],
                'nameJa': pokemon.get('nameJa', '')
            })

    # 重複をチェック
    print(f'{pokedex_name}図鑑の重複チェック:')
    print()

    duplicates = {num: pokemons for num, pokemons in number_to_pokemon.items() if len(pokemons) > 1}

    if duplicates:
        print(f'⚠️  重複している図鑑番号: {len(duplicates)}箇所')
        print()
        for num in sorted(duplicates.keys()):
            pokemons = duplicates[num]
            print(f'#{num}: {len(pokemons)}匹')
            for p in pokemons:
                print(f'  - {p["name"]} ({p["nameJa"]})')
            print()
    else:
        print('✅ 重複はありません')

    print(f'総ポケモン数: {sum(len(v) for v in number_to_pokemon.values())}匹')
    print(f'図鑑番号の範囲: #{min(number_to_pokemon.keys())} - #{max(number_to_pokemon.keys())}')

if __name__ == '__main__':
    if len(sys.argv) > 1:
        check_duplicates(sys.argv[1])
    else:
        print('使い方: python check_pokedex_duplicates.py [paldea|kitakami|blueberry]')
