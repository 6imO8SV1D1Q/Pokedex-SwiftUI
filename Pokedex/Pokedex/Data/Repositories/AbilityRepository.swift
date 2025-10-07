//
//  AbilityRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 特性データを取得するリポジトリ
final class AbilityRepository: AbilityRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private var cache: [String]?
    private let abilityCache = AbilityCache()

    /// イニシャライザ
    /// - Parameter apiClient: PokemonAPIクライアント
    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }

    /// 全特性のリストを取得
    /// - Returns: 特性名のリスト（ソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllAbilities() async throws -> [String] {
        // キャッシュチェック
        if let cached = cache {
            return cached
        }

        let abilities = try await apiClient.fetchAllAbilities()
        cache = abilities
        return abilities
    }

    // MARK: - v3.0 新規メソッド

    func fetchAbilityDetail(abilityId: Int) async throws -> AbilityDetail {
        // キャッシュチェック
        if let cached = await abilityCache.get(abilityId: abilityId) {
            return cached
        }

        // API呼び出し
        let detail = try await apiClient.fetchAbilityDetail(abilityId: abilityId)

        // キャッシュに保存
        await abilityCache.set(detail: detail)

        return detail
    }
}
