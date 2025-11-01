//
//  ItemCache.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// アイテム情報のキャッシュ（Actor-based）
actor ItemCache {
    private var cacheById: [Int: ItemEntity] = [:]
    private var cacheByName: [String: ItemEntity] = [:]
    private var allItemsCache: [ItemEntity]?

    /// IDでアイテムを取得
    func get(itemId: Int) -> ItemEntity? {
        cacheById[itemId]
    }

    /// 名前でアイテムを取得
    func get(itemName: String) -> ItemEntity? {
        cacheByName[itemName]
    }

    /// 全アイテムを取得
    func getAll() -> [ItemEntity]? {
        allItemsCache
    }

    /// アイテムをキャッシュに追加
    func set(item: ItemEntity) {
        cacheById[item.id] = item
        cacheByName[item.name] = item
    }

    /// 全アイテムをキャッシュに設定
    func setAll(items: [ItemEntity]) {
        allItemsCache = items
        for item in items {
            cacheById[item.id] = item
            cacheByName[item.name] = item
        }
    }

    /// キャッシュをクリア
    func clear() {
        cacheById.removeAll()
        cacheByName.removeAll()
        allItemsCache = nil
    }

    /// IDでアイテムを削除
    func remove(itemId: Int) {
        if let item = cacheById.removeValue(forKey: itemId) {
            cacheByName.removeValue(forKey: item.name)
        }
    }

    /// 名前でアイテムを削除
    func remove(itemName: String) {
        if let item = cacheByName.removeValue(forKey: itemName) {
            cacheById.removeValue(forKey: item.id)
        }
    }
}
