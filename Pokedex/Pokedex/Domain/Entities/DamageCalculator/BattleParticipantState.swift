//
//  BattleParticipantState.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// バトル参加者（攻撃側/防御側）の状態
struct BattleParticipantState: Equatable, Codable {
    /// ポケモンID（nil = 未選択）
    var pokemonId: Int?

    /// ポケモン名（表示用）
    var pokemonName: String?

    /// レベル（1-100）
    var level: Int

    /// 努力値
    var effortValues: EffortValueSet

    /// 個体値
    var individualValues: IndividualValueSet

    /// ランク補正
    var statStages: StatStageSet

    /// 特性ID（nil = 未選択）
    var abilityId: Int?

    /// 持ち物ID（nil = なし）
    var heldItemId: Int?

    /// 通常タイプ
    var baseTypes: [String]

    /// テラスタイプ（nil = 未選択）
    var teraType: String?

    /// テラスタル状態
    var isTerastallized: Bool

    /// デフォルト値でイニシャライズ
    init(
        pokemonId: Int? = nil,
        pokemonName: String? = nil,
        level: Int = 50,
        effortValues: EffortValueSet = .init(),
        individualValues: IndividualValueSet = .max,
        statStages: StatStageSet = .init(),
        abilityId: Int? = nil,
        heldItemId: Int? = nil,
        baseTypes: [String] = [],
        teraType: String? = nil,
        isTerastallized: Bool = false
    ) {
        self.pokemonId = pokemonId
        self.pokemonName = pokemonName
        self.level = level
        self.effortValues = effortValues
        self.individualValues = individualValues
        self.statStages = statStages
        self.abilityId = abilityId
        self.heldItemId = heldItemId
        self.baseTypes = baseTypes
        self.teraType = teraType
        self.isTerastallized = isTerastallized
    }
}

// MARK: - Effort Values

/// 努力値セット
struct EffortValueSet: Equatable, Codable {
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    /// デフォルト（全て0）
    init(
        hp: Int = 0,
        attack: Int = 0,
        defense: Int = 0,
        specialAttack: Int = 0,
        specialDefense: Int = 0,
        speed: Int = 0
    ) {
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
    }

    /// 合計努力値（最大510）
    var total: Int {
        hp + attack + defense + specialAttack + specialDefense + speed
    }

    /// 努力値が有効か（合計510以下、各値252以下）
    var isValid: Bool {
        total <= 510 && [hp, attack, defense, specialAttack, specialDefense, speed].allSatisfy { $0 <= 252 }
    }
}

// MARK: - Individual Values

/// 個体値セット
struct IndividualValueSet: Equatable, Codable {
    var hp: Int
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    /// デフォルト（全て31）
    init(
        hp: Int = 31,
        attack: Int = 31,
        defense: Int = 31,
        specialAttack: Int = 31,
        specialDefense: Int = 31,
        speed: Int = 31
    ) {
        self.hp = hp
        self.attack = attack
        self.defense = defense
        self.specialAttack = specialAttack
        self.specialDefense = specialDefense
        self.speed = speed
    }

    /// 最大個体値（31-31-31-31-31-31）
    static var max: IndividualValueSet {
        .init()
    }

    /// 最低個体値（0-0-0-0-0-0）
    static var min: IndividualValueSet {
        .init(hp: 0, attack: 0, defense: 0, specialAttack: 0, specialDefense: 0, speed: 0)
    }
}

// MARK: - Stat Stages

/// ランク補正セット（-6 ~ +6）
struct StatStageSet: Equatable, Codable {
    var attack: Int
    var defense: Int
    var specialAttack: Int
    var specialDefense: Int
    var speed: Int

    /// デフォルト（全て0）
    init(
        attack: Int = 0,
        defense: Int = 0,
        specialAttack: Int = 0,
        specialDefense: Int = 0,
        speed: Int = 0
    ) {
        self.attack = max(-6, min(6, attack))
        self.defense = max(-6, min(6, defense))
        self.specialAttack = max(-6, min(6, specialAttack))
        self.specialDefense = max(-6, min(6, specialDefense))
        self.speed = max(-6, min(6, speed))
    }

    /// ランク補正を倍率に変換
    /// - Parameter stage: ランク（-6 ~ +6）
    /// - Returns: 倍率
    static func multiplier(for stage: Int) -> Double {
        let clamped = max(-6, min(6, stage))
        if clamped >= 0 {
            return Double(2 + clamped) / 2.0
        } else {
            return 2.0 / Double(2 - clamped)
        }
    }
}
