//
//  FetchPokemonDetailUseCase.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import Foundation

/// ポケモン詳細取得UseCaseのプロトコル
protocol FetchPokemonDetailUseCaseProtocol {
    /// 指定されたIDのポケモン詳細を取得
    /// - Parameter pokemonId: ポケモンの図鑑番号
    /// - Returns: ポケモン詳細情報
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func execute(pokemonId: Int) async throws -> Pokemon
}

/// ポケモンの詳細情報を取得するUseCase
final class FetchPokemonDetailUseCase: FetchPokemonDetailUseCaseProtocol {
    private let repository: PokemonRepositoryProtocol

    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    func execute(pokemonId: Int) async throws -> Pokemon {
        return try await repository.fetchPokemonDetail(id: pokemonId)
    }
}
