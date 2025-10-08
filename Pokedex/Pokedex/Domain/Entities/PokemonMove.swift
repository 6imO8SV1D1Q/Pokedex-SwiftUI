//
//  PokemonMove.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

struct PokemonMove: Codable, Identifiable, Hashable {
    let id: Int  // 技のID
    let name: String
    let learnMethod: String
    let level: Int?

    var displayName: String {
        name.split(separator: "-")
            .map { $0.capitalized }
            .joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case learnMethod = "learn_method"
        case level
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(learnMethod)
        hasher.combine(level)
    }

    static func == (lhs: PokemonMove, rhs: PokemonMove) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.learnMethod == rhs.learnMethod && lhs.level == rhs.level
    }
}
