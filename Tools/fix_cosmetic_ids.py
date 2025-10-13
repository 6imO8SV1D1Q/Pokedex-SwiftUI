#!/usr/bin/env python3
"""
コスメティックフォームにユニークなIDを割り当て

ID重複を解消するため、コスメティックフォームに10000番台のIDを割り当てます。
アルセウスは既に10118-10134を使用しているため、それ以降から採番します。
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 コスメティックフォームにユニークなIDを割り当て")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # ID重複しているポケモンを検出
    ids = {}
    for p in pokemon_list:
        pid = p['id']
        if pid not in ids:
            ids[pid] = []
        ids[pid].append(p['name'])

    duplicates = {id: names for id, names in ids.items() if len(names) > 1}

    print(f"\n【ID重複検出: {len(duplicates)}件】")
    for id, names in sorted(duplicates.items()):
        print(f"  ID {id}: {len(names)}件 - {names[0]} 他")

    # コスメティックフォームのリスト（基本形以外）
    cosmetic_variants = []

    # 各グループの基本形とバリアントを識別
    groups = {
        'shellos': ['shellos-east', 'shellos-west'],
        'gastrodon': ['gastrodon-east', 'gastrodon-west'],
        'deerling': ['deerling-spring', 'deerling-summer', 'deerling-autumn', 'deerling-winter'],
        'sawsbuck': ['sawsbuck-spring', 'sawsbuck-summer', 'sawsbuck-autumn', 'sawsbuck-winter'],
        'vivillon': ['vivillon-meadow', 'vivillon-icy-snow', 'vivillon-polar', 'vivillon-tundra',
                     'vivillon-continental', 'vivillon-garden', 'vivillon-elegant', 'vivillon-modern',
                     'vivillon-marine', 'vivillon-archipelago', 'vivillon-high-plains', 'vivillon-sandstorm',
                     'vivillon-river', 'vivillon-monsoon', 'vivillon-savanna', 'vivillon-sun',
                     'vivillon-ocean', 'vivillon-jungle', 'vivillon-fancy', 'vivillon-poke-ball'],
        'flabebe': ['flabebe-red', 'flabebe-yellow', 'flabebe-orange', 'flabebe-blue', 'flabebe-white'],
        'floette': ['floette-red', 'floette-yellow', 'floette-orange', 'floette-blue', 'floette-white'],
        'florges': ['florges-red', 'florges-yellow', 'florges-orange', 'florges-blue', 'florges-white'],
        'minior': ['minior-orange-meteor', 'minior-yellow-meteor', 'minior-green-meteor',
                   'minior-blue-meteor', 'minior-indigo-meteor', 'minior-violet-meteor',
                   'minior-orange', 'minior-yellow', 'minior-green',
                   'minior-blue', 'minior-indigo', 'minior-violet'],
    }

    for base, variants in groups.items():
        cosmetic_variants.extend(variants)

    # 10135から採番開始（アルセウスが10134まで使用）
    next_id = 10135
    updated_count = 0

    print(f"\n【ユニークID割り当て】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in cosmetic_variants:
            old_id = pokemon['id']
            pokemon['id'] = next_id
            print(f"  {name}: ID {old_id} → {next_id}")
            next_id += 1
            updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了: {updated_count}件のIDを更新")
    print(f"📝 割り当てたID範囲: 10135-{next_id-1}")
    print(f"📝 保存先: {OUTPUT_FILE}")

    # 検証
    print(f"\n【検証】")
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        verify_data = json.load(f)

    verify_ids = [p['id'] for p in verify_data['pokemon']]
    verify_duplicates = [id for id in set(verify_ids) if verify_ids.count(id) > 1]

    if verify_duplicates:
        print(f"❌ まだID重複があります: {len(verify_duplicates)}件")
    else:
        print(f"✅ ID重複なし")

if __name__ == '__main__':
    main()
