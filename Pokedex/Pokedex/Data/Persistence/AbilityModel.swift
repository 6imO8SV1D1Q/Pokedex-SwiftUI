//
//  AbilityModel.swift
//  Pokedex
//
//  SwiftData persistence model for Abilities
//

import Foundation
import SwiftData

// MARK: - Ability Model

@Model
final class AbilityModel {
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int
    var name: String
    var nameJa: String

    // MARK: - Effect

    var effect: String
    var effectJa: String

    init(
        id: Int,
        name: String,
        nameJa: String,
        effect: String,
        effectJa: String
    ) {
        self.id = id
        self.name = name
        self.nameJa = nameJa
        self.effect = effect
        self.effectJa = effectJa
    }
}
