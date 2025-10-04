//
//  PokemonSpeciesMapper.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation
import PokemonAPI

struct PokemonSpeciesMapper {
    nonisolated static func map(from pkmSpecies: PKMPokemonSpecies) -> PokemonSpecies {
        PokemonSpecies(
            id: pkmSpecies.id ?? 0,
            name: pkmSpecies.name ?? "",
            evolutionChain: PokemonSpecies.EvolutionChainReference(
                url: pkmSpecies.evolutionChain?.url ?? ""
            )
        )
    }
}
