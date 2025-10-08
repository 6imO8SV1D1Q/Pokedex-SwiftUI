//
//  TypeMatchupView.swift
//  Pokedex
//
//  Created on 2025-10-08.
//

import SwiftUI

/// タイプ相性表示ビュー
struct TypeMatchupView: View {
    let matchup: TypeMatchup

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 攻撃面
            VStack(alignment: .leading, spacing: 8) {
                Text("【攻撃面】")
                    .font(.subheadline)
                    .fontWeight(.bold)

                HStack(alignment: .top, spacing: 8) {
                    Text("効果ばつぐん:")
                        .foregroundColor(.secondary)
                        .frame(width: 100, alignment: .leading)
                    TypeListView(types: matchup.offensive.superEffective)
                }
            }

            Divider()

            // 防御面
            VStack(alignment: .leading, spacing: 8) {
                Text("【防御面】")
                    .font(.subheadline)
                    .fontWeight(.bold)

                // 4倍弱点
                if !matchup.defensive.quadrupleWeak.isEmpty {
                    DefensiveMatchupRow(
                        label: "効果ばつぐん(4倍):",
                        types: matchup.defensive.quadrupleWeak,
                        color: .red
                    )
                }

                // 2倍弱点
                if !matchup.defensive.doubleWeak.isEmpty {
                    DefensiveMatchupRow(
                        label: "効果ばつぐん(2倍):",
                        types: matchup.defensive.doubleWeak,
                        color: .orange
                    )
                }

                // 1/2耐性
                if !matchup.defensive.doubleResist.isEmpty {
                    DefensiveMatchupRow(
                        label: "いまひとつ(1/2倍):",
                        types: matchup.defensive.doubleResist,
                        color: .green
                    )
                }

                // 1/4耐性
                if !matchup.defensive.quadrupleResist.isEmpty {
                    DefensiveMatchupRow(
                        label: "いまひとつ(1/4倍):",
                        types: matchup.defensive.quadrupleResist,
                        color: .green
                    )
                }

                // 無効
                if !matchup.defensive.immune.isEmpty {
                    DefensiveMatchupRow(
                        label: "効果なし:",
                        types: matchup.defensive.immune,
                        color: .gray
                    )
                }
            }
        }
        .padding()
    }
}

/// 防御面の倍率行
struct DefensiveMatchupRow: View {
    let label: String
    let types: [String]
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(label)
                .foregroundColor(color)
                .frame(width: 140, alignment: .leading)
            TypeListView(types: types)
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    TypeMatchupView(
        matchup: TypeMatchup(
            offensive: TypeMatchup.OffensiveMatchup(
                superEffective: ["grass", "bug", "ice"]
            ),
            defensive: TypeMatchup.DefensiveMatchup(
                quadrupleWeak: ["rock"],
                doubleWeak: ["water", "electric"],
                doubleResist: ["fighting", "bug", "steel"],
                quadrupleResist: [],
                immune: ["ground"]
            )
        )
    )
}
