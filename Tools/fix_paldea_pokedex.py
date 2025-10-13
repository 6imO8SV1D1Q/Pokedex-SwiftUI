#!/usr/bin/env python3
"""
パルデア図鑑の不具合を修正するスクリプト

修正内容:
【削除するポケモン】
1. ミミッキュ（化けの皮が剥がれた姿）
2. リージョンフォーム:
   - アローラ: ライチュウ、ディグダ、ダグトリオ、ニャース、ペルシアン
   - ガラル: ニャース、ニャイキング、ヤドラン、ヤドキング
   - ヒスイ: ビリリダマ、マルマイン、ガーディ、ウインディ、ゾロア、ゾロアーク、
            ニューラ、ドレディア、ハリーセン、ウォーグル、ヌメルゴン、クレベース
3. その他: ウパー（原種）、バスラオ（白筋）

【追加するポケモン】
- ノココッチ（全フォーム）
"""

import json
import sys

def fix_paldea_pokedex(input_file, output_file):
    """パルデア図鑑の不具合を修正"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # パルデア図鑑から削除すべきポケモン
    remove_from_paldea = [
        'mimikyu-busted',         # ミミッキュ（化けの皮が剥がれた姿）
        # リージョンフォーム - アローラ
        'raichu-alola',           # アローラライチュウ
        'diglett-alola',          # アローラディグダ
        'dugtrio-alola',          # アローラダグトリオ
        'meowth-alola',           # アローラニャース
        'persian-alola',          # アローラペルシアン
        'grimer-alola',           # アローラベトベター
        'muk-alola',              # アローラベトベトン
        # リージョンフォーム - ガラル
        'meowth-galar',           # ガラルニャース
        'perrserker',             # ニャイキング
        'slowpoke-galar',         # ガラルヤドン
        'slowbro-galar',          # ガラルヤドラン
        'slowking-galar',         # ガラルヤドキング
        # リージョンフォーム - ヒスイ
        'voltorb-hisui',          # ヒスイビリリダマ
        'electrode-hisui',        # ヒスイマルマイン
        'growlithe-hisui',        # ヒスイガーディ
        'arcanine-hisui',         # ヒスイウインディ
        'zorua-hisui',            # ヒスイゾロア
        'zoroark-hisui',          # ヒスイゾロアーク
        'sneasel-hisui',          # ヒスイニューラ
        'lilligant-hisui',        # ヒスイドレディア
        'qwilfish-hisui',         # ヒスイハリーセン
        'braviary-hisui',         # ヒスイウォーグル
        'sliggoo-hisui',          # ヒスイヌメイル
        'goodra-hisui',           # ヒスイヌメルゴン
        'avalugg-hisui',          # ヒスイクレベース
        # その他
        'wooper',                 # ウパー（原種）
        'basculin-white-striped', # バスラオ（白筋）
    ]

    fixed_count = 0

    for pokemon in data['pokemon']:
        name = pokemon['name']
        pokedex_numbers = pokemon.get('pokedexNumbers', {})

        # パルデア図鑑番号を削除
        if name in remove_from_paldea and 'paldea' in pokedex_numbers:
            print(f"修正: {name}: パルデア図鑑番号を削除")
            del pokedex_numbers['paldea']
            pokemon['pokedexNumbers'] = pokedex_numbers
            fixed_count += 1

        # ノココッチにパルデア図鑑番号を追加（既に持っているはずだが確認）
        if name in ['dudunsparce', 'dudunsparce-two-segment', 'dudunsparce-three-segment']:
            if 'paldea' not in pokedex_numbers:
                print(f"追加: {name}: パルデア図鑑番号を追加")
                pokedex_numbers['paldea'] = 189  # ノココッチのパルデア図鑑番号
                pokemon['pokedexNumbers'] = pokedex_numbers
                fixed_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_paldea_pokedex(input_file, output_file)
