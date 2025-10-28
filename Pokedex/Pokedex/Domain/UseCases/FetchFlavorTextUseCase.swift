//
//  FetchFlavorTextUseCase.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 図鑑テキストを取得するUseCaseのプロトコル
protocol FetchFlavorTextUseCaseProtocol {
    /// 図鑑テキストを取得
    /// - Parameters:
    ///   - speciesId: 種族ID
    ///   - versionGroup: バージョングループ（nilの場合は最新のテキスト）
    ///   - preferredVersion: 優先バージョン（例: "scarlet" または "violet"）
    ///   - preferredLanguage: 優先言語（例: "ja" または "en"）
    /// - Returns: 図鑑テキスト
    func execute(speciesId: Int, versionGroup: String?, preferredVersion: String?, preferredLanguage: String) async throws -> PokemonFlavorText?
}

/// 図鑑テキストを取得するUseCase
final class FetchFlavorTextUseCase: FetchFlavorTextUseCaseProtocol {
    private let pokemonRepository: PokemonRepositoryProtocol

    init(pokemonRepository: PokemonRepositoryProtocol) {
        self.pokemonRepository = pokemonRepository
    }

    func execute(speciesId: Int, versionGroup: String?, preferredVersion: String?, preferredLanguage: String = "ja") async throws -> PokemonFlavorText? {
        return try await pokemonRepository.fetchFlavorText(speciesId: speciesId, versionGroup: versionGroup, preferredVersion: preferredVersion, preferredLanguage: preferredLanguage)
    }
}
