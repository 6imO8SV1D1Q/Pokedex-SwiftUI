//
//  CalculatedStats.swift
//  Pokedex
//
//  Created on 2025-10-07.
//

import Foundation

/// 実数値計算結果を表すEntity
///
/// レベル50固定で、5つのパターン（理想、252、無振り、最低、下降）の実数値を保持します。
struct CalculatedStats: Equatable {
    /// 固定レベル
    let level: Int = 50

    /// 5つのパターンの実数値
    let patterns: [StatsPattern]

    /// 実数値のパターン
    struct StatsPattern: Equatable, Identifiable {
        /// パターンID（"ideal", "max", "neutral", "min", "hindered"）
        let id: String

        /// 表示名（"理想", "252", "無振り", "最低", "下降"）
        let displayName: String

        /// HP実数値
        let hp: Int

        /// 攻撃実数値
        let attack: Int

        /// 防御実数値
        let defense: Int

        /// 特攻実数値
        let specialAttack: Int

        /// 特防実数値
        let specialDefense: Int

        /// 素早さ実数値
        let speed: Int

        /// このパターンの設定
        let config: PatternConfig

        /// パターンの設定情報
        struct PatternConfig: Equatable {
            /// 個体値（0 or 31）
            let iv: Int

            /// 努力値（0 or 252）
            let ev: Int

            /// 性格補正
            let nature: NatureModifier

            /// 性格補正の種類
            enum NatureModifier: Equatable {
                /// 上昇補正（1.1倍）
                case boosted

                /// 補正なし（1.0倍）
                case neutral

                /// 下降補正（0.9倍）
                case hindered
            }

            /// 表示用テキスト（"252↑", "31-0" など）
            var displayText: String {
                let evText = ev > 0 ? "\(ev)" : "\(iv)-\(ev)"
                switch nature {
                case .boosted:
                    return "\(evText)↑"
                case .neutral:
                    return evText
                case .hindered:
                    return "\(evText)↓"
                }
            }
        }
    }
}
