//
//  MoveModel.swift
//  Pokedex
//
//  SwiftData persistence model for Moves
//

import Foundation
import SwiftData

// MARK: - Move Model

@Model
final class MoveModel {
    // MARK: - Basic Info

    @Attribute(.unique) var id: Int
    var name: String
    var nameJa: String

    // MARK: - Type & Category

    var type: String
    var damageClass: String  // physical/special/status

    // MARK: - Stats

    var power: Int?
    var accuracy: Int?
    var pp: Int
    var priority: Int
    var effectChance: Int?

    // MARK: - Effect

    var effect: String
    var effectJa: String

    // MARK: - Categories (v4.0 Phase 3)

    var categories: [String]  // ["sound", "punch", "dance"]

    // MARK: - Target (v4.0 Phase 4)

    var target: String  // "selected-pokemon", "user", "all-opponents", etc.

    // MARK: - Meta

    @Relationship(deleteRule: .cascade) var meta: MoveMetaModel?

    init(
        id: Int,
        name: String,
        nameJa: String,
        type: String,
        damageClass: String,
        power: Int? = nil,
        accuracy: Int? = nil,
        pp: Int,
        priority: Int,
        effectChance: Int? = nil,
        effect: String,
        effectJa: String,
        categories: [String] = [],
        target: String = "selected-pokemon",
        meta: MoveMetaModel? = nil
    ) {
        self.id = id
        self.name = name
        self.nameJa = nameJa
        self.type = type
        self.damageClass = damageClass
        self.power = power
        self.accuracy = accuracy
        self.pp = pp
        self.priority = priority
        self.effectChance = effectChance
        self.effect = effect
        self.effectJa = effectJa
        self.categories = categories
        self.target = target
        self.meta = meta
    }
}

// MARK: - Move Meta Model

@Model
final class MoveMetaModel {
    var ailment: String
    var ailmentChance: Int
    var category: String
    var critRate: Int
    var drain: Int
    var flinchChance: Int
    var healing: Int
    var statChance: Int
    var statChanges: [MoveStatChange]

    init(
        ailment: String,
        ailmentChance: Int,
        category: String,
        critRate: Int,
        drain: Int,
        flinchChance: Int,
        healing: Int,
        statChance: Int,
        statChanges: [MoveStatChange] = []
    ) {
        self.ailment = ailment
        self.ailmentChance = ailmentChance
        self.category = category
        self.critRate = critRate
        self.drain = drain
        self.flinchChance = flinchChance
        self.healing = healing
        self.statChance = statChance
        self.statChanges = statChanges
    }
}

// MARK: - Move Stat Change

struct MoveStatChange: Codable {
    var stat: String
    var change: Int

    init(stat: String, change: Int) {
        self.stat = stat
        self.change = change
    }
}
