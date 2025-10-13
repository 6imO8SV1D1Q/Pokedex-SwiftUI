#!/usr/bin/env python3
"""
コスメティックフォーム・性能違いフォームを追加

追加するポケモン（全てSVに登場）:
1. カラナクシ・トリトドン（東西）- コスメティック
2. シキジカ・メブキジカ（春夏秋冬）- コスメティック
3. ビビヨン（20模様）- コスメティック
4. フラベベ・フラエッテ・フラージェス（5色）- コスメティック
"""

import json
import requests
import time

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def fetch_pokemon_data(pokemon_id_or_name):
    """PokeAPIからポケモンデータを取得"""
    try:
        url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_id_or_name}/"
        response = requests.get(url)
        response.raise_for_status()
        time.sleep(0.15)
        return response.json()
    except Exception as e:
        print(f"  ⚠️  データ取得失敗: {pokemon_id_or_name} - {e}")
        return None

def create_pokemon_from_api(api_data, name_ja, pokedex_numbers=None):
    """PokeAPIデータからポケモンエントリを作成"""
    if not api_data:
        return None

    # 種族値
    stats = {}
    for stat in api_data.get('stats', []):
        stat_name = stat['stat']['name']
        if stat_name == 'hp':
            stats['hp'] = stat['base_stat']
        elif stat_name == 'attack':
            stats['attack'] = stat['base_stat']
        elif stat_name == 'defense':
            stats['defense'] = stat['base_stat']
        elif stat_name == 'special-attack':
            stats['spAttack'] = stat['base_stat']
        elif stat_name == 'special-defense':
            stats['spDefense'] = stat['base_stat']
        elif stat_name == 'speed':
            stats['speed'] = stat['base_stat']

    total = sum(stats.values())
    stats['total'] = total

    # 特性
    abilities_primary = []
    abilities_hidden = None
    for ability in api_data.get('abilities', []):
        ability_id = int(ability['ability']['url'].rstrip('/').split('/')[-1])
        if ability['is_hidden']:
            abilities_hidden = ability_id
        else:
            abilities_primary.append(ability_id)

    # スプライト
    sprites_data = api_data.get('sprites', {})
    other = sprites_data.get('other', {})
    home = other.get('home', {})

    sprites = {
        'normal': home.get('front_default', ''),
        'shiny': home.get('front_shiny', '')
    }

    # タイプ
    types = [t['type']['name'] for t in api_data.get('types', [])]

    # 基本情報
    pokemon_entry = {
        'id': api_data['id'],
        'nationalDexNumber': api_data['id'],
        'name': api_data['name'],
        'nameJa': name_ja,
        'sprites': sprites,
        'types': types,
        'abilities': {
            'primary': abilities_primary,
            'hidden': abilities_hidden
        },
        'baseStats': stats,
        'pokedexNumbers': pokedex_numbers or {}
    }

    return pokemon_entry

def create_cosmetic_variant(base_pokemon, form_name, name_ja):
    """コスメティックフォーム（性能同じ）を作成"""
    variant = base_pokemon.copy()
    variant['name'] = form_name
    variant['nameJa'] = name_ja
    # 図鑑番号は引き継がない（一覧に表示しない）
    variant['pokedexNumbers'] = {}
    return variant

