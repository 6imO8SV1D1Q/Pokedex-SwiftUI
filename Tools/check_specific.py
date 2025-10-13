import json

with open('/Users/yusuke/Development/Pokedex-SwiftUI/Pokedex/Pokedex/Resources/PreloadedData/scarlet_violet.json', 'r') as f:
    data = json.load(f)

for name in ['grimer-alola', 'muk-alola', 'grimer', 'muk']:
    for p in data['pokemon']:
        if p['name'] == name:
            has_paldea = 'paldea' in p.get('pokedexNumbers', {})
            print(f'{name}: paldea={has_paldea}')
            break
