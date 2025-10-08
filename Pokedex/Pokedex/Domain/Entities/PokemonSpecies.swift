//
//  PokemonSpecies.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

struct PokemonSpecies: Codable {
    let id: Int
    let name: String
    let evolutionChain: EvolutionChainReference
    let genderRate: Int  // -1: 性別不明, 0-8: ♀の確率（8分率）
    let eggGroups: [EggGroup]

    struct EvolutionChainReference: Codable {
        let url: String

        // URLから進化チェーンIDを取得
        var id: Int? {
            let components = url.split(separator: "/")
            guard let lastComponent = components.last else { return nil }
            return Int(lastComponent)
        }
    }

    struct EggGroup: Codable {
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case evolutionChain = "evolution_chain"
        case genderRate = "gender_rate"
        case eggGroups = "egg_groups"
    }

    // MARK: - Computed Properties

    /// 性別比の表示文字列
    var genderRatioDisplay: String {
        if genderRate == -1 {
            return "性別不明"
        }
        let femaleRate = Double(genderRate) / 8.0 * 100.0
        let maleRate = 100.0 - femaleRate
        return String(format: "♂ %.1f%% / ♀ %.1f%%", maleRate, femaleRate)
    }

    /// たまごグループの表示文字列
    var eggGroupsDisplay: String {
        if eggGroups.isEmpty {
            return "みはっけん"
        }
        return eggGroups.map { translateEggGroupName($0.name) }.joined(separator: "、")
    }

    /// たまごグループ名を日本語に変換
    private func translateEggGroupName(_ name: String) -> String {
        switch name {
        case "monster": return "かいじゅう"
        case "water1": return "すいちゅう1"
        case "water2": return "すいちゅう2"
        case "water3": return "すいちゅう3"
        case "bug": return "むし"
        case "flying": return "ひこう"
        case "field": return "りくじょう"
        case "fairy": return "ようせい"
        case "grass": return "しょくぶつ"
        case "plant": return "しょくぶつ"
        case "human-like": return "ひとがた"
        case "mineral": return "こうぶつ"
        case "amorphous": return "ふていけい"
        case "ditto": return "メタモン"
        case "dragon": return "ドラゴン"
        case "undiscovered": return "みはっけん"
        default: return name
        }
    }
}
