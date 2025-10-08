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
        // たまごグループのマッピング
        let eggGroups: [PokemonSpecies.EggGroup] = (pkmSpecies.eggGroups ?? []).compactMap { group in
            guard let name = group.name else { return nil }
            return PokemonSpecies.EggGroup(name: name)
        }

        return PokemonSpecies(
            id: pkmSpecies.id ?? 0,
            name: pkmSpecies.name ?? "",
            evolutionChain: PokemonSpecies.EvolutionChainReference(
                url: pkmSpecies.evolutionChain?.url ?? ""
            ),
            genderRate: pkmSpecies.genderRate ?? -1,
            eggGroups: eggGroups
        )
    }
}
