//
//  FetchEvolutionChainUseCase.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

/// 進化チェーン取得UseCaseのプロトコル
protocol FetchEvolutionChainUseCaseProtocol {
    /// 指定されたポケモンの進化チェーンを取得
    /// - Parameter pokemonId: ポケモンの図鑑番号
    /// - Returns: 進化チェーンに含まれるポケモンIDの配列
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func execute(pokemonId: Int) async throws -> [Int]

    /// 指定されたポケモンの進化チェーンをツリー構造で取得（v3.0）
    /// - Parameter pokemonId: ポケモンの図鑑番号
    /// - Returns: 進化チェーンのツリー構造
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func executeV3(pokemonId: Int) async throws -> EvolutionChainEntity
}

/// ポケモンの進化チェーンを取得するUseCase
///
/// 指定されたポケモンが属する進化チェーン全体のポケモンIDリストを取得します。
/// 例: フシギダネ(1)を指定すると、[1, 2, 3] (フシギダネ、フシギソウ、フシギバナ)を返します。
/// 分岐進化（イーブイなど）にも対応しています。
///
/// - Important: ネットワーク通信が発生するため、async/awaitで実行してください。
final class FetchEvolutionChainUseCase: FetchEvolutionChainUseCaseProtocol {

    // MARK: - Properties

    /// ポケモンデータを取得するリポジトリ
    private let repository: PokemonRepositoryProtocol

    // MARK: - Initialization

    /// イニシャライザ
    /// - Parameter repository: ポケモンデータを取得するリポジトリ
    init(repository: PokemonRepositoryProtocol) {
        self.repository = repository
    }

    // MARK: - Public Methods

    /// 指定されたポケモンの進化チェーンを取得
    ///
    /// - Parameter pokemonId: ポケモンの図鑑番号
    /// - Returns: 進化チェーンに含まれるポケモンIDの配列
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func execute(pokemonId: Int) async throws -> [Int] {
        // 1. pokemon-speciesを取得して進化チェーンIDを取得
        let species = try await repository.fetchPokemonSpecies(id: pokemonId)

        guard let evolutionChainId = species.evolutionChain.id else {
            return [pokemonId]
        }

        // 2. 進化チェーンを取得
        let evolutionChain = try await repository.fetchEvolutionChain(id: evolutionChainId)

        // 3. チェーンを再帰的に辿ってIDリストを作成
        var pokemonIds: [Int] = []
        extractPokemonIds(from: evolutionChain.chain, into: &pokemonIds)

        return pokemonIds
    }

    // MARK: - Private Methods

    /// 進化チェーンから再帰的にポケモンIDを抽出
    /// - Parameters:
    ///   - chainLink: 進化チェーンのノード
    ///   - ids: 抽出したIDを格納する配列
    private func extractPokemonIds(from chainLink: EvolutionChain.ChainLink, into ids: inout [Int]) {
        if let id = chainLink.species.id {
            ids.append(id)
        }

        for evolvedForm in chainLink.evolvesTo {
            extractPokemonIds(from: evolvedForm, into: &ids)
        }
    }

    /// 指定されたポケモンの進化チェーンをツリー構造で取得（v3.0）
    ///
    /// - Parameter pokemonId: ポケモンの図鑑番号
    /// - Returns: 進化チェーンのツリー構造
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func executeV3(pokemonId: Int) async throws -> EvolutionChainEntity {
        // repositoryのfetchEvolutionChainEntityメソッドを使用
        return try await repository.fetchEvolutionChainEntity(speciesId: pokemonId)
    }
}
