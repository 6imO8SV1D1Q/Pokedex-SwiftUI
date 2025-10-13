#!/usr/bin/env python3
"""
図鑑番号の連続性をチェックするスクリプト
"""

import json
import sys

def check_continuity(pokedex_name):
    """指定された図鑑の連続性をチェック"""
    with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r', encoding='utf-8') as f:
        data = json.load(f)

    # 図鑑のポケモンを図鑑番号順に取得
    pokedex_pokemon = []
    for pokemon in data['pokemon']:
        pokedex_numbers = pokemon.get('pokedexNumbers', {})
        if pokedex_name in pokedex_numbers:
            pokedex_pokemon.append({
                'name': pokemon['name'],
                'nameJa': pokemon.get('nameJa', ''),
                'number': pokedex_numbers[pokedex_name]
            })

    # 図鑑番号でソート
    pokedex_pokemon.sort(key=lambda x: x['number'])

    # 連続性チェック
    print(f'{pokedex_name}図鑑: {len(pokedex_pokemon)}匹')
    print()

    # 途切れている箇所を検出
    gaps = []
    prev_num = 0
    for entry in pokedex_pokemon:
        num = entry['number']
        if prev_num > 0 and num != prev_num + 1:
            gaps.append((prev_num, num))
        prev_num = num

    if gaps:
        print('⚠️  図鑑番号が途切れている箇所:')
        for start, end in gaps:
            missing_range = list(range(start + 1, end))
            print(f'  #{start} → #{end}: 欠番 {missing_range}')
    else:
        print('✅ 図鑑番号は連続しています')

    print()
    print(f'最小番号: #{pokedex_pokemon[0]["number"]} ({pokedex_pokemon[0]["name"]} / {pokedex_pokemon[0]["nameJa"]})')
    print(f'最大番号: #{pokedex_pokemon[-1]["number"]} ({pokedex_pokemon[-1]["name"]} / {pokedex_pokemon[-1]["nameJa"]})')

if __name__ == '__main__':
    if len(sys.argv) > 1:
        check_continuity(sys.argv[1])
    else:
        print('使い方: python check_pokedex_continuity.py [paldea|kitakami|blueberry]')
