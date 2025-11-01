//
//  BattleModifierResolver.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// バトル補正計算
struct BattleModifierResolver {

    /// 補正倍率を計算
    /// - Parameters:
    ///   - battleState: バトル状態
    ///   - moveType: 技のタイプ
    ///   - isPhysical: 物理技か
    ///   - attackerItem: 攻撃側のアイテム
    ///   - isSpreadMove: 範囲技か（ダブルバトル用）
    /// - Returns: 補正倍率
    static func resolveModifiers(
        battleState: BattleState,
        moveType: String,
        isPhysical: Bool,
        attackerItem: ItemEntity?,
        isSpreadMove: Bool = false
    ) -> DamageModifiers {
        let stab = resolveSTAB(
            moveType: moveType,
            attacker: battleState.attacker
        )

        let typeEffectiveness = resolveTypeEffectiveness(
            moveType: moveType,
            defenderTypes: battleState.defender.isTerastallized
                ? [battleState.defender.teraType].compactMap { $0 }
                : battleState.defender.baseTypes
        )

        let weather = resolveWeatherModifier(
            weather: battleState.environment.weather,
            moveType: moveType
        )

        let terrain = resolveTerrainModifier(
            terrain: battleState.environment.terrain,
            moveType: moveType
        )

        let screen = resolveScreenModifier(
            screen: battleState.environment.screen,
            isPhysical: isPhysical,
            isDouble: battleState.mode == .double
        )

        let item = resolveItemModifier(
            item: attackerItem,
            moveType: moveType,
            attacker: battleState.attacker
        )

        // ダブルバトルの範囲技補正
        let doubleBattleModifier = resolveDoubleBattleModifier(
            mode: battleState.mode,
            isSpreadMove: isSpreadMove
        )

        return DamageModifiers(
            stab: stab,
            typeEffectiveness: typeEffectiveness,
            weather: weather,
            terrain: terrain,
            screen: screen,
            item: item,
            other: doubleBattleModifier
        )
    }

    // MARK: - Private Methods

    private static func resolveSTAB(
        moveType: String,
        attacker: BattleParticipantState
    ) -> Double {
        // オーガポンマスク補正を計算
        var ogerponBonus = 1.0

        // TODO: オーガポン判定とマスク補正
        // 現時点では簡素化

        return DamageFormulaEngine.calculateSTAB(
            moveType: moveType,
            pokemonTypes: attacker.baseTypes,
            isTerastallized: attacker.isTerastallized,
            teraType: attacker.teraType,
            ogerponMaskBonus: ogerponBonus
        )
    }

    private static func resolveTypeEffectiveness(
        moveType: String,
        defenderTypes: [String]
    ) -> Double {
        // TODO: TypeRepositoryから相性倍率を取得
        // 現時点では簡素化して1.0（等倍）を返す
        return 1.0
    }

    private static func resolveWeatherModifier(
        weather: WeatherCondition?,
        moveType: String
    ) -> Double {
        guard let weather = weather else { return 1.0 }

        switch weather {
        case .sun:
            if moveType.lowercased() == "fire" {
                return 1.5
            } else if moveType.lowercased() == "water" {
                return 0.5
            }
        case .rain:
            if moveType.lowercased() == "water" {
                return 1.5
            } else if moveType.lowercased() == "fire" {
                return 0.5
            }
        case .sandstorm, .snow:
            break
        case .none:
            break
        }

        return 1.0
    }

    private static func resolveTerrainModifier(
        terrain: TerrainField?,
        moveType: String
    ) -> Double {
        guard let terrain = terrain else { return 1.0 }

        switch terrain {
        case .electric:
            if moveType.lowercased() == "electric" {
                return 1.3
            }
        case .grassy:
            if moveType.lowercased() == "grass" {
                return 1.3
            }
        case .psychic:
            if moveType.lowercased() == "psychic" {
                return 1.3
            }
        case .misty:
            if moveType.lowercased() == "dragon" {
                return 0.5
            }
        case .none:
            break
        }

        return 1.0
    }

    private static func resolveScreenModifier(
        screen: ScreenEffect?,
        isPhysical: Bool,
        isDouble: Bool
    ) -> Double {
        guard let screen = screen else { return 1.0 }
        return screen.damageReduction(isDouble: isDouble, isPhysical: isPhysical)
    }

    private static func resolveItemModifier(
        item: ItemEntity?,
        moveType: String,
        attacker: BattleParticipantState
    ) -> Double {
        guard let item = item,
              let damageEffect = item.effects?.damageMultiplier else {
            return 1.0
        }

        // 条件チェック
        switch damageEffect.condition {
        case "all_damaging_moves":
            return damageEffect.baseMultiplier

        case "same_type_as_mask":
            // オーガポンマスク
            if let types = damageEffect.types,
               types.contains(where: { $0.lowercased() == moveType.lowercased() }) {
                if attacker.isTerastallized {
                    return damageEffect.teraMultiplier ?? damageEffect.baseMultiplier
                } else {
                    return damageEffect.baseMultiplier
                }
            }

        case "super_effective":
            // TODO: タイプ相性判定が必要
            break

        default:
            break
        }

        return 1.0
    }

    private static func resolveDoubleBattleModifier(
        mode: BattleMode,
        isSpreadMove: Bool
    ) -> Double {
        if mode == .double && isSpreadMove {
            return 0.75  // ダブルバトルの範囲技は0.75倍
        }
        return 1.0
    }
}
