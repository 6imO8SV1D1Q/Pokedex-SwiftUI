//
//  Pokemon.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import SwiftUI

struct Pokemon: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let height: Int              // デシメートル単位
    let weight: Int              // ヘクトグラム単位
    let types: [PokemonType]
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let sprites: PokemonSprites
    let moves: [PokemonMove]

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Pokemon, rhs: Pokemon) -> Bool {
        lhs.id == rhs.id
    }

    // 身長をメートル単位で取得
    var heightInMeters: Double {
        Double(height) / 10.0
    }

    // 体重をキログラム単位で取得
    var weightInKilograms: Double {
        Double(weight) / 10.0
    }

    // 図鑑番号表示用
    var formattedId: String {
        String(format: "#%03d", id)
    }

    // 表示用の名前
    var displayName: String {
        name.capitalized
    }
}

// MARK: - PokemonType
struct PokemonType: Codable, Identifiable, Hashable {
    let id = UUID()
    let slot: Int
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

    // タイプの日本語名
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

    // ポケモン スカーレット・バイオレット 公式タイプカラー
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

    // タイプバッジのテキスト色（アクセシビリティ考慮）
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
struct PokemonStat: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let baseStat: Int

    // 日本語表示名
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
struct PokemonAbility: Codable, Identifiable, Hashable {
    let id = UUID()
    let name: String
    let isHidden: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case isHidden = "is_hidden"
    }

    // 表示用の名前
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
struct PokemonSprites: Codable, Hashable {
    let frontDefault: String?
    let frontShiny: String?
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

    // 優先順位: Home > デフォルト
    var preferredImageURL: String? {
        other?.home?.frontDefault ?? frontDefault
    }

    // 色違い用
    var shinyImageURL: String? {
        other?.home?.frontShiny ?? frontShiny
    }

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case other
    }
}
