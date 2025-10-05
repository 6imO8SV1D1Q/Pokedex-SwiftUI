//
//  FetchPokemonListUseCase.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

/// ポケモンリスト取得UseCaseのプロトコル
protocol FetchPokemonListUseCaseProtocol {
    /// ポケモンリストを取得
    /// - Parameters:
    ///   - limit: 取得する最大数
    ///   - offset: 取得開始位置のオフセット
    ///   - progressHandler: 進捗通知ハンドラ（0.0〜1.0）
    /// - Returns: ポケモンの配列
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func execute(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon]
}

/// ポケモン一覧を取得するUseCase
///
/// PokéAPIから第1世代（図鑑番号001〜151）のポケモンリストを取得します。
/// Repository層でキャッシュされるため、2回目以降の呼び出しは高速です。
///
/// - Important: ネットワーク通信が発生するため、async/awaitで実行してください。
final class FetchPokemonListUseCase: FetchPokemonListUseCaseProtocol {

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

    /// ポケモンリストを取得
    ///
    /// - Parameters:
    ///   - limit: 取得する最大数（デフォルト: 151）
    ///   - offset: 取得開始位置のオフセット（デフォルト: 0）
    ///   - progressHandler: 進捗通知ハンドラ（0.0〜1.0）
    /// - Returns: ポケモンの配列
    /// - Throws: ネットワークエラー、データ解析エラーなど
    func execute(limit: Int = 151, offset: Int = 0, progressHandler: ((Double) -> Void)? = nil) async throws -> [Pokemon] {
        return try await repository.fetchPokemonList(limit: limit, offset: offset, progressHandler: progressHandler)
    }
}
