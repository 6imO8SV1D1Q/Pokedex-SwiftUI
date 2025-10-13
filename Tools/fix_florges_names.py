#!/usr/bin/env python3
"""
フラベベ・フラエッテ・フラージェスの日本語名から色説明を削除

（あかいはな）（きいろのはな）などの説明を削除し、
全て基本形と同じ名前（フラベベ、フラエッテ、フラージェス）に統一
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 フラベベ系統の日本語名を統一")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # フラベベ系統の色フォーム
    florges_family = {
        'flabebe': 'フラベベ',
        'floette': 'フラエッテ',
        'florges': 'フラージェス',
    }

    for pokemon in pokemon_list:
        name = pokemon['name']

        # 各系統の色フォームをチェック
        for base_name, simple_name in florges_family.items():
            if name.startswith(base_name + '-'):
                # 色フォームの場合
                old_name = pokemon.get('nameJa', '')
                if old_name != simple_name:
                    pokemon['nameJa'] = simple_name
                    print(f"  {name}: {old_name} → {simple_name}")
                    updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {updated_count}件の名前を統一")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
