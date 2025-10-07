//
//  FetchAbilityDetailUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 特性詳細を取得するUseCaseのプロトコル
protocol FetchAbilityDetailUseCaseProtocol {
    /// 特性詳細を取得
    /// - Parameter abilityId: 特性ID
    /// - Returns: 特性詳細情報
    func execute(abilityId: Int) async throws -> AbilityDetail
}

/// 特性詳細を取得するUseCase
final class FetchAbilityDetailUseCase: FetchAbilityDetailUseCaseProtocol {
    private let abilityRepository: AbilityRepositoryProtocol

    init(abilityRepository: AbilityRepositoryProtocol) {
        self.abilityRepository = abilityRepository
    }

    func execute(abilityId: Int) async throws -> AbilityDetail {
        return try await abilityRepository.fetchAbilityDetail(abilityId: abilityId)
    }
}
