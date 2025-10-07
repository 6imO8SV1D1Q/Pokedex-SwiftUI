//
//  AbilityCache.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 特性詳細情報のキャッシュ（Actor-based）
actor AbilityCache {
    private var cacheById: [Int: AbilityDetail] = [:]
    private var cacheByName: [String: AbilityDetail] = [:]

    func get(abilityId: Int) -> AbilityDetail? {
        cacheById[abilityId]
    }

    func get(abilityName: String) -> AbilityDetail? {
        cacheByName[abilityName]
    }

    func set(detail: AbilityDetail) {
        cacheById[detail.id] = detail
        cacheByName[detail.name] = detail
    }

    func clear() {
        cacheById.removeAll()
        cacheByName.removeAll()
    }

    func remove(abilityId: Int) {
        if let detail = cacheById.removeValue(forKey: abilityId) {
            cacheByName.removeValue(forKey: detail.name)
        }
    }

    func remove(abilityName: String) {
        if let detail = cacheByName.removeValue(forKey: abilityName) {
            cacheById.removeValue(forKey: detail.id)
        }
    }
}
