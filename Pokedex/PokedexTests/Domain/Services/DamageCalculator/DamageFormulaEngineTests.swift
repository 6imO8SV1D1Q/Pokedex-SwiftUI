//
//  DamageFormulaEngineTests.swift
//  PokedexTests
//
//  Created on 2025-11-01.
//

import XCTest
@testable import Pokedex

final class DamageFormulaEngineTests: XCTestCase {

    // MARK: - Stat Calculation Tests

    func test_calculateStat_level50_baseAttack_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 31,
            ev: 252,
            nature: 1.1,  // Adamant/Jolly
            statStage: 0
        )

        // Expected: floor(floor((2 * 100 + 31 + 252/4) * 50 / 100 + 5) * 1.1) = 167
        XCTAssertEqual(result, 167)
    }

    func test_calculateStat_level100_baseDefense_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 100,
            iv: 31,
            ev: 252,
            nature: 1.1,  // Bold/Calm
            statStage: 0
        )

        // Expected: floor(floor((2 * 100 + 31 + 252/4) * 100 / 100 + 5) * 1.1) = 319
        XCTAssertEqual(result, 319)
    }

    func test_calculateStat_withStatStageBoost_appliesMultiplier() {
        let baseStat = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 31,
            ev: 0,
            nature: 1.0,
            statStage: 0
        )

        let boostedStat = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 31,
            ev: 0,
            nature: 1.0,
            statStage: 1  // +1 = 1.5x
        )

        XCTAssertEqual(boostedStat, Int(Double(baseStat) * 1.5))
    }

    func test_calculateStat_withStatStageDebuff_appliesMultiplier() {
        let baseStat = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 31,
            ev: 0,
            nature: 1.0,
            statStage: 0
        )

        let debuffedStat = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 31,
            ev: 0,
            nature: 1.0,
            statStage: -1  // -1 = 0.67x
        )

        XCTAssertEqual(debuffedStat, Int(Double(baseStat) * 0.67))
    }

    func test_calculateStat_minIVAndEV_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateStat(
            base: 100,
            level: 50,
            iv: 0,
            ev: 0,
            nature: 1.0,
            statStage: 0
        )

        // Expected: floor((2 * 100 + 0 + 0) * 50 / 100 + 5) = 105
        XCTAssertEqual(result, 105)
    }

    // MARK: - HP Calculation Tests

    func test_calculateHP_level50_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateHP(
            base: 100,
            level: 50,
            iv: 31,
            ev: 252
        )

        // Expected: floor((2 * 100 + 31 + 252/4) * 50 / 100 + 10 + 50) = 207
        XCTAssertEqual(result, 207)
    }

    func test_calculateHP_level100_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateHP(
            base: 100,
            level: 100,
            iv: 31,
            ev: 252
        )

        // Expected: floor((2 * 100 + 31 + 252/4) * 100 / 100 + 10 + 100) = 404
        XCTAssertEqual(result, 404)
    }

    func test_calculateHP_minStats_calculatesCorrectly() {
        let result = DamageFormulaEngine.calculateHP(
            base: 100,
            level: 50,
            iv: 0,
            ev: 0
        )

        // Expected: floor((2 * 100 + 0 + 0) * 50 / 100 + 10 + 50) = 160
        XCTAssertEqual(result, 160)
    }

    func test_calculateHP_shedinja_returns1() {
        let result = DamageFormulaEngine.calculateHP(
            base: 1,  // Shedinja has base HP of 1
            level: 50,
            iv: 31,
            ev: 252
        )

        // Shedinja always has 1 HP
        XCTAssertEqual(result, 1)
    }

    // MARK: - STAB Calculation Tests

    func test_calculateSTAB_matchingType_returns1_5() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "fire",
            pokemonTypes: ["fire", "flying"],
            isTerastallized: false,
            teraType: nil
        )

        XCTAssertEqual(stab, 1.5, accuracy: 0.001)
    }

    func test_calculateSTAB_nonMatchingType_returns1_0() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "water",
            pokemonTypes: ["fire", "flying"],
            isTerastallized: false,
            teraType: nil
        )

        XCTAssertEqual(stab, 1.0, accuracy: 0.001)
    }

    func test_calculateSTAB_terastallized_matchingOriginalType_returns2_0() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "fire",
            pokemonTypes: ["fire", "flying"],
            isTerastallized: true,
            teraType: "fire"
        )

        XCTAssertEqual(stab, 2.0, accuracy: 0.001)
    }

    func test_calculateSTAB_terastallized_matchingTeraType_returns1_5() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "water",
            pokemonTypes: ["fire", "flying"],
            isTerastallized: true,
            teraType: "water"
        )

        XCTAssertEqual(stab, 1.5, accuracy: 0.001)
    }

    func test_calculateSTAB_terastallized_nonMatchingType_returns1_0() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "grass",
            pokemonTypes: ["fire", "flying"],
            isTerastallized: true,
            teraType: "water"
        )

        XCTAssertEqual(stab, 1.0, accuracy: 0.001)
    }

    func test_calculateSTAB_withOgerponBonus_applies1_2Multiplier() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "water",
            pokemonTypes: ["grass", "water"],
            isTerastallized: false,
            teraType: nil,
            ogerponMaskBonus: 1.2
        )

        // 1.5 (STAB) * 1.2 (Ogerpon mask) = 1.8
        XCTAssertEqual(stab, 1.8, accuracy: 0.001)
    }

    func test_calculateSTAB_withOgerponBonus_terastallized_applies1_3Multiplier() {
        let stab = DamageFormulaEngine.calculateSTAB(
            moveType: "water",
            pokemonTypes: ["grass", "water"],
            isTerastallized: true,
            teraType: "water",
            ogerponMaskBonus: 1.3
        )

        // 2.0 (Tera STAB matching original) * 1.3 (Ogerpon mask tera) = 2.6
        XCTAssertEqual(stab, 2.6, accuracy: 0.001)
    }

    // MARK: - Damage Calculation Tests

    func test_calculateDamage_returns16Values() {
        let modifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let damageRange = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: modifiers
        )

        XCTAssertEqual(damageRange.count, 16)
    }

    func test_calculateDamage_valuesAreInAscendingOrder() {
        let modifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let damageRange = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: modifiers
        )

        for i in 0..<(damageRange.count - 1) {
            XCTAssertLessThanOrEqual(damageRange[i], damageRange[i + 1])
        }
    }

    func test_calculateDamage_minDamageIs85Percent() {
        let modifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let damageRange = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: modifiers
        )

        let minDamage = damageRange.first!
        let maxDamage = damageRange.last!

        // Min damage should be approximately 85% of max damage
        let ratio = Double(minDamage) / Double(maxDamage)
        XCTAssertGreaterThanOrEqual(ratio, 0.84)
        XCTAssertLessThanOrEqual(ratio, 0.86)
    }

    func test_calculateDamage_withSTAB_increasesValues() {
        let noStabModifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let stabModifiers = DamageModifiers(
            stab: 1.5,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let noStabDamage = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: noStabModifiers
        )

        let stabDamage = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: stabModifiers
        )

        // STAB damage should be approximately 1.5x
        let ratio = Double(stabDamage.last!) / Double(noStabDamage.last!)
        XCTAssertGreaterThanOrEqual(ratio, 1.4)
        XCTAssertLessThanOrEqual(ratio, 1.6)
    }

    func test_calculateDamage_withSuperEffective_doubles() {
        let normalModifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 1.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let superEffectiveModifiers = DamageModifiers(
            stab: 1.0,
            typeEffectiveness: 2.0,
            weather: 1.0,
            terrain: 1.0,
            screen: 1.0,
            item: 1.0,
            other: 1.0
        )

        let normalDamage = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: normalModifiers
        )

        let superEffectiveDamage = DamageFormulaEngine.calculateDamage(
            attackerLevel: 50,
            movePower: 80,
            attackStat: 150,
            defenseStat: 100,
            modifiers: superEffectiveModifiers
        )

        // Super effective should be approximately 2x
        let ratio = Double(superEffectiveDamage.last!) / Double(normalDamage.last!)
        XCTAssertGreaterThanOrEqual(ratio, 1.9)
        XCTAssertLessThanOrEqual(ratio, 2.1)
    }
}
