#!/usr/bin/env python3
"""
Scarlet/Violetのポケモン図鑑データをscarlet_violet.jsonに追加
"""

import json
import requests
import time

POKEDEX_NAMES = ["paldea", "kitakami", "blueberry"]

def fetch_pokedex(pokedex_name):
    """PokéAPIからポケモン図鑑データを取得"""
    url = f"https://pokeapi.co/api/v2/pokedex/{pokedex_name}"
    print(f"Fetching {pokedex_name} pokedex...")

    response = requests.get(url)
    response.raise_for_status()
    data = response.json()

    # species IDのリストを抽出
    species_ids = [entry["pokemon_species"]["url"].rstrip("/").split("/")[-1]
                   for entry in data["pokemon_entries"]]
    species_ids = [int(id) for id in species_ids]

    print(f"  Found {len(species_ids)} species")
    return {
        "name": pokedex_name,
        "speciesIds": sorted(species_ids)
    }

def main():
    json_path = "/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"

    # JSONを読み込み
    with open(json_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Pokedexデータを取得
    pokedexes = []
    for name in POKEDEX_NAMES:
        pokedex = fetch_pokedex(name)
        pokedexes.append(pokedex)
        time.sleep(0.5)  # API制限を考慮

    # JSONに追加
    data["pokedexes"] = pokedexes

    # 保存
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"\n✅ Added {len(pokedexes)} pokedexes to scarlet_violet.json")
    for pokedex in pokedexes:
        print(f"  - {pokedex['name']}: {len(pokedex['speciesIds'])} species")

if __name__ == "__main__":
    main()
