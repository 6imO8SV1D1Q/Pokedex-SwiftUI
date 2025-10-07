//
//  TypeRepository.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

final class TypeRepository: TypeRepositoryProtocol {
    private let apiClient: PokemonAPIClient
    private let typeCache = TypeCache()

    init(apiClient: PokemonAPIClient = PokemonAPIClient()) {
        self.apiClient = apiClient
    }

    func fetchTypeDetail(typeName: String) async throws -> TypeDetail {
        // キャッシュチェック
        if let cached = await typeCache.get(typeName: typeName) {
            return cached
        }

        // API呼び出し
        let typeDetail = try await apiClient.fetchTypeDetail(typeName: typeName)

        // キャッシュに保存
        await typeCache.set(typeName: typeName, detail: typeDetail)

        return typeDetail
    }
}
