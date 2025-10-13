#!/usr/bin/env python3
"""
ガチグマ（通常）からキタカミ図鑑番号を削除するスクリプト

キタカミ図鑑にはアカツキのガチグマのみが登録されているべき
"""

import json
import sys

def fix_ursaluna_pokedex(input_file, output_file):
    """通常のガチグマからキタカミ図鑑番号を削除"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_count = 0

    for pokemon in data['pokemon']:
        # 通常のガチグマのみ対象（アカツキは除外）
        if pokemon['name'] == 'ursaluna':
            pokedex_numbers = pokemon.get('pokedexNumbers', {})

            # キタカミ図鑑番号がある場合は削除
            if 'kitakami' in pokedex_numbers:
                print(f"修正: {pokemon['name']}: キタカミ図鑑番号を削除")
                del pokedex_numbers['kitakami']
                fixed_count += 1

                # pokedexNumbersが空になった場合は空オブジェクトのまま残す
                pokemon['pokedexNumbers'] = pokedex_numbers

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = 'Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_ursaluna_pokedex(input_file, output_file)
