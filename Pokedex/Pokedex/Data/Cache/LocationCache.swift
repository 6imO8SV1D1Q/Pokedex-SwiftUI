//
//  LocationCache.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// ポケモン出現場所情報のキャッシュ（Actor-based）
actor LocationCache {
    private var cache: [Int: [PokemonLocation]] = [:]

    func get(pokemonId: Int) -> [PokemonLocation]? {
        cache[pokemonId]
    }

    func set(pokemonId: Int, locations: [PokemonLocation]) {
        cache[pokemonId] = locations
    }

    func clear() {
        cache.removeAll()
    }

    func remove(pokemonId: Int) {
        cache.removeValue(forKey: pokemonId)
    }
}
