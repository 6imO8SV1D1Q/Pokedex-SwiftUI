//
//  FormCache.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモンフォーム情報のキャッシュ（Actor-based）
actor FormCache {
    private var cache: [Int: [PokemonForm]] = [:]

    func get(pokemonId: Int) -> [PokemonForm]? {
        cache[pokemonId]
    }

    func set(pokemonId: Int, forms: [PokemonForm]) {
        cache[pokemonId] = forms
    }

    func clear() {
        cache.removeAll()
    }

    func remove(pokemonId: Int) {
        cache.removeValue(forKey: pokemonId)
    }
}
