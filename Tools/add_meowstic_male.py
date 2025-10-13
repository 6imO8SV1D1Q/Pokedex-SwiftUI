#!/usr/bin/env python3
"""
ニャオニクス（オス）のデータを追加するスクリプト

ニャオニクスはオスとメスで特性・技が異なるため、両方を一覧に表示する
"""

import json
import sys

def add_meowstic_male(input_file, output_file):
    """ニャオニクス（オス）のデータを追加"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # メスのデータを探す
    meowstic_female = None
    for pokemon in data['pokemon']:
        if pokemon['name'] == 'meowstic-female':
            meowstic_female = pokemon
            break

    if not meowstic_female:
        print("エラー: meowstic-femaleが見つかりません")
        return

    # オスのデータが既に存在するかチェック
    meowstic_male_exists = any(p['name'] == 'meowstic' for p in data['pokemon'])
    if meowstic_male_exists:
        print("meowsticは既に存在します")
        return

    # オスのデータを作成（メスのデータをベースにする）
    meowstic_male = {
        "name": "meowstic",
        "nationalDexNumber": meowstic_female['nationalDexNumber'],
        "pokedexNumbers": meowstic_female['pokedexNumbers'].copy(),
        "nameJa": meowstic_female.get('nameJa', 'ニャオニクス'),
        "category": meowstic_female.get('category', 'normal'),
        "types": meowstic_female.get('types', []),
    }

    # メスの直後に挿入
    female_index = data['pokemon'].index(meowstic_female)
    data['pokemon'].insert(female_index, meowstic_male)

    print(f"追加: meowstic（オス）を meowstic-female の前に挿入")
    print(f"  nationalDexNumber: {meowstic_male['nationalDexNumber']}")
    print(f"  pokedexNumbers: {meowstic_male['pokedexNumbers']}")

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print("\n追加完了: 1件")

if __name__ == '__main__':
    input_file = 'Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    add_meowstic_male(input_file, output_file)
