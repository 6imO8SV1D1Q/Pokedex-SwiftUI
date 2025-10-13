#!/usr/bin/env python3
"""
スカーレット・バイオレットに登場する可能性があるコスメティックフォームを確認
"""
import json

with open('Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

all_names = [p['name'] for p in data['pokemon']]

print("📋 コスメティックフォームの確認\n")

# フラベベ系（5色）
print("【フラベベ系（5色）】")
flabebe_forms = ['flabebe', 'flabebe-red', 'flabebe-yellow', 'flabebe-orange', 'flabebe-blue', 'flabebe-white']
floette_forms = ['floette', 'floette-red', 'floette-yellow', 'floette-orange', 'floette-blue', 'floette-white']
florges_forms = ['florges', 'florges-red', 'florges-yellow', 'florges-orange', 'florges-blue', 'florges-white']

for base_name, forms in [('flabebe', flabebe_forms), ('floette', floette_forms), ('florges', florges_forms)]:
    base_exists = any(base_name in name for name in all_names)
    if base_exists:
        print(f"  {base_name}: 登場")
        for form in forms:
            exists = "✅" if form in all_names else "❌"
            print(f"    {exists} {form}")

# パンプジン・バケッチャ（4サイズ）
print("\n【パンプジン・バケッチャ（4サイズ）】")
pumpkaboo_forms = ['pumpkaboo', 'pumpkaboo-small', 'pumpkaboo-large', 'pumpkaboo-super']
gourgeist_forms = ['gourgeist', 'gourgeist-small', 'gourgeist-large', 'gourgeist-super']

for base_name, forms in [('pumpkaboo', pumpkaboo_forms), ('gourgeist', gourgeist_forms)]:
    base_exists = any(base_name in name for name in all_names)
    if base_exists:
        print(f"  {base_name}: 登場")
        for form in forms:
            exists = "✅" if form in all_names else "❌"
            print(f"    {exists} {form}")

# トリミアン（9カット）
print("\n【トリミアン（9カット）】")
furfrou_base = any('furfrou' in name for name in all_names)
if furfrou_base:
    print("  furfrou: 登場")
    furfrou_forms = [
        'furfrou', 'furfrou-heart', 'furfrou-star', 'furfrou-diamond',
        'furfrou-debutante', 'furfrou-matron', 'furfrou-dandy',
        'furfrou-la-reine', 'furfrou-kabuki', 'furfrou-pharaoh'
    ]
    for form in furfrou_forms:
        exists = "✅" if form in all_names else "❌"
        print(f"    {exists} {form}")
else:
    print("  furfrou: 未登場")

# スカーレット・バイオレット固有のフォーム
print("\n【その他の確認】")

# アルクジラ・ハルクジラ（2サイズ）
cetoddle_forms = ['cetoddle', 'cetoddle-curly']
cetitan_forms = ['cetitan', 'cetitan-curly']
print("  アルクジラ・ハルクジラ:")
for form in cetoddle_forms + cetitan_forms:
    exists = "✅" if form in all_names else "❌"
    print(f"    {exists} {form}")

