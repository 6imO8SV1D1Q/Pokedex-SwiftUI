#!/usr/bin/env python3
"""
ポケモンの区分（category）を修正するスクリプト

正しい分類:
- normal: 一般ポケモン（600族含む）
- subLegendary: 準伝説（三鳥、三犬、レジ系など）
- legendary: 伝説（パッケージ伝説・禁止級）
- mythical: 幻（配布限定）
"""

import json
import sys

# 600族（擬似伝説）を一般に分類
PSEUDO_LEGENDARY = {
    "dragonite", "tyranitar", "salamence", "metagross", "garchomp",
    "hydreigon", "goodra", "goodra-hisui", "kommo-o", "dragapult",
    "baxcalibur", "archaludon",
    # その他600族相当
    "slaking",  # 合計種族値670だが一般
    "greninja-ash",  # サトシゲッコウガ
    "palafin-hero",  # パルデア600族相当
}

# 準伝説ポケモン（固定シンボル、禁止級でない伝説）
SUB_LEGENDARY = {
    # 三鳥
    "articuno", "zapdos", "moltres",
    "articuno-galar", "zapdos-galar", "moltres-galar",
    # 三犬
    "raikou", "entei", "suicune",
    # レジ系
    "regirock", "regice", "registeel", "regigigas", "regieleki", "regidrago",
    # レイクトリオ
    "uxie", "mesprit", "azelf",
    # ゴーレム系
    "cobalion", "terrakion", "virizion", "keldeo",
    # 雲系
    "tornadus", "thundurus", "landorus", "enamorus",
    "tornadus-therian", "thundurus-therian", "landorus-therian", "enamorus-therian",
    # オーラ系
    "tapu-koko", "tapu-lele", "tapu-bulu", "tapu-fini",
    # UB
    "nihilego", "buzzwole", "pheromosa", "xurkitree", "celesteela",
    "kartana", "guzzlord", "poipole", "naganadel", "stakataka", "blacephalon",
    # 四災
    "wo-chien", "chien-pao", "ting-lu", "chi-yu",
    # その他準伝説
    "heatran", "cresselia", "phione",
    "kubfu", "urshifu", "urshifu-rapid-strike",
    "glastrier", "spectrier", "calyrex",
}

def fix_categories(input_file, output_file):
    """区分を修正"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    fixed_count = 0

    for pokemon in data['pokemon']:
        name = pokemon['name']
        current_category = pokemon.get('category', 'normal')

        # 600族を一般に変更
        if name in PSEUDO_LEGENDARY:
            if current_category != 'normal':
                print(f"修正: {name}: {current_category} -> normal (600族)")
                pokemon['category'] = 'normal'
                fixed_count += 1

        # 準伝説を正しく分類
        elif name in SUB_LEGENDARY:
            if current_category != 'subLegendary':
                print(f"修正: {name}: {current_category} -> subLegendary")
                pokemon['category'] = 'subLegendary'
                fixed_count += 1

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: {fixed_count}件")

if __name__ == '__main__':
    input_file = 'Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_categories(input_file, output_file)
