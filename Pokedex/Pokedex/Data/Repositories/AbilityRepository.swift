//
//  AbilityRepository.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation
import SwiftData

/// 特性データを取得するリポジトリ（SwiftDataのみ使用）
final class AbilityRepository: AbilityRepositoryProtocol {
    private let modelContext: ModelContext
    private var cache: [AbilityEntity]?
    private let abilityCache = AbilityCache()

    /// イニシャライザ
    /// - Parameters:
    ///   - modelContext: SwiftData ModelContext
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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

        // SwiftDataから取得
        let descriptor = FetchDescriptor<AbilityModel>(
            predicate: #Predicate { $0.id == abilityId }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw NSError(domain: "AbilityRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ability not found: \(abilityId)"])
        }

        let detail = AbilityDetail(
            id: model.id,
            name: model.name,
            nameJa: model.nameJa.isEmpty ? nil : model.nameJa,
            effect: model.effect,
            effectJa: model.effectJa.isEmpty ? nil : model.effectJa,
            flavorText: nil,  // フレーバーテキストは別データ（現状未使用）
            isHidden: false  // isHiddenはポケモンとの関係性なのでここでは不明
        )

        // キャッシュに保存
        await abilityCache.set(detail: detail)

        return detail
    }

    func fetchAbilityDetail(abilityName: String) async throws -> AbilityDetail {
        // キャッシュチェック（名前をキーとして使用）
        if let cached = await abilityCache.get(abilityName: abilityName) {
            return cached
        }

        // SwiftDataから取得
        let descriptor = FetchDescriptor<AbilityModel>(
            predicate: #Predicate { $0.name == abilityName }
        )
        guard let model = try modelContext.fetch(descriptor).first else {
            throw NSError(domain: "AbilityRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Ability not found: \(abilityName)"])
        }

        let detail = AbilityDetail(
            id: model.id,
            name: model.name,
            nameJa: model.nameJa.isEmpty ? nil : model.nameJa,
            effect: model.effect,
            effectJa: model.effectJa.isEmpty ? nil : model.effectJa,
            flavorText: nil,  // フレーバーテキストは別データ（現状未使用）
            isHidden: false  // isHiddenはポケモンとの関係性なのでここでは不明
        )

        // キャッシュに保存
        await abilityCache.set(detail: detail)

        return detail
    }
}
