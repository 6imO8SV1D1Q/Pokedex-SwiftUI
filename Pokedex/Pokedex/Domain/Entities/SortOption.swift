//
//  SortOption.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンリストのソートオプション
///
/// 図鑑番号、種族値などでソート可能
enum SortOption: Equatable {
    case pokedexNumber(ascending: Bool)
    case totalStats(ascending: Bool)
    case hp(ascending: Bool)
    case attack(ascending: Bool)
    case defense(ascending: Bool)
    case specialAttack(ascending: Bool)
    case specialDefense(ascending: Bool)
    case speed(ascending: Bool)

    /// 表示名
    var displayName: String {
        switch self {
        case .pokedexNumber(let ascending):
            return "図鑑番号\(ascending ? "↑" : "↓")"
        case .totalStats(let ascending):
            return "種族値合計\(ascending ? "↑" : "↓")"
        case .hp(let ascending):
            return "HP\(ascending ? "↑" : "↓")"
        case .attack(let ascending):
            return "攻撃\(ascending ? "↑" : "↓")"
        case .defense(let ascending):
            return "防御\(ascending ? "↑" : "↓")"
        case .specialAttack(let ascending):
            return "特攻\(ascending ? "↑" : "↓")"
        case .specialDefense(let ascending):
            return "特防\(ascending ? "↑" : "↓")"
        case .speed(let ascending):
            return "素早さ\(ascending ? "↑" : "↓")"
        }
    }
}
