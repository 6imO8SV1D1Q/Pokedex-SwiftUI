//
//  TypeCache.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// タイプ詳細情報のキャッシュ（Actor-based）
actor TypeCache {
    private var cache: [String: TypeDetail] = [:]

    func get(typeName: String) -> TypeDetail? {
        cache[typeName]
    }

    func set(typeName: String, detail: TypeDetail) {
        cache[typeName] = detail
    }

    func clear() {
        cache.removeAll()
    }

    func remove(typeName: String) {
        cache.removeValue(forKey: typeName)
    }
}
