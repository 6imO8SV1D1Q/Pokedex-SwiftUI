//
//  AbilityRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 特性データを取得するリポジトリのプロトコル
protocol AbilityRepositoryProtocol {
    // MARK: - 既存メソッド

    /// 全特性のリストを取得
    /// - Returns: 特性名のリスト（ソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllAbilities() async throws -> [String]

    // MARK: - v3.0 新規メソッド

    /// 特性の詳細情報を取得
    /// - Parameter abilityId: 特性ID
    /// - Returns: 特性の詳細情報
    /// - Throws: データ取得時のエラー
    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail
}
