#!/usr/bin/env python3
"""
全てのポケモンにnationalDexNumberを復元

基本形と同じnationalDexNumberを設定する
"""

import json

INPUT_FILE = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
OUTPUT_FILE = INPUT_FILE

def main():
    print("🎨 nationalDexNumberを復元")
    print("=" * 70)

    with open(INPUT_FILE, 'r', encoding='utf-8') as f:
        data = json.load(f)

    pokemon_list = data['pokemon']

    # 基本形のnationalDexNumberマッピング
    base_national_numbers = {
        # ピカチュウ帽子
        'pikachu': 25,
        # カラナクシ・トリトドン
        'shellos': 422,
        'gastrodon': 423,
        # バスラオ
        'basculin': 550,
        # シキジカ・メブキジカ
        'deerling': 585,
        'sawsbuck': 586,
        # ビビヨン
        'vivillon': 666,
        # フラベベ系統
        'flabebe': 669,
        'floette': 670,
        'florges': 671,
        # メテノ
        'minior': 774,
        # ミミッキュ
        'mimikyu': 778,
        # マギアナ
        'magearna': 801,
        # ザルード
        'zarude': 893,
        # イッカネズミ
        'maushold': 925,
        # シャリタツ
        'tatsugiri': 978,
        # ノココッチ
        'dudunsparce': 982,
    }

    updated_count = 0

    print("\n【nationalDexNumber復元】")
    for pokemon in pokemon_list:
        name = pokemon['name']

        # nationalDexNumberがない場合
        if 'nationalDexNumber' not in pokemon:
            # 基本形の名前を特定
            base_name = name.split('-')[0]

            if base_name in base_national_numbers:
                national_num = base_national_numbers[base_name]
                pokemon['nationalDexNumber'] = national_num
                print(f"  {name}: nationalDexNumber={national_num} を追加")
                updated_count += 1

    # 保存
    data['pokemon'] = pokemon_list
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n{'='*70}")
    print(f"✅ 完了: {updated_count}件のnationalDexNumberを復元")
    print(f"📝 保存先: {OUTPUT_FILE}")

    # 検証
    print(f"\n【検証】")
    with open(OUTPUT_FILE, 'r', encoding='utf-8') as f:
        verify_data = json.load(f)

    no_national = [p for p in verify_data['pokemon'] if 'nationalDexNumber' not in p]

    if no_national:
        print(f"⚠️  nationalDexNumberがないポケモン: {len(no_national)}件")
        for p in no_national[:10]:
            print(f"  {p['name']}")
    else:
        print(f"✅ 全てのポケモンにnationalDexNumberあり")

if __name__ == '__main__':
    main()
