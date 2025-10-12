//
//  PokedexType.swift
//  Pokedex
//
//  Created on 2025-10-12.
//

import Foundation

/// ポケモン図鑑の種類
enum PokedexType: String, CaseIterable, Identifiable, Codable {
    /// 全国図鑑
    case national

    /// パルデア図鑑
    case paldea

    /// キタカミ図鑑
    case kitakami

    /// ブルーベリー図鑑
    case blueberry

    var id: String { rawValue }

    /// 日本語名
    var nameJa: String {
        switch self {
        case .national:
            return "全国"
        case .paldea:
            return "パルデア"
        case .kitakami:
            return "キタカミ"
        case .blueberry:
            return "ブルーベリー"
        }
    }

    /// 英語名
    var nameEn: String {
        switch self {
        case .national:
            return "National"
        case .paldea:
            return "Paldea"
        case .kitakami:
            return "Kitakami"
        case .blueberry:
            return "Blueberry"
        }
    }
}
