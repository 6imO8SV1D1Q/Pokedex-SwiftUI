#!/usr/bin/env python3
"""
ニャオニクス♂のデータをPokeAPIから取得して正しく設定するスクリプト
"""

import json
import sys
import urllib.request

def fetch_pokemon_data(pokemon_name):
    """PokeAPIからポケモンデータを取得"""
    url = f"https://pokeapi.co/api/v2/pokemon/{pokemon_name}"
    with urllib.request.urlopen(url) as response:
        return json.loads(response.read())

def fix_meowstic_male(input_file, output_file):
    """ニャオニクス♂と♀のデータを修正"""
    with open(input_file, 'r', encoding='utf-8') as f:
        data = json.load(f)

    # meowstic-maleのデータをPokeAPIから取得
    print("📡 PokeAPIからmeowstic-maleのデータを取得中...")
    api_data_male = fetch_pokemon_data("meowstic-male")

    # meowstic-femaleのデータもPokeAPIから取得
    print("📡 PokeAPIからmeowstic-femaleのデータを取得中...")
    api_data_female = fetch_pokemon_data("meowstic-female")

    # meowstic-maleとmeowstic-femaleを探す
    meowstic_male_index = None
    meowstic_female_index = None

    for i, pokemon in enumerate(data['pokemon']):
        if pokemon['name'] in ['meowstic', 'meowstic-male']:
            meowstic_male_index = i
        elif pokemon['name'] == 'meowstic-female':
            meowstic_female_index = i

    if meowstic_male_index is None:
        print("❌ meowstic/meowstic-maleが見つかりません")
        return

    if meowstic_female_index is None:
        print("❌ meowstic-femaleが見つかりません")
        return

    # 既存のメスのデータから地方図鑑情報などをコピー
    meowstic_female_old = data['pokemon'][meowstic_female_index]

    # オスのデータを作成
    new_male = {
        "id": api_data_male["id"],
        "name": "meowstic-male",
        "nameJa": "ニャオニクス♂",
        "nationalDexNumber": 678,
        "pokedexNumbers": meowstic_female_old.get("pokedexNumbers", {}),
        "category": meowstic_female_old.get("category", "normal"),
        "height": api_data_male["height"],
        "weight": api_data_male["weight"],
        "types": [t["type"]["name"] for t in api_data_male["types"]],
        "abilities": {
            "primary": [int(a["ability"]["url"].rstrip('/').split('/')[-1]) for a in api_data_male["abilities"] if not a["is_hidden"]],
            "hidden": int(next((a["ability"]["url"].rstrip('/').split('/')[-1] for a in api_data_male["abilities"] if a["is_hidden"]), 0)) or None
        },
        "baseStats": meowstic_female_old.get("baseStats", {}),
        "sprites": {
            "normal": api_data_male["sprites"]["other"]["home"]["front_default"] if api_data_male["sprites"].get("other", {}).get("home", {}).get("front_default") else f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/{api_data_male['id']}.png",
            "shiny": api_data_male["sprites"]["other"]["home"]["front_shiny"] if api_data_male["sprites"].get("other", {}).get("home", {}).get("front_shiny") else f"https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/home/shiny/{api_data_male['id']}.png"
        },
        "moves": meowstic_female_old.get("moves", []),
        "genus": meowstic_female_old.get("genus"),
        "genusJa": meowstic_female_old.get("genusJa"),
        "eggGroups": meowstic_female_old.get("eggGroups", []),
        "genderRate": meowstic_female_old.get("genderRate"),
        "evolutionChain": meowstic_female_old.get("evolutionChain"),
        "varieties": meowstic_female_old.get("varieties", []),
    }

    # メスのデータを更新
    new_female = {
        "id": api_data_female["id"],
        "name": "meowstic-female",
        "nameJa": "ニャオニクス♀",
        "nationalDexNumber": 678,
        "pokedexNumbers": meowstic_female_old.get("pokedexNumbers", {}),
        "category": meowstic_female_old.get("category", "normal"),
        "height": api_data_female["height"],
        "weight": api_data_female["weight"],
        "types": [t["type"]["name"] for t in api_data_female["types"]],
        "abilities": {
            "primary": [int(a["ability"]["url"].rstrip('/').split('/')[-1]) for a in api_data_female["abilities"] if not a["is_hidden"]],
            "hidden": int(next((a["ability"]["url"].rstrip('/').split('/')[-1] for a in api_data_female["abilities"] if a["is_hidden"]), 0)) or None
        },
        "baseStats": meowstic_female_old.get("baseStats", {}),
        "sprites": meowstic_female_old.get("sprites", {}),
        "moves": meowstic_female_old.get("moves", []),
        "genus": meowstic_female_old.get("genus"),
        "genusJa": meowstic_female_old.get("genusJa"),
        "eggGroups": meowstic_female_old.get("eggGroups", []),
        "genderRate": meowstic_female_old.get("genderRate"),
        "evolutionChain": meowstic_female_old.get("evolutionChain"),
        "varieties": meowstic_female_old.get("varieties", []),
    }

    # 置き換え
    data['pokemon'][meowstic_male_index] = new_male
    data['pokemon'][meowstic_female_index] = new_female

    print(f"✅ meowstic-male を更新")
    print(f"   id: {new_male['id']}")
    print(f"   特性:")
    print(f"      primary: {new_male['abilities']['primary']}")
    print(f"      hidden: {new_male['abilities']['hidden']}")

    print(f"\n✅ meowstic-female を更新")
    print(f"   id: {new_female['id']}")
    print(f"   特性:")
    print(f"      primary: {new_female['abilities']['primary']}")
    print(f"      hidden: {new_female['abilities']['hidden']}")

    # 保存
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n修正完了: 1件")

if __name__ == '__main__':
    input_file = '/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json'
    output_file = input_file  # 上書き

    fix_meowstic_male(input_file, output_file)
