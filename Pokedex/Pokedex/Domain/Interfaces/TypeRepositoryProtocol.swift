//
//  TypeRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// タイプ相性データを取得するリポジトリのプロトコル
protocol TypeRepositoryProtocol {
    /// タイプの詳細情報（相性情報を含む）を取得
    /// - Parameter typeName: タイプ名（英語、小文字）
    /// - Returns: タイプの詳細情報
    /// - Throws: データ取得時のエラー
    func fetchTypeDetail(typeName: String) async throws -> TypeDetail
}

/// タイプの詳細情報
struct TypeDetail: Equatable {
    /// タイプ名
    let typeName: String

    /// ダメージ関係（相性情報）
    let damageRelations: DamageRelations

    /// ダメージ関係の構造
    struct DamageRelations: Equatable {
        /// このタイプの技が2倍ダメージを与えるタイプ
        let doubleDamageTo: [String]

        /// このタイプの技が1/2倍ダメージを与えるタイプ
        let halfDamageTo: [String]

        /// このタイプの技が無効（0倍）のタイプ
        let noDamageTo: [String]

        /// このタイプが2倍ダメージを受けるタイプ
        let doubleDamageFrom: [String]

        /// このタイプが1/2倍ダメージを受けるタイプ
        let halfDamageFrom: [String]

        /// このタイプが無効（0倍）で受けるタイプ
        let noDamageFrom: [String]
    }
}
