//
//  ItemProvider.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// アイテムデータを提供するプロバイダー
///
/// プリバンドルされたJSONファイル（items_v5.json）からアイテム情報を読み込み、
/// メモリキャッシュで管理します。
///
/// ## 主な責務
/// - items_v5.jsonの読み込み
/// - アイテムデータのキャッシュ管理
/// - ID/名前/カテゴリーによる検索
///
/// ## キャッシュ戦略
/// - アプリ起動時に全データを読み込み
/// - メモリキャッシュ（ItemCache）を使用
final class ItemProvider: ItemProviderProtocol {
    private let cache: ItemCache
    private let bundle: Bundle

    /// イニシャライザ
    /// - Parameters:
    ///   - cache: アイテムキャッシュ
    ///   - bundle: JSONファイルを含むバンドル（テスト用）
    init(cache: ItemCache = ItemCache(), bundle: Bundle = .main) {
        self.cache = cache
        self.bundle = bundle
    }

    /// 全アイテムのリストを取得
    /// - Returns: アイテム情報のリスト（ID順にソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllItems() async throws -> [ItemEntity] {
        // キャッシュチェック
        if let cached = await cache.getAll() {
            print("🔍 [ItemProvider] Cache hit: \(cached.count) items")
            return cached
        }

        // JSONファイルから読み込み
        let items = try loadItemsFromJSON()
        print("📦 [ItemProvider] Loaded from JSON: \(items.count) items")

        // キャッシュに保存
        await cache.setAll(items: items)
        return items
    }

    /// IDでアイテムを取得
    /// - Parameter itemId: アイテムID
    /// - Returns: アイテム情報
    /// - Throws: データ取得時のエラー
    func fetchItem(id itemId: Int) async throws -> ItemEntity {
        // キャッシュチェック
        if let cached = await cache.get(itemId: itemId) {
            return cached
        }

        // 全アイテムを読み込んでからキャッシュ検索
        _ = try await fetchAllItems()

        guard let item = await cache.get(itemId: itemId) else {
            throw ItemProviderError.itemNotFound(id: itemId)
        }

        return item
    }

    /// 名前でアイテムを取得
    /// - Parameter itemName: アイテム名（英語、ケバブケース）
    /// - Returns: アイテム情報
    /// - Throws: データ取得時のエラー
    func fetchItem(name itemName: String) async throws -> ItemEntity {
        // キャッシュチェック
        if let cached = await cache.get(itemName: itemName) {
            return cached
        }

        // 全アイテムを読み込んでからキャッシュ検索
        _ = try await fetchAllItems()

        guard let item = await cache.get(itemName: itemName) else {
            throw ItemProviderError.itemNotFound(name: itemName)
        }

        return item
    }

    /// カテゴリーでアイテムをフィルタリング
    /// - Parameter category: カテゴリー名（例: "held-item"）
    /// - Returns: 該当カテゴリーのアイテムリスト
    /// - Throws: データ取得時のエラー
    func fetchItems(category: String) async throws -> [ItemEntity] {
        let allItems = try await fetchAllItems()
        return allItems.filter { $0.category == category }
    }

    // MARK: - Private Methods

    /// JSONファイルからアイテムデータを読み込む
    private func loadItemsFromJSON() throws -> [ItemEntity] {
        guard let url = bundle.url(forResource: "items_v5", withExtension: "json", subdirectory: "PreloadedData") else {
            throw ItemProviderError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(ItemsResponse.self, from: data)

        print("📄 [ItemProvider] JSON schema version: \(response.schemaVersion)")

        // ID順にソート
        return response.items.sorted { $0.id < $1.id }
    }
}

// MARK: - JSON Response Model

/// items_v5.jsonのレスポンス構造
private struct ItemsResponse: Codable {
    let schemaVersion: Int
    let items: [ItemEntity]
}

// MARK: - Errors

/// ItemProviderのエラー
enum ItemProviderError: LocalizedError {
    case fileNotFound
    case itemNotFound(id: Int)
    case itemNotFound(name: String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "items_v5.json file not found"
        case .itemNotFound(let id):
            return "Item not found: id=\(id)"
        case .itemNotFound(let name):
            return "Item not found: name=\(name)"
        }
    }
}
