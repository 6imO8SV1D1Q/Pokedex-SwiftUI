//
//  PokemonRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func fetchPokemonList(limit: Int, offset: Int, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon]
    func fetchPokemonList(versionGroup: VersionGroup, progressHandler: ((Double) -> Void)?) async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonDetail(name: String) async throws -> Pokemon
    func fetchPokemonSpecies(id: Int) async throws -> PokemonSpecies
    func fetchEvolutionChain(id: Int) async throws -> EvolutionChain
    func clearCache()
}
