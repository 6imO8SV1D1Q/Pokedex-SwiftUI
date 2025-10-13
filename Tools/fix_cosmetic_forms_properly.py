#!/usr/bin/env python3
"""
コスメティックフォームを正しく処理

1. 指定したコスメティックフォームの pokedexNumbers を {} に設定（一覧非表示）
2. 指定したコスメティックフォームの nationalDexNumber を削除（全国図鑑からも非表示）
3. 指定したコスメティックフォームの日本語名から（）を削除（一覧表示用）

伝説・幻、地方フォームなどは影響を受けない
"""

import json
import re

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 コスメティックフォームを正しく処理")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # コスメティックフォームの明示的なリスト
    cosmetic_forms = [
        # ピカチュウ帽子
        'pikachu-original-cap', 'pikachu-hoenn-cap', 'pikachu-sinnoh-cap',
        'pikachu-unova-cap', 'pikachu-kalos-cap', 'pikachu-alola-cap',
        'pikachu-partner-cap', 'pikachu-world-cap',

        # フラベベ系統の色
        'flabebe-red', 'flabebe-yellow', 'flabebe-orange', 'flabebe-blue', 'flabebe-white',
        'floette-red', 'floette-yellow', 'floette-orange', 'floette-blue', 'floette-white',
        'florges-red', 'florges-yellow', 'florges-orange', 'florges-blue', 'florges-white',

        # ビビヨンの模様
        'vivillon-meadow', 'vivillon-icy-snow', 'vivillon-polar', 'vivillon-tundra',
        'vivillon-continental', 'vivillon-garden', 'vivillon-elegant', 'vivillon-modern',
        'vivillon-marine', 'vivillon-archipelago', 'vivillon-high-plains', 'vivillon-sandstorm',
        'vivillon-river', 'vivillon-monsoon', 'vivillon-savanna', 'vivillon-sun',
        'vivillon-ocean', 'vivillon-jungle', 'vivillon-fancy', 'vivillon-poke-ball',

        # シキジカ・メブキジカの季節
        'deerling-spring', 'deerling-summer', 'deerling-autumn', 'deerling-winter',
        'sawsbuck-spring', 'sawsbuck-summer', 'sawsbuck-autumn', 'sawsbuck-winter',

        # カラナクシ・トリトドンの地域
        'shellos-east', 'shellos-west', 'gastrodon-east', 'gastrodon-west',

        # アルセウスのタイプ
        'arceus-fighting', 'arceus-flying', 'arceus-poison', 'arceus-ground',
        'arceus-rock', 'arceus-bug', 'arceus-ghost', 'arceus-steel',
        'arceus-fire', 'arceus-water', 'arceus-grass', 'arceus-electric',
        'arceus-psychic', 'arceus-ice', 'arceus-dragon', 'arceus-dark', 'arceus-fairy',

        # メテノの色（赤以外）
        'minior-orange-meteor', 'minior-yellow-meteor', 'minior-green-meteor',
        'minior-blue-meteor', 'minior-indigo-meteor', 'minior-violet-meteor',
        'minior-orange', 'minior-yellow', 'minior-green',
        'minior-blue', 'minior-indigo', 'minior-violet',

        # その他コスメティック
        'zarude-dada', 'magearna-original',
        'maushold-family-of-four', 'maushold-family-of-three',
        'tatsugiri-droopy', 'tatsugiri-stretchy',
        'dudunsparce-two-segment', 'dudunsparce-three-segment',
        'basculin-blue-striped', 'mimikyu-busted',
    ]

    pokedex_cleared = 0
    national_removed = 0
    name_simplified = 0

    print("\n【コスメティックフォームを処理】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in cosmetic_forms:
            # 1. pokedexNumbers を空に
            old_pokedex = pokemon.get('pokedexNumbers', {})
            if old_pokedex != {}:
                pokemon['pokedexNumbers'] = {}
                print(f"  {name}: pokedexNumbers削除")
                pokedex_cleared += 1

            # 2. nationalDexNumber を削除
            if 'nationalDexNumber' in pokemon:
                del pokemon['nationalDexNumber']
                national_removed += 1

            # 3. 日本語名から（）を削除
            name_ja = pokemon.get('nameJa', '')
            if '（' in name_ja:
                new_name_ja = re.sub(r'（[^）]*）', '', name_ja)
                pokemon['nameJa'] = new_name_ja
                print(f"    {name_ja} → {new_name_ja}")
                name_simplified += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了:")
    print(f"   - pokedexNumbers削除: {pokedex_cleared}件")
    print(f"   - nationalDexNumber削除: {national_removed}件")
    print(f"   - 日本語名簡略化: {name_simplified}件")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
