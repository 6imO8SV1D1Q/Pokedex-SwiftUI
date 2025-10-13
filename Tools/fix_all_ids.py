#!/usr/bin/env python3
"""
全てのID重複を解消

10000番台は既に使われているため、20000番台から採番します。
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 全てのID重複を解消")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # 現在使用されている最大IDを確認
    max_id = max(p['id'] for p in pokemon_list)
    print(f"\n現在の最大ID: {max_id}")

    # ID重複しているポケモンを検出
    ids = {}
    for p in pokemon_list:
        pid = p['id']
        if pid not in ids:
            ids[pid] = []
        ids[pid].append(p)

    duplicates = {id: pokemons for id, pokemons in ids.items() if len(pokemons) > 1}

    print(f"\n【ID重複検出: {len(duplicates)}件】")

    # 20000から採番開始
    next_id = 20000
    updated_count = 0

    print(f"\n【ID修正】")
    for dup_id in sorted(duplicates.keys()):
        pokemons = duplicates[dup_id]
        # 最初の1つは元のIDのまま、残りに新しいIDを割り当て
        print(f"\nID {dup_id}: {len(pokemons)}件")
        for i, pokemon in enumerate(pokemons):
            if i == 0:
                print(f"  {pokemon['name']}: ID {dup_id} (維持)")
            else:
                old_id = pokemon['id']
                pokemon['id'] = next_id
                print(f"  {pokemon['name']}: ID {old_id} → {next_id}")
                next_id += 1
                updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了: {updated_count}件のIDを更新")
    print(f"📝 割り当てたID範囲: 20000-{next_id-1}")
    print(f"📝 保存先: {OUTPUT_FILE}")

    # 検証
    print(f"\n【検証】")
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        verify_data = json.load(f)

    verify_ids = [p['id'] for p in verify_data['pokemon']]
    verify_duplicates = [id for id in set(verify_ids) if verify_ids.count(id) > 1]

    if verify_duplicates:
        print(f"❌ まだID重複があります: {len(verify_duplicates)}件")
        for vid in verify_duplicates[:5]:
            matching = [p['name'] for p in verify_data['pokemon'] if p['id'] == vid]
            print(f"  ID {vid}: {matching}")
    else:
        print(f"✅ ID重複なし - 全{len(verify_data['pokemon'])}件のポケモン")

if __name__ == '__main__':
    main()
