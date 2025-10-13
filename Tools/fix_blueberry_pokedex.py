#!/usr/bin/env python3
"""
ブルーベリー図鑑の重複フォームを修正するスクリプト

修正内容:
【リージョンフォームのみが出現（通常を削除）】
- キュウコン: アローラのみ
- サンドパン: アローラのみ
- ディグダ、ダグトリオ: アローラのみ
- ベトベター、ベトベトン: アローラのみ
- ヤドラン、ヤドキング: ガラルのみ
- ハリーセン: ヒスイのみ

【通常フォームのみが出現（リージョンフォームを削除）】
- ケンタロス: 通常のみ（パルデアは削除）
- ウォーグル: 通常のみ（ヒスイは削除）
- ジュナイパー、バクフーン、ダイケンキ: 通常のみ（ヒスイは削除）
"""

import json
import sys

def fix_blueberry_pokedex(input_file, output_file):
    """ブルーベリー図鑑の重複フォームを削除"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # リージョンフォームのみが出現（通常の姿を削除）
    regional_form_only = [
        'vulpix',      # ロコン（アローラ）
        'ninetales',   # キュウコン（アローラ）
        'sandshrew',   # サンド（アローラ）
        'sandslash',   # サンドパン（アローラ）
        'diglett',     # ディグダ（アローラ）
        'dugtrio',     # ダグトリオ（アローラ）
        'geodude',     # イシツブテ（アローラ）
        'graveler',    # ゴローン（アローラ）
        'golem',       # ゴローニャ（アローラ）
        'grimer',      # ベトベター（アローラ）
        'muk',         # ベトベトン（アローラ）
        'slowpoke',    # ヤドン（ガラル）
        'slowbro',     # ヤドラン（ガラル）
        'slowking',    # ヤドキング（ガラル）
        'qwilfish',    # ハリーセン（ヒスイ）
    ]

    # 通常の姿のみが出現（リージョンフォームを削除）
    regional_forms_to_remove = [
        'tauros-paldea-combat-breed',     # ケンタロス（パルデア）
        'tauros-paldea-blaze-breed',
        'tauros-paldea-aqua-breed',
        'braviary-hisui',                 # ウォーグル（ヒスイ）
        'decidueye-hisui',                # ジュナイパー（ヒスイ）
        'typhlosion-hisui',               # バクフーン（ヒスイ）
        'samurott-hisui',                 # ダイケンキ（ヒスイ）
        'greninja-ash',                   # サトシゲッコウガ
    ]

    fixed_count = 0

    for pokemon in data['pokemon']:
        name = pokemon['name']
        pokedex_numbers = pokemon.get('pokedexNumbers', {})

        # リージョンフォームのみ（通常を削除）
        if name in regional_form_only and 'blueberry' in pokedex_numbers:
            print(f"修正: {name}: ブルーベリー図鑑番号を削除（リージョンフォームのみ残す）")
            del pokedex_numbers['blueberry']
            pokemon['pokedexNumbers'] = pokedex_numbers
            fixed_count += 1

        # 通常フォームのみ（リージョンフォームを削除）
        elif name in regional_forms_to_remove and 'blueberry' in pokedex_numbers:
            print(f"修正: {name}: ブルーベリー図鑑番号を削除（通常フォームのみ残す）")
            del pokedex_numbers['blueberry']
            pokemon['pokedexNumbers'] = pokedex_numbers
            fixed_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = 'Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_blueberry_pokedex(input_file, output_file)
