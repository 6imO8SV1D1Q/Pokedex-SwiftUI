//
//  MoveEntity.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技情報を表すEntity
struct MoveEntity: Identifiable, Equatable {
    /// 技のID
    let id: Int
    /// 技の名前（英語、ケバブケース）
    let name: String
    /// 技の名前（日本語）
    let nameJa: String
    /// 技のタイプ
    let type: PokemonType
    /// 威力（nilの場合は変化技）
    let power: Int?
    /// 命中率（nilの場合は必中）
    let accuracy: Int?
    /// PP
    let pp: Int?
    /// ダメージクラス（"physical", "special", "status"）
    let damageClass: String
    /// 技の説明文（英語）
    let effect: String?
    /// 技の説明文（日本語）
    let effectJa: String?
    /// 技マシン番号（例: "TM24", "HM03", "TR12"）
    let machineNumber: String?
    /// 技カテゴリー（例: ["sound", "punch"]）
    let categories: [String]
    /// 優先度（-7 〜 +5）
    let priority: Int
    /// 追加効果発動確率
    let effectChance: Int?
    /// 技の対象（例: "selected-pokemon", "user", "all-opponents"）
    let target: String
    /// 詳細メタデータ
    let meta: MoveMeta?

    /// IDで等価性を判定
    static func == (lhs: MoveEntity, rhs: MoveEntity) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Computed Properties

    /// 威力の表示用テキスト
    var displayPower: String {
        power.map(String.init) ?? "-"
    }

    /// 命中率の表示用テキスト
    var displayAccuracy: String {
        accuracy.map(String.init) ?? "-"
    }

    /// PPの表示用テキスト
    var displayPP: String {
        pp.map(String.init) ?? "-"
    }

    /// 分類アイコン
    var categoryIcon: String {
        switch damageClass {
        case "physical":
            return "💥"  // 物理
        case "special":
            return "✨"  // 特殊
        case "status":
            return "🔄"  // 変化
        default:
            return ""
        }
    }

    /// 分類の表示名
    var categoryDisplayName: String {
        switch damageClass {
        case "physical":
            return "物理"
        case "special":
            return "特殊"
        case "status":
            return "変化"
        default:
            return damageClass
        }
    }

    /// 説明文の表示用テキスト
    var displayEffect: String {
        effect ?? "説明なし"
    }

    /// 現在の言語設定に応じた説明文を返す
    func localizedEffect(language: AppLanguage) -> String {
        switch language {
        case .japanese:
            return effectJa ?? effect ?? "説明なし"
        case .english:
            return effect ?? "No description"
        }
    }
}

// MARK: - Move Meta

/// 技の詳細メタデータ
struct MoveMeta: Equatable, Codable {
    /// 状態異常（paralysis, burn, poison, freeze, sleep, confusion, none）
    let ailment: String
    /// 状態異常発動確率（0-100）
    let ailmentChance: Int
    /// カテゴリー
    let category: String
    /// 急所率（0=通常、1=高い、2=確定）
    let critRate: Int
    /// HP吸収率（-100〜100、負の値は反動）
    let drain: Int
    /// ひるみ確率（0-100）
    let flinchChance: Int
    /// 回復量（-100〜100）
    let healing: Int
    /// 能力変化発動確率（0-100）
    let statChance: Int
    /// 能力変化詳細
    let statChanges: [MoveStatChangeEntity]
}

/// 技の能力変化情報
struct MoveStatChangeEntity: Equatable, Codable {
    /// ステータス種類（attack, defense, special-attack, special-defense, speed, accuracy, evasion）
    let stat: String
    /// 変化量（-6〜+6）
    let change: Int
}
