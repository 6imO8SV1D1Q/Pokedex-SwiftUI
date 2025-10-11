//
//  PokemonFixture.swift
//  PokedexTests
//
//  Created on 2025-10-04.
//

import Foundation
@testable import Pokedex

struct PokemonFixture {
    static let pikachu = Pokemon.fixture(
        id: 25,
        speciesId: 25,
        name: "pikachu",
        types: [PokemonType(slot: 1, name: "electric")]
    )

    static let charizard = Pokemon.fixture(
        id: 6,
        speciesId: 6,
        name: "charizard",
        types: [PokemonType(slot: 1, name: "fire"), PokemonType(slot: 2, name: "flying")]
    )
}

extension Pokemon {
    static func fixture(
        id: Int = 1,
        speciesId: Int = 1,
        name: String = "bulbasaur",
        height: Int = 7,
        weight: Int = 69,
        types: [PokemonType] = [.fixture()],
        stats: [PokemonStat] = [.fixture()],
        abilities: [PokemonAbility] = [.fixture()],
        sprites: PokemonSprites = .fixture(),
        moves: [PokemonMove] = [.fixture()],
        availableGenerations: [Int] = [1]
    ) -> Pokemon {
        Pokemon(
            id: id,
            speciesId: speciesId,
            name: name,
            height: height,
            weight: weight,
            types: types,
            stats: stats,
            abilities: abilities,
            sprites: sprites,
            moves: moves,
            availableGenerations: availableGenerations
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
        id: Int = 1,
        name: String = "tackle",
        learnMethod: String = "level-up",
        level: Int? = 1,
        machineNumber: String? = nil
    ) -> PokemonMove {
        PokemonMove(
            id: id,
            name: name,
            learnMethod: learnMethod,
            level: level,
            machineNumber: machineNumber
        )
    }
}

extension PokemonSpecies {
    static func fixture(
        id: Int = 1,
        name: String = "bulbasaur",
        evolutionChain: EvolutionChainReference = .fixture(),
        genderRate: Int = 1,
        eggGroups: [EggGroup] = [.fixture()]
    ) -> PokemonSpecies {
        PokemonSpecies(
            id: id,
            name: name,
            evolutionChain: evolutionChain,
            genderRate: genderRate,
            eggGroups: eggGroups
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

extension PokemonSpecies.EggGroup {
    static func fixture(
        name: String = "monster"
    ) -> PokemonSpecies.EggGroup {
        PokemonSpecies.EggGroup(name: name)
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

extension MoveEntity {
    static func fixture(
        id: Int = 1,
        name: String = "tackle",
        type: PokemonType = .fixture(name: "normal"),
        power: Int? = 40,
        accuracy: Int? = 100,
        pp: Int? = 35,
        damageClass: String = "physical",
        effect: String? = "Inflicts regular damage with no additional effect.",
        machineNumber: String? = nil,
        categories: [String] = []
    ) -> MoveEntity {
        MoveEntity(
            id: id,
            name: name,
            type: type,
            power: power,
            accuracy: accuracy,
            pp: pp,
            damageClass: damageClass,
            effect: effect,
            machineNumber: machineNumber,
            categories: categories
        )
    }
}
