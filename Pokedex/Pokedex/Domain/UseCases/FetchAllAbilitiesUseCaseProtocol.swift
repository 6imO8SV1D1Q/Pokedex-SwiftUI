//
//  FetchAllAbilitiesUseCaseProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 全特性リストを取得するUseCaseのプロトコル
protocol FetchAllAbilitiesUseCaseProtocol {
    /// 全特性のリストを取得
    /// - Returns: 特性名のリスト（ソート済み）
    /// - Throws: データ取得時のエラー
    func execute() async throws -> [String]
}
