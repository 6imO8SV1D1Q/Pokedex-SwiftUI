#!/usr/bin/env swift

import Foundation

// Test the new pokedexNumbers structure
let testJson = """
{
  "id": 25,
  "nationalDexNumber": 25,
  "name": "pikachu",
  "nameJa": "ピカチュウ",
  "genus": "Mouse Pokémon",
  "genusJa": "ねずみポケモン",
  "sprites": {
    "normal": "https://example.com/25.png",
    "shiny": "https://example.com/shiny/25.png"
  },
  "types": ["electric"],
  "abilities": {
    "primary": [9],
    "hidden": 31
  },
  "baseStats": {
    "hp": 35,
    "attack": 55,
    "defense": 40,
    "spAttack": 50,
    "spDefense": 50,
    "speed": 90,
    "total": 320
  },
  "moves": [],
  "eggGroups": ["ground", "fairy"],
  "genderRate": 4,
  "height": 4,
  "weight": 60,
  "evolutionChain": {
    "chainId": 10,
    "evolutionStage": 2,
    "evolvesFrom": 172,
    "evolvesTo": [26],
    "canUseEviolite": true
  },
  "varieties": [25],
  "pokedexNumbers": {
    "paldea": 25,
    "kitakami": 196
  },
  "category": "normal"
}
"""

struct PokemonTest: Codable {
    let id: Int
    let nationalDexNumber: Int
    let name: String
    let nameJa: String
    let pokedexNumbers: [String: Int]
    let category: String
}

do {
    let data = testJson.data(using: .utf8)!
    let pokemon = try JSONDecoder().decode(PokemonTest.self, from: data)
    
    print("✅ JSON structure is valid!")
    print("  ID: \(pokemon.id)")
    print("  Name: \(pokemon.nameJa)")
    print("  National Dex: \(pokemon.nationalDexNumber)")
    print("  Pokedex Numbers:")
    for (dex, number) in pokemon.pokedexNumbers.sorted(by: { $0.key < $1.key }) {
        print("    \(dex): \(number)")
    }
    print("  Category: \(pokemon.category)")
} catch {
    print("❌ Error: \(error)")
    exit(1)
}
