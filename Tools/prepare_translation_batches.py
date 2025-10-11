#!/usr/bin/env python3

import json
import math

# Read effects to translate
with open('/tmp/effects_to_translate.json', 'r') as f:
    data = json.load(f)

moves = data['moves']
abilities = data['abilities']

# Batch size
BATCH_SIZE = 50

# Split into batches
move_batches = []
for i in range(0, len(moves), BATCH_SIZE):
    move_batches.append(moves[i:i+BATCH_SIZE])

ability_batches = []
for i in range(0, len(abilities), BATCH_SIZE):
    ability_batches.append(abilities[i:i+BATCH_SIZE])

print(f"📊 Translation Batches:")
print(f"  - Move batches: {len(move_batches)}")
print(f"  - Ability batches: {len(ability_batches)}")
print(f"  - Total batches: {len(move_batches) + len(ability_batches)}")

# Create batch files
import os
os.makedirs('/tmp/translation_batches', exist_ok=True)

for i, batch in enumerate(move_batches):
    filename = f'/tmp/translation_batches/moves_batch_{i+1}.json'
    with open(filename, 'w') as f:
        json.dump(batch, f, indent=2, ensure_ascii=False)
    print(f"  ✅ {filename}")

for i, batch in enumerate(ability_batches):
    filename = f'/tmp/translation_batches/abilities_batch_{i+1}.json'
    with open(filename, 'w') as f:
        json.dump(batch, f, indent=2, ensure_ascii=False)
    print(f"  ✅ {filename}")

print("\n✅ Batch files created")
