//
//  FetchGenerationsUseCaseProtocol.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 全世代情報を取得するUseCaseのプロトコル
protocol FetchGenerationsUseCaseProtocol {
    /// 全世代情報を取得
    /// - Returns: 世代のリスト
    func execute() -> [Generation]
}
