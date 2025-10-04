//
//  Pokemon.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import SwiftUI

/// ポケモンのエンティティ
///
/// ポケモンの基本情報、タイプ、ステータス、特性などを保持します。
/// PokéAPIから取得したデータをアプリ内で扱いやすい形に変換したものです。
struct Pokemon: Identifiable, Codable, Hashable {
    // MARK: - Properties

    /// ポケモンの図鑑番号（一意の識別子）
    let id: Int

    /// ポケモンの名前（英語名、小文字）
    let name: String

    /// 身長（デシメートル単位）
    let height: Int

    /// 体重（ヘクトグラム単位）
    let weight: Int

    /// タイプ（最大2つ）
    let types: [PokemonType]

    /// ステータス（種族値）
    let stats: [PokemonStat]

    /// 特性
    let abilities: [PokemonAbility]

    /// 画像URL
    let sprites: PokemonSprites

    /// 習得技
    let moves: [PokemonMove]

    // MARK: - Hashable

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - Computed Properties

    /// 身長をメートル単位で取得
    /// - Returns: 身長（メートル）
    var heightInMeters: Double {
        Double(height) / 10.0
    }

    /// 体重をキログラム単位で取得
    /// - Returns: 体重（キログラム）
    var weightInKilograms: Double {
        Double(weight) / 10.0
    }

    /// 図鑑番号の表示用フォーマット
    /// - Returns: 3桁0埋めされた図鑑番号（例: "#001"）
    var formattedId: String {
        String(format: "#%03d", id)
    }

    /// 表示用の名前（先頭大文字）
    /// - Returns: 先頭が大文字の名前
    var displayName: String {
        name.capitalized
    }
}

// MARK: - PokemonType

/// ポケモンのタイプ
///
/// ポケモンのタイプ情報（ほのお、みず、など）を保持します。
/// タイプカラーと日本語名も提供します。
struct PokemonType: Codable, Identifiable, Hashable {
    let id = UUID()

    /// タイプスロット（1または2）
    let slot: Int

    /// タイプ名（英語、小文字）
    let name: String

    enum CodingKeys: String, CodingKey {
        case slot, name
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(slot)
        hasher.combine(name)
    }

    static func == (lhs: PokemonType, rhs: PokemonType) -> Bool {
        lhs.slot == rhs.slot && lhs.name == rhs.name
    }

    /// タイプの日本語名
    /// - Returns: 日本語のタイプ名（例: "ほのお", "みず"）
    var japaneseName: String {
        switch name.lowercased() {
        case "normal": return "ノーマル"
        case "fire": return "ほのお"
        case "water": return "みず"
        case "grass": return "くさ"
        case "electric": return "でんき"
        case "ice": return "こおり"
        case "fighting": return "かくとう"
        case "poison": return "どく"
        case "ground": return "じめん"
        case "flying": return "ひこう"
        case "psychic": return "エスパー"
        case "bug": return "むし"
        case "rock": return "いわ"
        case "ghost": return "ゴースト"
        case "dragon": return "ドラゴン"
        case "dark": return "あく"
        case "steel": return "はがね"
        case "fairy": return "フェアリー"
        default: return name.capitalized
        }
    }

    /// ポケモン スカーレット・バイオレット 公式タイプカラー
    /// - Returns: タイプに対応する色
    var color: Color {
        switch name.lowercased() {
        case "normal":
            return Color(red: 159/255, green: 161/255, blue: 159/255)
        case "fire":
            return Color(red: 230/255, green: 40/255, blue: 41/255)
        case "water":
            return Color(red: 53/255, green: 126/255, blue: 199/255)
        case "grass":
            return Color(red: 99/255, green: 187/255, blue: 68/255)
        case "electric":
            return Color(red: 238/255, green: 213/255, blue: 53/255)
        case "ice":
            return Color(red: 116/255, green: 206/255, blue: 192/255)
        case "fighting":
            return Color(red: 206/255, green: 64/255, blue: 86/255)
        case "poison":
            return Color(red: 185/255, green: 127/255, blue: 201/255)
        case "ground":
            return Color(red: 217/255, green: 119/255, blue: 70/255)
        case "flying":
            return Color(red: 139/255, green: 170/255, blue: 229/255)
        case "psychic":
            return Color(red: 243/255, green: 102/255, blue: 185/255)
        case "bug":
            return Color(red: 145/255, green: 193/255, blue: 47/255)
        case "rock":
            return Color(red: 199/255, green: 183/255, blue: 139/255)
        case "ghost":
            return Color(red: 82/255, green: 105/255, blue: 172/255)
        case "dragon":
            return Color(red: 11/255, green: 109/255, blue: 195/255)
        case "dark":
            return Color(red: 90/255, green: 83/255, blue: 102/255)
        case "steel":
            return Color(red: 90/255, green: 142/255, blue: 161/255)
        case "fairy":
            return Color(red: 236/255, green: 143/255, blue: 230/255)
        default:
            return Color.gray
        }
    }

