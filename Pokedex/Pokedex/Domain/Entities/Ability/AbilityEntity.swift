//
//  AbilityEntity.swift
//  Pokedex
//
//  Created on 2025-10-11.
//

import Foundation

/// 特性情報を表すEntity
struct AbilityEntity: Identifiable, Equatable, Hashable {
    /// 特性のID
    let id: Int
    /// 特性の名前（英語、ケバブケース）
    let name: String
    /// 特性の名前（日本語）
    let nameJa: String

    /// IDで等価性を判定
    static func == (lhs: AbilityEntity, rhs: AbilityEntity) -> Bool {
        lhs.id == rhs.id
    }

    /// ハッシュ値はIDで計算
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
