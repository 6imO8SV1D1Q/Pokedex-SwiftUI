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
    /// 技の説明文（effectテキスト）
    let effect: String?
    /// 技マシン番号（例: "TM24", "HM03", "TR12"）
    let machineNumber: String?
    /// 技カテゴリー（例: ["sound", "punch"]）
    let categories: [String]

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
}
