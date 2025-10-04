//
//  Pokemon.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

struct Pokemon: Identifiable, Codable {
    let id: Int
    let name: String
    let height: Int              // デシメートル単位
    let weight: Int              // ヘクトグラム単位
    let types: [PokemonType]
    let stats: [PokemonStat]
    let abilities: [PokemonAbility]
    let sprites: PokemonSprites

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
}

// MARK: - PokemonType
struct PokemonType: Codable, Identifiable {
    let id = UUID()
    let slot: Int
    let name: String

    enum CodingKeys: String, CodingKey {
        case slot, name
    }
}

// MARK: - PokemonStat
struct PokemonStat: Codable, Identifiable {
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
}

// MARK: - PokemonAbility
struct PokemonAbility: Codable, Identifiable {
    let id = UUID()
    let name: String
    let isHidden: Bool

    enum CodingKeys: String, CodingKey {
        case name
        case isHidden = "is_hidden"
    }
}

// MARK: - PokemonSprites
struct PokemonSprites: Codable {
    let frontDefault: String?
    let frontShiny: String?

    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
    }
}
