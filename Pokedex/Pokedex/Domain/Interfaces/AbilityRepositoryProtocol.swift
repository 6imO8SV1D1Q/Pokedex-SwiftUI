//
//  AbilityRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 特性データを取得するリポジトリのプロトコル
protocol AbilityRepositoryProtocol {
    /// 全特性のリストを取得
    /// - Returns: 特性名のリスト（ソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllAbilities() async throws -> [String]
}
