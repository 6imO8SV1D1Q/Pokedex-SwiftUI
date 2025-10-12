//
//  FilterMode.swift
//  Pokedex
//
//  Created on 2025-10-12.
//

import Foundation

/// フィルターの検索モード
enum FilterMode: String, Codable {
    /// OR検索（いずれかに該当）
    case or

    /// AND検索（全てに該当）
    case and

    /// 表示名
    var displayName: String {
        switch self {
        case .or:
            return "OR（いずれか）"
        case .and:
            return "AND（全て）"
        }
    }
}
