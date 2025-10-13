#!/usr/bin/env python3
"""
最終修正：
1. アルセウスのタイプフォーム17個を一覧表示（nationalDexNumber復元、日本語名は「アルセウス」）
2. マイペースイワンコのスプライトを通常イワンコと同じにする
3. 他のコスメティックは非表示のまま
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 最終修正")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # アルセウスのタイプフォーム
    arceus_forms = [
        'arceus-fighting', 'arceus-flying', 'arceus-poison', 'arceus-ground',
        'arceus-rock', 'arceus-bug', 'arceus-ghost', 'arceus-steel',
        'arceus-fire', 'arceus-water', 'arceus-grass', 'arceus-electric',
        'arceus-psychic', 'arceus-ice', 'arceus-dragon', 'arceus-dark', 'arceus-fairy',
    ]

    arceus_updated = 0

    print("\n【アルセウス - タイプフォームを一覧表示】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in arceus_forms:
            # nationalDexNumberを復元（元々は493だがユニークIDが必要）
            # IDが既に10118-10134の範囲に設定されているはず
            pokemon_id = pokemon.get('id')
            if 'nationalDexNumber' not in pokemon:
                # 全国図鑑番号は493（アルセウス）
                pokemon['nationalDexNumber'] = 493
                print(f"  {name}: nationalDexNumber=493 を追加")
                arceus_updated += 1

            # 日本語名は「アルセウス」のみ（既に（）削除済みのはず）
            if pokemon.get('nameJa') != 'アルセウス':
                pokemon['nameJa'] = 'アルセウス'

    # マイペースイワンコのスプライトを修正
    print("\n【イワンコ - マイペース特性のスプライト修正】")
    rockruff_normal = next((p for p in pokemon_list if p['name'] == 'rockruff'), None)
    rockruff_own_tempo = next((p for p in pokemon_list if p['name'] == 'rockruff-own-tempo'), None)

    if rockruff_normal and rockruff_own_tempo:
        normal_sprites = rockruff_normal.get('sprites', {})
        old_sprites = rockruff_own_tempo.get('sprites', {})

        # 通常イワンコと同じスプライトに変更
        rockruff_own_tempo['sprites'] = normal_sprites.copy()

        print(f"  rockruff-own-tempo:")
        print(f"    変更前: {old_sprites.get('normal', '')}")
        print(f"    変更後: {normal_sprites.get('normal', '')}")
    else:
        print("  ⚠️  イワンコが見つかりませんでした")

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了:")
    print(f"   - アルセウス nationalDexNumber追加: {arceus_updated}件")
    print(f"   - イワンコスプライト修正: 1件")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
