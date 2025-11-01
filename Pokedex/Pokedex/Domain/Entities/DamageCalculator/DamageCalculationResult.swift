//
//  DamageCalculationResult.swift
//  Pokedex
//
//  Created on 2025-11-01.
//

import Foundation

/// ダメージ計算結果
struct DamageCalculationResult: Equatable {
    /// 最小ダメージ
    let minDamage: Int

    /// 最大ダメージ
    let maxDamage: Int

    /// 全16通りのダメージ値
    let damageRange: [Int]

    /// 撃破確率（0.0 ~ 1.0）
    let koChance: Double

    /// 確定数（何発で倒せるか）
    let hitsToKO: Int

    /// 防御側の最大HP
    let defenderMaxHP: Int

    /// 計算に使用した各種倍率
    let modifiers: DamageModifiers
}

/// ダメージ計算に使用した倍率
struct DamageModifiers: Equatable {
    /// タイプ一致補正（STAB）
    let stab: Double

    /// タイプ相性倍率
    let typeEffectiveness: Double

    /// 天候補正
    let weather: Double

    /// フィールド補正
    let terrain: Double

    /// 壁補正
    let screen: Double

    /// アイテム補正
    let item: Double

    /// その他補正
    let other: Double

    /// 最終的な総合倍率
    var total: Double {
        stab * typeEffectiveness * weather * terrain * screen * item * other
    }
}
