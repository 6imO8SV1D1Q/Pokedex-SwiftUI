//
//  BattleMode.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// バトルモード
enum BattleMode: String, Codable, CaseIterable, Identifiable {
    case single = "single"
    case double = "double"

    var id: String { rawValue }

    /// 表示名（日本語）
    var displayName: String {
        switch self {
        case .single:
            return "シングルバトル"
        case .double:
            return "ダブルバトル"
        }
    }

    /// 表示名（英語）
    var displayNameEn: String {
        switch self {
        case .single:
            return "Single Battle"
        case .double:
            return "Double Battle"
        }
    }

    /// 範囲技の威力倍率
    var spreadMovePowerMultiplier: Double {
        switch self {
        case .single:
            return 1.0
        case .double:
            return 0.75  // ダブルバトルでは範囲技は0.75倍
        }
    }
}
