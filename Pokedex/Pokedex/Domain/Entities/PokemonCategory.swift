//
//  PokemonCategory.swift
//  Pokedex
//
//  Created on 2025-10-12.
//

import Foundation

/// ポケモンの区分
enum PokemonCategory: String, CaseIterable, Identifiable, Codable {
    /// 一般ポケモン
    case normal

    /// 準伝説ポケモン
    case subLegendary

    /// 伝説ポケモン
    case legendary

    /// 幻のポケモン
    case mythical

    var id: String { rawValue }

    /// 表示名
    var displayName: String {
        switch self {
        case .normal:
            return L10n.Category.normal
        case .subLegendary:
            return L10n.Category.subLegendary
        case .legendary:
            return L10n.Category.legendary
        case .mythical:
            return L10n.Category.mythical
        }
    }

    /// PokéAPIのis_legendary, is_mythicalフラグから判定
    static func from(isLegendary: Bool, isMythical: Bool) -> PokemonCategory {
        if isMythical {
            return .mythical
        } else if isLegendary {
            return .legendary
        } else {
            return .normal
        }
    }
}
