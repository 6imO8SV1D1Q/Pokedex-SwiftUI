//
//  EvolutionChain.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

struct EvolutionChain: Codable {
    let chain: ChainLink

    struct ChainLink: Codable {
        let species: Species
        let evolvesTo: [ChainLink]

        struct Species: Codable {
            let name: String
            let url: String

            // URLからIDを取得
            var id: Int? {
                let components = url.split(separator: "/")
                guard let lastComponent = components.last else { return nil }
                return Int(lastComponent)
            }
        }

        enum CodingKeys: String, CodingKey {
            case species
            case evolvesTo = "evolves_to"
        }
    }
}
