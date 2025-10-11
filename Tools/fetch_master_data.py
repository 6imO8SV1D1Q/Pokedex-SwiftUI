#!/usr/bin/env python3
"""
Fetch ability and move master data from PokeAPI and update scarlet_violet.json
"""
import json
import time
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed
from move_categories import detect_move_categories

JSON_PATH = "../Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json"

def fetch_json(url):
    """Fetch JSON from URL"""
    try:
        with urllib.request.urlopen(url, timeout=10) as response:
            return json.loads(response.read())
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None

def fetch_ability(ability_id):
    """Fetch ability data from PokeAPI"""
    data = fetch_json(f"https://pokeapi.co/api/v2/ability/{ability_id}")
    if not data:
        return None

    # Extract names
    name = data.get("name", f"ability-{ability_id}")
    name_ja = next((n["name"] for n in data.get("names", []) if n["language"]["name"] == "ja"), None)

    # Extract effect
    effect_entries = data.get("effect_entries", [])
    effect = next((e["effect"] for e in effect_entries if e["language"]["name"] == "en"), "")
    effect_ja = next((e["effect"] for e in effect_entries if e["language"]["name"] == "ja"), "")

    return {
        "id": ability_id,
        "name": name,
        "nameJa": name_ja or f"特性{ability_id}",
        "effect": effect or "",
        "effectJa": effect_ja or ""
    }

def fetch_move(move_id):
    """Fetch move data from PokeAPI"""
    data = fetch_json(f"https://pokeapi.co/api/v2/move/{move_id}")
    if not data:
        return None

    # Extract names
    name = data.get("name", f"move-{move_id}")
    name_ja = next((n["name"] for n in data.get("names", []) if n["language"]["name"] == "ja"), None)

    # Extract effect
    effect_entries = data.get("effect_entries", [])
    effect = next((e["effect"] for e in effect_entries if e["language"]["name"] == "en"), "")
    effect_ja = next((e["effect"] for e in effect_entries if e["language"]["name"] == "ja"), "")

    # Type and damage class
    move_type = data.get("type", {}).get("name")
    damage_class = data.get("damage_class", {}).get("name")

    # Stats
    power = data.get("power")
    accuracy = data.get("accuracy")
    pp = data.get("pp", 0)
    priority = data.get("priority", 0)
    effect_chance = data.get("effect_chance")

    # Meta
    meta = data.get("meta") or {}
    stat_changes = [{"stat": s["stat"]["name"], "change": s["change"]} for s in (meta.get("stat_changes") or [])]

    # Categories (v4.0 Phase 3 - v2 with 43 categories)
    # Prepare move_data dict for category detection
    move_data_for_detection = {
        "name": name,
        "effect": effect or "",
        "meta": {
            "ailment": (meta.get("ailment") or {}).get("name") or "none",
            "ailmentChance": meta.get("ailment_chance") or 0,
            "category": (meta.get("category") or {}).get("name") or "damage",
            "critRate": meta.get("crit_rate") or 0,
            "drain": meta.get("drain") or 0,
            "flinchChance": meta.get("flinch_chance") or 0,
            "healing": meta.get("healing") or 0,
            "statChance": meta.get("stat_chance") or 0,
            "statChanges": stat_changes,
            "maxHits": meta.get("max_hits"),
            "minHits": meta.get("min_hits")
        },
        "priority": priority or 0,
        "accuracy": accuracy,
        "power": power,
        "damageClass": damage_class or "status"
    }
    categories = detect_move_categories(move_data_for_detection)

    return {
        "id": move_id,
        "name": name,
        "nameJa": name_ja or f"技{move_id}",
        "type": move_type or "normal",
        "damageClass": damage_class or "status",
        "power": power,
        "accuracy": accuracy,
        "pp": pp or 0,
        "priority": priority or 0,
        "effectChance": effect_chance,
        "effect": effect or "",
        "effectJa": effect_ja or "",
        "categories": categories,
        "meta": {
            "ailment": (meta.get("ailment") or {}).get("name") or "none",
            "ailmentChance": meta.get("ailment_chance") or 0,
            "category": (meta.get("category") or {}).get("name") or "damage",
            "critRate": meta.get("crit_rate") or 0,
            "drain": meta.get("drain") or 0,
            "flinchChance": meta.get("flinch_chance") or 0,
            "healing": meta.get("healing") or 0,
            "statChance": meta.get("stat_chance") or 0,
            "statChanges": stat_changes
        }
    }

def main():
    print("🚀 Fetching master data from PokeAPI...")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

    # Load existing JSON
    print("📖 Loading scarlet_violet.json...")
    with open(JSON_PATH, "r", encoding="utf-8") as f:
        game_data = json.load(f)

    # Extract needed IDs
    ability_ids = set()
    move_ids = set()

    for pokemon in game_data["pokemon"]:
        ability_ids.update(pokemon["abilities"]["primary"])
        if pokemon["abilities"].get("hidden"):
            ability_ids.add(pokemon["abilities"]["hidden"])

        for move in pokemon["moves"]:
            move_ids.add(move["moveId"])

    ability_ids = sorted(ability_ids)
    move_ids = sorted(move_ids)

    print(f"  Abilities needed: {len(ability_ids)}")
    print(f"  Moves needed: {len(move_ids)}")

    # Fetch abilities
    print("\n📊 Fetching abilities...")
    abilities = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(fetch_ability, aid): aid for aid in ability_ids}
        for i, future in enumerate(as_completed(futures), 1):
            result = future.result()
            if result:
                abilities.append(result)
            if i % 10 == 0 or i == len(ability_ids):
                print(f"  [{i}/{len(ability_ids)}] abilities fetched")
            time.sleep(0.05)  # Rate limiting

    # Fetch moves
    print("\n📊 Fetching moves...")
    moves = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(fetch_move, mid): mid for mid in move_ids}
        for i, future in enumerate(as_completed(futures), 1):
            result = future.result()
            if result:
                moves.append(result)
            if i % 50 == 0 or i == len(move_ids):
                print(f"  [{i}/{len(move_ids)}] moves fetched")
            time.sleep(0.05)  # Rate limiting

    # Update JSON
    print("\n💾 Updating JSON...")
    game_data["abilities"] = sorted(abilities, key=lambda x: x["id"])
    game_data["moves"] = sorted(moves, key=lambda x: x["id"])

    # Write back
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(game_data, f, ensure_ascii=False, indent=2, sort_keys=True)

    file_size = len(json.dumps(game_data, ensure_ascii=False)) / 1024 / 1024

    print("\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("✅ Master data update completed!")
    print(f"📊 Abilities: {len(abilities)}")
    print(f"📊 Moves: {len(moves)}")
    print(f"💾 File size: {file_size:.2f} MB")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

if __name__ == "__main__":
    main()
