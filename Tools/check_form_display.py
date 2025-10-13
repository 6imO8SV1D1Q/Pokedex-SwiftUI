#!/usr/bin/env python3
import json

with open('../Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

# 調査対象のポケモン
targets = {
    'dudunsparce': 'ノココッチ',
    'maushold': 'イッカネズミ',
    'deerling': 'シキジカ',
    'sawsbuck': 'メブキジカ',
    'vivillon': 'ビビヨン',
    'minior': 'メテノ',
}

for base_name, ja_name in targets.items():
    print(f"\n【{ja_name} ({base_name})】")
    forms = [p for p in data['pokemon'] if p['name'].startswith(base_name)]
    print(f"  登録数: {len(forms)}種類")
    for p in forms:
        national = p.get('nationalDexNumber', '?')
        blueberry = p.get('pokedexNumbers', {}).get('blueberry', '-')
        paldea = p.get('pokedexNumbers', {}).get('paldea', '-')
        print(f"    - {p['name']}: 全国#{national}, パルデア#{paldea}, ブルーベリー#{blueberry}")
