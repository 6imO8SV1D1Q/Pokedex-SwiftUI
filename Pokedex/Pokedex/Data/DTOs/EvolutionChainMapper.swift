//
//  EvolutionChainMapper.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import PokemonAPI

struct EvolutionChainMapper {
    nonisolated static func map(from pkmChain: PKMEvolutionChain) -> EvolutionChain {
        EvolutionChain(
            chain: mapChainLink(from: pkmChain.chain)
        )
    }

    private nonisolated static func mapChainLink(from pkmLink: PKMChainLink?) -> EvolutionChain.ChainLink {
        guard let pkmLink = pkmLink else {
            return EvolutionChain.ChainLink(
                species: EvolutionChain.ChainLink.Species(name: "", url: ""),
                evolvesTo: []
            )
        }

        return EvolutionChain.ChainLink(
            species: EvolutionChain.ChainLink.Species(
                name: pkmLink.species?.name ?? "",
                url: pkmLink.species?.url ?? ""
            ),
            evolvesTo: pkmLink.evolvesTo?.map { mapChainLink(from: $0) } ?? []
        )
    }
}
