//
//  AbilityDetail.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 特性の詳細情報を表すEntity
struct AbilityDetail: Equatable, Identifiable {
    /// 特性のID
    let id: Int

    /// 特性名（英語）
    let name: String

    /// 特性名（日本語）
    let nameJa: String?

    /// 特性の効果説明（英語）
    let effect: String

    /// 特性の効果説明（日本語）
    let effectJa: String?

    /// フレーバーテキスト（ゲーム内説明、日本語対応予定）
    let flavorText: String?

    /// 隠れ特性かどうか
    let isHidden: Bool

    /// 表示用の名前（先頭大文字）
    var displayName: String {
        name.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    /// 現在の言語設定に応じた特性名を返す
    func localizedName(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return nameJa ?? name.split(separator: "-")
                .map { $0.capitalized }
                .joined(separator: " ")
        case .english:
            return name.split(separator: "-")
                .map { $0.capitalized }
                .joined(separator: " ")
        }
    }

    /// 現在の言語設定に応じた説明文を返す
    func localizedEffect(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return effectJa ?? effect
        case .english:
            return effect
        }
    }
}