    /// タイプバッジのテキスト色（アクセシビリティ考慮）
    /// - Returns: 背景色に応じて適切なテキスト色（黒または白）
    var textColor: Color {
        switch name.lowercased() {
        case "electric", "ice":
            // 明るい背景色には黒文字
            return Color.black
        default:
            // それ以外は白文字
            return Color.white
        }
    }
}

// MARK: - PokemonStat

/// ポケモンのステータス（種族値）
///
/// HP、こうげき、ぼうぎょなどのステータス情報を保持します。
struct PokemonStat: Codable, Identifiable, Hashable {
    let id = UUID()

    /// ステータス名（英語）
    let name: String

    /// 種族値
    let baseStat: Int

    /// 日本語表示名
    /// - Returns: 日本語のステータス名
    var displayName: String {
        switch name {
        case "hp": return "HP"
        case "attack": return "こうげき"
        case "defense": return "ぼうぎょ"
        case "special-attack": return "とくこう"
        case "special-defense": return "とくぼう"
        case "speed": return "すばやさ"
        default: return name
        }
    }

    enum CodingKeys: String, CodingKey {
        case name
        case baseStat = "base_stat"
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(baseStat)
    }

    static func == (lhs: PokemonStat, rhs: PokemonStat) -> Bool {
        lhs.name == rhs.name && lhs.baseStat == rhs.baseStat
    }
}

// MARK: - PokemonAbility

/// ポケモンの特性
///
/// ポケモンの特性情報（通常特性と隠れ特性）を保持します。
struct PokemonAbility: Codable, Identifiable, Hashable {
    let id = UUID()

    /// 特性名（英語）
    let name: String

    /// 隠れ特性かどうか
    let isHidden: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case isHidden = "is_hidden"
    }

    /// 表示用の名前（隠れ特性の場合は注釈付き）
    /// - Returns: 表示用の特性名
    var displayName: String {
        let baseName = name.capitalized
        return isHidden ? "\(baseName) (隠れ特性)" : baseName
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(isHidden)
    }

    static func == (lhs: PokemonAbility, rhs: PokemonAbility) -> Bool {
        lhs.name == rhs.name && lhs.isHidden == rhs.isHidden
    }
}

// MARK: - PokemonSprites

/// ポケモンの画像URL
///
/// 通常画像と色違い画像のURLを保持します。
/// 複数のソース（デフォルト、Home）から最適な画像を選択できます。
struct PokemonSprites: Codable, Hashable {
    /// デフォルトの正面画像URL
    let frontDefault: String?

    /// 色違いの正面画像URL
    let frontShiny: String?

    /// その他の画像ソース
    let other: OtherSprites?

    struct OtherSprites: Codable, Hashable {
        let home: HomeSprites?

        struct HomeSprites: Codable, Hashable {
            let frontDefault: String?
            let frontShiny: String?

            enum CodingKeys: String, CodingKey {
                case frontDefault = "front_default"
                case frontShiny = "front_shiny"
            }
        }
    }

    /// 優先順位に基づいた画像URL（Home > デフォルト）
    /// - Returns: 最適な通常画像のURL
    var preferredImageURL: String? {
        other?.home?.frontDefault ?? frontDefault
    }

    /// 色違い画像のURL
    /// - Returns: 最適な色違い画像のURL
    var shinyImageURL: String? {
        other?.home?.frontShiny ?? frontShiny
    }

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case other
    }
}
