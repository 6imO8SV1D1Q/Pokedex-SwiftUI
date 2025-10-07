//
//  TypeMatchup.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// タイプ相性情報を表すEntity
///
/// ポケモンのタイプから、攻撃面と防御面の相性を計算した結果を保持します。
struct TypeMatchup: Equatable {
    /// 攻撃面の相性
    let offensive: OffensiveMatchup

    /// 防御面の相性
    let defensive: DefensiveMatchup

    /// 攻撃面の相性情報
    struct OffensiveMatchup: Equatable {
        /// 効果ばつぐん（2倍）になるタイプ
        let superEffective: [String]
    }

    /// 防御面の相性情報
    struct DefensiveMatchup: Equatable {
        /// 効果ばつぐん（4倍）
        let quadrupleWeak: [String]

        /// 効果ばつぐん（2倍）
        let doubleWeak: [String]

        /// いまひとつ（1/2倍）
        let doubleResist: [String]

        /// いまひとつ（1/4倍）
        let quadrupleResist: [String]

        /// 効果なし（0倍）
        let immune: [String]
    }
}
