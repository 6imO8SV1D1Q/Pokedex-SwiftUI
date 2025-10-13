#!/usr/bin/env python3
"""
キタカミ図鑑の不具合を修正するスクリプト

修正内容:
【削除するポケモン】
- ウパー（パルデア）
- リージョンフォーム:
  - アローラ: ライチュウ、ロコン、キュウコン、イシツブテ、ゴローン、ゴローニャ、サンド、サンドパン
  - ガラル: マタドガス
  - ヒスイ: ガーディ、ウインディ、ニューラ、ドレディア、ヌメルゴン
- 通常のバスラオ（赤筋・青筋）

【追加するポケモン】
- ノココッチ（全フォーム）
"""

import json
import sys

def fix_kitakami_pokedex(input_file, output_file):
    """キタカミ図鑑の不具合を修正"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # キタカミ図鑑から削除すべきポケモン
    remove_from_kitakami = [
        'mimikyu-busted',         # ミミッキュ（化けの皮が剥がれた姿）
        'wooper-paldea',          # ウパー（パルデア）
        # リージョンフォーム - アローラ
        'raichu-alola',           # アローラライチュウ
        'vulpix-alola',           # アローラロコン
        'ninetales-alola',        # アローラキュウコン
        'geodude-alola',          # アローライシツブテ
        'graveler-alola',         # アローラゴローン
        'golem-alola',            # アローラゴローニャ
        'sandshrew-alola',        # アローラサンド
        'sandslash-alola',        # アローラサンドパン
        # リージョンフォーム - ガラル
        'weezing-galar',          # ガラルマタドガス
        # リージョンフォーム - ヒスイ
        'growlithe-hisui',        # ヒスイガーディ
        'arcanine-hisui',         # ヒスイウインディ
        'sneasel-hisui',          # ヒスイニューラ
        'lilligant-hisui',        # ヒスイドレディア
        'sliggoo-hisui',          # ヒスイヌメイル
        'goodra-hisui',           # ヒスイヌメルゴン
        # 通常のバスラオ
        'basculin-red-striped',   # バスラオ（赤筋）
        'basculin-blue-striped',  # バスラオ（青筋）
    ]

    fixed_count = 0

    for pokemon in data['pokemon']:
        name = pokemon['name']
        pokedex_numbers = pokemon.get('pokedexNumbers', {})

        # キタカミ図鑑番号を削除
        if name in remove_from_kitakami and 'kitakami' in pokedex_numbers:
            print(f"修正: {name}: キタカミ図鑑番号を削除")
            del pokedex_numbers['kitakami']
            pokemon['pokedexNumbers'] = pokedex_numbers
            fixed_count += 1

        # ノココッチにキタカミ図鑑番号を追加
        if name in ['dudunsparce', 'dudunsparce-two-segment', 'dudunsparce-three-segment']:
            if 'kitakami' not in pokedex_numbers:
                # パルデア図鑑番号から推測（189）
                paldea_num = pokedex_numbers.get('paldea')
                if paldea_num:
                    print(f"追加: {name}: キタカミ図鑑番号を追加")
                    pokedex_numbers['kitakami'] = 161  # ノココッチのキタカミ図鑑番号
                    pokemon['pokedexNumbers'] = pokedex_numbers
                    fixed_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_kitakami_pokedex(input_file, output_file)
