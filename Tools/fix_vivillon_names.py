#!/usr/bin/env python3
"""
ビビヨンのフォーム名を漢字からカタカナ/ひらがなに変更
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 ビビヨンのフォーム名をカタカナに変更")
    print("=" * 60)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']
    updated_count = 0

    # ビビヨンのフォーム名マッピング
    vivillon_names = {
        'vivillon-meadow': 'ビビヨン（はなぞのもよう）',
        'vivillon-icy-snow': 'ビビヨン（ひょうせつのもよう）',
        'vivillon-polar': 'ビビヨン（ゆきぐにのもよう）',
        'vivillon-tundra': 'ビビヨン（ツンドラのもよう）',
        'vivillon-continental': 'ビビヨン（たいりくのもよう）',
        'vivillon-garden': 'ビビヨン（ていえんのもよう）',
        'vivillon-elegant': 'ビビヨン（こうがなもよう）',
        'vivillon-modern': 'ビビヨン（モダンなもよう）',
        'vivillon-marine': 'ビビヨン（マリンのもよう）',
        'vivillon-archipelago': 'ビビヨン（ぐんとうのもよう）',
        'vivillon-high-plains': 'ビビヨン（こうやのもよう）',
        'vivillon-sandstorm': 'ビビヨン（さじんのもよう）',
        'vivillon-river': 'ビビヨン（たいがのもよう）',
        'vivillon-monsoon': 'ビビヨン（スコールのもよう）',
        'vivillon-savanna': 'ビビヨン（サバンナのもよう）',
        'vivillon-sun': 'ビビヨン（たいようのもよう）',
        'vivillon-ocean': 'ビビヨン（おおうみのもよう）',
        'vivillon-jungle': 'ビビヨン（ジャングルのもよう）',
        'vivillon-fancy': 'ビビヨン（ファンシーなもよう）',
        'vivillon-poke-ball': 'ビビヨン（ボールのもよう）',
    }

    print("\n【ビビヨン】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        if name in vivillon_names:
            new_name = vivillon_names[name]
            old_name = pokemon.get('nameJa', '')
            if old_name != new_name:
                pokemon['nameJa'] = new_name
                print(f"  {name}: {old_name} → {new_name}")
                updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*60}")
    print(f"✅ 完了: {updated_count}件の名前を変更")
    print(f"📝 保存先: {OUTPUT_FILE}")

if __name__ == '__main__':
    main()
