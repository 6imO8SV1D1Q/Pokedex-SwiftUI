//
//  Generation.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// ポケモンの世代を表すエンティティ
struct Generation: Identifiable, Equatable {
    /// 世代番号（0=全国図鑑, 1-9=各世代）
    let id: Int

    /// 世代名
    let name: String

    /// その世代のポケモンID範囲（種族ID）
    let pokemonRange: ClosedRange<Int>

    /// その世代で使用するPokedex名のリスト
    let pokedexNames: [String]?

    /// 世代の表示名（日本語）
    var displayName: String {
        if id == 0 {
            return "全国図鑑"
        }
        return "第\(id)世代"
    }

    /// 全国図鑑（全ポケモン・全フォーム）
    static let nationalDex = Generation(
        id: 0,
        name: "national",
        pokemonRange: 1...1302,
        pokedexNames: nil  // すべて表示
    )

    /// 第1世代（カントー地方）
    static let generation1 = Generation(
        id: 1,
        name: "generation-i",
        pokemonRange: 1...151,
        pokedexNames: ["kanto"]
    )

    /// 第2世代（ジョウト地方）
    static let generation2 = Generation(
        id: 2,
        name: "generation-ii",
        pokemonRange: 152...251,
        pokedexNames: ["updated-johto"]
    )

    /// 第3世代（ホウエン地方）
    static let generation3 = Generation(
        id: 3,
        name: "generation-iii",
        pokemonRange: 252...386,
        pokedexNames: ["hoenn"]
    )

    /// 第4世代（シンオウ地方）
    static let generation4 = Generation(
        id: 4,
        name: "generation-iv",
        pokemonRange: 387...493,
        pokedexNames: ["extended-sinnoh"]
    )

    /// 第5世代（イッシュ地方）
    static let generation5 = Generation(
        id: 5,
        name: "generation-v",
        pokemonRange: 494...649,
        pokedexNames: ["updated-unova"]
    )

    /// 第6世代（カロス地方）
    static let generation6 = Generation(
        id: 6,
        name: "generation-vi",
        pokemonRange: 650...721,
        pokedexNames: ["kalos-central", "kalos-coastal", "kalos-mountain"]
    )

    /// 第7世代（アローラ地方）
    static let generation7 = Generation(
        id: 7,
        name: "generation-vii",
        pokemonRange: 722...809,
        pokedexNames: ["updated-alola"]
    )

    /// 第8世代（ガラル地方 + DLC）
    static let generation8 = Generation(
        id: 8,
        name: "generation-viii",
        pokemonRange: 810...905,
        pokedexNames: ["galar", "isle-of-armor", "crown-tundra"]
    )

    /// 第9世代（パルデア地方 + DLC）
    static let generation9 = Generation(
        id: 9,
        name: "generation-ix",
        pokemonRange: 906...1025,
        pokedexNames: ["paldea", "kitakami", "blueberry"]
    )

    /// 全世代リスト
    static let allGenerations: [Generation] = [
        .nationalDex,
        .generation1,
        .generation2,
        .generation3,
        .generation4,
        .generation5,
        .generation6,
        .generation7,
        .generation8,
        .generation9
    ]
}
