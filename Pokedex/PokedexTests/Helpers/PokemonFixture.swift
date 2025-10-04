//
//  PokemonFixture.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import Foundation
@testable import Pokedex

extension Pokemon {
    static func fixture(
        id: Int = 1,
        name: String = "bulbasaur",
        height: Int = 7,
        weight: Int = 69,
        types: [PokemonType] = [.fixture()],
        stats: [PokemonStat] = [.fixture()],
        abilities: [PokemonAbility] = [.fixture()],
        sprites: PokemonSprites = .fixture(),
        moves: [PokemonMove] = [.fixture()]
    ) -> Pokemon {
        Pokemon(
            id: id,
            name: name,
            height: height,
            weight: weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moves
        )
    }
}

extension PokemonType {
    static func fixture(
        slot: Int = 1,
        name: String = "grass"
    ) -> PokemonType {
        PokemonType(slot: slot, name: name)
    }
}

extension PokemonStat {
    static func fixture(
        name: String = "hp",
        baseStat: Int = 45
    ) -> PokemonStat {
        PokemonStat(name: name, baseStat: baseStat)
    }
}

extension PokemonAbility {
    static func fixture(
        name: String = "overgrow",
        isHidden: Bool = false
    ) -> PokemonAbility {
        PokemonAbility(name: name, isHidden: isHidden)
    }
}

extension PokemonSprites {
    static func fixture(
        frontDefault: String? = "https://example.com/1.png",
        frontShiny: String? = "https://example.com/1_shiny.png",
        other: OtherSprites? = nil
    ) -> PokemonSprites {
        PokemonSprites(
            frontDefault: frontDefault,
            frontShiny: frontShiny,
            other: other
        )
    }
}

extension PokemonMove {
    static func fixture(
        name: String = "tackle",
        learnMethod: String = "level-up",
        level: Int? = 1
    ) -> PokemonMove {
        PokemonMove(
            name: name,
            learnMethod: learnMethod,
            level: level
        )
    }
}

extension PokemonSpecies {
    static func fixture(
        id: Int = 1,
        name: String = "bulbasaur",
        evolutionChain: EvolutionChainReference = .fixture()
    ) -> PokemonSpecies {
        PokemonSpecies(
            id: id,
            name: name,
            evolutionChain: evolutionChain
        )
    }
}

extension PokemonSpecies.EvolutionChainReference {
    static func fixture(
        url: String = "https://pokeapi.co/api/v2/evolution-chain/1/"
    ) -> PokemonSpecies.EvolutionChainReference {
        PokemonSpecies.EvolutionChainReference(url: url)
    }
}

extension EvolutionChain {
    static func fixture(
        chain: ChainLink = .fixture()
    ) -> EvolutionChain {
        EvolutionChain(chain: chain)
    }
}

extension EvolutionChain.ChainLink {
    static func fixture(
        species: Species = .fixture(),
        evolvesTo: [EvolutionChain.ChainLink] = []
    ) -> EvolutionChain.ChainLink {
        EvolutionChain.ChainLink(
            species: species,
            evolvesTo: evolvesTo
        )
    }
}

extension EvolutionChain.ChainLink.Species {
    static func fixture(
        name: String = "bulbasaur",
        url: String = "https://pokeapi.co/api/v2/pokemon-species/1/"
    ) -> EvolutionChain.ChainLink.Species {
        EvolutionChain.ChainLink.Species(
            name: name,
            url: url
        )
    }
}
