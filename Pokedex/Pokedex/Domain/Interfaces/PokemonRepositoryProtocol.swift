//
//  PokemonRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

protocol PokemonRepositoryProtocol {
    // MARK: - 既存メソッド
    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon]
    func fetchPokemonList(versionGroup: VersionGroup, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonDetail(name: String) async throws -> Pokemon
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies
    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain
    func clearCache()

    // MARK: - v3.0 新規メソッド

    /// ポケモンのフォーム一覧を取得
    /// - Parameter pokemonId: ポケモンID
    /// - Returns: フォームのリスト
    /// - Throws: データ取得時のエラー
    func fetchPokemonForms(pokemonId: Int) async throws -> [PokemonForm]

    /// ポケモンの生息地情報を取得
    /// - Parameter pokemonId: ポケモンID
    /// - Returns: 生息地のリスト
    /// - Throws: データ取得時のエラー
    func fetchPokemonLocations(pokemonId: Int) async throws -> [PokemonLocation]

    /// ポケモンのフレーバーテキストを取得
    /// - Parameters:
    ///   - speciesId: 種族ID
    ///   - versionGroup: バージョングループ（nilの場合は最新）
    ///   - preferredVersion: 優先バージョン（例: "scarlet" または "violet"）
    /// - Returns: フレーバーテキスト
    /// - Throws: データ取得時のエラー
    func fetchFlavorText(speciesId: Int, versionGroup: String?, preferredVersion: String?, preferredLanguage: String) async throws -> PokemonFlavorText?

    /// 進化チェーン情報を取得（v3拡張版）
    /// - Parameter speciesId: 種族ID
    /// - Returns: 進化チェーンEntity
    /// - Throws: データ取得時のエラー
    func fetchEvolutionChainEntity(speciesId: Int) async throws -> EvolutionChainEntity
}
