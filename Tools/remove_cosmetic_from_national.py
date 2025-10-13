#!/usr/bin/env python3
"""
コスメティックフォームを全国図鑑から除外 & 日本語名から（）を削除

1. pokedexNumbers が空（{}）のポケモンから nationalDexNumber を削除
2. 全コスメティックフォームの日本語名から（）内の説明を削除
"""

import json
import re

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 コスメティックフォームを全国図鑑から除外 & 名前から（）削除")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    removed_count = 0
    renamed_count = 0

    print("\n【全国図鑑から除外 & 日本語名修正】")
    for pokemon in pokemon_list:
        name = pokemon['name']
        pokedex_numbers = pokemon.get('pokedexNumbers', {})

        # pokedexNumbers が空の場合、全国図鑑からも除外
        if not pokedex_numbers or pokedex_numbers == {}:
            if 'nationalDexNumber' in pokemon:
                del pokemon['nationalDexNumber']
                print(f"  {name}: nationalDexNumber削除")
                removed_count += 1

            # 日本語名から（）を削除
            name_ja = pokemon.get('nameJa', '')
            if '（' in name_ja:
                # （）とその中身を削除
                new_name_ja = re.sub(r'（[^）]*）', '', name_ja)
                pokemon['nameJa'] = new_name_ja
                print(f"    {name_ja} → {new_name_ja}")
                renamed_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了:")
    print(f"   - nationalDexNumber削除: {removed_count}件")
    print(f"   - 日本語名修正: {renamed_count}件")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
