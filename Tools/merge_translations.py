#!/usr/bin/env python3

import json
import glob
import os

print("📖 Merging Translation Files...")
print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")

# Collect all translation files
translation_dir = "/tmp/translations"
move_files = sorted(glob.glob(f"{translation_dir}/moves_batch_*_ja.json"))
ability_files = sorted(glob.glob(f"{translation_dir}/abilities_batch_*_ja.json"))

print(f"Found {len(move_files)} move translation files")
print(f"Found {len(ability_files)} ability translation files")

# Merge moves
move_translations = {}
for file_path in move_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        batch = json.load(f)
        move_translations.update(batch)
    print(f"  ✅ {os.path.basename(file_path)}: {len(batch)} entries")

print(f"\n✅ Total move translations: {len(move_translations)}")

# Merge abilities
ability_translations = {}
for file_path in ability_files:
    with open(file_path, 'r', encoding='utf-8') as f:
        batch = json.load(f)
        ability_translations.update(batch)
    print(f"  ✅ {os.path.basename(file_path)}: {len(batch)} entries")

print(f"\n✅ Total ability translations: {len(ability_translations)}")

# Create final dictionary
final_dict = {
    "moves": move_translations,
    "abilities": ability_translations
}

# Write merged dictionary
output_path = "/Users/yusuke/Development/Pokedex-SwiftUI/Tools/translation_dictionary.json"
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(final_dict, f, ensure_ascii=False, indent=2)

file_size = os.path.getsize(output_path) / 1024
print(f"\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
print(f"✅ Translation dictionary created!")
print(f"📦 Output: {output_path}")
print(f"💾 File size: {file_size:.1f} KB")
print(f"📊 Moves: {len(move_translations)}")
print(f"📊 Abilities: {len(ability_translations)}")
print(f"📊 Total: {len(move_translations) + len(ability_translations)}")
