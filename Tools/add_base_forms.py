#!/usr/bin/env python3
"""
フォーム違いポケモンの基本フォームを追加するスクリプト

追加するポケモン:
- maushold（イッカネズミ）: family-of-four のデータをベースに作成
- dudunsparce（ノココッチ）: two-segment のデータをベースに作成
"""

import json
import sys

def add_base_forms(input_file, output_file):
    """基本フォームを追加"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    added_count = 0

    # イッカネズミの基本フォームを追加
    maushold_four = None
    for pokemon in data['pokemon']:
        if pokemon['name'] == 'maushold-family-of-four':
            maushold_four = pokemon
            break

    if maushold_four and not any(p['name'] == 'maushold' for p in data['pokemon']):
        maushold_base = {
            "name": "maushold",
            "nationalDexNumber": maushold_four['nationalDexNumber'],
            "pokedexNumbers": maushold_four['pokedexNumbers'].copy(),
            "nameJa": maushold_four.get('nameJa', 'イッカネズミ'),
            "category": maushold_four.get('category', 'normal'),
            "types": maushold_four.get('types', []),
        }

        # family-of-four の前に挿入
        four_index = data['pokemon'].index(maushold_four)
        data['pokemon'].insert(four_index, maushold_base)

        print(f"追加: maushold（基本フォーム）")
        print(f"  nationalDexNumber: {maushold_base['nationalDexNumber']}")
        print(f"  pokedexNumbers: {maushold_base['pokedexNumbers']}")
        added_count += 1

    # ノココッチの基本フォームを追加
    dudunsparce_two = None
    for pokemon in data['pokemon']:
        if pokemon['name'] == 'dudunsparce-two-segment':
            dudunsparce_two = pokemon
            break

    if dudunsparce_two and not any(p['name'] == 'dudunsparce' for p in data['pokemon']):
        dudunsparce_base = {
            "name": "dudunsparce",
            "nationalDexNumber": dudunsparce_two['nationalDexNumber'],
            "pokedexNumbers": dudunsparce_two['pokedexNumbers'].copy(),
            "nameJa": dudunsparce_two.get('nameJa', 'ノココッチ'),
            "category": dudunsparce_two.get('category', 'normal'),
            "types": dudunsparce_two.get('types', []),
        }

        # two-segment の前に挿入
        two_index = data['pokemon'].index(dudunsparce_two)
        data['pokemon'].insert(two_index, dudunsparce_base)

        print(f"追加: dudunsparce（基本フォーム）")
        print(f"  nationalDexNumber: {dudunsparce_base['nationalDexNumber']}")
        print(f"  pokedexNumbers: {dudunsparce_base['pokedexNumbers']}")
        added_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n追加完了: {added_count}件")

if __name__ == '__main__':
    input_file = 'Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    add_base_forms(input_file, output_file)
