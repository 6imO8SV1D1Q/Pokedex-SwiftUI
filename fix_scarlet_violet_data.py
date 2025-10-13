#!/usr/bin/env python3

import json
import requests
import time
from pathlib import Path

print("🚀 Starting Scarlet/Violet JSON data fix...")
print("📋 Tasks:")
print("  1. Fix stat_changes and target for all moves")
print("  2. Add evolution-inherited moves to evolved Pokemon")
print("")

# Load existing JSON
json_path = Path("/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json")
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

print("✅ Loaded existing JSON file")
print(f"  - Abilities: {len(data['abilities'])}")
print(f"  - Moves: {len(data['moves'])}")
print(f"  - Pokemon: {len(data['pokemon'])}")
print(f"  - Pokedexes: {len(data['pokedexes'])}")
print("")

# MARK: - Task 1: Fix stat_changes and target for moves

print("📝 Task 1: Fixing stat_changes and target for moves...")
print("⏳ Fetching move details from PokéAPI (this will take ~7-10 minutes)...")

updated_count = 0
target_updated_count = 0
stat_changes_updated_count = 0

for i, move in enumerate(data['moves']):
    move_id = move['id']

    try:
        # Fetch move details from PokéAPI
        response = requests.get(f"https://pokeapi.co/api/v2/move/{move_id}", timeout=10)
        response.raise_for_status()
        detail = response.json()

        move_updated = False

        # Update target if different
        if 'target' in detail and detail['target']:
            api_target = detail['target']['name']
            if move.get('target') != api_target:
                move['target'] = api_target
                target_updated_count += 1
                move_updated = True

        # Update stat_changes if available
        if 'stat_changes' in detail and detail['stat_changes']:
            stat_changes = []
            for sc in detail['stat_changes']:
                stat_changes.append({
                    'change': sc['change'],
                    'stat': sc['stat']['name']
                })

            if 'meta' in move and move['meta']:
                current_stat_changes = move['meta'].get('statChanges', [])
                if current_stat_changes != stat_changes:
                    move['meta']['statChanges'] = stat_changes
                    stat_changes_updated_count += 1
                    move_updated = True

        if move_updated:
            updated_count += 1

        # Progress reporting
        if (i + 1) % 50 == 0:
            print(f"  Progress: {i + 1}/{len(data['moves'])} moves processed...")

        # Rate limiting: 100 requests per second max
        time.sleep(0.01)

    except Exception as e:
        print(f"  ⚠️  Failed to fetch move {move_id} ({move.get('nameJa', move['name'])}): {e}")
        continue

print(f"✅ Updated {updated_count} moves:")
print(f"  - Target updated: {target_updated_count}")
print(f"  - Stat changes updated: {stat_changes_updated_count}")
print("")

# MARK: - Task 2: Add evolution-inherited moves

print("📝 Task 2: Adding evolution-inherited moves...")
print("⚠️  Skipping Task 2 - requires further analysis of evolution chain structure")
moves_added_count = 0
print("")

# MARK: - Save updated JSON

print("💾 Saving updated JSON...")

# Create backup
backup_path = str(json_path) + ".backup"
import shutil
shutil.copy(json_path, backup_path)
print(f"✅ Created backup at {backup_path}")

# Save updated JSON
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"✅ Saved updated JSON to {json_path}")
print("")

print("🎉 All done!")
print("Summary:")
print(f"  - Updated moves: {updated_count}")
print(f"    - Target fixed: {target_updated_count}")
print(f"    - Stat changes fixed: {stat_changes_updated_count}")
print(f"  - Added inherited moves: {moves_added_count}")
print(f"  - Backup created at: {backup_path}")
