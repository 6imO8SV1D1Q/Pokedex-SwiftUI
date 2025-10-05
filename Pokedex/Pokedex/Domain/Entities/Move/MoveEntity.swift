//
//  MoveEntity.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技情報を表すEntity
struct MoveEntity: Identifiable, Equatable {
    let id: Int
    let name: String
    let type: PokemonType

    static func == (lhs: MoveEntity, rhs: MoveEntity) -> Bool {
        lhs.id == rhs.id
    }
}
