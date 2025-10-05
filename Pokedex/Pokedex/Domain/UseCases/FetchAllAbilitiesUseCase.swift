//
//  FetchAllAbilitiesUseCase.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 全特性リストを取得するUseCase
final class FetchAllAbilitiesUseCase: FetchAllAbilitiesUseCaseProtocol {
    private let abilityRepository: AbilityRepositoryProtocol

    /// イニシャライザ
    /// - Parameter abilityRepository: 特性データを取得するリポジトリ
    init(abilityRepository: AbilityRepositoryProtocol) {
        self.abilityRepository = abilityRepository
    }

    /// 全特性のリストを取得
    /// - Returns: 特性名のリスト（ソート済み）
    /// - Throws: データ取得時のエラー
    func execute() async throws -> [String] {
        try await abilityRepository.fetchAllAbilities()
    }
}
