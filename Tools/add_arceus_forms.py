#!/usr/bin/env python3
"""
アルセウスの17タイプフォームを追加（ノーマル除く全タイプ）

アルセウスはプレートでタイプが変わるため、各タイプを別個体として一覧に表示する。
種族値・特性は全フォーム同じだが、タイプが違うため性能が違うと判断。
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 アルセウス17タイプフォーム追加")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # 基本形のアルセウスを取得
    arceus_base = next((p for p in pokemon_list if p['name'] == 'arceus'), None)

    if not arceus_base:
        print("❌ アルセウスが見つかりません")
        return

    print(f"✅ 基本形アルセウス発見")
    print(f"   タイプ: {arceus_base.get('types', [])}")
    print(f"   パルデア図鑑: #{arceus_base.get('pokedexNumbers', {}).get('paldea', '-')}")

    # 17タイプのフォーム（ノーマルを除く全タイプ）
    type_forms = [
        ('arceus-fighting', 'アルセウス（かくとう）', 'fighting'),
        ('arceus-flying', 'アルセウス（ひこう）', 'flying'),
        ('arceus-poison', 'アルセウス（どく）', 'poison'),
        ('arceus-ground', 'アルセウス（じめん）', 'ground'),
        ('arceus-rock', 'アルセウス（いわ）', 'rock'),
        ('arceus-bug', 'アルセウス（むし）', 'bug'),
        ('arceus-ghost', 'アルセウス（ゴースト）', 'ghost'),
        ('arceus-steel', 'アルセウス（はがね）', 'steel'),
        ('arceus-fire', 'アルセウス（ほのお）', 'fire'),
        ('arceus-water', 'アルセウス（みず）', 'water'),
        ('arceus-grass', 'アルセウス（くさ）', 'grass'),
        ('arceus-electric', 'アルセウス（でんき）', 'electric'),
        ('arceus-psychic', 'アルセウス（エスパー）', 'psychic'),
        ('arceus-ice', 'アルセウス（こおり）', 'ice'),
        ('arceus-dragon', 'アルセウス（ドラゴン）', 'dragon'),
        ('arceus-dark', 'アルセウス（あく）', 'dark'),
        ('arceus-fairy', 'アルセウス（フェアリー）', 'fairy'),
    ]

    added_count = 0

    print(f"\n17タイプフォームを追加:")

    for form_name, name_ja, type_name in type_forms:
        # 既に存在するか確認
        if any(p['name'] == form_name for p in pokemon_list):
            print(f"  ✓ {form_name} は既に存在")
            continue

        # 基本形をコピー
        variant = arceus_base.copy()
        variant['name'] = form_name
        variant['nameJa'] = name_ja

        # タイプを変更
        variant['types'] = [type_name]

        # スプライトURLを変更（Pokemon HOME）
        type_suffix = form_name.replace('arceus-', '')
        variant['sprites'] = {
            'normal': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/493-{type_suffix}.png',
            'shiny': f'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/493-{type_suffix}.png'
        }

        # 図鑑番号は引き継ぐ（一覧に表示する）
        # すでにコピーされているのでそのまま

        pokemon_list.append(variant)
        print(f"  ✅ {form_name} ({name_ja}) - タイプ: {type_name}")
        added_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {added_count}フォームを追加")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
