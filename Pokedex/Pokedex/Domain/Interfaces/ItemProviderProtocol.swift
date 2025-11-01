//
//  ItemProviderProtocol.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// アイテムデータを取得するプロバイダーのプロトコル
protocol ItemProviderProtocol {
    /// 全アイテムのリストを取得
    /// - Returns: アイテム情報のリスト（ID順にソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllItems() async throws -> [ItemEntity]

    /// IDでアイテムを取得
    /// - Parameter itemId: アイテムID
    /// - Returns: アイテム情報
    /// - Throws: データ取得時のエラー
    func fetchItem(id itemId: Int) async throws -> ItemEntity

    /// 名前でアイテムを取得
    /// - Parameter itemName: アイテム名（英語、ケバブケース）
    /// - Returns: アイテム情報
    /// - Throws: データ取得時のエラー
    func fetchItem(name itemName: String) async throws -> ItemEntity

    /// カテゴリーでアイテムをフィルタリング
    /// - Parameter category: カテゴリー名（例: "held-item"）
    /// - Returns: 該当カテゴリーのアイテムリスト
    /// - Throws: データ取得時のエラー
    func fetchItems(category: String) async throws -> [ItemEntity]
}
