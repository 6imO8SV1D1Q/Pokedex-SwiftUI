//
//  PokemonRepositoryProtocol.swift
//  Pokedex
//
//  Created on 2025-10-04.
//

import Foundation

protocol PokemonRepositoryProtocol {
    func fetchPokemonList(limit: Int, offset: Int) async throws -> [Pokemon]
    func fetchPokemonDetail(id: Int) async throws -> Pokemon
    func fetchPokemonDetail(name: String) async throws -> Pokemon
}
