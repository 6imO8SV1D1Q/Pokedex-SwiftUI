#!/usr/bin/env python3
"""
シキジカ、メブキジカ、ビビヨンのフォーム違いを追加するスクリプト

追加フォーム:
- シキジカ (deerling): spring, summer, autumn, winter
- メブキジカ (sawsbuck): spring, summer, autumn, winter
- ビビヨン (vivillon): 20種類の模様
"""

import json
import requests
import time

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def fetch_pokemon_form_data(form_name):
    """PokeAPIからフォームデータを取得"""
    try:
        url = f"https://pokeapi.co/api/v2/pokemon-form/{form_name}/"
        response = requests.get(url)
        response.raise_for_status()
        time.sleep(0.1)  # レート制限対策
        return response.json()
    except Exception as e:
        print(f"  ⚠️  フォームデータ取得失敗: {form_name} - {e}")
        return None

def create_form_variant(base_pokemon, form_name, form_name_ja):
    """基本形からフォームバリアントを作成"""
    variant = base_pokemon.copy()
    variant['name'] = form_name
    variant['nameJa'] = form_name_ja

    # スプライトは基本形と同じものを使用
    # 将来的にフォーム別の画像が必要な場合は、ここで差し替え可能

    return variant

def main():
    print("🎨 フォーム違いポケモン追加スクリプト")
    print("=" * 60)

    # JSONファイル読み込み
    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    added_count = 0

    # シキジカ (deerling)
    print("\n【シキジカ (deerling)】")
    deerling_base = next((p for p in pokemon_list if p['name'] == 'deerling'), None)
    if deerling_base:
        seasonal_forms = [
            ('deerling-spring', 'シキジカ（春）'),
            ('deerling-summer', 'シキジカ（夏）'),
            ('deerling-autumn', 'シキジカ（秋）'),
            ('deerling-winter', 'シキジカ（冬）'),
        ]

        for form_name, form_name_ja in seasonal_forms:
            # 既に存在するか確認
            if any(p['name'] == form_name for p in pokemon_list):
                print(f"  ✓ {form_name} は既に存在")
                continue

            variant = create_form_variant(deerling_base, form_name, form_name_ja)
            pokemon_list.append(variant)
            print(f"  ✅ 追加: {form_name} ({form_name_ja})")
            added_count += 1

    # メブキジカ (sawsbuck)
    print("\n【メブキジカ (sawsbuck)】")
    sawsbuck_base = next((p for p in pokemon_list if p['name'] == 'sawsbuck'), None)
    if sawsbuck_base:
        seasonal_forms = [
            ('sawsbuck-spring', 'メブキジカ（春）'),
            ('sawsbuck-summer', 'メブキジカ（夏）'),
            ('sawsbuck-autumn', 'メブキジカ（秋）'),
            ('sawsbuck-winter', 'メブキジカ（冬）'),
        ]

        for form_name, form_name_ja in seasonal_forms:
            if any(p['name'] == form_name for p in pokemon_list):
                print(f"  ✓ {form_name} は既に存在")
                continue

            variant = create_form_variant(sawsbuck_base, form_name, form_name_ja)
            pokemon_list.append(variant)
            print(f"  ✅ 追加: {form_name} ({form_name_ja})")
            added_count += 1

    # ビビヨン (vivillon)
    print("\n【ビビヨン (vivillon)】")
    vivillon_base = next((p for p in pokemon_list if p['name'] == 'vivillon'), None)
    if vivillon_base:
        pattern_forms = [
            ('vivillon-meadow', 'ビビヨン（花園）'),
            ('vivillon-icy-snow', 'ビビヨン（氷雪）'),
            ('vivillon-polar', 'ビビヨン（雪国）'),
            ('vivillon-tundra', 'ビビヨン（大陸）'),
            ('vivillon-continental', 'ビビヨン（大陸）'),
            ('vivillon-garden', 'ビビヨン（庭園）'),
            ('vivillon-elegant', 'ビビヨン（高雅）'),
            ('vivillon-modern', 'ビビヨン（モダン）'),
            ('vivillon-marine', 'ビビヨン（マリン）'),
            ('vivillon-archipelago', 'ビビヨン（群島）'),
            ('vivillon-high-plains', 'ビビヨン（荒野）'),
            ('vivillon-sandstorm', 'ビビヨン（砂塵）'),
            ('vivillon-river', 'ビビヨン（大河）'),
            ('vivillon-monsoon', 'ビビヨン（季節風）'),
            ('vivillon-savanna', 'ビビヨン（サバンナ）'),
            ('vivillon-sun', 'ビビヨン（太陽）'),
            ('vivillon-ocean', 'ビビヨン（大洋）'),
            ('vivillon-jungle', 'ビビヨン（ジャングル）'),
            ('vivillon-fancy', 'ビビヨン（ファンシー）'),
            ('vivillon-poke-ball', 'ビビヨン（ボール）'),
        ]

        for form_name, form_name_ja in pattern_forms:
            if any(p['name'] == form_name for p in pokemon_list):
                print(f"  ✓ {form_name} は既に存在")
                continue

            variant = create_form_variant(vivillon_base, form_name, form_name_ja)
            pokemon_list.append(variant)
            print(f"  ✅ 追加: {form_name} ({form_name_ja})")
            added_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n✅ 完了: {added_count}フォームを追加")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
