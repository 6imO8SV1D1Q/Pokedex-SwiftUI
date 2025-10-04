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

    struct EvolutionChainReference: Codable {
        let url: String

        // URLから進化チェーンIDを取得
        var id: Int? {
            let components = url.split(separator: "/")
            guard let lastComponent = components.last else { return nil }
            return Int(lastComponent)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, name
        case evolutionChain = "evolution_chain"
    }
}
