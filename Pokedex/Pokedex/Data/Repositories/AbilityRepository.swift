//
//  AbilityRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation
import SwiftData

/// 特性データを取得するリポジトリ
final class AbilityRepository: AbilityRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private let modelContext: ModelContext
    private var cache: [AbilityEntity]?
    private let abilityCache = AbilityCache()

    /// イニシャライザ
    /// - Parameters:
    ///   - modelContext: SwiftData ModelContext
    ///   - apiClient: PokemonAPIクライアント（後方互換性のため保持）
    init(modelContext: ModelContext, apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.modelContext = modelContext
        self.apiClient = apiClient
    }

    /// 全特性のリストを取得（SwiftDataから）
    /// - Returns: 特性情報のリスト（名前でソート済み）
    /// - Throws: データ取得時のエラー
    func fetchAllAbilities() async throws -> [AbilityEntity] {
        // キャッシュチェック
        if let cached = cache {
            print("🔍 [AbilityRepository] Cache hit: \(cached.count) abilities")
            return cached
        }

        // SwiftDataから全特性を取得
        let descriptor = FetchDescriptor<AbilityModel>(
            sortBy: [SortDescriptor(\.name)]
        )
        let models = try modelContext.fetch(descriptor)
        print("📦 [AbilityRepository] Fetched from SwiftData: \(models.count) abilities")

        // AbilityEntityに変換
        let entities = models.map { model in
            AbilityEntity(
                id: model.id,
                name: model.name,
                nameJa: model.nameJa
            )
        }

        cache = entities
        return entities
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

    func fetchAbilityDetail(abilityName: String) async throws -> AbilityDetail {
        // キャッシュチェック（名前をキーとして使用）
        if let cached = await abilityCache.get(abilityName: abilityName) {
            return cached
        }

        // API呼び出し（PokéAPIは名前でもアクセス可能）
        let detail = try await apiClient.fetchAbilityDetail(abilityName: abilityName)

        // キャッシュに保存
        await abilityCache.set(detail: detail)

        return detail
    }
}