def main():
    print("🎨 全フォーム追加スクリプト")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    added_count = 0

    # ===== カラナクシ・トリトドン（東西） =====
    print("\n【カラナクシ・トリトドン】")
    shellos_base = next((p for p in pokemon_list if p['name'] == 'shellos'), None)
    gastrodon_base = next((p for p in pokemon_list if p['name'] == 'gastrodon'), None)

    if shellos_base:
        forms = [
            ('shellos-east', 'カラナクシ（ひがしのうみ）'),
            ('shellos-west', 'カラナクシ（にしのうみ）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(shellos_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    if gastrodon_base:
        forms = [
            ('gastrodon-east', 'トリトドン（ひがしのうみ）'),
            ('gastrodon-west', 'トリトドン（にしのうみ）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(gastrodon_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    # ===== シキジカ・メブキジカ（春夏秋冬） =====
    print("\n【シキジカ・メブキジカ】")
    deerling_base = next((p for p in pokemon_list if p['name'] == 'deerling'), None)
    sawsbuck_base = next((p for p in pokemon_list if p['name'] == 'sawsbuck'), None)

    if deerling_base:
        forms = [
            ('deerling-spring', 'シキジカ（はるのすがた）'),
            ('deerling-summer', 'シキジカ（なつのすがた）'),
            ('deerling-autumn', 'シキジカ（あきのすがた）'),
            ('deerling-winter', 'シキジカ（ふゆのすがた）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(deerling_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    if sawsbuck_base:
        forms = [
            ('sawsbuck-spring', 'メブキジカ（はるのすがた）'),
            ('sawsbuck-summer', 'メブキジカ（なつのすがた）'),
            ('sawsbuck-autumn', 'メブキジカ（あきのすがた）'),
            ('sawsbuck-winter', 'メブキジカ（ふゆのすがた）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(sawsbuck_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    # ===== ビビヨン（20模様） =====
    print("\n【ビビヨン】")
    vivillon_base = next((p for p in pokemon_list if p['name'] == 'vivillon'), None)

    if vivillon_base:
        forms = [
            ('vivillon-meadow', 'ビビヨン（花園）'),
            ('vivillon-icy-snow', 'ビビヨン（氷雪）'),
            ('vivillon-polar', 'ビビヨン（雪国）'),
            ('vivillon-tundra', 'ビビヨン（ツンドラ）'),
            ('vivillon-continental', 'ビビヨン（大陸）'),
            ('vivillon-garden', 'ビビヨン（庭園）'),
            ('vivillon-elegant', 'ビビヨン（高雅）'),
            ('vivillon-modern', 'ビビヨン（モダン）'),
            ('vivillon-marine', 'ビビヨン（マリン）'),
            ('vivillon-archipelago', 'ビビヨン（群島）'),
            ('vivillon-high-plains', 'ビビヨン（荒野）'),
            ('vivillon-sandstorm', 'ビビヨン（砂塵）'),
            ('vivillon-river', 'ビビヨン（大河）'),
            ('vivillon-monsoon', 'ビビヨン（スコール）'),
            ('vivillon-savanna', 'ビビヨン（サバンナ）'),
            ('vivillon-sun', 'ビビヨン（太陽）'),
            ('vivillon-ocean', 'ビビヨン（大洋）'),
            ('vivillon-jungle', 'ビビヨン（ジャングル）'),
            ('vivillon-fancy', 'ビビヨン（ファンシー）'),
            ('vivillon-poke-ball', 'ビビヨン（ボール）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(vivillon_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    # ===== フラベベ・フラエッテ・フラージェス（5色） =====
    print("\n【フラベベ・フラエッテ・フラージェス】")
    flabebe_base = next((p for p in pokemon_list if p['name'] == 'flabebe'), None)
    floette_base = next((p for p in pokemon_list if p['name'] == 'floette'), None)
    florges_base = next((p for p in pokemon_list if p['name'] == 'florges'), None)

    if flabebe_base:
        forms = [
            ('flabebe-red', 'フラベベ（あかいはな）'),
            ('flabebe-yellow', 'フラベベ（きいろのはな）'),
            ('flabebe-orange', 'フラベベ（オレンジいろのはな）'),
            ('flabebe-blue', 'フラベベ（あおいはな）'),
            ('flabebe-white', 'フラベベ（しろいはな）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(flabebe_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    if floette_base:
        forms = [
            ('floette-red', 'フラエッテ（あかいはな）'),
            ('floette-yellow', 'フラエッテ（きいろのはな）'),
            ('floette-orange', 'フラエッテ（オレンジいろのはな）'),
            ('floette-blue', 'フラエッテ（あおいはな）'),
            ('floette-white', 'フラエッテ（しろいはな）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(floette_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    if florges_base:
        forms = [
            ('florges-red', 'フラージェス（あかいはな）'),
            ('florges-yellow', 'フラージェス（きいろのはな）'),
            ('florges-orange', 'フラージェス（オレンジいろのはな）'),
            ('florges-blue', 'フラージェス（あおいはな）'),
            ('florges-white', 'フラージェス（しろいはな）'),
        ]
        for form_name, name_ja in forms:
            if not any(p['name'] == form_name for p in pokemon_list):
                variant = create_cosmetic_variant(florges_base, form_name, name_ja)
                pokemon_list.append(variant)
                print(f"  ✅ {form_name} ({name_ja})")
                added_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了: {added_count}フォームを追加")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
