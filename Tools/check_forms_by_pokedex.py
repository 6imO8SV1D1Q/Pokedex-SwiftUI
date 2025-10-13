#!/usr/bin/env python3
"""
各図鑑でフォームが不足しているポケモンを確認
"""
import json

with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

# 各図鑑に登場するポケモンをグループ化
pokedexes = ['paldea', 'kitakami', 'blueberry']

for pokedex_name in pokedexes:
    print(f"\n{'='*60}")
    print(f"【{pokedex_name.upper()}図鑑】")
    print('='*60)
    
    # この図鑑に登場するポケモンを全国図鑑番号でグループ化
    by_national = {}
    for p in data['pokemon']:
        if pokedex_name in p.get('pokedexNumbers', {}):
            nat_num = p.get('nationalDexNumber')
            if nat_num:
                if nat_num not in by_national:
                    by_national[nat_num] = []
                by_national[nat_num].append(p['name'])
    
    # フォーム違いがあるべきポケモン（代表例）
    expected_forms = {
        422: ('shellos', 'カラナクシ', ['shellos', 'shellos-east', 'shellos-west']),
        423: ('gastrodon', 'トリトドン', ['gastrodon', 'gastrodon-east', 'gastrodon-west']),
        585: ('deerling', 'シキジカ', ['deerling-spring', 'deerling-summer', 'deerling-autumn', 'deerling-winter']),
        586: ('sawsbuck', 'メブキジカ', ['sawsbuck-spring', 'sawsbuck-summer', 'sawsbuck-autumn', 'sawsbuck-winter']),
        592: ('frillish', 'プルリル', ['frillish-male', 'frillish-female']),
        593: ('jellicent', 'ブルンゲル', ['jellicent-male', 'jellicent-female']),
        666: ('vivillon', 'ビビヨン', ['vivillon-meadow', 'vivillon-icy-snow', 'vivillon-polar']),  # 20種あるが代表例
        669: ('flabebe', 'フラベベ', ['flabebe-red', 'flabebe-yellow', 'flabebe-orange', 'flabebe-blue', 'flabebe-white']),
        670: ('floette', 'フラエッテ', ['floette-red', 'floette-yellow', 'floette-orange', 'floette-blue', 'floette-white']),
        671: ('florges', 'フラージェス', ['florges-red', 'florges-yellow', 'florges-orange', 'florges-blue', 'florges-white']),
        710: ('pumpkaboo', 'バケッチャ', ['pumpkaboo-small', 'pumpkaboo-average', 'pumpkaboo-large', 'pumpkaboo-super']),
        711: ('gourgeist', 'パンプジン', ['gourgeist-small', 'gourgeist-average', 'gourgeist-large', 'gourgeist-super']),
        801: ('magearna', 'マギアナ', ['magearna', 'magearna-original']),
        890: ('eternatus', 'ムゲンダイナ', ['eternatus', 'eternatus-eternamax']),
    }
    
    missing = []
    for nat_num, (base_name, name_ja, expected) in expected_forms.items():
        if nat_num in by_national:
            actual = by_national[nat_num]
            # 期待されるフォームのうち、実際にあるものをチェック
            missing_forms = [f for f in expected if f not in actual]
            if missing_forms:
                missing.append({
                    'nat_num': nat_num,
                    'name_ja': name_ja,
                    'base_name': base_name,
                    'actual': actual,
                    'missing': missing_forms
                })
    
    if missing:
        print("\n⚠️  フォーム不足:")
        for m in missing:
            print(f"\n  #{m['nat_num']:03d} {m['name_ja']} ({m['base_name']})")
            print(f"    登録済み: {', '.join(m['actual'])}")
            print(f"    未登録: {', '.join(m['missing'])}")
    else:
        print("\n✅ フォーム不足なし（チェック対象のみ）")

# 全国図鑑も確認
print(f"\n{'='*60}")
print(f"【全国図鑑（全ポケモン）】")
print('='*60)

all_by_national = {}
for p in data['pokemon']:
    nat_num = p.get('nationalDexNumber')
    if nat_num:
        if nat_num not in all_by_national:
            all_by_national[nat_num] = []
        all_by_national[nat_num].append(p['name'])

expected_forms = {
    422: ('shellos', 'カラナクシ', ['shellos', 'shellos-east', 'shellos-west']),
    423: ('gastrodon', 'トリトドン', ['gastrodon', 'gastrodon-east', 'gastrodon-west']),
    585: ('deerling', 'シキジカ', ['deerling-spring', 'deerling-summer', 'deerling-autumn', 'deerling-winter']),
    586: ('sawsbuck', 'メブキジカ', ['sawsbuck-spring', 'sawsbuck-summer', 'sawsbuck-autumn', 'sawsbuck-winter']),
    592: ('frillish', 'プルリル', ['frillish-male', 'frillish-female']),
    593: ('jellicent', 'ブルンゲル', ['jellicent-male', 'jellicent-female']),
    666: ('vivillon', 'ビビヨン', ['vivillon-meadow', 'vivillon-icy-snow', 'vivillon-polar']),
    669: ('flabebe', 'フラベベ', ['flabebe-red', 'flabebe-yellow', 'flabebe-orange', 'flabebe-blue', 'flabebe-white']),
    670: ('floette', 'フラエッテ', ['floette-red', 'floette-yellow', 'floette-orange', 'floette-blue', 'floette-white']),
    671: ('florges', 'フラージェス', ['florges-red', 'florges-yellow', 'florges-orange', 'florges-blue', 'florges-white']),
    710: ('pumpkaboo', 'バケッチャ', ['pumpkaboo-small', 'pumpkaboo-average', 'pumpkaboo-large', 'pumpkaboo-super']),
    711: ('gourgeist', 'パンプジン', ['gourgeist-small', 'gourgeist-average', 'gourgeist-large', 'gourgeist-super']),
    801: ('magearna', 'マギアナ', ['magearna', 'magearna-original']),
    890: ('eternatus', 'ムゲンダイナ', ['eternatus', 'eternatus-eternamax']),
}

missing = []
for nat_num, (base_name, name_ja, expected) in expected_forms.items():
    if nat_num in all_by_national:
        actual = all_by_national[nat_num]
        missing_forms = [f for f in expected if f not in actual]
        if missing_forms:
            missing.append({
                'nat_num': nat_num,
                'name_ja': name_ja,
                'base_name': base_name,
                'actual': actual,
                'missing': missing_forms
            })

if missing:
    print("\n⚠️  フォーム不足:")
    for m in missing:
        print(f"\n  #{m['nat_num']:03d} {m['name_ja']} ({m['base_name']})")
        print(f"    登録済み: {', '.join(m['actual'])}")
        print(f"    未登録: {', '.join(m['missing'])}")
else:
    print("\n✅ フォーム不足なし（チェック対象のみ）")

