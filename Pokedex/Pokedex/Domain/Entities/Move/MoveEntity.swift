//
//  MoveEntity.swift
//  Pokedex
//
//  Created on 2025-10-05.
//

import Foundation

/// 技情報を表すEntity
struct MoveEntity: Identifiable, Equatable {
    /// 技のID
    let id: Int
    /// 技の名前（英語）
    let name: String
    /// 技のタイプ
    let type: PokemonType

    /// IDで等価性を判定
    static func == (lhs: MoveEntity, rhs: MoveEntity) -> Bool {
        lhs.id == rhs.id
    }
}
