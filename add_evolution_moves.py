#!/usr/bin/env python3

import json
from pathlib import Path

print("🚀 Adding evolution-inherited moves...")
print("")

# Load existing JSON
json_path = Path("/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json")
with open(json_path, 'r', encoding='utf-8') as f:
    data = json.load(f)

print("✅ Loaded existing JSON file")
print(f"  - Pokemon: {len(data['pokemon'])}")
print("")

# Build pokemon ID to pokemon mapping
pokemon_by_id = {p['id']: p for p in data['pokemon']}

moves_added_count = 0

# For each pokemon, check if it evolves from another pokemon
for pokemon in data['pokemon']:
    if 'evolutionChain' not in pokemon or pokemon['evolutionChain'] is None:
        continue

    evolution_chain = pokemon['evolutionChain']
    evolution_stage = evolution_chain.get('evolutionStage', 1)

    # Only process evolved pokemon (stage 2 or higher)
    if evolution_stage <= 1:
        continue

    # Find pre-evolution(s) by checking other pokemon in same chain
    chain_id = evolution_chain.get('chainId')
    if chain_id is None:
        continue

    # Find all pokemon in same evolution chain with lower stage
    # Note: evolvesToは信頼できない（リージョンフォームで通常フォームを指している）
    # 代わりに、同じchainIdでevolutionStageが直前のポケモンを探す
    pre_evolutions = [
        p for p in data['pokemon']
        if p.get('evolutionChain') and
           p['evolutionChain'].get('chainId') == chain_id and
           p['evolutionChain'].get('evolutionStage', 1) == evolution_stage - 1  # 直前のステージ
    ]

    if not pre_evolutions:
        continue

    current_move_ids = {m['moveId'] for m in pokemon.get('moves', [])}

    # Inherit moves from all pre-evolutions
    for pre_evo in pre_evolutions:
        for move in pre_evo.get('moves', []):
            if move['moveId'] not in current_move_ids:
                # 継承された技にフラグを追加
                inherited_move = move.copy()
                inherited_move['isFromPreEvolution'] = True
                pokemon['moves'].append(inherited_move)
                current_move_ids.add(move['moveId'])
                moves_added_count += 1

print(f"✅ Added {moves_added_count} inherited moves to evolved Pokemon")
print("")

# Save updated JSON
print("💾 Saving updated JSON...")

# Create backup
backup_path = str(json_path) + ".backup2"
import shutil
shutil.copy(json_path, backup_path)
print(f"✅ Created backup at {backup_path}")

# Save updated JSON
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print(f"✅ Saved updated JSON to {json_path}")
print("")

print("🎉 All done!")
print(f"  - Added inherited moves: {moves_added_count}")
print(f"  - Backup created at: {backup_path}")
