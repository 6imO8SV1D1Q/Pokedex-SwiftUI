//
//  PokedexModel.swift
//  Pokedex
//
//  SwiftData persistence model for Pokedex data
//

import Foundation
import SwiftData

@Model
final class PokedexModel {
    @Attribute(.unique) var name: String
    var speciesIds: [Int]

    init(name: String, speciesIds: [Int]) {
        self.name = name
        self.speciesIds = speciesIds
    }
}
