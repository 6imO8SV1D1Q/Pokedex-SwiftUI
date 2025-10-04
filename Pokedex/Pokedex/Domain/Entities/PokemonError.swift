//
//  PokemonError.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

enum PokemonError: LocalizedError {
    case networkError(Error)
    case notFound
    case invalidData
    case timeout

    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "通信エラー: \(error.localizedDescription)"
        case .notFound:
            return "ポケモンが見つかりませんでした"
        case .invalidData:
            return "データの形式が正しくありません"
        case .timeout:
            return "通信がタイムアウトしました"
        }
    }
}
