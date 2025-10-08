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
    let machineNumber: String?  // TM/HM/TR番号（例: "TM24", "HM03", "TR12"）

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
        case machineNumber = "machine_number"
    }

    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(learnMethod)
        hasher.combine(level)
        hasher.combine(machineNumber)
    }

    static func == (lhs: PokemonMove, rhs: PokemonMove) -> Bool {
        lhs.id == rhs.id && lhs.name == rhs.name && lhs.learnMethod == rhs.learnMethod && lhs.level == rhs.level && lhs.machineNumber == rhs.machineNumber
    }
}
