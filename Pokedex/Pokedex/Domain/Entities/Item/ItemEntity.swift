//
//  ItemEntity.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// アイテム情報を表すEntity
struct ItemEntity: Identifiable, Equatable, Codable {
    /// アイテムのID
    let id: Int
    /// アイテムの名前（英語、ケバブケース）
    let name: String
    /// アイテムの名前（日本語）
    let nameJa: String
    /// カテゴリー（"held-item", "berry", "mega-stone"など）
    let category: String
    /// 説明文（英語）
    let description: String?
    /// 説明文（日本語）
    let descriptionJa: String?
    /// 効果の詳細
    let effects: ItemEffects?

    /// IDで等価性を判定
    static func == (lhs: ItemEntity, rhs: ItemEntity) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Computed Properties

    /// 現在の言語設定に応じた名前を返す
    func localizedName(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return nameJa
        case .english:
            return name.split(separator: "-").map { $0.capitalized }.joined(separator: " ")
        }
    }

    /// 現在の言語設定に応じた説明文を返す
    func localizedDescription(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return descriptionJa ?? description ?? "説明なし"
        case .english:
            return description ?? "No description"
        }
    }

    /// アイテムがダメージ倍率効果を持つか
    var hasDamageMultiplier: Bool {
        effects?.damageMultiplier != nil
    }

    /// アイテムがステータス倍率効果を持つか
    var hasStatMultiplier: Bool {
        effects?.statMultiplier != nil
    }

    /// アイテムが何らかの効果を持つか
    var hasEffects: Bool {
        effects != nil && (hasDamageMultiplier || hasStatMultiplier)
    }
}

// MARK: - Item Effects

/// アイテムの効果詳細
struct ItemEffects: Equatable, Codable {
    /// ダメージ倍率効果
    let damageMultiplier: DamageMultiplierEffect?
    /// ステータス倍率効果
    let statMultiplier: StatMultiplierEffect?
}

// MARK: - Damage Multiplier Effect

/// ダメージ倍率効果
struct DamageMultiplierEffect: Equatable, Codable {
    /// 適用条件（"same_type_as_mask", "all_damaging_moves", "super_effective"など）
    let condition: String
    /// 対象タイプ（オーガポンマスクなど特定タイプに限定する場合）
    let types: [String]?
    /// 基本倍率（例: 1.2, 1.3, 1.5）
    let baseMultiplier: Double
    /// テラスタル時の倍率（オーガポン用）
    let teraMultiplier: Double?
    /// テラスタル時も適用されるか
    let appliesDuringTera: Bool?
    /// 特定のポケモンにのみ適用（例: ["ogerpon-wellspring-mask"]）
    let restrictedTo: [String]?

    /// オーガポン専用マスクかどうか
    var isOgerponMask: Bool {
        restrictedTo?.contains(where: { $0.hasPrefix("ogerpon") }) ?? false
    }

    /// 指定されたポケモンに適用可能か
    /// - Parameter pokemonName: ポケモンの名前（英語、ケバブケース）
    /// - Returns: 適用可能な場合true
    func canApply(to pokemonName: String) -> Bool {
        guard let restrictedTo = restrictedTo else {
            return true  // 制限なし
        }
        return restrictedTo.contains(pokemonName)
    }

    /// 指定されたタイプに適用可能か
    /// - Parameter type: タイプ名（英語、小文字）
    /// - Returns: 適用可能な場合true
    func appliesToType(_ type: String) -> Bool {
        guard let types = types else {
            return true  // タイプ制限なし
        }
        return types.contains(type.lowercased())
    }
}

// MARK: - Stat Multiplier Effect

/// ステータス倍率効果
struct StatMultiplierEffect: Equatable, Codable {
    /// 対象ステータス（"attack", "defense", "special-attack", "special-defense", "speed"）
    let stat: String
    /// 倍率（例: 1.5）
    let multiplier: Double

    /// ステータス名の表示用テキスト（日本語）
    var displayStatName: String {
        switch stat {
        case "attack":
            return "攻撃"
        case "defense":
            return "防御"
        case "special-attack":
            return "特攻"
        case "special-defense":
            return "特防"
        case "speed":
            return "素早さ"
        default:
            return stat
        }
    }
}
