#!/usr/bin/env python3
"""
性別で姿が違うポケモンのスプライト確認
"""
import json

with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

# 性別違いがあるポケモン（代表例）
gender_diff_pokemon = [
    'hippopotas',    # ヒポポタス
    'hippowdon',     # カバルドン
    'pyroar',        # カエンジシ
    'meowstic',      # ニャオニクス - 既に別登録
    'indeedee',      # イエッサン - 既に別登録
    'unfezant',      # ケンホロウ
    'frillish',      # プルリル
    'jellicent',     # ブルンゲル
]

print("📋 性別違いポケモンのスプライト確認\n")

for base_name in gender_diff_pokemon:
    matching = [p for p in data['pokemon'] if p['name'].startswith(base_name)]
    
    if not matching:
        print(f"❌ {base_name}: 未登録")
        continue
    
    print(f"{'='*60}")
    print(f"【{base_name.upper()}】")
    
    for p in matching:
        name = p['name']
        name_ja = p.get('nameJa', '')
        sprites = p.get('sprites', {})
        
        print(f"\n  {name} ({name_ja})")
        print(f"    normal: {sprites.get('normal', 'なし')}")
        print(f"    shiny:  {sprites.get('shiny', 'なし')}")
        
        # PokeAPIのスプライトURLパターンを確認
        if 'normal' in sprites:
            url = sprites['normal']
            print(f"    URL形式: {url}")

print("\n" + "="*60)
print("📋 PokeAPIでの性別違いスプライト確認")
print("="*60)

import requests
import time

# カバルドンで確認
print("\n【カバルドン (hippowdon) の確認】")
try:
    response = requests.get("https://pokeapi.co/api/v2/pokemon/hippowdon/")
    data_api = response.json()
    
    sprites_api = data_api.get('sprites', {})
    print(f"  front_default: {sprites_api.get('front_default', 'なし')}")
    print(f"  front_female:  {sprites_api.get('front_female', 'なし')}")
    print(f"  front_shiny:   {sprites_api.get('front_shiny', 'なし')}")
    print(f"  front_shiny_female: {sprites_api.get('front_shiny_female', 'なし')}")
    
    # official-artworkも確認
    other = sprites_api.get('other', {})
    official = other.get('official-artwork', {})
    print(f"\n  official-artwork:")
    print(f"    front_default: {official.get('front_default', 'なし')}")
    print(f"    front_female:  {official.get('front_female', 'なし')[:100] if official.get('front_female') else 'なし'}...")
    
except Exception as e:
    print(f"  エラー: {e}")

time.sleep(0.1)

# カエンジシで確認
print("\n【カエンジシ (pyroar) の確認】")
try:
    response = requests.get("https://pokeapi.co/api/v2/pokemon/pyroar/")
    data_api = response.json()
    
    sprites_api = data_api.get('sprites', {})
    print(f"  front_default: {sprites_api.get('front_default', 'なし')}")
    print(f"  front_female:  {sprites_api.get('front_female', 'なし')}")
    print(f"  front_shiny:   {sprites_api.get('front_shiny', 'なし')}")
    print(f"  front_shiny_female: {sprites_api.get('front_shiny_female', 'なし')}")
    
    # official-artworkも確認
    other = sprites_api.get('other', {})
    official = other.get('official-artwork', {})
    print(f"\n  official-artwork:")
    print(f"    front_default: {official.get('front_default', 'なし')}")
    print(f"    front_female:  {official.get('front_female', 'なし')[:100] if official.get('front_female') else 'なし'}...")
    
except Exception as e:
    print(f"  エラー: {e}")

