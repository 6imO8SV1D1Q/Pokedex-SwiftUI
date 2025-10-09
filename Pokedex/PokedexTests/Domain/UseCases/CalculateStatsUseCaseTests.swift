//
//  CalculateStatsUseCaseTests.swift
//  PokedexTests
//
//  Created on 2025-10-09.
//

import XCTest
@testable import Pokedex

final class CalculateStatsUseCaseTests: XCTestCase {
    var sut: CalculateStatsUseCase!

    override func setUp() {
        super.setUp()
        sut = CalculateStatsUseCase()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Test Data

    /// フシギダネの種族値
    private func bulbasaurBaseStats() -> [PokemonStat] {
        return [
            PokemonStat(name: "hp", baseStat: 45),
            PokemonStat(name: "attack", baseStat: 49),
            PokemonStat(name: "defense", baseStat: 49),
            PokemonStat(name: "special-attack", baseStat: 65),
            PokemonStat(name: "special-defense", baseStat: 65),
            PokemonStat(name: "speed", baseStat: 45)
        ]
    }

    // MARK: - Success Cases

    func testExecute_returnsAllFivePatterns() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)

        // Then
        XCTAssertEqual(result.patterns.count, 5, "5パターンが返される")
        XCTAssertEqual(result.patterns[0].id, "ideal", "1番目は理想個体")
        XCTAssertEqual(result.patterns[1].id, "max", "2番目は252")
        XCTAssertEqual(result.patterns[2].id, "neutral", "3番目は無振り")
        XCTAssertEqual(result.patterns[3].id, "min", "4番目は最低")
        XCTAssertEqual(result.patterns[4].id, "hindered", "5番目は下降")
    }

    func testCalculateStats_理想個体_correctValues() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)
        let idealPattern = result.patterns[0]

        // Then: 31-252↑ の実数値を検証
        XCTAssertEqual(idealPattern.displayName, "理想")
        XCTAssertEqual(idealPattern.hp, 152, "HP: ((45*2+31+63)*50)/100+60 = 152")
        XCTAssertEqual(idealPattern.attack, 111, "攻撃: floor((((49*2+31+63)*50)/100+5)*1.1) = floor(101*1.1) = 111")
        XCTAssertEqual(idealPattern.defense, 111, "防御: floor(101*1.1) = 111")
        XCTAssertEqual(idealPattern.specialAttack, 128, "特攻: floor((((65*2+31+63)*50)/100+5)*1.1) = floor(117*1.1) = 128")
        XCTAssertEqual(idealPattern.specialDefense, 128, "特防: floor(117*1.1) = 128")
        XCTAssertEqual(idealPattern.speed, 106, "素早さ: floor((((45*2+31+63)*50)/100+5)*1.1) = floor(97*1.1) = 106")
    }

    func testCalculateStats_252_correctValues() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)
        let maxPattern = result.patterns[1]

        // Then: 31-252 の実数値を検証
        XCTAssertEqual(maxPattern.displayName, "252")
        XCTAssertEqual(maxPattern.hp, 152, "HP: 152")
        XCTAssertEqual(maxPattern.attack, 101, "攻撃: (((49*2+31+63)*50)/100+5)*1.0 = 101")
        XCTAssertEqual(maxPattern.defense, 101, "防御: 101")
        XCTAssertEqual(maxPattern.specialAttack, 117, "特攻: (((65*2+31+63)*50)/100+5)*1.0 = 117")
        XCTAssertEqual(maxPattern.specialDefense, 117, "特防: 117")
        XCTAssertEqual(maxPattern.speed, 97, "素早さ: 97")
    }

    func testCalculateStats_無振り_correctValues() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)
        let neutralPattern = result.patterns[2]

        // Then: 31-0 の実数値を検証
        XCTAssertEqual(neutralPattern.displayName, "無振り")
        XCTAssertEqual(neutralPattern.hp, 120, "HP: ((45*2+31+0)*50)/100+60 = 120")
        XCTAssertEqual(neutralPattern.attack, 69, "攻撃: (((49*2+31+0)*50)/100+5)*1.0 = 69")
        XCTAssertEqual(neutralPattern.defense, 69, "防御: 69")
        XCTAssertEqual(neutralPattern.specialAttack, 85, "特攻: (((65*2+31+0)*50)/100+5)*1.0 = 85")
        XCTAssertEqual(neutralPattern.specialDefense, 85, "特防: 85")
        XCTAssertEqual(neutralPattern.speed, 65, "素早さ: 65")
    }

    func testCalculateStats_最低_correctValues() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)
        let minPattern = result.patterns[3]

        // Then: 0-0 の実数値を検証
        XCTAssertEqual(minPattern.displayName, "最低")
        XCTAssertEqual(minPattern.hp, 105, "HP: ((45*2+0+0)*50)/100+60 = 105")
        XCTAssertEqual(minPattern.attack, 54, "攻撃: (((49*2+0+0)*50)/100+5)*1.0 = 54")
        XCTAssertEqual(minPattern.defense, 54, "防御: 54")
        XCTAssertEqual(minPattern.specialAttack, 70, "特攻: (((65*2+0+0)*50)/100+5)*1.0 = 70")
        XCTAssertEqual(minPattern.specialDefense, 70, "特防: 70")
        XCTAssertEqual(minPattern.speed, 50, "素早さ: 50")
    }

    func testCalculateStats_下降_correctValues() {
        // Given
        let baseStats = bulbasaurBaseStats()

        // When
        let result = sut.execute(baseStats: baseStats)
        let hinderedPattern = result.patterns[4]

        // Then: 0-0↓ の実数値を検証
        XCTAssertEqual(hinderedPattern.displayName, "下降")
        XCTAssertEqual(hinderedPattern.hp, 105, "HP: HPは性格補正なし")
        XCTAssertEqual(hinderedPattern.attack, 48, "攻撃: floor((((49*2+0+0)*50)/100+5)*0.9) = floor(54*0.9) = 48")
        XCTAssertEqual(hinderedPattern.defense, 48, "防御: 48")
        XCTAssertEqual(hinderedPattern.specialAttack, 63, "特攻: floor((((65*2+0+0)*50)/100+5)*0.9) = floor(70*0.9) = 63")
        XCTAssertEqual(hinderedPattern.specialDefense, 63, "特防: 63")
        XCTAssertEqual(hinderedPattern.speed, 45, "素早さ: floor(50*0.9) = 45")
    }

    func testCalculateHP_正しい計算() {
        // Given: 種族値45のHP（フシギダネ）
        let baseStats = [PokemonStat(name: "hp", baseStat: 45)]

        // When
        let result = sut.execute(baseStats: baseStats)

        // Then: 各パターンのHPを検証
        XCTAssertEqual(result.patterns[0].hp, 152, "理想: 31-252")
        XCTAssertEqual(result.patterns[1].hp, 152, "252: 31-252")
        XCTAssertEqual(result.patterns[2].hp, 120, "無振り: 31-0")
        XCTAssertEqual(result.patterns[3].hp, 105, "最低: 0-0")
        XCTAssertEqual(result.patterns[4].hp, 105, "下降: 0-0（HPは性格補正なし）")
    }

    func testCalculateStat_性格補正() {
        // Given: 攻撃種族値49（フシギダネ）
        let baseStats = [
            PokemonStat(name: "hp", baseStat: 45),
            PokemonStat(name: "attack", baseStat: 49),
            PokemonStat(name: "defense", baseStat: 49),
            PokemonStat(name: "special-attack", baseStat: 49),
            PokemonStat(name: "special-defense", baseStat: 49),
            PokemonStat(name: "speed", baseStat: 49)
        ]

        // When
        let result = sut.execute(baseStats: baseStats)

        // Then: 性格補正の影響を検証
        let boosted = result.patterns[0].attack // 1.1倍
        let neutral = result.patterns[1].attack // 1.0倍
        let hindered = result.patterns[4].attack // 0.9倍

        XCTAssertGreaterThan(boosted, neutral, "上昇補正は補正なしより高い")
        XCTAssertGreaterThan(neutral, hindered, "補正なしは下降補正より高い")
    }

    // MARK: - Edge Cases

    func testCalculateStats_emptyStats_returnsZeroValues() {
        // Given
        let emptyStats: [PokemonStat] = []

        // When
        let result = sut.execute(baseStats: emptyStats)

        // Then: 種族値0でも理想個体（31IV/252EV/1.1倍）で計算される
        XCTAssertEqual(result.patterns[0].hp, 107, "HP: ((0*2+31+63)*50)/100+60 = 107")
        XCTAssertEqual(result.patterns[0].attack, 57, "攻撃: floor(((0*2+31+63)*50)/100+5)*1.1 = floor(52*1.1) = 57")
        XCTAssertEqual(result.patterns[0].defense, 57, "防御: 57")
    }

    func testCalculateStats_maximumStats_correctValues() {
        // Given: 全ステータス255（理論上の最大値）
        let maxStats = [
            PokemonStat(name: "hp", baseStat: 255),
            PokemonStat(name: "attack", baseStat: 255),
            PokemonStat(name: "defense", baseStat: 255),
            PokemonStat(name: "special-attack", baseStat: 255),
            PokemonStat(name: "special-defense", baseStat: 255),
            PokemonStat(name: "speed", baseStat: 255)
        ]

        // When
        let result = sut.execute(baseStats: maxStats)
        let idealPattern = result.patterns[0]

        // Then: ((255*2+31+63)*50)/100+60 = 362
        XCTAssertEqual(idealPattern.hp, 362, "HP最大値: ((255*2+31+63)*50)/100+60 = 362")
        XCTAssertGreaterThan(idealPattern.attack, 300, "攻撃最大値は300以上")
    }
}
