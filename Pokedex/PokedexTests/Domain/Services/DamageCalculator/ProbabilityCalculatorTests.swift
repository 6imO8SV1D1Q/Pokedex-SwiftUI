//
//  ProbabilityCalculatorTests.swift
//  PokedexTests
//
//  Created on 2025-11-01.
//

import XCTest
@testable import Pokedex

final class ProbabilityCalculatorTests: XCTestCase {

    // MARK: - KO Probability Tests

    func test_calculateKOProbability_allDamageKills_returns100Percent() {
        let damageRange = Array(repeating: 100, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateKOProbability(
            damageRange: damageRange,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    func test_calculateKOProbability_noDamageKills_returns0Percent() {
        let damageRange = Array(repeating: 10, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateKOProbability(
            damageRange: damageRange,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 0.0, accuracy: 0.001)
    }

    func test_calculateKOProbability_halfDamageKills_returns50Percent() {
        let damageRange = [50, 50, 50, 50, 50, 50, 50, 50, 40, 40, 40, 40, 40, 40, 40, 40]
        let targetHP = 45

        let probability = ProbabilityCalculator.calculateKOProbability(
            damageRange: damageRange,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 0.5, accuracy: 0.001)
    }

    func test_calculateKOProbability_singleHitKills_returnsCorrectProbability() {
        let damageRange = [100, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50, 50]
        let targetHP = 60

        let probability = ProbabilityCalculator.calculateKOProbability(
            damageRange: damageRange,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 1.0 / 16.0, accuracy: 0.001)
    }

    // MARK: - Two-Turn KO Probability Tests

    func test_calculateTwoTurnKOProbability_allCombinationsKill_returns100Percent() {
        let firstTurnDamage = Array(repeating: 30, count: 16)
        let secondTurnDamage = Array(repeating: 30, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateTwoTurnKOProbability(
            firstTurnDamage: firstTurnDamage,
            secondTurnDamage: secondTurnDamage,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    func test_calculateTwoTurnKOProbability_noCombinationKills_returns0Percent() {
        let firstTurnDamage = Array(repeating: 10, count: 16)
        let secondTurnDamage = Array(repeating: 10, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateTwoTurnKOProbability(
            firstTurnDamage: firstTurnDamage,
            secondTurnDamage: secondTurnDamage,
            targetHP: targetHP
        )

        XCTAssertEqual(probability, 0.0, accuracy: 0.001)
    }

    func test_calculateTwoTurnKOProbability_withAccuracy_appliesHitChance() {
        let firstTurnDamage = Array(repeating: 30, count: 16)
        let secondTurnDamage = Array(repeating: 30, count: 16)
        let targetHP = 50
        let hitChance = 0.9

        let probability = ProbabilityCalculator.calculateTwoTurnKOProbability(
            firstTurnDamage: firstTurnDamage,
            secondTurnDamage: secondTurnDamage,
            targetHP: targetHP,
            hitChance: hitChance
        )

        // Expected: 1.0 * 0.9 * 0.9 = 0.81
        XCTAssertEqual(probability, 0.81, accuracy: 0.001)
    }

    func test_calculateTwoTurnKOProbability_mixedDamage_calculatesCorrectly() {
        // First turn: 25 damage
        // Second turn: 26 damage
        // Target HP: 50
        // Only combinations where first + second >= 50 count as KO
        let firstTurnDamage = Array(repeating: 25, count: 16)
        let secondTurnDamage = Array(repeating: 26, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateTwoTurnKOProbability(
            firstTurnDamage: firstTurnDamage,
            secondTurnDamage: secondTurnDamage,
            targetHP: targetHP
        )

        // 25 + 26 = 51 >= 50, so all 256 combinations kill
        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    // MARK: - N-Turn KO Probability Tests

    func test_calculateNTurnKOProbability_oneTurn_matchesSingleKOProbability() {
        let damageRange = Array(repeating: 50, count: 16)
        let targetHP = 45

        let nTurnProb = ProbabilityCalculator.calculateNTurnKOProbability(
            damageRange: damageRange,
            targetHP: targetHP,
            turns: 1
        )

        let singleProb = ProbabilityCalculator.calculateKOProbability(
            damageRange: damageRange,
            targetHP: targetHP
        )

        XCTAssertEqual(nTurnProb, singleProb, accuracy: 0.001)
    }

    func test_calculateNTurnKOProbability_twoTurns_allCombinationsKill() {
        let damageRange = Array(repeating: 30, count: 16)
        let targetHP = 50

        let probability = ProbabilityCalculator.calculateNTurnKOProbability(
            damageRange: damageRange,
            targetHP: targetHP,
            turns: 2
        )

        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    func test_calculateNTurnKOProbability_zeroTurns_returns0() {
        let damageRange = Array(repeating: 50, count: 16)
        let targetHP = 45

        let probability = ProbabilityCalculator.calculateNTurnKOProbability(
            damageRange: damageRange,
            targetHP: targetHP,
            turns: 0
        )

        XCTAssertEqual(probability, 0.0, accuracy: 0.001)
    }

    func test_calculateNTurnKOProbability_threeTurns_calculatesCorrectly() {
        let damageRange = Array(repeating: 20, count: 16)
        let targetHP = 55

        // Each turn does 20 damage
        // 1 turn: 20 < 55 → 0% KO
        // 2 turns: 40 < 55 → 0% KO
        // 3 turns: 60 >= 55 → 100% KO

        let probability = ProbabilityCalculator.calculateNTurnKOProbability(
            damageRange: damageRange,
            targetHP: targetHP,
            turns: 3
        )

        XCTAssertEqual(probability, 1.0, accuracy: 0.001)
    }

    // MARK: - Average Damage Tests

    func test_calculateAverageDamage_uniformDamage_returnsValue() {
        let damageRange = Array(repeating: 50, count: 16)

        let average = ProbabilityCalculator.calculateAverageDamage(damageRange: damageRange)

        XCTAssertEqual(average, 50.0, accuracy: 0.001)
    }

    func test_calculateAverageDamage_mixedDamage_calculatesCorrectly() {
        let damageRange = [85, 87, 90, 92, 95, 97, 100, 102, 85, 87, 90, 92, 95, 97, 100, 102]

        let expected = Double(85 + 87 + 90 + 92 + 95 + 97 + 100 + 102 + 85 + 87 + 90 + 92 + 95 + 97 + 100 + 102) / 16.0

        let average = ProbabilityCalculator.calculateAverageDamage(damageRange: damageRange)

        XCTAssertEqual(average, expected, accuracy: 0.001)
    }

    func test_calculateAverageDamage_emptyRange_returns0() {
        let damageRange: [Int] = []

        let average = ProbabilityCalculator.calculateAverageDamage(damageRange: damageRange)

        XCTAssertTrue(average.isNaN)
    }

    // MARK: - Damage Distribution Tests

    func test_calculateDamageDistribution_uniformDamage_returnsSingleEntry() {
        let damageRange = Array(repeating: 50, count: 16)

        let distribution = ProbabilityCalculator.calculateDamageDistribution(damageRange: damageRange)

        XCTAssertEqual(distribution.count, 1)
        XCTAssertEqual(distribution[50], 1.0, accuracy: 0.001)
    }

    func test_calculateDamageDistribution_twoDifferentValues_returnsCorrectDistribution() {
        let damageRange = Array(repeating: 50, count: 8) + Array(repeating: 60, count: 8)

        let distribution = ProbabilityCalculator.calculateDamageDistribution(damageRange: damageRange)

        XCTAssertEqual(distribution.count, 2)
        XCTAssertEqual(distribution[50], 0.5, accuracy: 0.001)
        XCTAssertEqual(distribution[60], 0.5, accuracy: 0.001)
    }

    func test_calculateDamageDistribution_multipleDifferentValues_calculatesCorrectly() {
        let damageRange = [85, 85, 85, 85, 90, 90, 90, 90, 95, 95, 95, 95, 100, 100, 100, 100]

        let distribution = ProbabilityCalculator.calculateDamageDistribution(damageRange: damageRange)

        XCTAssertEqual(distribution.count, 4)
        XCTAssertEqual(distribution[85], 0.25, accuracy: 0.001)
        XCTAssertEqual(distribution[90], 0.25, accuracy: 0.001)
        XCTAssertEqual(distribution[95], 0.25, accuracy: 0.001)
        XCTAssertEqual(distribution[100], 0.25, accuracy: 0.001)
    }

    func test_calculateDamageDistribution_emptyRange_returnsEmptyDictionary() {
        let damageRange: [Int] = []

        let distribution = ProbabilityCalculator.calculateDamageDistribution(damageRange: damageRange)

        XCTAssertTrue(distribution.isEmpty)
    }
}
